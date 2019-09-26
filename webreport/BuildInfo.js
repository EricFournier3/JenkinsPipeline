var container_div = document.getElementById("contenu");

var run_name_h = document.createElement("h4");
run_name_h.innerHTML = "Nom de la run: " + "<span style=\"font-weight:normal\">" + run_name + "</span>";

var project_name_h = document.createElement("h4");
project_name_h.innerHTML = "Nom du projet: " + "<span style=\"font-weight:normal\">" + project_name + "</span>";

var project_desc_h = document.createElement("h4");
project_desc_h.innerHTML = "Description:";
var project_desc_p = document.createElement("p");
project_desc_p.innerHTML = project_desc;

container_div.appendChild(run_name_h);
container_div.appendChild(project_name_h);
container_div.appendChild(project_desc_h);
container_div.appendChild(project_desc_p);



