#!/bin/bash

<<HEADER
Eric Fournier 2019-07-09

HEADER
PARAM_FILE="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/JenkinsParameter.yaml"
GET_PARAM_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/GetJenkinsParamVal.py"
RUN_QUAL_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/MiSeqRunQuality/MiSeqStat7.py"
GET_SPECIMENS_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/GetSpecimensForTask.py"
COMPUTE_SAMPLE_COVERAGE_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/MiSeqRunQuality/ComputeExpectedGenomesCoverage.py"
CORESNV_REFERENCE_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/CheckCoreSnvReference.py"
CORESNV_EXEC="/home/foueri01@inspq.qc.ca/InternetProgram/SNVPhyl_CLI/snvphyl-galaxy-cli/bin/snvphyl.py"
POSITION2PHYLOVIZ_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/SNVPhyl_CLI/PerlScript/positions2phyloviz.pl"
FUNANNOTATE_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/Funannotate/funannotate/funannotate.py"


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

        lspq_miseq_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  lspq_miseq_subdir  2>&1))
        LSPQ_MISEQ_EXPERIMENTAL=${lspq_miseq_subdir_arr[0]}"/"
	LSPQ_MISEQ_MISEQ_RUN_TRACE=${lspq_miseq_subdir_arr[1]}"/"
        LSPQ_MISEQ_SEQ_BRUT=${lspq_miseq_subdir_arr[2]}"/"
        LSPQ_ANALYSES=${lspq_miseq_subdir_arr[3]}"/"


     slbio_subdir_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  slbio_subdir  2>&1))
#OLD
#        SLBIO_FASTQ_BRUT=${slbio_subdir_arr[0]}"/"
#        SLBIO_FASTQC_1=${slbio_subdir_arr[1]}"/"
#        SLBIO_FASTQ_TRIMMO=${slbio_subdir_arr[2]}"/"
#        SLBIO_FASTQC_2=${slbio_subdir_arr[3]}"/"
#        SLBIO_SPADES=${slbio_subdir_arr[4]}"/"
#        SLBIO_SPADES_FILTER=${slbio_subdir_arr[5]}"/"
#        SLBIO_SPADES_STAT=${slbio_subdir_arr[6]}"/"
#        SLBIO_PROKKA=${slbio_subdir_arr[7]}"/"
#        SLBIO_LOG=${slbio_subdir_arr[8]}"/"
#	SLBIO_CORESNV=${slbio_subdir_arr[9]}"/"
#	SLBIO_FUNANNOTATE=${slbio_subdir_arr[10]}"/"

#NEW
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
	SLBIO_LOG=${slbio_subdir_arr[13]}"/"

	GENOME_LENGTH_FILE=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  genome_length_file  2>&1))
}


SetFinalPath(){
	PROJECT_NAME=$1
        LSPQ_MISEQ_RUN_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}/
        LSPQ_MISEQ_SAMPLESHEET_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}"${RUN_NAME}.csv"
        LSPQ_MISEQ_FASTQ_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_SEQ_BRUT}
        LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/"${LSPQ_MISEQ_MISEQ_RUN_TRACE}"MiSeqStat_"*

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
	SLBIO_SPADES_QC_QUALIMAP=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC_QUALIMAP}
        SLBIO_SPADES_QC_QUAST=${SLBIO_PROJECT_PATH}${SLBIO_SPADES_QC_QUAST}
	SLBIO_PROKKA_PATH=${SLBIO_PROJECT_PATH}${SLBIO_PROKKA}
	SLBIO_FUNANNOTATE_PATH=${SLBIO_PROJECT_PATH}${SLBIO_FUNANNOTATE}
	SLBIO_CORESNV_PATH=${SLBIO_PROJECT_PATH}${SLBIO_CORESNV}
        SLBIO_LOG_PATH=${SLBIO_PROJECT_PATH}${SLBIO_LOG}
        SLBIO_LOG_FILE=${SLBIO_LOG_PATH}"SnakeMakeLog.log"
	LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}"CoreSnvSamplesToAdd/"${RUN_NAME}"_${PROJECT_NAME}.txt"
}

GetProjectsNamefromRunName(){
        projects_list_temp=$(echo $RUN_NAME | cut -d '_' -f 2)
        IFS_BKP=$IFS
        IFS='-'
        read -r -a projects_list <<< "$projects_list_temp"

        IFS=$IFS_BKP
        echo "${projects_list[@]}"
}

