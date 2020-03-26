#!/bin/bash

<<HEADER
Eric Fournier 2019-09-25

Web reports

HEADER

#RUN_NAME="77777777_test2-test3"

source "/data/Applications/GitScript/Jenkins/SetPath.sh"
SetStaticPath
GetProjectsNamefromRunName

BuildProjectDesc(){

	dos2unix $desc_file > /dev/null 2>&1
	sed -i '$a\' $desc_file

	while read myline
		do
		PROJECT_DESC+=${myline}"<br/>"
	done < $desc_file

}

ImportWebFiles(){
        webfiles_basedir="/data/Applications/GitScript/Jenkins/webreport/"
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
        nb_spec=${#proj_spec_arr[@]}

        for spec in ${proj_spec_arr[@]}
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

	if [ -d ${SLBIO_QIIME_PATH} ]
		then
		sed -i "/add object/a  myQiimeObj = new QiimeObj();" $build_procedure_slbio_js_path
	fi
	
	if [ -d ${SLBIO_METAGENOMIC_SHOTGUN_PATH} ]
		then
		sed -i "/add object/a  myKrakenObj = new KrakenObj();" $build_procedure_slbio_js_path
		sed -i "/add object/a  myCentrifugeObj = new CentrifugeObj();" $build_procedure_slbio_js_path
		sed -i "/add object/a  myClarkObj = new ClarkObj();" $build_procedure_slbio_js_path

	fi
		
}

BuildResult(){
	sed -i 's/linkpage=\"\"/linkpage=\"res\"/' $resultats_slbio_html
	sed -i '/<\/body>/i <script id="buildresultjs" src="BuildResultats.js"> </script>' $resultats_slbio_html
	LSPQ_MISEQ_PROJECT_ANALYSES_PATH=${LSPQ_MISEQ_ANALYSES_PATH}${PROJECT_NAME}"/"
	LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE=${LSPQ_MISEQ_ANALYSE_PATH_FROM_SPARTAGE}${PROJECT_NAME}"\\\\"
	
	sed -i "1i var project_analysis_basedir = \"$LSPQ_MISEQ_PROJECT_ANALYSES_PATH\";" $build_resultats_slbio_js_path


	if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1} ]
          then
	  sudo mkdir ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1}
        fi
	sudo cp ${SLBIO_FASTQC_BRUT_PATH}*".html" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_1}

        if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_2} ]
          then
	  sudo mkdir ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FASTQC_2}
        fi
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

                if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_BRUT} ]
                  then
         	  sudo mkdir -p  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_BRUT}
                fi

		for subdir in $(ls -d ${SLBIO_SPADES_BRUT_PATH}*)
			do
			spec=$(basename $subdir)
			sudo cp ${subdir}"/contigs.fasta"  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_BRUT}"${spec}.fasta"
		done

		if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER} ]
                  then
                  sudo mkdir -p  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER}
                fi
		sudo cp ${SLBIO_SPADES_FILTER_PATH}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_FILTER}		

		if [ ! ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUALIMAP} ]
                  then 
		  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUALIMAP}
                fi

		for subdir in $(ls -d ${SLBIO_SPADES_QC_QUALIMAP_PATH}*)
			do
			spec=$(basename $subdir)
			sudo cp ${SLBIO_SPADES_QC_QUALIMAP_PATH}${spec}"/report.pdf" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUALIMAP}"${spec}.pdf"  
			
		done

                if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUAST} ]
                  then
		  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_SPADES_QC_QUAST}
                fi
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

		if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_PROKKA} ]
                  then
 		  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_PROKKA}
                fi
		sudo cp ${SLBIO_PROKKA_PATH}*"/"*".gbk" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_PROKKA}
		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_PROKKA}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}
		sed -i "/add object/a myBactAnnotResObj = new BactAnnotResObj(\"${path_1}\");"  $build_resultats_slbio_js_path
	fi	

	if [ -d ${SLBIO_FUNANNOTATE_PATH} ] 
		then

		if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FUNANNOTATE} ]
                  then
		  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_FUNANNOTATE}
		fi

		for specs_dir in $(ls -d "${SLBIO_FUNANNOTATE_PATH}"*"/")
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

                if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CORESNV} ]
                  then
            	  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CORESNV}
                fi
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

	if [ -d ${SLBIO_QIIME_PATH} ]
		then

                if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_QIIME} ]
                  then
            	  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_QIIME}
                fi

		sudo cp ${SLBIO_QIIME_PATH}*.qza ${SLBIO_QIIME_PATH}*.qzv ${SLBIO_QIIME_PATH}*.txt  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_QIIME} 2>/dev/null

		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_QIIME}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}

		sed -i "/add object/a myQiimeResObj = new QiimeResObj(\"${path_1}\");" $build_resultats_slbio_js_path
	fi

	if [ -d ${SLBIO_METAGENOMIC_SHOTGUN_PATH} ]
		then

		if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_KRAKEN} ]
		  then
		  sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_KRAKEN}  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CENTRIFUGE}  ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CLARK}
                fi    

		sudo cp ${SLBIO_KRAKEN_PATH}"Report_"* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_KRAKEN}	
		sudo cp ${SLBIO_CENTRIFUGE_PATH}*"_ClassificationResult_Kraken.txt" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CENTRIFUGE}
		sudo cp ${SLBIO_CLARK_PATH}*".html" ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_CLARK}

		path_1=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_KRAKEN}
		path_1=${path_1//\//\\\\}
                path_1=${path_1//\\/\\\\}

		sed -i "/add object/a myKrakenResObj = new KrakenResObj(\"${path_1}\");" $build_resultats_slbio_js_path

		path_2=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_CENTRIFUGE}
		path_2=${path_2//\//\\\\}
                path_2=${path_2//\\/\\\\}

		sed -i "/add object/a myCentrifugeResObj = new CentrifugeResObj(\"${path_2}\");" $build_resultats_slbio_js_path

		path_3=${LSPQ_MISEQ_PROJECT_ANALYSES_PATH_FROM_SPARTAGE}${SLBIO_CLARK}
		path_3=${path_3//\//\\\\}
                path_3=${path_3//\\/\\\\}

		sed -i "/add object/a myClarkResObj = new ClarkResObj(\"${path_3}\");" $build_resultats_slbio_js_path
	fi
	
}

TransferWebFiles(){

        if [ ! -d ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT} ]
          then
          sudo mkdir -p ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT}
        fi
	sudo cp ${SLBIO_WEBREPORT_PATH}* ${LSPQ_MISEQ_PROJECT_ANALYSES_PATH}${SLBIO_WEBREPORT}
}


BuildSpecimensList(){
	proj_spec_arr=()

	for id_list_file in $(ls -1 ${SLBIO_PROJECT_PATH}ID_list_C*);
          do
		for sp in $(awk '{print $1}' ${id_list_file})
			do
			proj_spec_arr+=($sp)
		done
        done

}



BuildSpecimensListOBSOLETE(){
	proj_spec_arr=()

	for sp in $(awk 'BEGIN{FS=","}NR>1{print $1}' $SAMPLE_SHEET)
		do
		proj_spec_arr+=($sp)
	done
}

		
ImportProjDescFromLspqMiSeq(){
	cp $LSPQ_MISEQ_PROJ_DESC_PATH ${SLBIO_WEBREPORT_PATH}
}


for proj in "${projects_list[@]}"

        do
        PROJECT_NAME=$proj
        SetFinalPath $PROJECT_NAME
	SAMPLE_SHEET=$(cat ${SLBIO_PROJECT_PATH}"CurrentSampleSheetName.txt")

	PROJECT_DESC=""
	BuildSpecimensList 

	if [ ${#proj_spec_arr[@]} -gt 0 ]
		then
		if [ -s $LSPQ_MISEQ_PROJ_DESC_PATH ]
			then
			desc_file=${SLBIO_WEBREPORT_PATH}${PROJECT_NAME}"_desc.txt"
			ImportProjDescFromLspqMiSeq
			BuildProjectDesc
		else
			PROJECT_DESC="Aucune description"        	
		fi

		ImportWebFiles
		BuildInfo
		BuildSpecimen
		BuildAbout
		BuildProcedure
		BuildResult
		TransferWebFiles
	fi
done


		


