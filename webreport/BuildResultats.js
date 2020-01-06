BuildResDiv = function(res_name, list_item,counter){
	
	var res_header = document.createElement("h3");
	res_header.innerHTML = counter + res_name; 
	var res_div = document.createElement("div");
	var res_ol = document.createElement("ol");
	var res_li;

	for(res_li in list_item){
		var new_res_li = document.createElement("li");

		var link = document.createElement("a");
		link.innerHTML = res_li;
		link.href = list_item[res_li];
		link.target = "_blank";

		new_res_li.appendChild(link);
		res_ol.appendChild(new_res_li)
	}
	res_div.appendChild(res_header);
	res_div.appendChild(res_ol);
	container_div.appendChild(res_div);
}



var container_div = document.getElementById("contenu");

function FastqQcResObj(url_before_clean,url_after_clean){
	this.res_name = " - Rapports contro&#770le de la qualite&#769 des reads";
	this.url_before_clean = url_before_clean;
	this.url_after_clean = url_after_clean;

	this.list_item = {"Avant nettoyage":this.url_before_clean,"Apre&#768s nettoyage":this.url_after_clean};
/*
	this.BuildResDiv = function(){
		
		var res_header = document.createElement("h2");
		res_header.innerHTML = this.res_name; 
		var res_div = document.createElement("div");
		var res_ol = document.createElement("ol");
		var res_li;

		for(res_li in this.list_item){
			var new_res_li = document.createElement("li");

			var link = document.createElement("a");
			link.innerHTML = res_li;
			link.href = this.list_item[res_li];
			link.target = "_blank";

			new_res_li.appendChild(link);
			res_ol.appendChild(new_res_li)
		}
		res_div.appendChild(res_header);
		res_div.appendChild(res_ol);
		container_div.appendChild(res_div);
	}
*/
}

function AssembResObj(url_assemb_brut,url_assemb_filter){
	this.res_name = " - Assemblages des ge&#769nomes";
	this.url_assemb_brut = url_assemb_brut;
	this.url_assemb_filter = url_assemb_filter; //todo dans ce repertoire il faut aussi mettre les fichiers _stat.txt
	this.list_item = {"Brutes":this.url_assemb_brut, "Filtre&#769s":this.url_assemb_filter};
}

function AssembQcResObj(url_qualimap,url_quast){
	this.res_name = " - Rapports contro&#770le de la qualite&#769 des assemblages";
	this.url_qualimap = url_qualimap;
	this.url_quast = url_quast;
	this.list_item = {"Qualimap":this.url_qualimap,"Quast":this.url_quast};

}

function BactAnnotResObj(url_annot){
	this.res_name = " - Annotation des ge&#769nomes bacte&#769riens";
	this.url_annot = url_annot;
	this.list_item = {"Fichiers GenBank":this.url_annot};

}

function MycAnnotResObj(url_annot){
	this.res_name = " - Annotation des ge&#769nomes de myce&#768tes";
	this.url_annot = url_annot;
	this.list_item = {"Fichiers GenBank":this.url_annot};
}

function EpidemioResObj(url_epidemio){
	this.res_name = " - Analyse e&#769pide&#769miologique";
	this.url_epidemio = url_epidemio;
	this.list_item = {"Core SNV":this.url_epidemio};	
}

function QiimeResObj(url_qiime){
	this.res_name = " - Analyse Qiime";
	this.url_qiime = url_qiime;
	this.list_item = {"Qiime":this.url_qiime};

}

function ClarkResObj(url_clark){
	this.res_name = " - Analyse Clark";
        this.url_clark = url_clark;
        this.list_item = {"Clark":this.url_clark};
}

function CentrifugeResObj(url_centrifuge){
	this.res_name = " - Analyse Centrifuge";
        this.url_centrifuge = url_centrifuge;
        this.list_item = {"Centrifuge":this.url_centrifuge};
}

function KrakenResObj(url_kraken){
	this.res_name = " - Analyse Kraken";
        this.url_kraken = url_kraken;
        this.list_item = {"Kraken":this.url_kraken};
}

function BasecvResObj(url_basecv){
        this.res_name = " - Analyse Basecv";
        this.url_basecv = url_basecv;
        this.list_item = {"Basecv":this.url_basecv};
}


var myFastqQcResObj;
var myAssembResObj;
var myAssembQcResObj;
var myBactAnnotResObj;
var myMycAnnotResObj;
var myEpidemioResObj;
var myQiimeResObj;
var myBasecvResObj;

var myClarkResObj;
var myCentrifugeResObj;
var myKrakenResObj;
//add object

var res_incr = 0;

if(myFastqQcResObj != undefined){

	res_incr += 1;
	//myFastqQcResObj.BuildResDiv();
	BuildResDiv(myFastqQcResObj.res_name, myFastqQcResObj.list_item,res_incr)
}

if(myAssembResObj != undefined){
	res_incr += 1;
	BuildResDiv(myAssembResObj.res_name, myAssembResObj.list_item,res_incr)
}

if(myAssembQcResObj != undefined){
	res_incr += 1;
	BuildResDiv(myAssembQcResObj.res_name, myAssembQcResObj.list_item,res_incr)
}
if(myBactAnnotResObj != undefined){
	res_incr += 1;
	BuildResDiv(myBactAnnotResObj.res_name, myBactAnnotResObj.list_item,res_incr)
}

if(myMycAnnotResObj != undefined){
	res_incr += 1;
	BuildResDiv(myMycAnnotResObj.res_name, myMycAnnotResObj.list_item,res_incr);
}

if(myEpidemioResObj != undefined){
	res_incr += 1;
	BuildResDiv(myEpidemioResObj.res_name, myEpidemioResObj.list_item, res_incr);
}

if(myQiimeResObj != undefined){
	res_incr += 1
	BuildResDiv(myQiimeResObj.res_name, myQiimeResObj.list_item,res_incr);
}

if(myBasecvResObj != undefined){
        res_incr += 1;
        BuildResDiv(myBasecvResObj.res_name, myBasecvResObj.list_item, res_incr);
}


if(myClarkResObj != undefined){
	res_incr += 1;
	BuildResDiv(myClarkResObj.res_name, myClarkResObj.list_item, res_incr);
}

if(myCentrifugeResObj != undefined){
	res_incr += 1;
	BuildResDiv(myCentrifugeResObj.res_name, myCentrifugeResObj.list_item, res_incr);
}

if(myKrakenResObj != undefined){
	res_incr += 1;
	BuildResDiv(myKrakenResObj.res_name, myKrakenResObj.list_item, res_incr);
}
