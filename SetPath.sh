#!/bin/bash

<<HEADER
Eric Fournier 2019-07-09

HEADER
CURRENT_YEAR=$(echo $(date +'%Y'))
PARAM_FILE="/data/Applications/GitScript/Jenkins/JenkinsParameter.yaml"
GET_PARAM_SCRIPT="/data/Applications/GitScript/Jenkins/GetJenkinsParamVal.py"
RUN_QUAL_SCRIPT="/data/Applications/GitScript/MiSeqRunQuality/MiSeqStat7.py"
GET_SPECIMENS_SCRIPT="/data/Applications/GitScript/Jenkins/GetSpecimensForTask.py"
COMPUTE_SAMPLE_COVERAGE_SCRIPT="/data/Applications/GitScript/MiSeqRunQuality/ComputeExpectedGenomesCoverage.py"
CORESNV_REFERENCE_SCRIPT="/data/Applications/GitScript/Jenkins/CheckCoreSnvReference.py"
QUAST_REFERENCE_SCRIPT="/data/Applications/GitScript/Jenkins/CheckQuastReference.py"
CORESNV_EXEC="/home/foueri01@inspq.qc.ca/InternetProgram/SNVPhyl_CLI/snvphyl-galaxy-cli/bin/snvphyl.py"
POSITION2PHYLOVIZ_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/SNVPhyl_CLI/PerlScript/positions2phyloviz.pl"
FUNANNOTATE_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/Funannotate/funannotate/funannotate.py"
GRAPETREE_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/GrapeTree/GrapeTree/grapetree.py"
PASS_FILE="/home/foueri01@inspq.qc.ca/pass.txt"
PARSE_SPEC_TAXON_SCRIPT="/data/Applications/GitScript/Jenkins/ParseQiime.awk"
SILVA_CLASSIFIER="/data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10/Classifier/silva-132-99-nb-classifier.qza"
GREENGENE_CLASSIFIER="/data/Applications/Miniconda/miniconda3/envs/qiime2-2019.10/Classifier/gg-13-8-99-nb-classifier.qza"
QIIME_TEMPLATE_SAMPLE_SHEET="/data/Applications/GitScript/Metagenomic/BasicWorkSheetTemplate2.tsv"
AUGUSTUS_SPECIES_DIR="/data/Databases/FunannotateDB_v171/trained_species/"


if grep -qs '/mnt/Partage' /proc/mounts
        then
        :
else
        echo "mount /mnt/Partage"
        read pw < $PASS_FILE
        sudo mount -t cifs -o username=foueri01,password=$pw,vers=3.0 "//swsfi52p/partage" /mnt/Partage
fi

errno=$?

if [ $errno -eq 0 ]
        then
        :
else
        echo "ERROR WITH mount /mnt/Partage"
        exit 1
fi


SetStaticPath(){

        path_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  path  2>&1))
        LSPQ_MISEQ_BASE_PATH=${path_arr[0]}"/"
        SLBIO_BASE_PATH=${path_arr[1]}"/"
        GITSCRIPT_BASE_PATH=${path_arr[2]}"/"
	LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE=${path_arr[3]}"\\\\"

        lspq_miseq_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  lspq_miseq_subdir  2>&1))
        LSPQ_MISEQ_EXPERIMENTAL=${lspq_miseq_subdir_arr[0]}"/"
	LSPQ_MISEQ_MISEQ_RUN_TRACE=${lspq_miseq_subdir_arr[1]}"/"
        LSPQ_MISEQ_SEQ_BRUT=${lspq_miseq_subdir_arr[2]}"/"
        LSPQ_ANALYSES=${lspq_miseq_subdir_arr[3]}"/"


        slbio_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  slbio_subdir  2>&1))
        SLBIO_FASTQ_BRUT=${slbio_subdir_arr[0]}"/"
        SLBIO_FASTQC_1=${slbio_subdir_arr[1]}"/"
        SLBIO_FASTQ_TRIMMO=${slbio_subdir_arr[2]}"/"
        SLBIO_FASTQC_2=${slbio_subdir_arr[3]}"/"
	SLBIO_SPADES=${slbio_subdir_arr[4]}"/"
	SLBIO_SPADES_BRUT=${SLBIO_SPADES}${slbio_subdir_arr[5]}"/"
	SLBIO_SPADES_FILTER=${SLBIO_SPADES}${slbio_subdir_arr[6]}"/"
	SLBIO_SPADES_QC=${slbio_subdir_arr[7]}"/"
	SLBIO_SPADES_QC_QUALIMAP=${SLBIO_SPADES_QC}${slbio_subdir_arr[8]}"/"
	SLBIO_SPADES_QC_QUAST=${SLBIO_SPADES_QC}${slbio_subdir_arr[9]}"/"
	SLBIO_PROKKA=${slbio_subdir_arr[10]}"/"
	SLBIO_FUNANNOTATE=${slbio_subdir_arr[11]}"/"
	SLBIO_CORESNV=${slbio_subdir_arr[12]}"/"
	SLBIO_QIIME=${slbio_subdir_arr[13]}"/"
	SLBIO_LOG=${slbio_subdir_arr[14]}"/"
	SLBIO_WEBREPORT=${slbio_subdir_arr[15]}"/"
	GENOME_LENGTH_FILE=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  genome_length_file  2>&1))
}


SetFinalPath(){
	PROJECT_NAME=$1
        LSPQ_MISEQ_RUN_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}/
	LSPQ_MISEQ_RUN_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE}${RUN_NAME}"\\\\"
	LSPQ_MISEQ_ANALYSES_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_ANALYSES}
	LSPQ_MISEQ_ANALYSIS_PROJECT_PATH=${LSPQ_MISEQ_ANALYSES_PATH}${PROJECT_NAME}/
	LSPQ_MISEQ_ANALYSE_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_RUN_PATH_FROM_SPARTAGE}${LSPQ_ANALYSES}
        LSPQ_MISEQ_SAMPLESHEET_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}"${RUN_NAME}.csv"
        LSPQ_MISEQ_FASTQ_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_SEQ_BRUT}
        LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/"${LSPQ_MISEQ_MISEQ_RUN_TRACE}"MiSeqStat_"*
	LSPQ_MISEQ_PROJ_DESC_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/"${LSPQ_MISEQ_EXPERIMENTAL}${PROJECT_NAME}"_desc.txt"

        SLBIO_RUN_PATH=${SLBIO_BASE_PATH}"$RUN_NAME/"
        SLBIO_PROJECT_PATH=${SLBIO_RUN_PATH}"$PROJECT_NAME/"
        SLBIO_FASTQ_BRUT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQ_BRUT}
	SLBIO_FASTQC_BRUT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQC_1}	
        SLBIO_FASTQ_TRIMMO_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQ_TRIMMO}
        SLBIO_FASTQC_TRIMMO_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FASTQC_2}
	SLBIO_SPADES_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES}
        SLBIO_SPADES_BRUT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_BRUT}
	SLBIO_SPADES_FILTER_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_FILTER}
	SLBIO_SPADES_QC_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC}
	SLBIO_SPADES_QC_QUALIMAP_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC_QUALIMAP}
        SLBIO_SPADES_QC_QUAST_PATH=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC_QUAST}
	SLBIO_SPADES_QC_QUAST_ALL=${SLBIO_SPADES_QC_QUAST_PATH}"ALL/"
	SLBIO_PROKKA_PATH=${SLBIO_PROJECT_PATH}${SLBIO_PROKKA}
	SLBIO_FUNANNOTATE_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FUNANNOTATE}
	SLBIO_CORESNV_PATH=${SLBIO_PROJECT_PATH}${SLBIO_CORESNV}
	SLBIO_QIIME_PATH=${SLBIO_PROJECT_PATH}${SLBIO_QIIME}
        SLBIO_LOG_PATH=${SLBIO_PROJECT_PATH}${SLBIO_LOG}
        SLBIO_LOG_FILE=${SLBIO_LOG_PATH}"JenkinsLog.log"
	LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/1_Experimental/CoreSnvSamplesToAdd_"${RUN_NAME}"_${PROJECT_NAME}.txt"
	LSPQ_MISEQ_CORESNV_METADATA_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/1_Experimental/CoreSnvMetadata_"${RUN_NAME}"_${PROJECT_NAME}.txt"
	SLBIO_WEBREPORT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_WEBREPORT}
}

GetProjectsNamefromRunName(){
        projects_list_temp=$(echo $RUN_NAME | cut -d '_' -f 2)
        IFS_BKP=$IFS
        IFS='-'
        read -r -a projects_list <<< "$projects_list_temp"

        IFS=$IFS_BKP
        #echo "${projects_list[@]}"
}

