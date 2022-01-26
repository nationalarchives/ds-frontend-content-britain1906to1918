//add hotkey klee v1.0 ;-)
var lcKeyArray = new Array('!','"','£','$','%','^','&','@','C','S','L');
var lcLocationArray = new Array('../g1/gallery1.htm','../g2/gallery2.htm','../g3/gallery3.htm','../g4/gallery4.htm','../g5/gallery5.htm','../g6/gallery6.htm','../g7/gallery7.htm','../default.htm','../credits/default.htm','../sitemap/default.htm','../links/default.htm');

function doHotKey(lc){
	for(i=0; i < lcKeyArray.length; i++){
		if(document.layers){ // NN4+ ;-)
			if (lcKeyArray[i] == String.fromCharCode(lc.which)){
				window.location = lcLocationArray[i];
			}
		} else if(document.all){ // IE4+ ;->
			if(lcKeyArray[i] == String.fromCharCode(event.keyCode)){
				window.location = lcLocationArray[i];
			}
		} else if(document.getElementById){ // NN6 :8)
			if(lcKeyArray[i] == String.fromCharCode(lc.which)){
				window.location = lcLocationArray[i];
			}
		}
	}
}
if(document.layers){
	document.captureEvents(Event.KEYPRESS);
}
document.onkeypress=doHotKey;