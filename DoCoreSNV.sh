#!/bin/bash
<<HEADER
Eric FOurnier 2019-07-15

HEADER

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

STEP="CoreSNV"

for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
	spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))
	
	if [ ${#spec_arr[@]} -gt 0 ]
		then
		organism=$(sed -n '/epidemio/p' ${SLBIO_PROJECT_PATH}${RUN_NAME}.csv.temp3 | awk 'BEGIN{FS=","}NR==1{print $11}')
		get_ref_cmd="/usr/bin/python2.7 $CORESNV_REFERENCE_SCRIPT $SLBIO_RUN_PATH  $SLBIO_PROJECT_PATH $PARAM_FILE \"${organism}\" get 2>&1"
		ref_acc_refpath=($(eval $get_ref_cmd))
		acc=${ref_acc_refpath[0]}
		refpath=${ref_acc_refpath[1]}
		
		if grep -l "$acc" ${refpath}{*.fna,*.fa,*.fasta}
			then
			ref_file=$(grep -l "$acc" ${refpath}{*.fna,*.fa,*.fasta} | head -n 1)
		else 
		   ncbi-acc-download -m nucleotide -F fasta  -o  ${refpath}${acc}".fna"  $acc 
		   ref_file=${refpath}${acc}".fna"
		fi

		temp_fastq_dir=${SLBIO_FASTQ_TRIMMO_PATH}"TEMP/"

		mkdir  $temp_fastq_dir

		for spec in "${spec_arr[@]}"
			do 
			echo "spec is $spec"
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

		rm -r $temp_fastq_dir
	else
	        :
	fi
done
