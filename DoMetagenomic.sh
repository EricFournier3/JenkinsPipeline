#!/bin/bash

<<HEADER
Eric Fournier 2019-12-31

Metagenomic => Kraken, Centrifuge, Clark

HEADER

source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

STEP="Metagenomic"



DoKraken(){
	echo "In Kraken"
	current_kraken_spec=$1
	echo -e "Kraken on ${current_kraken_spec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
	all_fastq=${SLBIO_FASTQ_TRIMMO_PATH}${current_kraken_spec}*"fastq.gz"
	kraken_cmd="kraken2 --db ${KRAKENDB} --output  ${SLBIO_KRAKEN_PATH}Out_${current_kraken_spec} --report ${SLBIO_KRAKEN_PATH}Report_${current_kraken_spec} --thread 30 <(zcat ${all_fastq})"
	#eval ${kraken_cmd}
}

DoCentrifuge(){
	
	echo "In centrifuge"
	current_centrifuge_spec=$1
	echo -e "Centrifuge on ${current_centrifuge_spec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
	PAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R1_PAIR.fastq.gz"
        UNPAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R1_UNPAIR.fastq.gz"
        PAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R2_PAIR.fastq.gz"
        UNPAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R2_UNPAIR.fastq.gz"	
	
	centrifuge_cmd="centrifuge -x ${CENTRIFUGEDB} -1 ${PAIR_R1_TRIMMO} -2 ${PAIR_R2_TRIMMO} -U ${UNPAIR_R1_TRIMMO},${UNPAIR_R2_TRIMMO} -S ${SLBIO_CENTRIFUGE_PATH}${current_centrifuge_spec}_ClassificationResult.txt  --report-file ${SLBIO_CENTRIFUGE_PATH}${current_centrifuge_spec}_ClassificationSummary.txt --thread 30"

	centrifuge_kreport_cmd="centrifuge-kreport -x ${CENTRIFUGEDB} ${SLBIO_CENTRIFUGE_PATH}${current_centrifuge_spec}_ClassificationResult.txt > ${SLBIO_CENTRIFUGE_PATH}${current_centrifuge_spec}_ClassificationResult_Kraken.txt"

	eval $centrifuge_cmd
	eval $centrifuge_kreport_cmd
}

DoClark(){
	echo "In Clark"
}



for proj in "${projects_list[@]}"
        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
        SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))

        if [ ${#spec_arr[@]} -gt 0 ]
        then
                mkdir -p  $SLBIO_KRAKEN_PATH
                mkdir -p  $SLBIO_CENTRIFUGE_PATH 
                mkdir -p  $SLBIO_CLARK_PATH
          	
		for spec in "${spec_arr[@]}"
			do
			DoKraken $spec
			DoCentrifuge $spec			
		done	
		 
	fi
done

