#!/bin/bash

<<HEADER
Eric Fournier 2019-09-13

Web Report

HEADER

RUN_NAME="88888888_test1"
PROJECT_NAME="test1"
PROJECT_DESC="Decrire le project ici"
SPEC_LIST=("MySpec_1" "MySpec_2" "MySpec_3")

PARAM_FILE="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/JenkinsParameter.yaml"
GET_PARAM_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/GetJenkinsParamVal.py"
RUN_QUAL_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/MiSeqRunQuality/MiSeqStat7.py"
GET_SPECIMENS_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/GetSpecimensForTask.py"
COMPUTE_SAMPLE_COVERAGE_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/MiSeqRunQuality/ComputeExpectedGenomesCoverage.py"
CORESNV_REFERENCE_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/CheckCoreSnvReference.py"
QUAST_REFERENCE_SCRIPT="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/CheckQuastReference.py"
CORESNV_EXEC="/home/foueri01@inspq.qc.ca/InternetProgram/SNVPhyl_CLI/snvphyl-galaxy-cli/bin/snvphyl.py"
POSITION2PHYLOVIZ_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/SNVPhyl_CLI/PerlScript/positions2phyloviz.pl"
FUNANNOTATE_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/Funannotate/funannotate/funannotate.py"
GRAPETREE_SCRIPT="/home/foueri01@inspq.qc.ca/InternetProgram/GrapeTree/GrapeTree/grapetree.py"

SetStaticPath(){

        path_arr=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  path  2>&1))
        LSPQ_MISEQ_BASE_PATH=${path_arr[0]}"/"
        SLBIO_BASE_PATH=${path_arr[1]}"/"
        GITSCRIPT_BASE_PATH=${path_arr[2]}"/"
	LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE=${path_arr[3]}"\\\\"
	#echo $LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE

	
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
        SLBIO_LOG=${slbio_subdir_arr[13]}"/"
	SLBIO_WEBREPORT=${slbio_subdir_arr[14]}"/"
        GENOME_LENGTH_FILE=($(/usr/bin/python2.7 $GET_PARAM_SCRIPT  $PARAM_FILE  genome_length_file  2>&1))
}


SetFinalPath(){
        LSPQ_MISEQ_RUN_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}/
	LSPQ_MISEQ_RUN_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_BASE_PATH_FROM_SPARTAGE}${RUN_NAME}"\\\\"
	LSPQ_MISEQ_ANALYSES_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_ANALYSES}
	LSPQ_MISEQ_ANALYSE_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_RUN_PATH_FROM_SPARTAGE}${LSPQ_ANALYSES}
        LSPQ_MISEQ_SAMPLESHEET_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_EXPERIMENTAL}"${RUN_NAME}.csv"
        LSPQ_MISEQ_FASTQ_PATH=${LSPQ_MISEQ_RUN_PATH}${LSPQ_MISEQ_SEQ_BRUT}
        LSPQ_MISEQ_RUNQUALFILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/"${LSPQ_MISEQ_MISEQ_RUN_TRACE}"MiSeqStat_"*

        SLBIO_RUN_PATH=${SLBIO_BASE_PATH}"$RUN_NAME/"
#	echo SLBIO_BASE_PATH $SLBIO_BASE_PATH
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
        SLBIO_LOG_PATH=${SLBIO_PROJECT_PATH}${SLBIO_LOG}
        SLBIO_LOG_FILE=${SLBIO_LOG_PATH}"JenkinsLog.log"
        LSPQ_MISEQ_SAMPLE_LIST_TO_ADD_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/1_Experimental/CoreSnvSamplesToAdd_"${RUN_NAME}"_${PROJECT_NAME}.txt"
        LSPQ_MISEQ_CORESNV_METADATA_FILE_PATH=${LSPQ_MISEQ_BASE_PATH}${RUN_NAME}"/1_Experimental/CoreSnvMetadata_"${RUN_NAME}"_${PROJECT_NAME}.txt"
	SLBIO_WEBREPORT_PATH=${SLBIO_PROJECT_PATH}${SLBIO_WEBREPORT}
}

ImportWebFiles(){
	webfiles_basedir="/home/foueri01@inspq.qc.ca/GitScript/Jenkins/webreport/"
	build_header_js_path="${webfiles_basedir}BuildHeader.js"
	build_info_js_path="${webfiles_basedir}BuildInfo.js"
	build_procedure_js_path="${webfiles_basedir}BuildProcedure.js"
	build_resultats_js_path="${webfiles_basedir}BuildResultats.js"
	build_specimens_js_path="${webfiles_basedir}BuildSpecimens.js"
	build_aboutsam_js_path="${webfiles_basedir}BuildAboutSandrineMoreira.js"
	build_aboutef_js_path="${webfiles_basedir}BuildAboutEricFournier.js"
	header_css_path="${webfiles_basedir}Header.css"
	bioinfo_icon_png="${webfiles_basedir}bioin_icon.png"
	webfiles_arr=($about_ef_path $about_ef_path $about_sam_path $build_header_js_path $build_info_js_path $build_procedure_js_path $build_resultats_js_path $build_specimens_js_path $header_css_path  $bioinfo_icon_png $build_aboutsam_js_path $build_aboutef_js_path)

	for webfile in ${webfiles_arr[@]}
	 do
	  :
	  #echo $webfile
	  #echo $SLBIO_WEBREPORT_PATH
          #echo "***"
	  cp $webfile $SLBIO_WEBREPORT_PATH	
	done
		
	template_html="${webfiles_basedir}template.html"
        info_slbio_html=${SLBIO_WEBREPORT_PATH}"Info.html"
	procedure_slbio_html=${SLBIO_WEBREPORT_PATH}"Procedure.html"
	resultats_slbio_html=${SLBIO_WEBREPORT_PATH}"Resultats.html"
	specimens_slbio_html=${SLBIO_WEBREPORT_PATH}"Specimens.html"
	about_ef_slbio_html=${SLBIO_WEBREPORT_PATH}"AboutEricFournier.html"
	about_sam_slbio_html=${SLBIO_WEBREPORT_PATH}"AboutSandrineMoreira.html"
	
	htmlfiles_arr=($info_slbio_html $procedure_slbio_html $resultats_slbio_html $specimens_slbio_html $about_ef_slbio_html $about_sam_slbio_html)

	for htmlfile in ${htmlfiles_arr[@]}
	 do
	 :
	 cp $template_html $htmlfile
	done 

	build_info_slbio_js_path="${SLBIO_WEBREPORT_PATH}BuildInfo.js"
        build_procedure_slbio_js_path="${SLBIO_WEBREPORT_PATH}BuildProcedure.js"
        build_resultats_slbio_js_path="${SLBIO_WEBREPORT_PATH}BuildResultats.js"
        build_specimens_slbio_js_path="${SLBIO_WEBREPORT_PATH}BuildSpecimens.js"

}

BuildInfo(){
	sed -i 's/linkpage=\"\"/linkpage=\"info\"/' $info_slbio_html
	sed -i '/<\/body>/i <script id="buildinfojs" src="BuildInfo.js"> </script>' $info_slbio_html

	sed -i "1i var run_name = \"$RUN_NAME\";" $build_info_slbio_js_path
	sed -i "1i var project_name = \"$PROJECT_NAME\";" $build_info_slbio_js_path
	sed -i "1i var project_desc = \"$PROJECT_DESC\";" $build_info_slbio_js_path
}

BuildSpecimen(){
	sed -i 's/linkpage=\"\"/linkpage=\"spec\"/' $specimens_slbio_html
	sed -i '/<\/body>/i <script id="buildspecimenjs" src="BuildSpecimens.js"> </script>' $specimens_slbio_html
	
	spec_arg=""

        spec_inc=0
	nb_spec=${#SPEC_LIST[@]}
        
	for spec in ${SPEC_LIST[@]}
	 do
	 ((++spec_inc))  
         if [ $spec_inc -ne $nb_spec ]
	  then
           spec_arg+="\""${spec}"\", "
	  else
	   spec_arg+="\""${spec}"\""     
 	 fi 
	done

	sed -i "/new speclist/a var proj_spec_list_obj = new SpecListObj([${spec_arg}]);" $build_specimens_slbio_js_path
	
}

BuildAbout(){
	sed -i 's/linkpage=\"\"/linkpage=\"aboutericf\"/' $about_ef_slbio_html
	sed -i '/<\/body>/i <script id="buildaboutefjs" src="BuildAboutEricFournier.js"> </script>' $about_ef_slbio_html

	sed -i 's/linkpage=\"\"/linkpage=\"aboutsam\"/' $about_sam_slbio_html
	sed -i '/<\/body>/i <script id="buildaboutsamjs" src="BuildAboutSandrineMoreira.js"> </script>' $about_sam_slbio_html
}

BuildProcedure(){
 	sed -i 's/linkpage=\"\"/linkpage=\"proc\"/' $procedure_slbio_html
        sed -i '/<\/body>/i <script id="buildprocedurejs" src="BuildProcedure.js"> </script>' $procedure_slbio_html

	if [ -d ${SLBIO_SPADES_PATH} ]
		then
		sed -i "/add object/a  myAssemblyObj = new AssemblyObj();\nvar myAssemblyQCObj = new AssemblyQCObj();" $build_procedure_slbio_js_path
	fi

	if [ -d ${SLBIO_PROKKA_PATH} ]
		then
		sed -i "/add object/a  myBactAnnotObj = new BactAnnotObj();" $build_procedure_slbio_js_path
	fi
	
	if [ -d ${SLBIO_FUNANNOTATE_PATH} ]
		then
		sed -i "/add object/a  myMycAnnotObj = new MycAnnotObj();" $build_procedure_slbio_js_path
	fi

	if [ -d ${SLBIO_CORESNV_PATH} ]
		then
		sed -i "/add object/a  myEpidemioObj = new EpidemioObj();" $build_procedure_slbio_js_path
	fi
}


BuildResult(){
	#echo "In BuildResult"
	sed -i 's/linkpage=\"\"/linkpage=\"res\"/' $resultats_slbio_html
	sed -i '/<\/body>/i <script id="buildresultjs" src="BuildResultats.js"> </script>' $resultats_slbio_html
	LSPQ_MISEQ_PROJECT_ANALYSES_PATH=${LSPQ_MISEQ_ANALYSES_PATH}${PROJECT_NAME}"/"
	LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_ANALYSE_PATH_FROM_SPARTAGE}${PROJECT_NAME}"\\\\"
	
	#SUPPRIMER LA LIGNE SUIVANTE CAR PLUS NECESSAIRE
	#LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE//\//\\\\}


	sed -i "1i var project_analysis_basedir = \"$LSPQ_MISEQ_PROJECT_ANALYSES_PATH\";" $build_resultats_slbio_js_path

	sudo mkdir ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1}
	sudo cp ${SLBIO_FASTQC_BRUT_PATH}*".html" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1}
	sudo mkdir ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_2}
	sudo cp ${SLBIO_FASTQC_TRIMMO_PATH}*".html" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_2}
	path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_FASTQC_1}
	#echo "before $path_1"
	path_1=${path_1//\//\\\\}
	path_1=${path_1//\\/\\\\}
	#echo "after $path_1"

	path_2=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_FASTQC_2}
	path_2=${path_2//\//\\\\}
	path_2=${path_2//\\/\\\\}
	
	sed -i "/add object/a  myFastqQcResObj = new FastqQcResObj(\"${path_1}\",\"${path_2}\");" $build_resultats_slbio_js_path
	
	#echo "MY PAPTH IS $LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE"	

	if [ -d ${SLBIO_SPADES_PATH} ]
		then
		:
		sudo mkdir -p  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_BRUT}
		sudo mkdir -p  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER}
		sudo cp ${SLBIO_SPADES_FILTER_PATH}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER}		

		sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUALIMAP}

		for subdir in $(ls -d ${SLBIO_SPADES_QC_QUALIMAP_PATH}*)
			do
			spec=$(basename $subdir)
			#echo "spec is $spec"
			sudo cp ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}"/report.pdf" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUALIMAP}"${spec}.pdf"  
			
		done

		sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUAST}
		sudo cp -r ${SLBIO_SPADES_QC_QUAST_ALL}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUAST} 2>/dev/null

		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_SPADES_BRUT}
		path_1=${path_1//\//\\\\}
	        path_1=${path_1//\\/\\\\}
		
		path_2=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_SPADES_FILTER}
		path_2=${path_2//\//\\\\}
	        path_2=${path_2//\\/\\\\}

		path_3=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_SPADES_QC_QUALIMAP}
		path_3=${path_3//\//\\\\}
        	path_3=${path_3//\\/\\\\}

		path_4=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_SPADES_QC_QUAST}
		path_4=${path_4//\//\\\\}
        	path_4=${path_4//\\/\\\\}

		sed -i "/add object/a myAssembResObj = new AssembResObj(\"${path_1}\",\"${path_2}\");"  $build_resultats_slbio_js_path

		sed -i "/add object/a myAssembQcResObj = new AssembQcResObj(\"${path_3}\",\"${path_4}\");"  $build_resultats_slbio_js_path
	fi

	 if [ -d ${SLBIO_PROKKA_PATH} ]
		then
		sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_PROKKA}
		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_PROKKA}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myBactAnnotResObj = new BactAnnotResObj(\"${path_1}\");"  $build_resultats_slbio_js_path
	fi	

	if [ -d ${SLBIO_FUNANNOTATE_PATH} ] 
		then
		sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FUNANNOTATE}
		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_PROKKA}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myMycAnnotResObj = new MycAnnotResObj(\"${path_1}\");" $build_resultats_slbio_js_path
	fi

	if [ -d ${SLBIO_CORESNV_PATH} ]
		then
		:
            	sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CORESNV}
		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_CORESNV}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myEpidemioResObj = new EpidemioResObj(\"${path_1}\");" $build_resultats_slbio_js_path
	fi
	
}

TransferWebFiles(){
	echo "in TransferWebFiles"
        sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT}
	sudo cp ${SLBIO_WEBREPORT_PATH}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT}
}


SetStaticPath
SetFinalPath

ImportWebFiles
BuildInfo
BuildSpecimen
BuildAbout
BuildProcedure
BuildResult
TransferWebFiles
