#!/bin/bash

<<COMMENT
TODO : a adpater pour pipeleine Jenkins. D'ici là, simplement modifier le base_dir et executer comme suit
/home/foueri01@inspq.qc.ca/GitScript/Jenkins/DoClark.sh
COMMENT

CLARKDB="/data/Databases/CLARK_DB"

base_dir="/home/foueri01@inspq.qc.ca/temp/TEMP2/TEST_CLARK/"
fastq_trimmo_dir=${base_dir}"FASTQ/"
metagen_dir=${base_dir}"METAGENOMIC_CLARK/"

mkdir $metagen_dir

spec_arr=()

settarget_cmd="set_targets.sh ${CLARKDB} bacteria viruses fungi"

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
        echo "Clark on ${spec}"
	
	all_fastq_spec=$(ls ${fastq_trimmo_dir}${spec}*fastq.gz)
	fastq_concat=${metagen_dir}${spec}".fastq"
	
	out_classify=${metagen_dir}${spec}"_out"
	out_abundance_1=${metagen_dir}${spec}"_abundance.txt"
	out_abundance_2=${metagen_dir}"results.krn"
	
	in_krona=${metagen_dir}${spec}"_krona.krn"
	out_krona=${metagen_dir}${spec}"_krona.html"
	
	classify_cmd="classify_metagenome.sh -O ${fastq_concat} -n 30 -R ${out_classify} "
	abundance_cmd="estimate_abundance.sh -F ${out_classify}.csv -D ${CLARKDB} --krona > ${out_abundance_1}"
	krona_cmd="ktImportTaxonomy -o ${out_krona} -m 3 ${in_krona}"

	zcat ${all_fastq_spec} > ${fastq_concat}
	eval ${settarget_cmd}	
	eval ${classify_cmd}
	eval ${abundance_cmd}
		
	mv ${out_abundance_2} ${in_krona}
	eval ${krona_cmd}
	
	rm ${fastq_concat}
	
done



exit 1



CLARKDB="/home/foueri01@inspq.qc.ca/InternetProgram/Clark/DATABASE"

base_dir="/data/Users/Eric/NGSjenkins/20191120_pulsenet-blasto-metag-16s/16s/"
fastq_trimmo_dir=${base_dir}"3_FASTQ_CLEAN_TRIMMOMATIC/"
metagen_dir=${base_dir}"METAGENOMIC_CLARK/"

mkdir $metagen_dir

spec_arr=()

settarget_cmd="set_targets.sh ${CLARKDB} bacteria viruses fungi"

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
        echo "Clark on ${spec}"
	
	all_fastq_spec=$(ls ${fastq_trimmo_dir}${spec}*fastq.gz)
	fastq_concat=${metagen_dir}${spec}".fastq"
	
	out_classify=${metagen_dir}${spec}"_out"
	out_abundance_1=${metagen_dir}${spec}"_abundance.txt"
	out_abundance_2=${metagen_dir}"results.krn"
	
	in_krona=${metagen_dir}${spec}"_krona.krn"
	out_krona=${metagen_dir}${spec}"_krona.html"
	
	classify_cmd="classify_metagenome.sh -O ${fastq_concat} -n 30 -R ${out_classify} "
	abundance_cmd="estimate_abundance.sh -F ${out_classify}.csv -D ${CLARKDB} --krona > ${out_abundance_1}"
	krona_cmd="ktImportTaxonomy -o ${out_krona} -m 3 ${in_krona}"

	zcat ${all_fastq_spec} > ${fastq_concat}
	eval ${settarget_cmd}	
	eval ${classify_cmd}
	eval ${abundance_cmd}
		
	mv ${out_abundance_2} ${in_krona}
	eval ${krona_cmd}
	
	rm ${fastq_concat}
	
done

