#!/bin/bash

<<HEADER
Eric Fournier 2019-07-10

Fastqc
HEADER

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	#echo "PROJ NAME IS ${PROJECT_NAME}"
        #echo "In DoFastqc $SLBIO_SPADES_FILTER_PATH"
	echo -e "Fastqc avant trimmomatic \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
	fastqc -q   -o $SLBIO_FASTQC_BRUT_PATH "${SLBIO_FASTQ_BRUT_PATH}"*".fastq.gz"
	rm "$SLBIO_FASTQC_BRUT_PATH"*".zip"

	echo -e "Fastqc après trimmomatic \t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
	fastqc -q   -o $SLBIO_FASTQC_TRIMMO_PATH "${SLBIO_FASTQ_TRIMMO_PATH}"*".fastq.gz"
        rm "$SLBIO_FASTQC_TRIMMO_PATH"*".zip"
done


