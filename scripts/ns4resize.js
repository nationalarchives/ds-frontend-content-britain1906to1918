//refresh NS4 when resized klee v1.0
function LC_reloadPage(init) {
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.LC_pgW=innerWidth; document.LC_pgH=innerHeight; onresize=LC_reloadPage; }}
  else if (innerWidth!=document.LC_pgW || innerHeight!=document.LC_pgH) location.reload();
}
LC_reloadPage(true);
// -->
//refresh the browser when resized klee v1.0