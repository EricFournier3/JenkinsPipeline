function SpecListObj(arr) {
	this.spec_arr = arr;
	
	this.nb_spec = function(){
	 return this.spec_arr.length;
	}
}

var container_div = document.getElementById("contenu");

var speclist_div = document.createElement("div");
speclist_div.id = "speclist";

var speclist_ol = document.createElement("ol");
speclist_ol.id = "speclist_ol";

speclist_div.appendChild(speclist_ol);

var title_h = document.createElement("h2");
title_h.innerHTML = "Liste des spe&#769cimens";
container_div.appendChild(title_h);

//new speclist

var spec;
for (spec of proj_spec_list_obj.spec_arr){
	var new_spec_item = document.createElement("li");
        new_spec_item.innerHTML = spec;
	speclist_ol.appendChild(new_spec_item);
}

container_div.appendChild(speclist_div);


