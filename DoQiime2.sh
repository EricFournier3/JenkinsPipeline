#!/bin/bash

<<HEADER
Eric Fournier 2019-11-07

Qiime2


HEADER


MakeClassificationSummary(){

	final_summary="${metagen_dir}Summary.txt"

	sed -n '/index/p' $res_tax_classifier  | awk 'BEGIN{FS=","}{for(i==1;i<=NF;i++){print i"\t"$(i)}}' | sed -n '2,$p' > ${metagen_dir}"temp_1.txt";sed -i 's/ /__/g' ${metagen_dir}"temp_1.txt"


	for i in $(awk 'BEGIN{FS=","}NR>1{print $1}' ${res_tax_classifier}) 
		do 
			sed -n "/$i/p" $res_tax_classifier  | awk 'BEGIN{FS=","}{for(j==1;j<=NF;j++){print j"\t"$(j)}}' | sed -n '2,$p' >  ${metagen_dir}"${i}temp_2.txt"
                        join ${metagen_dir}"temp_1.txt"  ${metagen_dir}"${i}temp_2.txt" | sed -n '/ 0.0/!p' >  ${metagen_dir}"${i}temp_3.txt"      
                        sed -n '/Year\|SampleSite\|index/!p' ${metagen_dir}"${i}temp_3.txt" | sort -nrk 3 > ${metagen_dir}"TaxProfil_${i}.txt"
			rm ${metagen_dir}"${i}temp_2.txt";rm ${metagen_dir}"${i}temp_3.txt"

			echo -e "Sample_id\tProgramme\tNbReads(>1%)\tFracReads\tTaxon\t" >> $final_summary

			sed  -E "{s/^[0-9]+ //}" ${metagen_dir}"TaxProfil_${i}.txt" | awk -v mysample=$i -f ${parse_spec_taxon_script} | sed  -E "{s/.?__//g}" | sort -nrk 3 >> $final_summary

			echo -e "\n" >> $final_summary

        done

	rm ${metagen_dir}"temp_1.txt"


}

parse_spec_taxon_script="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/ParseQiime.awk"

current_year=$(echo $(date +'%Y'))

silva_classifier="/data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10/Classifier/silva-132-99-nb-classifier.qza"
greengene_classifier="/data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10/Classifier/gg-13-8-99-nb-classifier.qza"
classification_res_dir="CLASSIFICATION_RESULTS"

base_dir="/data/Users/Eric/NGSjenkins/99999999_proj1/proj1/"
fastq_trimmo_dir=${base_dir}"FASTQ_CLEAN_TRIMMOMATIC/"
metagen_dir=${base_dir}"METAGENOMIC_QIIME2/"
tmp_dir=${metagen_dir}"TEMP"

res_tax_classifier=${metagen_dir}"${classification_res_dir}/*/data/level-7.csv"


fastq_concat_dir=${metagen_dir}"TEMP_FASTQ_CONCAT/"
spec_arr=("L166501-16S" "L165803-16S")

template_sample_sheet="/home/foueri01@inspq.qc.ca/GitScript/Metagenomic/BasicWorkSheetTemplate2.tsv"
template_sample_sheet_path=${base_dir}"${template_sample_sheet_name}"

new_sample_sheet_name="qiime_sample_sheet.tsv"
new_sample_sheet_path=${metagen_dir}${new_sample_sheet_name}

#cp $template_sample_sheet $new_sample_sheet_path


fastq_qza="FASTQ.qza"
fastq_qzv="FASTQ.qzv"

#mkdir -p  ${fastq_concat_dir}
#mkdir $tmp_dir


echo "Qiime : concat fastq"
for spec in "${spec_arr[@]}"
	do
        :	
	#cat ${fastq_trimmo_dir}${spec}* > ${fastq_concat_dir}${spec}"_S999_L001_R1_001.fastq.gz"
        #sed -i "\$a ${spec}\tunknown\t${current_year}" $new_sample_sheet_path
done

echo "Qiime : step 1"
qiime_cmd_1="qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path ${fastq_concat_dir} --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path ${metagen_dir}${fastq_qza}" 
#eval $qiime_cmd_1

#rm -r $fastq_concat_dir

echo "Qiime : step 2"
qiime_cmd_2="qiime demux summarize --i-data ${metagen_dir}${fastq_qza}  --o-visualization ${metagen_dir}${fastq_qzv}"
#eval $qiime_cmd_2

echo "Qiime : step 3"
qiime_cmd_3="qiime dada2 denoise-single --p-n-threads 40 --i-demultiplexed-seqs ${metagen_dir}${fastq_qza} --p-trim-left 0 --p-trunc-len 300 --o-representative-sequences ${metagen_dir}REP-SEQS-DADA2.qza --o-table ${metagen_dir}TABLE-DADA2.qza --o-denoising-stats ${metagen_dir}STATS-DADA2.qza"
#eval $qiime_cmd_3

echo "Qiime : step 4"
qiime_cmd_4="qiime metadata tabulate --m-input-file ${metagen_dir}STATS-DADA2.qza --o-visualization ${metagen_dir}STATS-DADA2.qzv"
#eval $qiime_cmd_4

echo "Qiime : step 5"
qiime_cmd_5="qiime feature-table summarize --i-table ${metagen_dir}TABLE-DADA2.qza --o-visualization ${metagen_dir}TABLE-DADA2.qzv --m-sample-metadata-file $new_sample_sheet_path"
#eval $qiime_cmd_5

echo "Qiime : step 6"
qiime_cmd_6="qiime feature-table tabulate-seqs --i-data ${metagen_dir}REP-SEQS-DADA2.qza --o-visualization ${metagen_dir}REP-SEQS-DADA2.qzv"
#eval $qiime_cmd_6

echo "Qiime : step 7"
qiime_cmd_7="qiime phylogeny align-to-tree-mafft-fasttree --i-sequences ${metagen_dir}REP-SEQS-DADA2.qza --o-alignment ${metagen_dir}ALIGNED-REP-SEQS.qza  --o-masked-alignment ${metagen_dir}MASKED-ALIGNED-REP-SEQS.qza  --o-tree  ${metagen_dir}UNROOTED-TREE.qza  --o-rooted-tree ${metagen_dir}ROOTED-TREE.qza "
#eval $qiime_cmd_7

#export TMPDIR=${tmp_dir}


echo "Qiime : step 8"
qiime_cmd_8="qiime feature-classifier classify-sklearn --p-n-jobs -1 --i-classifier $silva_classifier --i-reads ${metagen_dir}REP-SEQS-DADA2.qza --o-classification ${metagen_dir}TAXONOMY.qza"
#eval $qiime_cmd_8

echo "Qiime : step 9"
qiime_cmd_9="qiime metadata tabulate --m-input-file ${metagen_dir}TAXONOMY.qza --o-visualization ${metagen_dir}TAXONOMY.qzv"
#eval $qiime_cmd_9

echo "Qiime : step 10"
qiime_cmd_10="qiime taxa barplot --i-table ${metagen_dir}TABLE-DADA2.qza --i-taxonomy ${metagen_dir}TAXONOMY.qza --m-metadata-file ${new_sample_sheet_path} --o-visualization ${metagen_dir}TAXA-BAR-PLOTS.qzv"
#eval $qiime_cmd_10

unzip ${metagen_dir}TAXA-BAR-PLOTS.qzv "*.csv" -d ${metagen_dir}"${classification_res_dir}" > /dev/null

MakeClassificationSummary

echo "Qiime Finish"


