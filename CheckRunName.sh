#!/bin/bash

<<HEADER
Eric Fournier 2019-07-11

HEADER


source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath

input_run_name=$1
echo "Input run is $input_run_name"
#echo ${LSPQ_MISEQ_BASE_PATH}
if [ -d "${LSPQ_MISEQ_BASE_PATH}${input_run_name}" ]
	then
	:
else
	echo "ERREUR : Ce numéro de run est inexistant !!!!!!!!!!"
	exit 1
fi
	
