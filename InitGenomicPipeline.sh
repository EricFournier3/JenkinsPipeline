#!/bin/bash

<<HEADER
Eric Fournier 2019-07-09

HEADER

PASS_FILE="/home/foueri01@inspq.qc.ca/pass.txt"

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

BuildSlbioStruct(){
	echo $SLBIO_RUN_PATH	
	if [ -d $SLBIO_RUN_PATH ]
		then :
        else
		mkdir $SLBIO_RUN_PATH
	fi
        mkdir -p $SLBIO_FASTQ_BRUT_PATH $SLBIO_FASTQ_TRIMMO_PATH  $SLBIO_FASTQC_BRUT_PATH   $SLBIO_FASTQC_TRIMMO_PATH   $SLBIO_LOG_PATH
        echo -e "Création des sous répertoires 1_FASTQ_BRUT 2_FASTQC_BRUT 3_FASTQ_TRIMMO  4_FASTQC_TRIMMO\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
}

CopyFASTQ(){

        echo -e "Copie des fichiers fastq.gz de S:Partage/LSPQ_MiSeq vers 1_FASTQ_BRUT\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE

        sudo cp $LSPQ_MISEQ_SAMPLESHEET_PATH $SLBIO_PROJECT_PATH
        sample_sheet_name=$(basename $LSPQ_MISEQ_SAMPLESHEET_PATH)
        #convertir de DOS vers Linux format
        awk '{sub("\r$", "");print}' ${SLBIO_PROJECT_PATH}${sample_sheet_name} > ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp"

        #Supprimer le header
        sed -n '/Sample_ID/,$p' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp" >  ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2"

        #Extraire les sample id du projet cible
        awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project){print $1}}' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2" > ${SLBIO_PROJECT_PATH}"ID_list.txt"
        awk -v project=$PROJECT_NAME 'BEGIN{FS=","}{if($9 == project || $1 == "Sample_ID"){print $0}}' ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp2" > ${SLBIO_PROJECT_PATH}${sample_sheet_name}".temp3"

        myarr=();
        for i in $(cat ${SLBIO_PROJECT_PATH}"ID_list.txt")
                do
                myarr+=($i)
        done

        for j in ${myarr[@]}
                do
                sudo cp ${LSPQ_MISEQ_FASTQ_PATH}${j}*".fastq.gz" $SLBIO_FASTQ_BRUT_PATH
        done


}

RenameFastq(){

             for fastq in $(ls ${SLBIO_FASTQ_BRUT_PATH}/*.fastq.gz)
                do
                fastq_ori=$fastq
                fastq_path=$(dirname $fastq_ori)
                fastq_base=$(basename $fastq_ori)
                new_fastq_base=$(echo $fastq_base | cut -d '_' -f1,4)".fastq.gz"
                fastq_new=${fastq_path}/${new_fastq_base}
                mv $fastq_ori $fastq_new
             done
}


for proj in "${projects_list[@]}"
	do
	PROJECT_NAME=$proj
	SetFinalPath $PROJECT_NAME
	#echo "In InitGEnomicPipeline $SLBIO_SPADES_FILTER_PATH"
	BuildSlbioStruct
	CopyFASTQ
	RenameFastq
done



