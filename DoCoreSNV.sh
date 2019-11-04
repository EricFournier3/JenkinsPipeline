#!/bin/bash
<<HEADER
Eric FOurnier 2019-07-15

HEADER

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

STEP="CoreSNV"

MakeGrapeTreeProfile(){
	profile_file="${SLBIO_CORESNV_PATH}prefix-profile.tsv"
	strain_file="${SLBIO_CORESNV_PATH}prefix-strains.tsv"
	grapetree_profile_file="${SLBIO_CORESNV_PATH}grapetree-profile.tsv"

	awk '/^ST/{print "#Name\t"$0}' $profile_file > $grapetree_profile_file

	{
	read
	while read ST STRAIN
		do
		awk -v mystrain="${STRAIN}" -v myst="^${ST}$" '$1 ~ myst {print mystrain"\t"$0}' $profile_file >> $grapetree_profile_file
	done
	
	} < $strain_file

}

MakeGrapeTreeMetadata(){
	strain_file="${SLBIO_CORESNV_PATH}prefix-strains.tsv"
	metadata_file="${SLBIO_CORESNV_PATH}metadata.tsv"
	grapetree_metadata_file="${SLBIO_CORESNV_PATH}grapetree-metadata.tsv"

	awk '/^ID/{print $0"\tST"}' $metadata_file > $grapetree_metadata_file

	{
	read
	while read ST STRAIN
		do
		awk -v mystrain="${STRAIN}$" -v myst="${ST}" '$1 ~ mystrain {print $0"\t"myst}' $metadata_file >> $grapetree_metadata_file
	done
	
	} < $strain_file
	
	#pour entrer ^M il faut faire <ctrl>+V+M
	sed -i 's///g' $grapetree_metadata_file
}


ConcatContig(){

	grep -v ">" $ref_file  >  ${refpath}${acc}"_temp.fna" 
	header=$(head -n 1 $ref_file)
	sed -i "1i $header" ${refpath}${acc}"_temp.fna" 
	# on linearise la reference
	seqkit seq -w 0 ${refpath}${acc}"_temp.fna" > ${refpath}${acc}"_temp2.fna"
	rm ${refpath}${acc}"_temp.fna"
	ref_file=${refpath}${acc}"_temp2.fna"
}


for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
	spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))
        
	to_concat_spec_arr=()

        if [ -s $LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH ]
		then
		while read myspec runs
			do
			to_concat_spec_arr+=($myspec)
		done < $LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH	
	fi

	for myspec in "${to_concat_spec_arr[@]}"
		do
		if [[ " ${spec_arr[@]} " =~ " $myspec " ]]
			then
			:
		else
			spec_arr+=($myspec)
		fi
	done
	
	if [ ${#spec_arr[@]} -gt 0 ]
		then
		organism=$(sed -n '/epidemio/p' ${SLBIO_PROJECT_PATH}${RUN_NAME}.csv.temp3 | awk 'BEGIN{FS=","}NR==1{print $11}')
		get_ref_cmd="/usr/bin/python2.7 $CORESNV_REFERENCE_SCRIPT $SLBIO_RUN_PATH  $SLBIO_PROJECT_PATH $PARAM_FILE \"${organism}\" get 2>&1"
		ref_acc_refpath=($(eval $get_ref_cmd))
		acc=${ref_acc_refpath[0]}
		refpath=${ref_acc_refpath[1]}
		
		if grep -l "$acc" ${refpath}*".fna" 2>/dev/null  || grep -l "$acc" ${refpath}*".fa" 2>/dev/null || grep -l "$acc" ${refpath}*".fasta" 2>/dev/null
			then
			ref_file=$(grep -l "$acc" ${refpath}{*.fna,*.fa,*.fasta} 2>/dev/null  | head -n 1)
		else 
		   ncbi-acc-download -m nucleotide -F fasta  -o  ${refpath}${acc}".fna"  $acc 
		   ref_file=${refpath}${acc}".fna"
		fi

                nb_contig=$(sed -n '/>/p' ${ref_file} | wc -l)
                if [ $nb_contig > 1 ]
			then
			ConcatContig
		fi

 
		temp_fastq_dir=${SLBIO_FASTQ_TRIMMO_PATH}"TEMP/"

		mkdir  $temp_fastq_dir

		for spec in "${spec_arr[@]}"
			do 
			for primer in R1 R2
				do
				
				cp ${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_${primer}_PAIR.fastq.gz" ${temp_fastq_dir}${spec}"_${primer}.fastq.gz"
			done	
		done

                echo -e "CoreSNV pour le project $PROJECT_NAME \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE

		if [ "$(systemctl show --property ActiveState docker)" = "ActiveState=active" ]
			then 
			:
		else
			sudo service docker start	
		fi
              
		coresnv_cmd="sudo /usr/bin/python2.7 $CORESNV_EXEC --deploy-docker --fastq-dir $temp_fastq_dir --reference-file $ref_file --min-coverage 20 --output-dir $SLBIO_CORESNV_PATH --min-mean-mapping 30 --relative-snv-abundance 0.75  --filter-density-window 20  --filter-density-threshold 2"

		position2phyloviz_cmd="sudo perl $POSITION2PHYLOVIZ_SCRIPT -i ${SLBIO_CORESNV_PATH}snvTable.tsv --reference-name $acc -b ${SLBIO_CORESNV_PATH}prefix"
	
		eval $coresnv_cmd
			
		eval $position2phyloviz_cmd

		#ERIC FOURNIER 2019-11-01
		sudo chmod 777 ${SLBIO_CORESNV_PATH}

		MakeGrapeTreeProfile

		if [ -s $LSPQ_MISEQ_CORESNV_METADATA_FILE_PATH ]
			then
			sudo cp $LSPQ_MISEQ_CORESNV_METADATA_FILE_PATH "${SLBIO_CORESNV_PATH}metadata.tsv"
			MakeGrapeTreeMetadata
		fi

		grapetree_cmd="/usr/bin/python2.7 $GRAPETREE_SCRIPT -p $grapetree_profile_file -m MSTreeV2 > ${SLBIO_CORESNV_PATH}grapetree-tree.nwk"
		eval $grapetree_cmd

		rm -r $temp_fastq_dir
		
		if [ -e  ${refpath}${acc}"_temp.fna" ]
			then
			rm ${refpath}${acc}"_temp.fna"
		fi
	else
	        :
	fi
done
