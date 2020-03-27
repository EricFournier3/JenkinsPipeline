#!/bin/bash

<<HEADER
Eric Fournier 2019-07-10

Trimmomatic
HEADER


source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

EXEC="/data/Applications/Trimmomatic/Trimmomatic-0.36/trimmomatic-0.36.jar"
ADAPTFILE="/data/Applications/Trimmomatic/Trimmomatic-0.36/adapters/NexteraPE-PE.fa"

if [  "${PARAM_SAMPLESHEET_NAME}" = "no_sample_sheet" ]
  then

	for proj in "${projects_list[@]}"
		do
		PROJECT_NAME=$proj
		SetFinalPath $PROJECT_NAME

		id_list_file_name=$(cat ${SLBIO_PROJECT_PATH}"CurrentIDlistFileName.txt") 

		while read myspec
		  do
		  echo "myspec is ${myspec}"

		  PAIR_R1=$(echo "${SLBIO_FASTQ_BRUT_PATH}${myspec}_"*"R1.fastq.gz")
		  PAIR_R2=$(echo "${SLBIO_FASTQ_BRUT_PATH}${myspec}_"*"R2.fastq.gz")
	  
		  PAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${myspec}"_R1_PAIR.fastq.gz"
		  PAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${myspec}"_R2_PAIR.fastq.gz"
		  
		  UNPAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${myspec}"_R1_UNPAIR.fastq.gz"
		  UNPAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${myspec}"_R2_UNPAIR.fastq.gz"
		  echo -e "Trimmomatic pour ${myspec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE

		  LOGFILE="${SLBIO_FASTQ_TRIMMO_PATH}"${myspec}".log"
		  
		  TRIMMO_CMD="java -jar $EXEC PE -threads 8   -phred33 $PAIR_R1 $PAIR_R2 $PAIR_R1_TRIMMO $UNPAIR_R1_TRIMMO $PAIR_R2_TRIMMO $UNPAIR_R2_TRIMMO LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50 ILLUMINACLIP:$ADAPTFILE:2:30:10 2>$LOGFILE"

		  eval ${TRIMMO_CMD}

		done < ${id_list_file_name}
	done
else
  :
fi

exit 0




