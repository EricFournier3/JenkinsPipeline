
BuildResDiv = function(res_name, list_item){
	
	var res_header = document.createElement("h2");
	res_header.innerHTML = res_name; 
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

//code here
//document.getElementById("mytest").innerHTML = project_analysis_basedir;
//
//


var res_incr = 1;
var container_div = document.getElementById("contenu");

function FastqQcResObj(url_before_clean,url_after_clean){
	this.res_name = res_incr + " - Rapport contro&#770le de la qualite&#769";
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

var myFastqQcResObj;


//add object


if(myFastqQcResObj != undefined){

	//myFastqQcResObj.BuildResDiv();
	BuildResDiv(myFastqQcResObj.res_name, myFastqQcResObj.list_item)
	
}
