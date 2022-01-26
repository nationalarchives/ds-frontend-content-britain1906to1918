//dynamic menu for Learning Curve (lc) - 3Cs klee v1.0
//3Cs klee v1.1 fix on Opera5 and NS7 and IE cell layer.
function lcLoadMenus() {
  if (window.lc_menu_0) return;
  window.lc_menu_0 = new Menu("root",148,19,"Verdana, Arial, Helvetica, sans-serif",12,"#336600","#ffffff","#ffffff","#336600","left","middle",0,0,1000,0,0,true,true,true,15,true,true);
  lc_menu_0.addMenuItem("source&nbsp;1","location='g5cs4s1.htm'");
  lc_menu_0.addMenuItem("source&nbsp;2","location='g5cs4s2.htm'");
  lc_menu_0.addMenuItem("source&nbsp;3","location='g5cs4s3a.htm'");
  lc_menu_0.addMenuItem("source&nbsp;4","location='g5cs4s4a.htm'");
  lc_menu_0.addMenuItem("source&nbsp;5","location='g5cs4s5.htm'");
  lc_menu_0.addMenuItem("source&nbsp;6","location='g5cs4s6.htm'");
  lc_menu_0.addMenuItem("source&nbsp;7","location='g5cs4s7.htm'");
  lc_menu_0.addMenuItem("source&nbsp;8","location='g5cs4s8.htm'");
  lc_menu_0.bgImageUp="../images/option_g5_d.gif";
  lc_menu_0.bgImageOver="../images/option_g5_u.gif";
  lc_menu_0.fontWeight="normal";
  lc_menu_0.hideOnMouseOut=true;
  lc_menu_0.writeMenus();
}//dynamic menu for Learning Curve end