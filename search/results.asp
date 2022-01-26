<%@ Language=VBScript%>
<%
	' --------------------------------------------------------------------------
	' RESULTS.ASP
	' --------------------------------------------------------------------------
	' Author:	Dario Mratovich (dario.mratovich@pro.gov.uk)
	' Created:	20/02/2003
	' Purpose:	Searches Index Server catalogue for Learning Curve Britain 1906-
	'				18 exhibition and displays search results
	'           ----------------------------
	' Notes:	WHEN MOVING BETWEEEN SERVERS
	'           ----------------------------
	'           Ensure the catalogue name ("objQuery.Catalog" in this page) matches
	'               the Indexing Service catalogue name that is indexing the Learning Curve site on this
	'               server.
	'			Ensure the paths to the /britain1906to1918 content folders 
	'               ("objUtil.AddScopeToQuery", and strDocUrl in this page) are pointing to the 
	'               correct folders on this server.
	'           Ensure that in Indexing Service, the custom property "searchlinktosource" is 
	'               cached so that it can be output into the page 
	'               (Datatype: VT_LPWSTR, Size: 4, Storage Level: Secondary).
	' --------------------------------------------------------------------------

	Option Explicit

	Dim objQuery
	Dim objUtil
	Dim objRegExp
	Dim rstRecordSet
	Dim avarResults
	Dim intResult
	Dim intStartResult
	Dim intEndResult
	Dim intTotalResults
	Dim intResultsPerPage
	Dim intPageNum
	Dim intCurPageNum
	Dim intTotalPages

	Dim blnSearchSubmitted  ' flag to check if search form was submitted

	Dim strCustomColumn

	Dim strSearchScript
	Dim strSearchString
	Dim strPageNum
	Dim strURL
	Dim strPageNavLinks

	Dim strDocTitle
	Dim strDocDescription
	Dim strDocURL
	Dim strGalleryNum
	Dim strCaseStudyNum
	Dim strSourceNum

	Dim strError

	' constants for .GetRows results array
	Const VPATH                 = 0
	Const DOCTITLE              = 1
	Const HITCOUNT              = 2
	Const FILENAME              = 3
	Const SEARCH_DESCRIPTION    = 4
	Const CHARACTERIZATION      = 5
	Const SEARCH_LINK_TO_SOURCE = 6


	' set number of results per page
	intResultsPerPage = 10

	' get the script name
	strSearchScript = Request.ServerVariables("SCRIPT_NAME")

	' get parameters passed
	strSearchString = Trim(Request("keys"))
	strPageNum      = Trim(Request("p"))

	' create regular expression object
	Set objRegExp = New RegExp

	' match a number
	objRegExp.Pattern = "^\d+$"

	' default page to 1 if not a number
	If Not objRegExp.Test(strPageNum) Then
		intCurPageNum = 1
	Else
		intCurPageNum = CInt(strPageNum)
	End If ' Not objRegExp.Test(strPageNum)

	' match alphanumeric, quotes, wildcards and separator characters
	objRegExp.Pattern = "^[A-Za-z0-9_ \.,;:'""\*\?\-]+$"


	' check if the form was submitted (either from the search results page itself
	' (POST or GET if form submitted or page nav link clicked)
	' or from the search box on the site's pages (GET, <input type="image" name="Go"...>)
	If Request("action") = "search" _
	Or (Len(Request.QueryString("Go.x")) > 0 And Len(Request.QueryString("Go.y")) > 0) Then
		blnSearchSubmitted = True
	Else
		blnSearchSubmitted = False
	End If


	' check that the form was submitted
	If blnSearchSubmitted Then
		If strSearchString = "" Then
			strError = "Please enter a word or phrase to search for"
		ElseIf Not objRegExp.Test(strSearchString) Then
			strError = "The search text specified is invalid"
		Else
			' create a new query object
			Set objQuery = Server.CreateObject("IXSSO.Query")

			' define a custom column for the SearchDescription META property
			strCustomColumn = "SearchDescription = d1b5d3f0-c0b3-11cf-9a92-00a0c908dbf1 searchdescription"
			' add custom column to query object
			objQuery.DefineColumn(strCustomColumn)

			' define a custom column for the SearchLinkToSource META property
			strCustomColumn = "SearchLinkToSource = d1b5d3f0-c0b3-11cf-9a92-00a0c908dbf1 searchlinktosource"
			' add custom column to query object
			objQuery.DefineColumn(strCustomColumn)

			' build search query object
			objQuery.Catalog    = "learningcurve"
			objQuery.Query      = "(" & strSearchString & ") and not #filename g?_source*.htm and not #filename *.asp"
			objQuery.Columns    = "vpath, DocTitle, HitCount, filename, searchdescription, characterization, searchlinktosource"
			objQuery.SortBy     = "rank[d]"
			objQuery.MaxRecords = 300

			' create a utility object to limit the searching scope
			Set objUtil = Server.CreateObject("IXSSO.Util")

			' limit the scope to the /3cs folder
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/credits/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/links/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/sitemap/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/transcript/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/usefulnotes/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g1/", "deep"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g2/", "deep"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g3/", "deep"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g4/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g4/cs1/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g4/cs2/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g4/cs3/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g4/cs4/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g5/", "deep"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g6/", "deep"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g7/", "shallow"
			objUtil.AddScopeToQuery objQuery, "/britain1906to1918/g7/g7cs1/", "shallow"

			Set rstRecordSet = objQuery.CreateRecordSet("nonsequential")

			If Not(rstRecordSet.EOF Or rstRecordSet.EOF) Then
				avarResults = rstRecordSet.GetRows()
			Else
				strError = "No results were found that match your search"
			End If ' Not(rstRecordSet.EOF Or rstRecordSet.EOF)

			' cleanup
			Set objQuery = Nothing
			rstRecordSet.Close
			Set rstRecordSet = Nothing
		End If ' strSearchString = ""
	End If ' blnSearchSubmitted
%>
<html><!-- #BeginTemplate "/Templates/search.dwt" --><!-- DW6 -->
<head>
<!-- #BeginEditable "doctitle" --> <title>The National Archives | Education | Britain 1906-18 | Search</title>
<!--#include virtual="/includes/google-analytics-gtm-head.inc" -->
<!-- #EndEditable -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META NAME="DC.Title" content="The National Archives, Britain 1906-18">
<META NAME="DC.Identifier" content="http://learningcurve.pro.gov.uk/britain1906to1918/default.htm">
<META NAME="DC.Creator" content="Public Record Office">
<META NAME="DC.Language" CONTENT="en-UK">
<META NAME="DC.Publisher" content="Public Record Office">
<META NAME="DC.Type" content="text; image; interactive resource">
<META NAME="DC.Format" content="text/html">
<META NAME="DC.Source" content="Public Record Office, The National Archives">
<META NAME="DC.Rights" content="http://www.nationalarchives.gov.uk/legal/copyright.htm"><!-- #BeginEditable "metascript" -->

<!-- #EndEditable -->
<script language="JavaScript" type="text/JavaScript" src="../scripts/roll_pop.js"></script>
<script language="JavaScript" type="text/JavaScript" src="../scripts/browser_search.js"></script>
<link href="/css/menusmicrosites/breadcrumb.css" rel="stylesheet" type="text/css"></head>
<body bgcolor="#FFFFFF" text="#000000" onLoad="MM_preloadImages('../images/foot_gloss_d.gif','../images/foot_time_d.gif','../images/foot_cred_d.gif','../images/foot_feed_d.gif','../images/foot_sitemap_u.gif')"  >
<!--#include virtual="/includes/google-analytics-gtm-body.inc" --><!--#include virtual="/includes/menusmicrosites/3c_breadcrumb.inc" -->
<!-- banner start -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td rowspan="2" bgcolor="#990033" background="../images/banner_line.gif"><img src="../images/banner_3cs.gif" width="148" height="68" border="0" alt="Contrast, Contradiction and Change"></td>
    <td bgcolor="#990033" background="../images/banner_line.gif"><img src="../images/banner_britain.gif" width="220" height="42" border="0" alt="Britain 1906-1918"></td>
    <td rowspan="2" bgcolor="#990033" background="../images/banner_line.gif"align="right"><a href="/default.htm"><img src="../images/banner_pic.gif" width="270" height="68" border="0" alt="link to Learning Curve home page"></a></td>
  </tr>
  <tr>
    <td bgcolor="#990033" background="../images/banner_line.gif" ><img src="../images/banner_blank.gif" width="357" height="26" border="0" alt="Case Study"></td>
  </tr>
</table>
<!-- banner end -->
<!-- breadcrumb start -->
<form name="queryform" action="results.asp" class="search_form">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="24" width="35"><img src="../images/pixeltrans.gif" width="35" height="24" border="0" alt="*"></td>
    <td class="breadcrumb" height="24">
      <a href="../default.htm">Home</a> &gt; Search
    </td>
      <td align="right" height="24" valign="bottom"> <a href="javascript:popwindow('../help/default.htm#6','500','400')" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1','','../images/qm_u.gif',1)"><img src="../images/qm_d.gif" width="18" height="18" alt="Help" border="0" name="Image1"></a>
        <img src="../images/search_label.gif" width="48" height="24" border="0" alt="Search">
        <input name="keys" size="7" tabindex="1">
      <input type="hidden" name="action" value="search">
      <input type="image" border="0" name="Go" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Go','','../images/search_go_a.gif',1)" src="../images/search_go_u.gif" width="24" height="24" tabindex="2" alt="Go" title="Go">
      <img src="../images/pixeltrans.gif" width="35" height="24" border="0" alt="*">
    </td>
  </tr>
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="1" border="0" alt="*"></td><td width="100%"><img src="../images/pixeltrans.gif" width="445" height="1" border="0" alt="*"></td><td width="300"><img src="../images/pixeltrans.gif" width="300" height="1" border="0" alt="*"></td>
  </tr>
</table>
</form>
<!-- breadcrumb end -->

<!-- titlebar start -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="1" border="0" alt="*"></td>
    <td width="100%"><img src="../images/pixeltrans.gif" width="450" height="1" border="0" alt="*"></td>
    <td width="260"><img src="../images/pixeltrans.gif" width="260" height="1" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="1" border="0" alt="*"></td>
  </tr>
  <tr>
    <td valign="middle" width="35" bgcolor="#990033"><img src="../images/pixelG8.gif" width="1" height="1" alt="*"></td>
    <td valign="middle" width="100%" bgcolor="#990033" height="23"><img name="source" border="0" src="images/title_search.gif" width="143" height="23" alt="Search Results"></td>
    <td valign="middle" bgcolor="#990033" width="260"><img src="../images/pixelG8.gif" width="260" height="23" alt="*"></td>
    <td width="35" bgcolor="#990033"><img src="../images/pixelG8.gif" width="1" height="1" border="0" alt="*"></td>
  </tr>
</table>
<!-- titlebar end -->
<!-- contentA start -->
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="10" border="0" alt="*"></td>
    <td><img src="../images/pixeltrans.gif" width="710" height="10" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="10" border="0" alt="*"></td>
  </tr>
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="41" border="0" alt="*"></td>
    <td valign="top" class="bodybold"><!-- #BeginEditable "results" -->
<%
	If IsArray(avarResults) Then
		intTotalResults   = UBound(avarResults, 2)

		' get total number of pages
		If (intTotalResults + 1) Mod intResultsPerPage <> 0 Then
			intTotalPages = Int((intTotalResults + 1) / intResultsPerPage) + 1
		Else
			intTotalPages = (intTotalResults + 1) / intResultsPerPage
		End If ' (intTotalResults + 1) Mod intResultsPerPage <> 0

		' check that current page is within allowed range
		If intCurPageNum < 1 Then
			intCurPageNum = 1
		ElseIf intCurPageNum > intTotalPages Then
			intCurPageNum = intTotalPages
		End If

		' build string for navigation between pages
		If intTotalPages > 1 Then
			' add page and previous/next links as appropriate
			strPageNavLinks = strPageNavLinks & "Show page(s): "

			' loop for each page
			For intPageNum = 1 To intTotalPages
				If intPageNum = intCurPageNum Then
					strPageNavLinks = strPageNavLinks & " <b>" & intCurPageNum & "</b>"
				Else
					' build URL for this page link
					strURL = strSearchScript & "?keys=" & Server.URLEncode(strSearchString) _
						& "&p=" & Server.URLEncode(intPageNum) _
						& "&action=search"

					strPageNavLinks = strPageNavLinks & " <a href=""" & strURL & """>" & intPageNum & "</a>"
				End If ' intPageNum = intCurPageNum
			Next ' intPageNum = 1 To intTotalPages
		End If ' intTotalPages > 1

		' separate page numbers from previous/next links
		strPageNavLinks = strPageNavLinks & "<br>"

		' add a previous link
		If intCurPageNum > 1 Then
			' build URL for this page link
			strURL = strSearchScript & "?keys=" & Server.URLEncode(strSearchString) _
				& "&p=" & Server.URLEncode(intCurPageNum - 1) _
				& "&action=search"

			strPageNavLinks = strPageNavLinks & "<a href=""" & strURL & """>&lt; Previous page</a>"
		End If ' intCurPage > 1

		' add a separator string if neccessary
		If intCurPageNum > 1 And intCurPageNum < intTotalPages Then
			strPageNavLinks = strPageNavLinks & " | "
		End If ' intCurPageNum > 1 And intCurPageNum < intTotalPages

		' add a next link
		If intCurPageNum < intTotalPages Then
			' build URL for this page link
			strURL = strSearchScript & "?keys=" & Server.URLEncode(strSearchString) _
				& "&p=" & Server.URLEncode(intCurPageNum + 1) _
				& "&action=search"

			strPageNavLinks = strPageNavLinks & "<a href=""" & strURL & """>Next page &gt;</a>"
		End If ' intCurPageNum < intTotalPages

		intStartResult = (intCurPageNum * intResultsPerPage) - intResultsPerPage + 1
		intEndResult   = intCurPageNum * intResultsPerPage
		If intEndResult > (intTotalResults + 1) Then
			intEndResult = intTotalResults + 1
		End If ' intEndResult > (intTotalResults + 1)
%>
        <table width="100%" border="0" cellspacing="0" cellpadding="4" align="center">
          <tr bgcolor="#FFFFFF">
            <td class="bodyblack" align="center" colspan="2">
              <p><strong>Search Results</strong>:
                Showing <% = intStartResult %> to <% = intEndResult %>  of <% = intTotalResults + 1 %> document(s) matching &quot;<% = Server.HTMLEncode(strSearchString) %>&quot; in Britain 1906-18</p>
            </td>
          </tr>
          <tr>
            <td class="searchnormal" align="center" colspan="2">&nbsp;</td>
          </tr>
<%
		For intResult = (intStartResult - 1) To (intEndResult - 1)
			' get document title (or filename if no title)
			If Len(avarResults(DOCTITLE, intResult)) > 0 Then
				strDocTitle = avarResults(DOCTITLE, intResult)
			Else
				strDocTitle = avarResults(FILENAME, intResult)
			End If

			' get document search description meta data (or default charazcterization if none)
			If Len(avarResults(SEARCH_DESCRIPTION, intResult)) > 0 Then
				strDocDescription = avarResults(SEARCH_DESCRIPTION, intResult)
			ElseIf Len(avarResults(CHARACTERIZATION, intResult)) > 0 Then
				strDocDescription = avarResults(CHARACTERIZATION, intResult)
			End If

			' strip out <noscript> tag content, and tail off descriptions with "..." after last space character
			objRegExp.Pattern = "^This website requires Javascript to be enabled\.\.(:? source \d+[a]?\.)?(.*)\s.*?$"
			objRegExp.IgnoreCase = True
			strDocDescription = objRegExp.Replace(strDocDescription, "$2...")

			' get document URL
			' check if this is a transcript or usefulnotes URL
			objRegExp.Pattern = "^.*?(?:/transcript/|/usefulnotes/)g\d+?cs\d+?s\d+?(?:u|t).htm$"
			objRegExp.IgnoreCase = True

			If objRegExp.Test(avarResults(VPATH, intResult)) Then
				strDocURL = "http://" & Request.ServerVariables("SERVER_NAME") & "/britain1906to1918" & avarResults(SEARCH_LINK_TO_SOURCE, intResult)
			Else
				strDocURL = "http://" & Request.ServerVariables("SERVER_NAME") & avarResults(VPATH, intResult)
			End If

			' strip off the "The National Archives Learning Curve | Britain 1906-18 | " part of the page title
			strDocTitle = Replace(strDocTitle, "The National Archives Learning Curve | Britain 1906-18 | ", "")
%>
          <tr>
            <td width="4%" valign="top" align="right" class="bodyblack"><strong><% = intResult + 1 %>.</strong></td>
            <td width="96%" valign="top" class="bodyblack">
              <strong><a href="<% = strDocURL %>"><% = strDocTitle %></a></strong><br>
              <% = strDocDescription %><br>
              URL: <% = strDocURL %>
            </td>
          </tr>
<%
		Next
%>
          <tr>
            <td colspan="2" class="bodyblack">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2" align="center" class="bodyblack"><% = strPageNavLinks %></td>
          </tr>
        </table>
<%
	Else
		If strError <> "" Then
			Response.Write "<p class=""error"">" & strError & "</p>"
		End If ' strError <> ""
	End If ' Not(rstRecordSet.EOF Or rstRecordSet.EOF)
%>
        <table border="0" cellspacing="0" cellpadding="8" align="center">
          <tr bgcolor="#FFFFFF">
            <td align="center" class="bodyblack">
              <form name="search" method="post" action="<% = strSearchScript %>">
                New search for
                <input type="text" name="keys" value="<% = strSearchString %>" size="20">
                <input type="hidden" name="action" value="search">
                <input type="image" border="0" name="Search" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Search','','../images/search_go_a.gif',1)" src="../images/search_go_u.gif" width="24" height="24" tabindex="2" alt="Go" title="Go">
              </form>
            </td>
          </tr>
        </table>
      <!-- #EndEditable --> </td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="10" border="0" alt="*"></td>
  </tr>
  <tr>
    <td width="35">&nbsp;</td>
    <td valign="top" class="bodyblack">
      <div align="left">Enter a keyword or
        keywords into the search to find web pages within the Britain 1906-18
        exhibition on the subject of your choice. Note: This search only looks
        for web pages within the Britain 1906-18 exhibition, not the whole Learning
        Curve website. It only looks for web pages, not other file formats (such
        as rtf, pdf, films). For search tips, see <a href="javascript:popwindow('../help/default.htm#6','500','400')">help</a>.</div>
    </td>
    <td width="35">&nbsp;</td>
  </tr>
</table>
<!-- contentA end -->
<!-- footer start -->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="5" border="0" alt="*"></td>
    <td width="440"><img src="../images/pixeltrans.gif" width="450" height="5" border="0" alt="*"></td>
    <td><img src="../images/pixeltrans.gif" width="260" height="5" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="5" border="0" alt="*"></td>
  </tr>
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="1" border="0" alt="*"></td>
    <td bgcolor="#000000"><img src="../images/pixeltrans.gif" width="450" height="1" border="0" alt="*"></td>
    <td bgcolor="#000000"><img src="../images/pixeltrans.gif" width="260" height="1" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="1" border="0" alt="*"></td>
  </tr>
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="5" border="0" alt="*"></td>
    <td width="440"><img src="../images/pixeltrans.gif" width="450" height="5" border="0" alt="*"></td>
    <td><img src="../images/pixeltrans.gif" width="260" height="5" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="5" border="0" alt="*"></td>
  </tr>
    <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="10" border="0" alt="*"></td>
    <td><a href="javascript:popwindow('../feedback/default.htm','500','400')" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('feedback','','../images/foot_feed_d.gif',1)"><img name="feedback" border="0" src="../images/foot_feed_u.gif" width="54" height="8" alt="Feedback"></a><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><img src="../images/foot_line.gif" width="2" height="8" alt="*"><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><a href="../credits/default.htm" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('credits','','../images/foot_cred_d.gif',1)"><img name="credits" border="0" src="../images/foot_cred_u.gif" width="44" height="8" alt="Credits"></a><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><img src="../images/foot_line.gif" width="2" height="8" alt="*"><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><a href="../sitemap/default.htm" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('sitemap','','../images/foot_sitemap_d.gif',1)"><img name="sitemap" border="0" src="../images/foot_sitemap_u.gif" width="46" height="8" alt="Sitemap"></a><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><img src="../images/foot_line.gif" width="2" height="8" alt="*"><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><a href="../links/default.htm" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('links','','../images/foot_links_d.gif',1)"><img name="links" border="0" src="../images/foot_links_u.gif" width="30" height="8" alt="Links"></a><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><img src="../images/foot_line.gif" width="2" height="8" alt="*"><img src="../images/pixeltrans.gif" width="10" height="8" alt="*"><a href="javascript:popwindow('../help/default.htm#6','500','400')" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('help','','../images/foot_help_d.gif',1)"><img name="help" border="0" src="../images/foot_help_u.gif" width="27" height="8" alt="Help"></a></td>
    <td><img src="../images/pixeltrans.gif" width="260" height="10" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="10" border="0" alt="*"></td>
  </tr>
  <tr>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="5" border="0" alt="*"></td>
    <td><img src="../images/pixeltrans.gif" width="450" height="5" border="0" alt="*"></td>
    <td><img src="../images/pixeltrans.gif" width="260" height="5" border="0" alt="*"></td>
    <td width="35"><img src="../images/pixeltrans.gif" width="35" height="5" border="0" alt="*"></td>
  </tr>
</table>
<!-- footer end -->
<!--#include virtual="/includes/menu/sdc.inc" -->
</body>
<!-- #EndTemplate --></html>
