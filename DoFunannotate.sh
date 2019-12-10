#!/bin/bash

<<HEADER
Eric Fournier 2019-07-18

Fnuannotate

HEADER

source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

STEP="Funannotate"

GetAugustusSpecies(){
	echo $1
	#AUGUSTUS_SPECIES_DIR=${AUGUSTUS_CONFIG_PATH}/species/  path obsolete
	species=$(awk -v specimen="^$1$" 'BEGIN{FS=","}$1~specimen{print tolower($11)}' ${SLBIO_PROJECT_PATH}${RUN_NAME}.csv.temp3)
	species2=${species/ /_}
	gender=$(echo $species2 | cut -d '_' -f 1)

	if [ -d "${AUGUSTUS_SPECIES_DIR}${species2}" ]
		then
		augustus_species=$species2
	elif [ -d "${AUGUSTUS_SPECIES_DIR}${gender}" ]
		then
		augustus_species=$gender
	elif ls "${AUGUSTUS_SPECIES_DIR}${gender}"* > /dev/null 2>&1
		then
		dir_arr=($(ls -1 -d "${AUGUSTUS_SPECIES_DIR}${gender}_"*))
		augustus_species=$(basename "${dir_arr[0]}")
	else
		#Nouvelle espece pour le training augustus
                #On ne met pas les parametre --busco_seed_species et --augustus_species
                #le nouveau training dataset sera ajouté dans /home/foueri01@inspq.qc.ca/InternetProgram/Quast_5_0_2/quast-5.0.2/quast_libs/augustus3.2.3/config/species
                #Le nom du repertoire sera la concatenation de l argument --species avec celui de --isolate
                augustus_species=""
	fi
}


for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
        SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))

	if [ ${#spec_arr[@]} -gt 0 ]
	        then
		
		funannotate_mask_base_cmd="funannotate mask --cpus 30 --repeatmasker_species fungi "
		funannotate_iprscan_base_cmd="sudo python $FUNANNOTATE_SCRIPT iprscan -m docker --cpus 30 "	
		funannotate_annotate_base_cmd="funannotate annotate --cpus 30"

		mkdir ${SLBIO_FUNANNOTATE_PATH}
		for spec in "${spec_arr[@]}"
                        do
			GetAugustusSpecies $spec
			if [ ${#augustus_species} -gt 0 ]
				then
				funannotate_predict_base_cmd="funannotate predict --cpus 30 --species \"$species\" --busco_seed_species $augustus_species --augustus_species $augustus_species "
			else
				funannotate_predict_base_cmd="funannotate predict --cpus 30 --species \"$species\" "
			
			fi
			fasta_in=${SLBIO_SPADES_FILTER_PATH}${spec}"_filter.fasta"
			cp $fasta_in ${SLBIO_FUNANNOTATE_PATH}
			fasta_in=${SLBIO_FUNANNOTATE_PATH}${spec}"_filter.fasta"
			sed -i -E 's/NODE_(.+)_length_(.+)/NODE_\1/g' $fasta_in

			#C est ok de mettre fungi pour --repeatmasker_species
			funannotate_mask_cmd=${funannotate_mask_base_cmd}" -i $fasta_in -o ${SLBIO_FUNANNOTATE_PATH}${spec}_filter_mask.fasta"
			funannotate_predict_cmd=${funannotate_predict_base_cmd}" -i ${SLBIO_FUNANNOTATE_PATH}${spec}_filter_mask.fasta -o ${SLBIO_FUNANNOTATE_PATH}${spec}_Results"
			funannotate_iprscan_cmd=${funannotate_iprscan_base_cmd}" -i ${SLBIO_FUNANNOTATE_PATH}${spec}_Results"
			funannotate_annotate_cmd=${funannotate_annotate_base_cmd}" -i ${SLBIO_FUNANNOTATE_PATH}${spec}_Results"
		
			#echo -e "${funannotate_mask_cmd}\n${funannotate_predict_cmd}\n${funannotate_iprscan_cmd}\n${funannotate_annotate_cmd}\n"

			echo -e "Funannotate pour ${spec}\t$(date "+%Y-%m-%d @ %H:%M$S")"   >> $SLBIO_LOG_FILE

			eval $funannotate_mask_cmd
			echo $funannotate_mask_cmd
			eval $funannotate_predict_cmd
		        echo $funannotate_predict_cmd
			eval $funannotate_iprscan_cmd
			sudo chmod 777 ${SLBIO_FUNANNOTATE_PATH}"${spec}_Results/annotate_misc" 
			eval $funannotate_annotate_cmd
	
		done
        fi
done
