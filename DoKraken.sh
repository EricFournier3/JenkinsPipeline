#!/bin/bash

<<COMMENT
TODO : a adpater pour pipeleine Jenkins. D'ici là, simplement modifier le base_dir et executer comme suit
/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoKraken.sh
COMMENT

KRAKENDB="/home/foueri01@inspq.qc.ca/InternetProgram/Kraken/kraken2/database/krakenv2Db/"
base_dir="/data/Users/Eric/NGSjenkins/20191120_pulsenet-blasto-metag-16s/16s/"
fastq_trimmo_dir=${base_dir}"3_FASTQ_CLEAN_TRIMMOMATIC/"
metagen_dir=${base_dir}"METAGENOMIC_KRAKEN/"
spec_arr=()

mkdir $metagen_dir

for fastq in $(ls -1 "${fastq_trimmo_dir}"*".fastq.gz")
	do 
	fastq=$(basename ${fastq})
	fastq_spec=$(echo ${fastq} | cut -d '_' -f 1)

	if [[ ! " ${spec_arr[@]} " =~ " ${fastq_spec} " ]]
		then
		spec_arr+=(${fastq_spec})
	fi
done

for spec in ${spec_arr[@]}
	do
	echo "Kraken on "$spec
	all_fastq=${fastq_trimmo_dir}${spec}*"gz"
	kraken2 --db $KRAKENDB --output ${metagen_dir}"Out_"${spec} --report ${metagen_dir}"Report_"${spec} --thread 30 <(zcat ${all_fastq})	
done
