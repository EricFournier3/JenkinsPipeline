#!/bin/bash

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

ComputeExpectedGenomesCoverage(){
	echo "Genome file is $GENOME_LENGTH_FILE"
	temp_file_base=$(echo $(dirname $GENOME_LENGTH_FILE))/
	temp_file=${temp_file_base}"temp.txt"
	echo "temp is $temp_file"
        awk 'BEGIN{FS=","}NR>1{print $1"\t"$8}' $GENOME_LENGTH_FILE > $temp_file


	for proj in "${projects_list[@]}"
                do
                PROJECT_NAME=$proj
                SetFinalPath $PROJECT_NAME
		OUT_FILE=${SLBIO_RUN_PATH}"ExpectedGenomeCoverage.txt"
		compute_cov_cmd="/usr/bin/python2.7 $COMPUTE_SAMPLE_COVERAGE_SCRIPT  $SLBIO_RUN_PATH  $SLBIO_PROJECT_PATH  $temp_file  $LSPQ_MISEQ_RUN_PATH $OUT_FILE ${LSPQ_ANALYSES} $SLBIO_FASTQ_BRUT"

		echo $compute_cov_cmd
                eval $compute_cov_cmd 
	done

	sed -i '1i Sample\tOrganism\tGenomeLength\tCoverage' $OUT_FILE 
	sudo cp $OUT_FILE ${LSPQ_MISEQ_RUN_PATH}${LSPQ_ANALYSES}
	sudo rm $OUT_FILE
	rm $temp_file
}


Clean(){
        for proj in "${projects_list[@]}"
                do
                PROJECT_NAME=$proj
                SetFinalPath $PROJECT_NAME
                #rm ${SLBIO_FASTQ_BRUT_PATH}*"fastq.gz"
                #rm ${SLBIO_FASTQ_TRIMMO_PATH}*"fastq.gz"
        done
}

ComputeMiSeqStat(){
	MiSeq_Stat_Command="/usr/bin/python2.7 $RUN_QUAL_SCRIPT --runno $RUN_NAME  --param $PARAM_FILE"
	LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/"${LSPQ_ANALYSES}"MiSeqStat_"*

	if [ -e $LSPQ_MISEQ_RUNQUALFILE_PATH ]
                then
                :
        else 
                echo "Running MiSeqStat7.py ..."
                eval $MiSeq_Stat_Command > /dev/null 2>&1
        fi

}

CountReads(){
	for proj in "${projects_list[@]}"
		do
		PROJECT_NAME=$proj
        	SetFinalPath $PROJECT_NAME
		read_count_file_name="ReadCount.txt"
		read_count_file_before=${SLBIO_FASTQ_BRUT_PATH}"$read_count_file_name"
		read_count_file_after=${SLBIO_FASTQ_TRIMMO_PATH}"$read_count_file_name"

		echo -e "Fichier_FASTQ\tRead_Count\n" > $read_count_file_before
		for i in $(ls -1 ${SLBIO_FASTQ_BRUT_PATH}*".fastq.gz")
			do
			fastq_name=$(echo $(basename $i))
			echo -e "Count reads for $fastq_name \t$(date "+%Y-%m-%d @ %H:%M")" >>$SLBIO_LOG_FILE
			count=$(zcat $i | expr $(wc -l) / 4)
			echo -e "$fastq_name\t$count" >> $read_count_file_before
		done

		echo -e "Fichier_FASTQ\tRead_Count\n" > $read_count_file_after
		for i in $(ls -1 ${SLBIO_FASTQ_TRIMMO_PATH}*".fastq.gz")
			do
			fastq_name=$(echo $(basename $i))
			echo -e "Count reads for $fastq_name \t$(date "+%Y-%m-%d @ %H:%M")" >>$SLBIO_LOG_FILE
			count=$(zcat $i | expr $(wc -l) / 4)
			echo -e "$fastq_name\t$count" >> $read_count_file_after
		done
	done

}

$1

exit 0


<<TEMP
ComputeMiSeqStat(){

        echo -e "Calcul des metrics de la run\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE

        MiSeq_Stat_Command="/usr/bin/python2.7 $RUN_QUAL_SCRIPT --runno $RUN_NAME --gl $genome_length --param $PARAM_FILE"
        if [ -e $LSPQ_MISEQ_RUNQUALFILE_PATH ]
                then
                :
        else
                echo "Running MiSeqStat6.py ..."
                #echo $MiSeq_Stat_Command
                eval $MiSeq_Stat_Command > /dev/null 2>&1
        fi
}


CountReads(){
        read_count_file_name="ReadCount.txt"
        read_count_file_before=${SLBIO_FASTQ_BRUT_PATH}"$read_count_file_name"
        read_count_file_after=${SLBIO_FASTQ_TRIMMO_PATH}"$read_count_file_name"

        echo -e "Fichier_FASTQ\tRead_Count\n" > $read_count_file_before
        for i in $(ls -1 ${SLBIO_FASTQ_BRUT_PATH}*".fastq.gz")
                do
                fastq_name=$(echo $(basename $i))
                echo -e "Count reads for $fastq_name \t$(date "+%Y-%m-%d @ %H:%M")" >>$SLBIO_LOG_FILE
                count=$(zcat $i | expr $(wc -l) / 4)
                echo -e "$fastq_name\t$count" >> $read_count_file_before
        done

        echo -e "Fichier_FASTQ\tRead_Count\n" > $read_count_file_after
        for i in $(ls -1 ${SLBIO_FASTQ_TRIMMO_PATH}*".fastq.gz")
                do
                fastq_name=$(echo $(basename $i))
                echo -e "Count reads for $fastq_name \t$(date "+%Y-%m-%d @ %H:%M")" >>$SLBIO_LOG_FILE
                count=$(zcat $i | expr $(wc -l) / 4)
                echo -e "$fastq_name\t$count" >> $read_count_file_after
        done


}
TEMP
