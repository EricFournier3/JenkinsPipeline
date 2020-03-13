#!/bin/bash

<<HEADER
Eric Fournier 2019-07-09

HEADER


source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName


BuildSlbioStruct(){
	echo $SLBIO_RUN_PATH	
	if [ -d $SLBIO_RUN_PATH ]
		then :
                echo "${SLBIO_RUN_PATH} existe déjà !"
        else
		mkdir $SLBIO_RUN_PATH
	fi

        if [ -d $SLBIO_FASTQ_BRUT_PATH ]
          then
          :
        else
          mkdir -p $SLBIO_FASTQ_BRUT_PATH $SLBIO_FASTQ_TRIMMO_PATH  $SLBIO_FASTQC_BRUT_PATH   $SLBIO_FASTQC_TRIMMO_PATH   $SLBIO_LOG_PATH  $SLBIO_WEBREPORT_PATH
          echo -e "Création des sous répertoires FASTQ_BRUT QC_FASTQC_BRUT_FASTQC FASTQ_CLEAN_TRIMMOMATIC  QC_FASTQ_CLEAN_FASTQC\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
        fi

        if [ ${PARAM_SAMPLESHEET_NAME} = "no_sample_sheet" ]
          then
          GetAllCartridge
          GetCurrentCartridge
          BuildSampleSheetName
        else
          GetCurrentCartridge "newpipeline"
          BuildSampleSheetName "newpipeline" ${PARAM_SAMPLESHEET_NAME}
        fi

        echo "============ current_cartridge_list ${current_cartridge_list[@]}"
        echo "============ all_cartridge_list ${all_cartridge_list[@]}"

}


CreateSymLinkForCoreSNV(){
	SLBIO_CORE_SNV_SAMPLE_LIST_FILE_NAME="CoreSnvSampleList.txt"
        SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH=${SLBIO_PROJECT_PATH}${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_NAME}
	SLBIO_SAMPLE_LIST_FILE_PATH=${SLBIO_PROJECT_PATH}"ID_list.txt"
        LSPQ_MISEQ_CORE_SNV_TEMP_PATH=${LSPQ_MISEQ_FASTQ_PATH}"CORE_SNV_TEMP/"

	sudo mkdir $LSPQ_MISEQ_CORE_SNV_TEMP_PATH

	while read spec runs
		do
		runs=(${runs/|/ })

		for run in ${runs[@]}
			do
			:
			printf "%s\t%s\n" ${spec} ${run} >> ${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH}.temp
		done
	done < ${LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH}


	while read spec 
		do
		:
		printf "%s\t%s\n" $spec $RUN_NAME >> ${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH}.temp
	done <  $SLBIO_SAMPLE_LIST_FILE_PATH

	sed -i 's///g' ${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH}.temp
	sort -k 1 ${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH}.temp > ${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH}
	rm ${SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH}.temp

	while read spec run
		do
                #Modif_20200130
		fastq_path=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${run}"/3_SequencesBrutes/"
		fastq_arr=($(find ${fastq_path} -maxdepth 1 -name "$spec"* | xargs -I % sh -c 'basename %'))

		for fastq in "${fastq_arr[@]}"
			do
			fastq_prefix=$(echo $fastq | cut -d '_' -f 1)
			if [[ "$fastq" =~ "_R1_" ]]
				then
				already_transfered=$(find  ${LSPQ_MISEQ_CORE_SNV_TEMP_PATH} -name "${fastq_prefix}"*"_R1_"*".fastq.gz")
				if [ ${#already_transfered} -gt 0 ]
					then
					sudo bash -c "cat ${fastq_path}${fastq} >> $already_transfered"
				else
					sudo cp ${fastq_path}${fastq} ${LSPQ_MISEQ_CORE_SNV_TEMP_PATH}
				fi

			elif [[ "$fastq" =~ "_R2_" ]]
				then
				already_transfered=$(find  ${LSPQ_MISEQ_CORE_SNV_TEMP_PATH} -name "${fastq_prefix}"*"_R2_"*".fastq.gz")
				if [ ${#already_transfered} -gt 0 ]
					then
					sudo bash -c "cat ${fastq_path}${fastq} >> $already_transfered"
				else
					sudo cp ${fastq_path}${fastq} ${LSPQ_MISEQ_CORE_SNV_TEMP_PATH}
				fi
			fi
		done

	done  < $SLBIO_CORE_SNV_SAMPLE_LIST_FILE_PATH

	for fastq in $(ls ${LSPQ_MISEQ_CORE_SNV_TEMP_PATH}*".fastq.gz")
		do
		ln -s $fastq ${SLBIO_FASTQ_BRUT_PATH}
	done
}


CreateSymLink(){
  echo "IN NEW CREATESYMLINK"


  if [ ${PARAM_SAMPLESHEET_NAME} = "no_sample_sheet" ]
    then
    :
    #ICI LE CODE DE CreateSymLinkOBSOLETE
  
  else
    :
    #sudo cp "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${PARAM_SAMPLESHEET_NAME}" $SLBIO_PROJECT_PATH

    #awk '{sub("\r$", "");print}' "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}" >  "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}.temp"
    #sed -n '/Sample_ID/,$p' "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}.temp" > "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}.temp2"

    #awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project || $1 == "Sample_Name"){print $0}}' "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}.temp2" > "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}.temp3"
   
    #sudo rm  "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}"
    #cat "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}.temp3" > "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}"
    #echo "mmmmmmmmmmmmmmmmmmmmmmmmmm ${final_sample_sheet_name}" 
   
    awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project){print $1}}' "${SLBIO_PROJECT_PATH}${PARAM_SAMPLESHEET_NAME}" > ${SLBIO_PROJECT_PATH}${id_list_file_name} 
    
  fi


}



CreateSymLinkOBSOLETE(){
  for cartridge in ${current_cartridge_list[@]} 
    do
    echo -e "Création des liens symboliques fastq.gz de S:Partage/LSPQ_MiSeq de la cartouche ${cartridge} vers FASTQ_BRUT\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE

    sudo cp "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${RUN_NAME}_${cartridge}.csv"  $SLBIO_PROJECT_PATH
    sample_sheet_name=$(basename "${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}${RUN_NAME}_${cartridge}.csv")

    awk '{sub("\r$", "");print}' ${SLBIO_PROJECT_PATH}${sample_sheet_name} > ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp"
   
    #Supprimer le header
    sed -n '/Sample_ID/,$p' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp" >  ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2"

    #Extraire les sample id du projet cible
    #awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project){print $1}}' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2" >> ${SLBIO_PROJECT_PATH}"ID_list.txt"
    awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project || $1 == "Sample_Name"){print $0}}' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2" > ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp3"
 
    cat ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp3" >> ${SLBIO_PROJECT_PATH}${final_sample_sheet_name}".temp"

  done

  sed  '2,${/Sample_Name/d}' ${SLBIO_PROJECT_PATH}${final_sample_sheet_name}".temp" > ${SLBIO_PROJECT_PATH}${final_sample_sheet_name}
  echo "HERE 2 "${id_list_file_name}
  awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project){print $1}}' ${SLBIO_PROJECT_PATH}${final_sample_sheet_name}  > ${SLBIO_PROJECT_PATH}${id_list_file_name}


  CountNumberOfCoreSnvSpec
   
  if [ $NUMBER_OF_CORE_SNV_SPEC -gt 0 ] && [ -s $LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH ]
                then
                CreateSymLinkForCoreSNV
  else
                myarr=();
                for i in $(cat ${SLBIO_PROJECT_PATH}${id_list_file_name})
                        do
                        myarr+=($i)
                done

                for j in ${myarr[@]}
                        do
                        ln -s ${LSPQ_MISEQ_FASTQ_PATH}${j}"_"*".fastq.gz" $SLBIO_FASTQ_BRUT_PATH
                done
  fi

}


CreateSymLinkOBSOLETE_20200309(){

        echo -e "Création des liens symboliques fastq.gz de S:Partage/LSPQ_MiSeq vers FASTQ_BRUT\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE

	sudo cp ${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}"${RUN_NAME}"*"_"*".csv" $SLBIO_RUN_PATH
	sudo dos2unix "${SLBIO_RUN_PATH}"*".csv"

        sudo cp $LSPQ_MISEQ_SAMPLESHEET_PATH $SLBIO_PROJECT_PATH
        sample_sheet_name=$(basename $LSPQ_MISEQ_SAMPLESHEET_PATH)
        #convertir de DOS vers Linux format
        awk '{sub("\r$", "");print}' ${SLBIO_PROJECT_PATH}${sample_sheet_name} > ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp"

        #Supprimer le header
        sed -n '/Sample_ID/,$p' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp" >  ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2"
        #Extraire les sample id du projet cible
        awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project){print $1}}' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2" > ${SLBIO_PROJECT_PATH}"ID_list.txt"
        awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project || $1 == "Sample_Name"){print $0}}' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2" > ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp3"

        CountNumberOfCoreSnvSpec
	if [ $NUMBER_OF_CORE_SNV_SPEC -gt 0 ] && [ -s $LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH ]
		then
		CreateSymLinkForCoreSNV
	else
		myarr=();
		for i in $(cat ${SLBIO_PROJECT_PATH}"ID_list.txt")
			do
			myarr+=($i)
		done

		for j in ${myarr[@]}
			do
			ln -s ${LSPQ_MISEQ_FASTQ_PATH}${j}"_"*".fastq.gz" $SLBIO_FASTQ_BRUT_PATH
		done
	fi
}

RenameFastq(){

  while read myspec
   do
   #spec3_R2.fastq.gz   spec3_S3_L001_R2_001.fastq.gz

   PAIR_R1=$(echo "${SLBIO_FASTQ_BRUT_PATH}${myspec}_"*"R1_001.fastq.gz")
   PAIR_R2=$(echo "${SLBIO_FASTQ_BRUT_PATH}${myspec}_"*"R2_001.fastq.gz")

   echo "PAIR_R1 "${PAIR_R1}
   echo "PAIR_R2 "${PAIR_R2}

   fastq_base_r1=$(basename $PAIR_R1)
   fastq_base_r2=$(basename $PAIR_R2)

   new_fastq_base_r1=$(echo $fastq_base_r1 | cut -d '_' -f1,4)".fastq.gz"
   new_fastq_base_r2=$(echo $fastq_base_r2 | cut -d '_' -f1,4)".fastq.gz"
  
   NEW_PAIR_R1=${SLBIO_FASTQ_BRUT_PATH}${new_fastq_base_r1}
   NEW_PAIR_R2=${SLBIO_FASTQ_BRUT_PATH}${new_fastq_base_r2}

  echo "NEW_PAIR_R1 "${NEW_PAIR_R1}
  echo "NEW_PAIR_R2 "${NEW_PAIR_R2}

  mv ${PAIR_R1} ${NEW_PAIR_R1}
  mv ${PAIR_R2} ${NEW_PAIR_R2}

  done < ${SLBIO_PROJECT_PATH}${id_list_file_name}

}


RenameFastqOBSOLETE(){
             for fastq in $(ls "${SLBIO_FASTQ_BRUT_PATH}"*".fastq.gz")
                do
                fastq_ori=$fastq
                fastq_path=$(dirname $fastq_ori)
                fastq_base=$(basename $fastq_ori)
                new_fastq_base=$(echo $fastq_base | cut -d '_' -f1,4)".fastq.gz"
                fastq_new=${fastq_path}/${new_fastq_base}
                mv $fastq_ori $fastq_new
             done
}

NUMBER_OF_CORE_SNV_SPEC=0


CountNumberOfCoreSnvSpec(){
  SAMPLE_SHEET=${SLBIO_PROJECT_PATH}${final_sample_sheet_name}
  STEP="CoreSNV"
  
  spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))
  NUMBER_OF_CORE_SNV_SPEC=${#spec_arr[@]}


}

CountNumberOfCoreSnvSpecOBSOLETE_20200309(){
        SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
	STEP="CoreSNV"
	spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))
	NUMBER_OF_CORE_SNV_SPEC=${#spec_arr[@]}
}


for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
	SetFinalPath $PROJECT_NAME
        #Modif_20200309
        #GetDoneCartridge
        #GetCurrentCartridge
        #TODO AREACTER LES  SUIVANTS
	BuildSlbioStruct	
        #BuildSampleSheetName
        CreateSymLink
	echo "NUMBER OF CORE SNV SPEC "$NUMBER_OF_CORE_SNV_SPEC
        #
        #TODO IL NE FAUT PAS REFEAIRE LES CASSETTE DEJA FAITE 
        #TODO AREACTIVER
	#RenameFastq
done



