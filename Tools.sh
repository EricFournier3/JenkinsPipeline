#!/bin/bash

source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

RemoveNumericPrefixFromSubDir(){

     for proj in "${projects_list[@]}"
	do
          PROJECT_NAME=$proj
     
	  SetFinalPath $PROJECT_NAME

          #pour slbio00d
	  for mydir in $(ls -d "${SLBIO_PROJECT_PATH}"*"/")
            do
            current_dirname=$(basename ${mydir})
            dir_prefix=$(echo ${current_dirname} | cut -d '_' -f1)

            regex="^[0-9]+$"
            if  [[ ${dir_prefix} =~ $regex ]]
              then 
                   
              new_dirname=$(echo ${current_dirname} | cut -d '_' -f2-)
              
              new_dirpath=${SLBIO_PROJECT_PATH}${new_dirname}

	      mv $mydir ${new_dirpath}

            fi

          done

	  #pour LSPQ_MiSeq
          for mydir in $(ls -d "${LSPQ_MISEQ_ANALYSIS_PROJECT_PATH}"*"/")
            do
              current_dirname=$(basename ${mydir})
              dir_prefix=$(echo ${current_dirname} | cut -d '_' -f1)

              regex="^[0-9]+$"
              if  [[ ${dir_prefix} =~ $regex ]]
                then

                new_dirname=$(echo ${current_dirname} | cut -d '_' -f2-)

                new_dirpath=${LSPQ_MISEQ_ANALYSIS_PROJECT_PATH}${new_dirname}
                sudo  mv $mydir ${new_dirpath}

              fi
	  done
     done
}


AddNumericPrefixToSubdir(){
 	slbio_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  slbio_subdir  2>&1))
		
	for proj in "${projects_list[@]}"
                do
		prefix=1
                PROJECT_NAME=$proj
                SetFinalPath $PROJECT_NAME
		
		for subdir in "${slbio_subdir_arr[@]}"
			do
			
			if [ "$STAGE" = "WEB_REPORT" ]
				then
				subdir_path=${LSPQ_MISEQ_ANALYSIS_PROJECT_PATH}${subdir}
				if [ -d ${subdir_path} ]
					then
					new_subdir_name="${prefix}_${subdir}"
					new_subdir_path="${LSPQ_MISEQ_ANALYSIS_PROJECT_PATH}${new_subdir_name}"
					if [ "$subdir" != "WEB_REPORT" ]
						then
						sudo mv $subdir_path  $new_subdir_path
						prefix=$(echo $((++prefix)))
						sudo sed -i "s/\\\\${subdir}\\\\/\\\\${new_subdir_name}\\\\/g" ${LSPQ_MISEQ_ANALYSIS_PROJECT_PATH}"WEB_REPORT/BuildResultats.js"
					fi
				fi
			else
				subdir_path=${SLBIO_PROJECT_PATH}${subdir}
				if [ -d ${subdir_path} ]
                                        then
                                        new_subdir_name="${prefix}_${subdir}"
                                        new_subdir_path="${SLBIO_PROJECT_PATH}${new_subdir_name}"
                                        mv $subdir_path  $new_subdir_path
                                        prefix=$(echo $((++prefix)))
                                fi
			fi

		done
	done
}


CoreSnvReference(){
	for proj in "${projects_list[@]}"
                do
                PROJECT_NAME=$proj
                SetFinalPath $PROJECT_NAME
		samp_sheet=$(cat ${SLBIO_PROJECT_PATH}"CurrentSampleSheetName.txt")
		organism=$(sed -n '/epidemio/p' $samp_sheet  | awk 'BEGIN{FS=","}NR==1{print $11}')
		
                if [ ${#organism} -gt 0 ]
			then          
			check_ref_cmd="/usr/bin/python2.7 $CORESNV_REFERENCE_SCRIPT $SLBIO_RUN_PATH  $SLBIO_PROJECT_PATH $PARAM_FILE \"${organism}\" check"
			eval $check_ref_cmd
			errno=$?
			if [ $errno -eq 0 ]
			    then
			    :
			else
			    echo -e "${red_message}ERROR: ""Reference manquante dans JenkinsParameter.yaml"
			    echo -e "${white_message}"
			    sudo rm -rf $SLBIO_RUN_PATH
			    exit 1
			fi
		fi
	done
}


ComputeExpectedGenomesCoverage(){
       
	temp_file_base=$(echo $(dirname $GENOME_LENGTH_FILE))/
	temp_file=${temp_file_base}"temp.txt"
        awk 'BEGIN{FS=","}NR>1{print $1"\t"$8}' $GENOME_LENGTH_FILE > $temp_file

        is_new_pipeline="false"
	
	OUT_FILE=${SLBIO_RUN_PATH}"ExpectedGenomeCoverage.txt"

        if [ ! -f ${OUT_FILE} ]
	  then
            echo -e "Sample\tOrganism\tGenomeLength\tCoverage\n" > $OUT_FILE
	else
	    :
        fi

	for proj in "${projects_list[@]}"
                do
                PROJECT_NAME=$proj
                SetFinalPath $PROJECT_NAME

		samp_sheet=$(cat ${SLBIO_PROJECT_PATH}"CurrentSampleSheetName.txt")

		if [[ ${samp_sheet} == *"New"* ]] #Pas besoin de recalculer pour new pipeline
		  then
		  return
		else
		  compute_cov_cmd="/usr/bin/python2.7 $COMPUTE_SAMPLE_COVERAGE_SCRIPT  $SLBIO_RUN_PATH  $SLBIO_PROJECT_PATH  $temp_file  $LSPQ_MISEQ_RUN_PATH $OUT_FILE $SLBIO_FASTQ_BRUT ${samp_sheet}"

                  eval $compute_cov_cmd
                fi 
	done

	sudo cp $OUT_FILE ${LSPQ_MISEQ_RUN_PATH}${LSPQ_ANALYSES}
	#sudo rm $OUT_FILE on ne supprime pas, on le garde pour les autres cassettes
	rm $temp_file
}


Clean(){
        for proj in "${projects_list[@]}"
                do
                PROJECT_NAME=$proj
                SetFinalPath $PROJECT_NAME
        done

	if [ -d ${LSPQ_MISEQ_FASTQ_PATH}"CORE_SNV_TEMP/" ]
		then
		sudo rm ${LSPQ_MISEQ_FASTQ_PATH}"CORE_SNV_TEMP/"*".fastq.gz"
	fi
}

ComputeMiSeqStat(){
	for fullpath in $(ls -1 -d "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}""/""${LSPQ_MISEQ_MISEQ_RUN_TRACE}"*)
		do
		subdir=$(echo $(basename ${fullpath}))
		LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/"${LSPQ_MISEQ_MISEQ_RUN_TRACE}""${subdir}/"MiSeqStat_"*
		if [ -e $LSPQ_MISEQ_RUNQUALFILE_PATH ]
			then
                        echo "MiSeq Stat already computed for cartridge ${subdir}"
			
		else
			MakeCartridgeFastqLink $subdir
			echo -e "${green_message}INFO: ""Running MiSeqStat7.py ..."	
			echo -e "${white_message}"

			MiSeq_Stat_Command="/usr/bin/python2.7 $RUN_QUAL_SCRIPT --runno $RUN_NAME  --param $PARAM_FILE --subdir $subdir"
			eval $MiSeq_Stat_Command  > /dev/null 2>&1
		fi
	done

}


MakeCartridgeFastqLink(){

	mkdir ${SLBIO_BASE_PATH}$RUN_NAME"/"${1}

	for sample in $(awk 'BEGIN{FS=","}/Sample_ID/,EOF {print $1}' "${SLBIO_BASE_PATH}"$RUN_NAME/""*"_"${1}".csv" | sed -n '/Sample_Name/!p')
		do
		ln -s ${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/"${LSPQ_MISEQ_SEQ_BRUT}${sample}"_"*".fastq.gz" ${SLBIO_BASE_PATH}$RUN_NAME"/"${1}
	done	

}



CountReads(){
	for proj in "${projects_list[@]}"
		do
		PROJECT_NAME=$proj
        	SetFinalPath $PROJECT_NAME
		read_count_file_name="ReadCount.txt"
		read_count_file_before=${SLBIO_FASTQ_BRUT_PATH}"$read_count_file_name"
		read_count_file_after=${SLBIO_FASTQ_TRIMMO_PATH}"$read_count_file_name"


		if [ ! -f ${read_count_file_before} ]
                  then
                      echo -e "Fichier_FASTQ\tRead_Count\n" > $read_count_file_before
		fi


		for i in $(ls -1 ${SLBIO_FASTQ_BRUT_PATH}*".fastq.gz")
			do
			fastq_name=$(echo $(basename $i))

                        if grep -l "${fastq_name}" $read_count_file_before   > /dev/null 2>&1

			  then
                          :
                        else
			    echo -e "Count reads for $fastq_name \t$(date "+%Y-%m-%d @ %H:%M")" >>$SLBIO_LOG_FILE
			    count=$(zcat $i | expr $(wc -l) / 4)
			    echo -e "$fastq_name\t$count" >> $read_count_file_before
		        fi
		done

		if [ ! -f ${read_count_file_after} ]
                  then
	             echo -e "Fichier_FASTQ\tRead_Count\n" > $read_count_file_after
		fi

		for i in $(ls -1 ${SLBIO_FASTQ_TRIMMO_PATH}*".fastq.gz")
			do
			fastq_name=$(echo $(basename $i))

			if grep -l "${fastq_name}"  $read_count_file_after > /dev/null 2>&1
			  then
			  :
                        else
			  echo -e "Count reads for $fastq_name \t$(date "+%Y-%m-%d @ %H:%M")" >>$SLBIO_LOG_FILE
			  count=$(zcat $i | expr $(wc -l) / 4)
			  echo -e "$fastq_name\t$count" >> $read_count_file_after
                        fi
		done
	done

}


$1



