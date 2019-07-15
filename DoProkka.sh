#!/bin/bash

<<HEADER
Eric Fournier 2019-07-10

Prokka

HEADER

PROKKA_EXEC="prokka --addgenes --compliant --force --cpus 28 --quiet"

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

STEP="Prokka"

for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))

	#echo "In DoProkka $SLBIO_SPADES_FILTER_PATH"

	if [ ${#spec_arr[@]} -gt 0 ]
		then
		mkdir ${SLBIO_PROKKA_PATH}
		
		for spec in "${spec_arr[@]}"
			do
			FASTA_FILTERED=${SLBIO_SPADES_FILTER_PATH}${spec}"_filter.fasta"
			OUTDIR=${SLBIO_PROKKA_PATH}${spec}
			echo -e "Annotation Prokka pour ${spec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
			PROKKA_CMD="${PROKKA_EXEC} --outdir $OUTDIR --prefix $spec --locustag $spec $FASTA_FILTERED"
			eval $PROKKA_CMD
		done
	fi

done



