#!/bin/bash
<<HEADER
Eric Fournier 2019-08-05
Qualimap

HEADER

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"

SetStaticPath
GetProjectsNamefromRunName

STEP="Qualimap"

BOWTIE2_INDEX_EXEC="bowtie2-build -q "
BOWTIE2_MAP_EXEC="bowtie2 --no-discordant --no-unal "

QUALIMAP_EXEC="qualimap bamqc "

SamToBam(){
	sample=$1
	spec_dir=$2
	tobam_cmd="samtools view -h -bS ${spec_dir}/${sample}.sam > ${spec_dir}/${sample}.bam"
	#echo $tobam_cmd
	eval $tobam_cmd
}

SortBam(){
	sample=$1
	spec_dir=$2
	sort_cmd="samtools sort ${spec_dir}/${sample}.bam ${spec_dir}/${sample}_sort"
	#echo $sort_cmd
	eval $sort_cmd
}

IndexBam(){
	sample=$1
	spec_dir=$2
	index_cmd="samtools index ${spec_dir}/${sample}_sort.bam"
	#echo $index_cmd
	eval $index_cmd
}


Bowtie2IndexRef(){
	fasta_assemb=$1
	db_dir=$2
	index_cmd="${BOWTIE2_INDEX_EXEC} -f $1 $2"
	eval $index_cmd
}

Bowtie2Map(){
	p_r1=$1;p_r2=$2;u_r1=$3;u_r2=$4;sample=$5;db=$6
        
        out_sam=${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}"/${spec}.sam"
	map_cmd="${BOWTIE2_MAP_EXEC} -x $6 -1 $p_r1 -2 $p_r2 -U ${u_r1},${u_r2} -S ${out_sam} >/dev/null 2>&1"
	eval $map_cmd
}


IndexRef(){
	sample=$1
	seqkit faidx ${SLBIO_SPADES_FILTER_PATH}${sample}"_filter.fasta"
        mv ${SLBIO_SPADES_FILTER_PATH}${sample}"_filter.fasta.fai" ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}
}


Qualimap(){
	sample=$1
	spec_dir=$2
	bam_file="${spec_dir}/${spec}_sort.bam"
	qualimap_cmd="$QUALIMAP_EXEC -bam ${bam_file} -outdir ${spec_dir} -nt 10 --java-mem-size=4G -outformat PDF:HTML -c > /dev/null 2>&1"
	#echo $qualimap_cmd
	eval $qualimap_cmd
}

for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
        SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))
	
	if [ ${#spec_arr[@]} -gt 0 ]
        	then
		mkdir -p ${SLBIO_SPADES_QC_QUALIMAP_PATH}
	fi
	
	for spec in "${spec_arr[@]}"
		do
		echo -e "Qualimap pour ${spec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
		fasta_assemb=${SLBIO_SPADES_FILTER_PATH}${spec}"_filter.fasta"
		mkdir ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}
		db_prefix=${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}"/Bowtie2DB"
		Bowtie2IndexRef $fasta_assemb $db_prefix
		IndexRef $spec
		PAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R1_PAIR.fastq.gz"
                UNPAIR_R1_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R1_UNPAIR.fastq.gz"
                PAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R2_PAIR.fastq.gz"
                UNPAIR_R2_TRIMMO=${SLBIO_FASTQ_TRIMMO_PATH}${spec}"_R2_UNPAIR.fastq.gz"
		
		Bowtie2Map $PAIR_R1_TRIMMO $PAIR_R2_TRIMMO $UNPAIR_R1_TRIMMO $UNPAIR_R2_TRIMMO $spec $db_dir
		rm  ${db_prefix}*
		SamToBam $spec ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}
		SortBam $spec ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}
		IndexBam $spec ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}
		rm ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}/${spec}".sam"
		rm ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}/${spec}".bam" 
		
		Qualimap $spec ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}
	done
done
