#!/bin/bash

<<HEADER
Eric Fournier 2019-07-11

HEADER


source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath

input_run_name=$1
run_year=${input_run_name:0:4}

echo -e "${green_message}INFO: ""Run is ${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}"
echo -e "${white_message}"

if [ -d "${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}" ]
	then
	:
else
	echo -e "${red_message}""ERREUR : Ce numéro de run est inexistant !!!!!!!!!!"
	echo -e "${white_message}"
	exit 1
fi
	
param_samplesheet_name=$2


if [ "${param_samplesheet_name}" = "no_sample_sheet" ]
  then
  :
else

  if [ -f ${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}/${LSPQ_MISEQ_EXPERIMENTAL}${param_samplesheet_name} ]
    then
    :
  else
    
    echo -e "${red_message}""ERREUR: La samplesheet ${LSPQ_MISEQ_BASE_PATH}${run_year}/${input_run_name}/${LSPQ_MISEQ_EXPERIMENTAL}${param_samplesheet_name} n'existe pas !!!!!!!!!!"
    echo -e "${white_message}"
    exit 1
  fi
fi


