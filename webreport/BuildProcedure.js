function CleanFastqObj(){
 this.procedure_name = "Nettoyage des reads";
 this.software = "Trimmomatic";
 this.software_url = "http://www.usadellab.org/cms/?page=trimmomatic";
 this.step1 = "Filter et supprimer les adapteurs dans les reads";
 this.steps = [this.step1];
}

function QcFastqObj(){
 this.procedure_name = "Contro&#770le de la qualite&#769 des reads";
 this.software = "FastQC";
 this.software_url = "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/";
 this.step1 = "Analyse de la qualite&#769 <b>avant</b> le nettoyage";
 this.step2 = "Analyse de la qualite&#769 <b>apre&#768s</b> le nettoyage";
 this.steps = [this.step1, this.step2];
}

function AssemblyObj(){
 this.procedure_name = "Assemblage de ge&#769nomes";
 this.software = "Spades";
 this.software_url = "http://cab.spbu.ru/software/spades/";
 this.step1 = "Assemblage";
 this.step2 = "Filtration des contigs dont la longueur est infe&#769rieur a&#768 1000pb";
 this.step3 = "Calculer les statistiques d'assemblage";
 this.steps = [this.step1, this.step2, this.step3];
}

function AssemblyQCObj(){
 this.procedure_name = "Contro&#770le de la qualite&#769 des assemblages";
 this.software_1 = "Qualimap";
 this.software_1_url = "http://qualimap.bioinfo.cipf.es/";
 this.software_2 = "Quast";
 this.software_2_url = "http://quast.sourceforge.net/quast.html";
 this.steps = {"Evaluer les profondeurs de couverture avec ":{"prog":this.software_1,"url":this.software_1_url}, "Evaluer les distributions de longueurs de contigs avec ":{"prog":this.software_2,"url":this.software_2_url}};
}

function BactAnnotObj(){
 this.procedure_name = "Annotation des ge&#769nomes bacte&#769riens";
 this.software = "Prokka";
 this.software_url = "https://github.com/tseemann/prokka";
 this.step1 = "Annotation";
 this.steps = [this.step1];
}

function MycAnnotObj(){
 this.procedure_name = "Annotation des ge&#769nomes de myce&#768tes";
 this.software = "Funannotate";
 this.software_url = "https://funannotate.readthedocs.io/en/latest/#";
 this.step1 = "Annotation";
 this.steps = [this.step1];
}

function EpidemioObj(){
 this.procedure_name = "Analyse e&#769pide&#769miologie (Core SNV)";
 this.software_1 = "SNVPhyl";
 this.software_1_url = "https://snvphyl.readthedocs.io/en/v1.0/install/versions/";
 this.software_2 = "GrapeTree";
 this.software_2_url = "https://github.com/achtman-lab/GrapeTree";
 this.steps = {"Mapping des reads et construction du pseudo-alignement avec ":{"prog":this.software_1,"url":this.software_1_url}, "Construction et visualisation du Minimum Spanning Tree (MSP) avec ":{"prog":this.software_2,"url":this.software_2_url}};
}

function AssembResObj(){
 this.testing = "";

}


var myCleanFastqObj = new CleanFastqObj();
var myQcFastqObj = new QcFastqObj();
var myAssemblyObj;
var myAssemblyQCObj;
var myBactAnnotObj;
var myMycAnnotObj;
var myEpidemioObj;

var step_incr = 1;

var container_div = document.getElementById("contenu");

var fastq_cleaning_div = document.createElement("div");
var fastq_qc_div = document.createElement("div");
var assemb_div = document.createElement("div");
var assemb_qc_div = document.createElement("div");
var bact_annot_div = document.createElement("div");
var myc_annot_div = document.createElement("div");
var epidemio_div = document.createElement("div");

//add object

//Fastq Cleaning
var fastq_cleaning_header = document.createElement("h2");
var prog_link = document.createElement("a");
prog_link.href = myCleanFastqObj.software_url;
prog_link.target = "_blank";
prog_link.innerHTML = myCleanFastqObj.software;
fastq_cleaning_header.innerHTML = step_incr + " - " + myCleanFastqObj.procedure_name + " avec&nbsp";
fastq_cleaning_header.appendChild(prog_link);
var fastq_cleaning_ol = document.createElement("ol");
var fastq_cleaning_step;
for (fastq_cleaning_step of myCleanFastqObj.steps){
	var new_fastq_cleaning_step = document.createElement("li");
	new_fastq_cleaning_step.innerHTML = fastq_cleaning_step;
	fastq_cleaning_ol.appendChild(new_fastq_cleaning_step);	
}
fastq_cleaning_div.appendChild(fastq_cleaning_header);
fastq_cleaning_div.appendChild(fastq_cleaning_ol);
container_div.appendChild(fastq_cleaning_div);
step_incr += 1;

//Fastq QC
var fastq_qc_header = document.createElement("h2");
var prog_link = document.createElement("a");
prog_link.href = myQcFastqObj.software_url;
prog_link.target = "_blank";
prog_link.innerHTML = myQcFastqObj.software;
fastq_qc_header.innerHTML = step_incr + " - " + myQcFastqObj.procedure_name + " avec&nbsp";
fastq_qc_header.appendChild(prog_link);
var fastq_qc_ol = document.createElement("ol");
var fastq_qc_step;
for (fastq_qc_step of myQcFastqObj.steps){
	var new_fastq_qc_step = document.createElement("li");
	new_fastq_qc_step.innerHTML = fastq_qc_step;
	fastq_qc_ol.appendChild(new_fastq_qc_step);
}
fastq_qc_div.appendChild(fastq_qc_header);
fastq_qc_div.appendChild(fastq_qc_ol);
container_div.appendChild(fastq_qc_div);
step_incr += 1;


//Assembly
if (myAssemblyObj != undefined ){
	var assemb_header = document.createElement("h2");
	var prog_link = document.createElement("a");
	prog_link.href = myAssemblyObj.software_url;
	prog_link.target = "_blank";
	prog_link.innerHTML = myAssemblyObj.software;
	assemb_header.innerHTML = step_incr + " - " + myAssemblyObj.procedure_name + " avec&nbsp";
	assemb_header.appendChild(prog_link);
	var assemb_ol = document.createElement("ol");
	var assemb_step;
	for (assemb_step of myAssemblyObj.steps){
		var new_assemb_step = document.createElement("li");
		new_assemb_step.innerHTML = assemb_step;
		assemb_ol.appendChild(new_assemb_step);
	}
	assemb_div.appendChild(assemb_header);
	assemb_div.appendChild(assemb_ol);
	container_div.appendChild(assemb_div);
	step_incr += 1;
}


//Assembly QC
if (myAssemblyQCObj != undefined){
	var assemb_qc_header = document.createElement("h2");
        assemb_qc_header.innerHTML = step_incr + " - " + myAssemblyQCObj.procedure_name;
	var assemb_qc_ol = document.createElement("ol");
        var assemb_qc_step;
	
	for (assemb_qc_step in myAssemblyQCObj.steps){
		var new_assemb_qc_step = document.createElement("li");
		var prog_link = document.createElement("a");
		prog_link.href = myAssemblyQCObj.steps[assemb_qc_step]["url"];
		prog_link.target = "_blank";
		prog_link.innerHTML = myAssemblyQCObj.steps[assemb_qc_step]["prog"];
		new_assemb_qc_step.innerHTML = assemb_qc_step;
		new_assemb_qc_step.appendChild(prog_link);
		assemb_qc_ol.appendChild(new_assemb_qc_step);
	}
	assemb_qc_div.appendChild(assemb_qc_header);
	assemb_qc_div.appendChild(assemb_qc_ol);
	container_div.appendChild(assemb_qc_div);
	step_incr += 1;
	
}

//Annotation Bact
if (myBactAnnotObj != undefined){
	var bact_annot_header = document.createElement("h2");
	var prog_link = document.createElement("a");
	prog_link.href = myBactAnnotObj.software_url;
	prog_link.target = "_blank";
	prog_link.innerHTML = myBactAnnotObj.software;
	bact_annot_header.innerHTML = step_incr + " - " + myBactAnnotObj.procedure_name + " avec&nbsp";
	bact_annot_header.appendChild(prog_link);
	var bact_annot_ol = document.createElement("ol");
	var bact_annot_step;

	for (bact_annot_step of myBactAnnotObj.steps){
		var new_bact_annot_step = document.createElement("li");
		new_bact_annot_step.innerHTML = bact_annot_step;
		bact_annot_ol.appendChild(new_bact_annot_step);
	}
	bact_annot_div.appendChild(bact_annot_header);
	bact_annot_div.appendChild(bact_annot_ol);
	container_div.appendChild(bact_annot_div);
	step_incr += 1;
}

//Annotation Myc
if (myMycAnnotObj != undefined){
	var myc_annot_header = document.createElement("h2");
	var prog_link = document.createElement("a");
        prog_link.href = myMycAnnotObj.software_url;
        prog_link.target = "_blank";
	prog_link.innerHTML = myMycAnnotObj.software;
	myc_annot_header.innerHTML = step_incr + " - " + myMycAnnotObj.procedure_name + " avec&nbsp";
	myc_annot_header.appendChild(prog_link);
	var myc_annot_ol = document.createElement("ol");
	var myc_annot_step;

	for(bact_annot_step of myMycAnnotObj.steps){
		var new_myc_annot_step = document.createElement("li");
		new_myc_annot_step.innerHTML = bact_annot_step;
		myc_annot_ol.appendChild(new_myc_annot_step);
	}
	myc_annot_div.appendChild(myc_annot_header);
	myc_annot_div.appendChild(myc_annot_ol);
	container_div.appendChild(myc_annot_div);
	step_incr += 1;
	
}

//Epidemio
if (myEpidemioObj != undefined){
	var epidemio_header = document.createElement("h2");
	epidemio_header.innerHTML = step_incr + " - " + myEpidemioObj.procedure_name;
	var epidemio_ol = document.createElement("ol");
	var epidemio_step;

	for (epidemio_step in myEpidemioObj.steps){
		var new_epidemio_step = document.createElement("li");	
		var prog_link = document.createElement("a");
		prog_link.href = myEpidemioObj.steps[epidemio_step]["url"];
		prog_link.target = "_blank";
		prog_link.innerHTML = myEpidemioObj.steps[epidemio_step]["prog"];
		new_epidemio_step.innerHTML = epidemio_step;
		new_epidemio_step.appendChild(prog_link);
		epidemio_ol.appendChild(new_epidemio_step);
	}
	epidemio_div.appendChild(epidemio_header);
	epidemio_div.appendChild(epidemio_ol);
	container_div.appendChild(epidemio_div);
	step_incr += 1;
}

//var myobj = new QcFastqObj();
//var myobj = new CleanFastqObj();
//var container_div = document.getElementById("contenu");
//var test_p = document.createElement("p");
//container_div.appendChild(test_p);
//test_p.innerHTML = myobj.procedure_name;
