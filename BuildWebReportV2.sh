#!/bin/bash

<<HEADER
Eric Fournier 2019-09-25

Web reports

HEADER

source "/home/foueri01@inspq.qc.ca/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

STEP="WebReport"

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
        nb_spec=${#spec_arr[@]}

        for spec in ${spec_arr[@]}
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
	sed -i 's/linkpage=\"\"/linkpage=\"res\"/' $resultats_slbio_html
	sed -i '/<\/body>/i <script id="buildresultjs" src="BuildResultats.js"> </script>' $resultats_slbio_html
	LSPQ_MISEQ_PROJECT_ANALYSES_PATH=${LSPQ_MISEQ_ANALYSES_PATH}${PROJECT_NAME}"/"
	LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_ANALYSE_PATH_FROM_SPARTAGE}${PROJECT_NAME}"\\\\"
	
	sed -i "1i var project_analysis_basedir = \"$LSPQ_MISEQ_PROJECT_ANALYSES_PATH\";" $build_resultats_slbio_js_path

	sudo mkdir ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1}
	sudo cp ${SLBIO_FASTQC_BRUT_PATH}*".html" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1}
	sudo mkdir ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_2}
	sudo cp ${SLBIO_FASTQC_TRIMMO_PATH}*".html" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_2}
	path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_FASTQC_1}
	path_1=${path_1//\//\\\\}
	path_1=${path_1//\\/\\\\}
	
	path_2=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_FASTQC_2}
	path_2=${path_2//\//\\\\}
	path_2=${path_2//\\/\\\\}
	
	sed -i "/add object/a  myFastqQcResObj = new FastqQcResObj(\"${path_1}\",\"${path_2}\");" $build_resultats_slbio_js_path
	
	if [ -d ${SLBIO_SPADES_PATH} ]
		then
		:
		sudo mkdir -p  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_BRUT}

		for subdir in $(ls -d ${SLBIO_SPADES_BRUT_PATH}*)
			do
			spec=$(basename $subdir)
			sudo cp ${subdir}"/contigs.fasta"  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_BRUT}"${spec}.fasta"
		done

		sudo mkdir -p  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER}
		sudo cp ${SLBIO_SPADES_FILTER_PATH}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER}		

		sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUALIMAP}

		for subdir in $(ls -d ${SLBIO_SPADES_QC_QUALIMAP_PATH}*)
			do
			spec=$(basename $subdir)
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
		sudo cp ${SLBIO_PROKKA_PATH}*"/"*".gbk" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_PROKKA}
		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_PROKKA}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myBactAnnotResObj = new BactAnnotResObj(\"${path_1}\");"  $build_resultats_slbio_js_path
	fi	

	if [ -d ${SLBIO_FUNANNOTATE_PATH} ] 
		then
		sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FUNANNOTATE}

		for specs_dir in $(ls -d ${SLBIO_FUNANNOTATE_PATH}*)
			do
			spec=$(basename $specs_dir)
			spec=$(echo $spec | cut -d '_' -f 1)
			sudo cp ${specs_dir}"/annotate_results/"*".gbk" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FUNANNOTATE}"${spec}.gbk"
		done

		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_FUNANNOTATE}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myMycAnnotResObj = new MycAnnotResObj(\"${path_1}\");" $build_resultats_slbio_js_path
	fi

	if [ -d ${SLBIO_CORESNV_PATH} ]
		then
		:
            	sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CORESNV}
		sudo cp ${SLBIO_CORESNV_PATH}*".json" ${SLBIO_CORESNV_PATH}*".txt" ${SLBIO_CORESNV_PATH}*".nwk" ${SLBIO_CORESNV_PATH}*".newick" ${SLBIO_CORESNV_PATH}*".phy"  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CORESNV} 2>/dev/null 

		for tsv_file in $(ls ${SLBIO_CORESNV_PATH}*".tsv")
			do
			tsv=$(basename $tsv_file)
			sudo cp $tsv_file ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CORESNV}${tsv}".txt"
		done

		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_CORESNV}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myEpidemioResObj = new EpidemioResObj(\"${path_1}\");" $build_resultats_slbio_js_path
	fi
	
}

TransferWebFiles(){
        sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT}
	sudo cp ${SLBIO_WEBREPORT_PATH}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT}
}

for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
        SAMPLE_SHEET="${SLBIO_PROJECT_PATH}"*".temp3"
        spec_arr=($(/usr/bin/python2.7 $GET_SPECIMENS_SCRIPT  $PARAM_FILE  $SAMPLE_SHEET $STEP  2>&1))

	if [ ${#spec_arr[@]} -gt 0 ]
        	then
		ImportWebFiles
		BuildInfo
		BuildSpecimen
		BuildAbout
		BuildProcedure
		BuildResult
		TransferWebFiles
	fi
done


		

