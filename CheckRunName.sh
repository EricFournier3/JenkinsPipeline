#!/bin/bash

<<HEADER
Eric Fournier 2019-07-11

HEADER


source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath

input_run_name=$1
#Modif_20200130
run_year=${input_run_name:0:4}
echo "Input run is $input_run_name"
#echo ${LSPQ_MISEQ_BASE_PATH}
#Modif_20200130
echo "Run is ${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}"
if [ -d "${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}" ]
	then
	:
else
	echo "ERREUR : Ce numéro de run est inexistant !!!!!!!!!!"
	exit 1
fi
	


param_samplesheet_name=$2
echo "****** param_samplesheet_name ${param_samplesheet_name}"


if [ "${param_samplesheet_name}" = "no_sample_sheet" ]
  then
  echo "Aucun sample sheet en parametre"
else
  echo "Un samplesheet en parametre"

  if [ -f ${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}/${LSPQ_MISEQ_EXPERIMENTAL}${param_samplesheet_name} ]
    then
    echo "OK SAMPLESHEET EXIST"
    
  else
    
    echo "ERREUR: La samplesheet ${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}/${LSPQ_MISEQ_EXPERIMENTAL}${param_samplesheet_name} n'existe pas !!!!!!!!!!"
    exit 1
  fi

fi


