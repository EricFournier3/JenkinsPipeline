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

for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
	SetFinalPath $PROJECT_NAME
#	echo "In DoTrimmomatic $SLBIO_SPADES_FILTER_PATH"
	for fastq in $(ls ${SLBIO_FASTQ_BRUT_PATH}*R1.fastq.gz)
		do
			SAMPLE_NAME=$(echo $(basename $fastq))
			SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
			echo -e "Trimmomatic pour ${SAMPLE_NAME}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
			
			PAIR_R1=$fastq	
			PAIR_R2=${PAIR_R1/_R1.fastq.gz/_R2.fastq.gz}
			PAIR_R1_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R1_PAIR.fastq.gz}
			PAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}$(echo $(basename $PAIR_R1_TRIMMO))

			PAIR_R2_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R2_PAIR.fastq.gz}
			PAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}$(echo $(basename $PAIR_R2_TRIMMO))

			UNPAIR_R1_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R1_UNPAIR.fastq.gz}
			UNPAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}$(echo $(basename $UNPAIR_R1_TRIMMO))

			UNPAIR_R2_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R2_UNPAIR.fastq.gz}
			UNPAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}$(echo $(basename $UNPAIR_R2_TRIMMO))

			LOGFILE="${SLBIO_FASTQ_TRIMMO_PATH}"${SAMPLE_NAME}".log"


			TRIMMO_CMD="java -jar $EXEC PE -threads 8   -phred33 $PAIR_R1 $PAIR_R2 $PAIR_R1_TRIMMO $UNPAIR_R1_TRIMMO $PAIR_R2_TRIMMO $UNPAIR_R2_TRIMMO LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50 ILLUMINACLIP:$ADAPTFILE:2:30:10 2>$LOGFILE"
			
			eval $TRIMMO_CMD
	done
done





