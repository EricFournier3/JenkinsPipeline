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
	
