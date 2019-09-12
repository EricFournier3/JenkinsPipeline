var linkpage_map = {info:"Info.html", spec:"Specimens.html", proc:"Procedure.html", res:"Resultats.html"};
var attr_val = document.getElementById("headerjs").getAttribute("linkpage");
var linkpage = linkpage_map[attr_val];

var header_div = document.getElementsByClassName("header")[0];

var lspq_logo_div = document.createElement("div");
lspq_logo_div.id = "lspq_logo";
var h1_in_lspq_logo_div = document.createElement("h1");
h1_in_lspq_logo_div.id = "lspq";
h1_in_lspq_logo_div.innerHTML = "LSPQ";
var p1_in_lspq_logo_div = document.createElement("p");
p1_in_lspq_logo_div.className = "pheader";
p1_in_lspq_logo_div.innerHTML = "Laboratoire de sante&#769 publique du Que&#769bec";

var date_in_lspq_logo_div = document.createElement("p");
date_in_lspq_logo_div.id = "today";
date_in_lspq_logo_div.className = "pheader";
date_in_lspq_logo_div.innerHTML = new Date();

lspq_logo_div.appendChild(h1_in_lspq_logo_div);
lspq_logo_div.appendChild(p1_in_lspq_logo_div);
lspq_logo_div.appendChild(date_in_lspq_logo_div);

var bioinfo_logo_div = document.createElement("div");
bioinfo_logo_div.id = "bioinf_logo";
var p1_in_bioinfo_logo_div = document.createElement("p");
p1_in_bioinfo_logo_div.className = "pheader";
p1_in_bioinfo_logo_div.innerHTML = "Bioinformatique - Ge&#769nomique";
bioinfo_logo_div.appendChild(p1_in_bioinfo_logo_div);
var image_in_p1_in_bioinfo_logo_div = document.createElement("img");
image_in_p1_in_bioinfo_logo_div.id = "bioinficon";
image_in_p1_in_bioinfo_logo_div.src = "bioin_icon.png";
image_in_p1_in_bioinfo_logo_div.alt = "BioInf";
bioinfo_logo_div.appendChild(image_in_p1_in_bioinfo_logo_div);


header_div.appendChild(lspq_logo_div);
header_div.appendChild(bioinfo_logo_div);

var menu_ul = document.getElementsByClassName("menu")[0];

var li_1 = document.createElement("li");
var li_2 = document.createElement("li");
var li_3 = document.createElement("li");
var li_4 = document.createElement("li");
var li_5 = document.createElement("li");
li_5.id = "dropdownabout";

var a_1 = document.createElement("a");
a_1.href = "Info.html";
a_1.innerHTML = "Informations";

var a_2 = document.createElement("a");
a_2.href = "Specimens.html";
a_2.innerHTML = "Spe&#769cimens";

var a_3 = document.createElement("a");
a_3.href = "Procedure.html";
a_3.innerHTML = "Proce&#769dure";

var a_4 = document.createElement("a");
a_4.href = "Resultats.html";
a_4.innerHTML = "Re&#769sultats";


var a_5_1 = document.createElement("a");
a_5_1.href = "javascript:void(0)";
a_5_1.innerHTML = "&#192 propos";
a_5_1.id = "dropbtnabout";

li_1.appendChild(a_1);
li_2.appendChild(a_2);
li_3.appendChild(a_3);
li_4.appendChild(a_4);

switch (linkpage) {
 case "Info.html":
  a_1.className = "active";
  break;
 case "Specimens.html":
  a_2.className = "active";
  break;
 case "Procedure.html":
  a_3.className = "active";
  break;
 case "Resultats.html":
  a_4.className = "active";
  break;
 default:
  a_5_1.className = "active";
  break;

}


var a_5_2 = document.createElement("a");
a_5_2.href = "AboutEricFournier.html";
a_5_2.innerHTML = "Eric Fournier";

var a_5_3 = document.createElement("a");
a_5_3.href = "AboutSandrineMoreira.html";
a_5_3.innerHTML = "Sandrine Moreira";

var div_5 = document.createElement("div");
div_5.id = "dropdownabout-content";

div_5.appendChild(a_5_2);
div_5.appendChild(a_5_3);

li_5.appendChild(a_5_1);
li_5.appendChild(div_5);

menu_ul.appendChild(li_1);
menu_ul.appendChild(li_2);
menu_ul.appendChild(li_3);
menu_ul.appendChild(li_4);
menu_ul.appendChild(li_5);

