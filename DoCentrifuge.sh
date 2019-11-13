#!/bin/bash

<<COMMENT
TODO : a adpater pour pipeleine Jenkins. D'ici là, simplement modifier le base_dir et executer comme suit
/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoCentrifuge.sh
COMMENT

CENTRIFUGEDB="/home/foueri01@inspq.qc.ca/InternetProgram/Centrifuge/centrifuge/abv"

FASTQ_R1_PAIR_SUFFIX="_R1_PAIR.fastq.gz"
FASTQ_R2_PAIR_SUFFIX="_R2_PAIR.fastq.gz"
FASTQ_R1_UNPAIR_SUFFIX="_R1_UNPAIR.fastq.gz"
FASTQ_R2_UNPAIR_SUFFIX="_R2_UNPAIR.fastq.gz"

base_dir="/data/Users/Eric/NGSjenkins/20191016_gono-16s-cloac/gono/"
fastq_trimmo_dir=${base_dir}"3_FASTQ_CLEAN_TRIMMOMATIC/"
metagen_dir=${base_dir}"METAGENOMIC_CENTRIFUGE/"
spec_arr=()

mkdir $metagen_dir


for fastq in $(ls -1 ${fastq_trimmo_dir})
        do
        fastq_spec=$(echo ${fastq} | cut -d '_' -f 1)

        if [[ ! " ${spec_arr[@]} " =~ " ${fastq_spec} " ]]
                then
                spec_arr+=(${fastq_spec})
        fi
done

for spec in ${spec_arr[@]}
	do
	echo "Centrifuge on ${spec}"
	fastq_pair_r1=${fastq_trimmo_dir}"${spec}"${FASTQ_R1_PAIR_SUFFIX}
	fastq_pair_r2=${fastq_trimmo_dir}"${spec}"${FASTQ_R2_PAIR_SUFFIX}
	fastq_unpair_r1=${fastq_trimmo_dir}"${spec}"${FASTQ_R1_UNPAIR_SUFFIX}
	fastq_unpair_r2=${fastq_trimmo_dir}"${spec}"${FASTQ_R2_UNPAIR_SUFFIX}

	centrifuge_cmd="centrifuge -x ${CENTRIFUGEDB} -1 ${fastq_pair_r1} -2 ${fastq_pair_r1} -U ${fastq_unpair_r1},${fastq_unpair_r2} -S ${metagen_dir}${spec}_ClassificationResult.txt  --report-file ${metagen_dir}${spec}_ClassificationSummary.txt --thread 30"

	centrifuge_kreport_cmd="centrifuge-kreport -x ${CENTRIFUGEDB} ${metagen_dir}${spec}_ClassificationResult.txt > ${metagen_dir}${spec}_ClassificationResult_Kraken.txt"

	eval $centrifuge_cmd
	eval $centrifuge_kreport_cmd
done



