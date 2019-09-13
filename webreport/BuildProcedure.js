function CleanFastqObj(){
 this.procedure_name = "Nettoyage des reads";
 this.software = "Trimmomatic";
 this.software_url = "http://www.usadellab.org/cms/?page=trimmomatic";
 this.step1 = "Filter et supprimer les adapteurs dans les reads avec le programme ";
 this.steps = [this.step1];
}

function QcFastqObj(){
 this.procedure_name = "Contro&#770le de qualite&#769 des reads";
 this.software = "FastQC";
 this.software_url = "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/";
 this.step1 = "Analyse de la qualite&#769 <b>avant</b> le nettoyage";
 this.step2 = "Analyse de la qualite&#769 <b>apr&#768s</b> le nettoyage";
 this.steps = [this.step1, this.step2];
}

//var myobj = new QcFastqObj();
var myobj = new CleanFastqObj();

var container_div = document.getElementById("contenu");
var test_p = document.createElement("p");
container_div.appendChild(test_p);
test_p.innerHTML = myobj.procedure_name;
