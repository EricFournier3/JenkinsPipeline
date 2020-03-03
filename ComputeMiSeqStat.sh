#!/bin/bash

LSPQ_MISEQ_MISEQ_RUN_TRACE="2_MiSeqRunTrace/"
LSPQ_MISEQ_EXPERIMENTAL="1_Experimental/"
LSPQ_MISEQ_SEQ_BRUT="3_SequencesBrutes/"

stat_script="/data/Applications/GitScript/MiSeqRunQuality/MiSeqStatOnFly.py"
PARAM_FILE="/data/Applications/GitScript/Jenkins/JenkinsParameter.yaml"


MakeCartridgeFastqLink(){
  fastq_link_subdir=$1
  cartridge=$2

  if [ -d ${fastq_link_subdir} ]
    then
    :
  else
    mkdir ${fastq_link_subdir}
  fi

  for sample in $(awk 'BEGIN{FS=","}/Sample_ID/,EOF {print $1}' "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}/${LSPQ_MISEQ_EXPERIMENTAL}"*"_"${cartridge}".csv" | sed -n '/Sample_Name/!p')
                do
                if  ls "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}/${LSPQ_MISEQ_SEQ_BRUT}${sample}"*".fastq.gz" 1>/dev/null  2>&1
		  then
                  ln -s "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}/${LSPQ_MISEQ_SEQ_BRUT}${sample}_"*".fastq.gz"  ${fastq_link_subdir} 2>/dev/null
                  #ln -s "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}/${LSPQ_MISEQ_SEQ_BRUT}${sample}_"*".fastq.gz"  ${fastq_link_subdir} 
                fi
        done



}


slbio_user=$(whoami)
ldap_user=$(echo ${slbio_user} | cut -d '@' -f 1)
PASS_FILE="/home/${slbio_user}/pass.txt"

if grep -qs '/mnt/Partage' /proc/mounts
        then
        :
else
        echo "mount /mnt/Partage"
        read pw < $PASS_FILE
        sudo mount -t cifs -o username=${ldap_user},password=$pw,vers=3.0 "//swsfi52p/partage" /mnt/Partage
fi


LSPQ_MISEQ_BASE_PATH="/mnt/Partage/LSPQ_MiSeq/"

if [ ${#1} -lt 1 ]
  then
  echo "Entrer un numero de run"
  exit 1
fi

RUN_NAME=$1

RUN_YEAR=${RUN_NAME:0:4}
LSPQ_MISEQ_MISEQ_RUN_TRACE="2_MiSeqRunTrace/"

if [ -d "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}" ]
  then 
  :
else
  echo "Run innexistante"
  exit 1
fi
 
TEMP_FASTQ_LINK_DIR="/data/temp/TEMP_FASTQ_LINK/${RUN_NAME}/"


if [ -d ${TEMP_FASTQ_LINK_DIR} ]
  then
  :
else
  mkdir ${TEMP_FASTQ_LINK_DIR}
fi



for fullpath in $(ls -1 -d "${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}""/""${LSPQ_MISEQ_MISEQ_RUN_TRACE}"*)
  do
  subdir=$(echo $(basename ${fullpath}))

  LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_YEAR}/${RUN_NAME}"/"${LSPQ_MISEQ_MISEQ_RUN_TRACE}""${subdir}/"MiSeqStat_"*

  if [ -e $LSPQ_MISEQ_RUNQUALFILE_PATH ]
    then
    :
  else
    MakeCartridgeFastqLink ${TEMP_FASTQ_LINK_DIR}${subdir} ${subdir}
    echo "Running MiSeqStatOnFly.py ..."        
    MiSeq_Stat_Command="/usr/bin/python2.7 ${stat_script} --runno $RUN_NAME  --param $PARAM_FILE --subdir $subdir --tempdir ${TEMP_FASTQ_LINK_DIR}"
    eval $MiSeq_Stat_Command  > /dev/null 2>&1
    #eval $MiSeq_Stat_Command 
  fi

  rm ${TEMP_FASTQ_LINK_DIR}${subdir}"/"*".fastq.gz"

done


exit 1

