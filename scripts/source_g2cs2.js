//dynamic menu for Learning Curve (lc) - 3Cs klee v1.0
//3Cs klee v1.1 fix on Opera5 and NS7 and IE cell layer.
function lcLoadMenus() {
  if (window.lc_menu_0) return;
  window.lc_menu_0 = new Menu("root",148,19,"Verdana, Arial, Helvetica, sans-serif",12,"#333399","#ffffff","#ffffff","#333399","left","middle",0,0,1000,0,0,true,true,true,15,true,true);
  lc_menu_0.addMenuItem("source&nbsp;1","location='g2cs2s1a.htm'");
  lc_menu_0.addMenuItem("source&nbsp;2","location='g2cs2s2.htm'");
  lc_menu_0.addMenuItem("source&nbsp;3","location='g2cs2s3.htm'");
  lc_menu_0.addMenuItem("source&nbsp;4","location='g2cs2s4a.htm'");
  lc_menu_0.addMenuItem("source&nbsp;5","location='g2cs2s5.htm'");
  lc_menu_0.addMenuItem("source&nbsp;6","location='g2cs2s6a.htm'");
  lc_menu_0.addMenuItem("source&nbsp;7","location='g2cs2s7a.htm'");
  lc_menu_0.addMenuItem("source&nbsp;8","location='g2cs2s8a.htm'");
  lc_menu_0.bgImageUp="../images/option_g2_d.gif";
  lc_menu_0.bgImageOver="../images/option_g2_u.gif";
  lc_menu_0.fontWeight="normal";
  lc_menu_0.hideOnMouseOut=true;
  lc_menu_0.writeMenus();
}//dynamic menu for Learning Curve end