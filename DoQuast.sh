#!/bin/bash
<<HEADER
Eric Fournier 2019-08-15
Quast

HEADER

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"

echo "IN QUAST"


SetStaticPath
GetProjectsNamefromRunName

STEP="Qualimap"

QUAST_EXEC="quast.py "

for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))

	if [ ${#spec_arr[@]} -gt 0 ]
                then
                mkdir -p ${SLBIO_SPADES_QC_QUAST_PATH}
		quast_cmd_all="${QUAST_EXEC} -o ${SLBIO_SPADES_QC_QUAST_ALL} -t 40 ${SLBIO_SPADES_FILTER_PATH}"*".fasta 1>/dev/null"
	        #echo ${quast_cmd_all}
		eval ${quast_cmd_all}	
		
		for spec in "${spec_arr[@]}"
			do
			echo -e "Quast pour ${spec}\t$(date "+%Y-%m-%d @ %H:%M$S")" >> $SLBIO_LOG_FILE
			organism=$(sed -n "/$spec/p" ${SLBIO_PROJECT_PATH}${RUN_NAME}.csv.temp3 | awk 'BEGIN{FS=","}NR==1{print $11}')
			get_ref_cmd="/usr/bin/python2.7 $QUAST_REFERENCE_SCRIPT $SLBIO_RUN_PATH  $SLBIO_PROJECT_PATH $PARAM_FILE \"${organism}\" get 2>&1"
			ref_acc_microb_refpath=($(eval $get_ref_cmd))
                        acc=${ref_acc_microb_refpath[0]}
			microb=${ref_acc_microb__refpath[1]}
                        refpath=${ref_acc_microb_refpath[2]}

			if [ ${#acc} -eq 0 ]
				then
				mkdir ${SLBIO_SPADES_QC_QUAST_PATH}"$spec"
				missing_note_file=${SLBIO_SPADES_QC_QUAST_PATH}"${spec}/ReferenceMissing.txt"
				echo ${organism} > $missing_note_file
			else
				if grep -l "$acc" ${refpath}*".fna" 2>/dev/null  || grep -l "$acc" ${refpath}*".fa" 2>/dev/null || grep -l "$acc" ${refpath}*".fasta" 2>/dev/null 
					then
					ref_file=$(grep -l "$acc" ${refpath}{*.fna,*.fa,*.fasta} 2>/dev/null  | head -n 1)
				else
					ncbi-acc-download -m nucleotide -F fasta  -o  ${refpath}${acc}".fna"  $acc
					ref_file=${refpath}${acc}".fna"
				fi

				if [ "${microb}" = "fungus" ]
					then
					organism_parameter="--fungus"
				else
					organism_parameter=""
				fi
		
				quast_cmd_spec="${QUAST_EXEC} --silent  -o ${SLBIO_SPADES_QC_QUAST_PATH}${spec} -r ${ref_file} ${oganism_parameter} --glimmer --conserved-genes-finding -t 40 ${SLBIO_SPADES_FILTER_PATH}${spec}_filter.fasta 1>/dev/null"
				#echo "quast cmd is ${quast_cmd_spec}"
				eval ${quast_cmd_spec}
				report_file=${SLBIO_SPADES_QC_QUAST_PATH}${spec}"/report.txt"
				summary=${SLBIO_SPADES_QC_QUAST_PATH}${spec}"/report_summary.txt"
				sed -n '/^Assembly\|N50\|Genome fraction\|BUSCO/p' $report_file > $summary
			fi
		done
        fi

done
