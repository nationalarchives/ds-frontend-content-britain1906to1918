//check browser klee v1.0
css_NS4 = "../../css/ns4.css";
css_NS6 = "../../css/ns6.css";
css_IE4 = "../../css/ie4.css";
css_IE5 = "../../css/ie5.css";
if(document.layers){
   document.write("<link rel='stylesheet' href='" + css_NS4 + "' type='text/css'>");
}
if(document.all && !document.getElementById){
   document.write("<link rel='stylesheet' href='" + css_IE4 + "' type='text/css'>");
}
if(document.all && document.getElementById){
   document.write("<link rel='stylesheet' href='" + css_IE5 + "' type='text/css'>");
}
if(!document.all && document.getElementById){
   document.write("<link rel='stylesheet' href='" + css_NS6 + "' type='text/css'>");
}//check browser end