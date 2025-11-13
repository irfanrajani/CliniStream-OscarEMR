<%--

    Copyright (c) 2014-2015. KAI Innovations Inc. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
    
    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada
    
--%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName2$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName2$%>" objectName="_form" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_form");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>
<%
  String formClass = "AR2017";
  String formLink = "formAR2017Record1.jsp";

  boolean bView = false;
  if (request.getParameter("view") != null && request.getParameter("view").equals("1")) bView = true; 
  
  int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
  int formId = request.getParameter("formId") != null ? Integer.parseInt(request.getParameter("formId")) : 0;
  int provNo = Integer.parseInt((String) session.getAttribute("user"));
  
  FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
  Properties props = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request), demoNo, formId);
  
//get project_home
  String project_home = request.getContextPath().substring(1); 
%>
<%@page import="oscar.OscarProperties"%>
<%@page import="java.util.*"%>
<%@ page import="oscar.util.*, oscar.form.*, oscar.form.data.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<!--add for con report-->
<%@ taglib uri="http://www.caisi.ca/plugin-tag" prefix="plugin" %>
<%@page import="org.oscarehr.util.LoggedInInfo" %>

<html:html locale="true">
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Antenatal Record 1</title>
<link rel="stylesheet" type="text/css"
	href="<%=bView?"arStyleView.css" : "arStyle.css"%>">
<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="../share/calendar/calendar.css" title="win2k-cold-1" />

<!-- main calendar program -->
<script type="text/javascript" src="../share/calendar/calendar.js"></script>

<!-- language for the calendar -->
<script type="text/javascript"
	src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>

<!-- the following script defines the Calendar.setup helper function, which makes
       adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript" src="../share/calendar/calendar-setup.js"></script>
<html:base />
<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
<script type="text/javascript" language="Javascript">
var wasLocked = false;

		function reset() {        
           document.forms[0].target = "";
           document.forms[0].action = "/<%=project_home%>/form/formname.do" ;
       }
       
       function setLock (checked) {
       	formElems = document.forms[0].elements;
       	for (var i=0; i<formElems.length; i++) {
       		if (formElems[i].type == "text" || formElems[i].type == "textarea") {
               		formElems[i].readOnly = checked;             		
       		} else if ((formElems[i].type == "checkbox") && (formElems[i].id != "pg1_lockPage")/* && (formElems[i].id != "pg1_4ColCom")*/) {
               		formElems[i].disabled = checked;
       		}
       	}
       }
       
       function onPrint() {
           document.forms[0].submit.value="print"; 
           var ret = checkAllDates(); //allows empty dates!
           setLock(false);
           if(ret==true)
           {
           		if( document.forms[0].c_fedb.value == "" /*&& !confirm("<bean:message key="oscarEncounter.formOnar.msgNoEDB"/>")*/) {
                	alert('Please set Final EDB before printing');
        			ret = false;
            	} else {
            		document.forms[0].action = "../form/createpdf?__title=Ontario+Perinatal+Record+1&__cfgfile=ar2017PrintCfgPg1&__template=ar2017pg1";
               		document.forms[0].target="_blank";    
            	}   
           } else {
               alert('Please set Final EDB before printing');
           }
           setTimeout('setLock(wasLocked)', 500);
           return ret;
       }
       
       function onPrintAll() {
           document.forms[0].submit.value="printAll"; 
           var ret = checkAllDates(); //allows empty dates!
           setLock(false);
           if(ret==true)
           {
                        if( document.forms[0].c_fedb.value == "" /*&& !confirm("<bean:message key="oscarEncounter.formOnar.msgNoEDB"/>")*/) {
                        alert('Please set Final EDB before printing');
                                ret = false;
                } else {
                        document.forms[0].action = "../form/createpdf?__title=Ontario+Perinatal+Record+1&__cfgfile=ar2017PrintCfgPg1&__template=ar2017pg1&multiple=4&__title1=Antenatal+Record+Part+2&__cfgfile1=ar2017PrintCfgPg2&__template1=ar2017pg2&__title2=Antenatal+Record+Part+3&__cfgfile2=ar2017PrintCfgPg3&__template2=ar2017pg3&__title3=Antenatal+Record+Part+3+Appendix&__cfgfile3=ar2017PrintCfgPg4&__template3=ar2017pg4";

                        document.forms[0].target="_blank";    
                }   
           } else {
               alert('Please set Final EDB before printing');
           }
           setTimeout('setLock(wasLocked)', 500);
           return ret;
       }

       
       function refreshOpener() {
   		if (window.opener && window.opener.name=="inboxDocDetails") {
   			window.opener.location.reload(true);
   		}	
       }
       
       window.onunload=refreshOpener;
       
       function onSave() {
       	setLock(false);
           document.forms[0].submit.value="save";
           var ret = checkAllDates();
           if(ret==true)
           {
               reset();
               ret = confirm("Are you sure you want to save this form?");
           }
           if (ret)
               window.onunload=null;
           return ret;
       }
       
       function onPageChange(url) {
       	var result = false;
       	var newID = 0;
       	document.forms[0].submit.value="save";
           //var ret1 = validate();
           var ret = checkAllDates();
          // if(ret==true && ret1==true)
        	  if(ret==true)
           {
               reset();
               ret = confirm("Are you sure you want to save this form?");
               if(ret) {
   	            window.onunload=null;
   	           
   	            jQuery.ajax({
   	            	url:'<%=request.getContextPath()%>/Pregnancy.do?method=saveFormAjax',
   	            	data: $("form").serialize(),
   	            	async:false, 
   	            	dataType:'json', 
   	            	success:function(data) {
   	        			if(data.value == 'error') {
   	        				alert('Error saving form.');
   	        				result = false;	        				
   	        			} else {
   	        				result= true;
   	        				newID = parseInt(data.value);
   	        			}
   	        		}
   	            });
               } else {
               	url = url.replace('#id','<%=formId%>');
               	location.href=url;
               }
           }
           
           if(result == true) {
           	url = url.replace('#id',newID);
           	location.href=url;
           }
             
          return;
       }
       
       function onExit() {
           var bView = <%= bView %>;
 		   var ret = true;	
           if(!bView) ret = confirm("Are you sure you wish to exit without saving your changes?");
           if(ret==true)
           {
           	   refreshOpener();
               window.close();
           }
           return(false);
       }
       function onSaveExit() {
       	setLock(false);
           document.forms[0].submit.value="exit";
           var ret = checkAllDates();
           if(ret == true)
           {
               reset();
               ret = confirm("Are you sure you wish to save and close this window?");
           }
           if (ret)
           	refreshOpener();
           return ret;
       }
       function popupPage(varpage) {
           windowprops = "height=960,width=1280"+
               ",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=no,screenX=50,screenY=50,top=20,left=20";
           var popup = window.open(varpage, "ar2", windowprops);
           if (popup.opener == null) {
               popup.opener = self;
           }
       }
       
/*       
       function popupPageFull(varpage) {
           windowprops = "location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=no,screenX=50,screenY=50,top=20,left=20";
           var popup = window.open(varpage, "ar2", windowprops);
           if (popup.opener == null) {
               popup.opener = self;
           }
       }
*/
/*
       function popPage(varpage,pageName) {
           windowprops = "height=700,width=960"+
               ",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=no,screenX=50,screenY=50,top=20,left=20";
           var popup = window.open(varpage,pageName, windowprops);
           //if (popup.opener == null) {
           //    popup.opener = self;
           //}
           popup.focus();
       }
*/
/*
		function popupFixedPage(vheight,vwidth,varpage) { 
          var page = "" + varpage;
          windowprop = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=10,screenY=0,top=0,left=0";
          var popup=window.open(page, "planner", windowprop);
       }
*/
/*
   	function isNumber(ss){
   		var s = ss.value;
           var i;
           for (i = 0; i < s.length; i++){
               // Check that current character is number.
               var c = s.charAt(i);
   			if (c == '.') {
   				continue;
   			} else if (((c < "0") || (c > "9"))) {
                   alert('Invalid '+s+' in field ' + ss.name);
                   ss.focus();
                   return false;
   			}
           }
           // All characters are numbers.
           return true;
       }
*/       
/* in page 2
function wtEnglish2Metric(obj) {
   	//if(isNumber(document.forms[0].c_ppWt) ) {
   	//	weight = document.forms[0].c_ppWt.value;
   	if(isNumber(obj) ) {
   		weight = obj.value;
   		weightM = Math.round(weight * 10 * 0.4536) / 10 ;
   		if(confirm("Are you sure you want to change " + weight + " pounds to " + weightM +"kg?") ) {
   			//document.forms[0].c_ppWt.value = weightM;
   			obj.value = weightM;
   		}
   	}
   }
*/
/* in page 2
   function htEnglish2Metric(obj) {
   	height = obj.value;
   	if(height.length > 1 && height.indexOf("'") > 0 ) {
   		feet = height.substring(0, height.indexOf("'"));
   		inch = height.substring(height.indexOf("'"));
   		if(inch.length == 1) {
   			inch = 0;
   		} else {
   			inch = inch.charAt(inch.length-1)=='"' ? inch.substring(0, inch.length-1) : inch;
   			inch = inch.substring(1);
   		}
   		
   		if(isNumber(feet) && isNumber(inch) ) {
   			height = Math.round((feet * 30.48 + inch * 2.54) * 10) / 10 ;
   			if(confirm("Are you sure you want to change " + feet + " feet " + inch + " inch(es) to " + height +"cm?") ) {
   				obj.value = height;
   			}
   		}
   	}
   }
*/   
/*   
   function calcBMIMetric(obj) {
   	if(isNumber(document.forms[0].pg1_wt) && isNumber(document.forms[0].pg1_ht)) {
   		weight = document.forms[0].pg1_wt.value;
   		height = document.forms[0].pg1_ht.value / 100;
   		if(weight!="" && weight!="0" && height!="" && height!="0") {
   			obj.value = (Math.round(weight * 10 / height) / height) / 10;
   		}
   	}
   }
*/
   /**
    * DHTML date validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
    */
   // Declaring valid date character, minimum year and maximum year
   var dtCh= "/";
   var minYear=1900;
   var maxYear=2040;

       function isInteger(s){
           var i;
           for (i = 0; i < s.length; i++){
               // Check that current character is number.
               var c = s.charAt(i);
               if (((c < "0") || (c > "9"))) return false;
           }
           // All characters are numbers.
           return true;
       }

       function stripCharsInBag(s, bag){
           var i;
           var returnString = "";
           // Search through string's characters one by one.
           // If character is not in bag, append to returnString.
           for (i = 0; i < s.length; i++){
               var c = s.charAt(i);
               if (bag.indexOf(c) == -1) returnString += c;
           }
           return returnString;
       }

       function daysInFebruary (year){
           // February has 29 days in any year evenly divisible by four,
           // EXCEPT for centurial years which are not also divisible by 400.
           return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
       }
       function DaysArray(n) {
           for (var i = 1; i <= n; i++) {
               this[i] = 31
               if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
               if (i==2) {this[i] = 29}
          }
          return this
       }

       function isDate(dtStr){
           var daysInMonth = DaysArray(12)
           var pos1=dtStr.indexOf(dtCh)
           var pos2=dtStr.indexOf(dtCh,pos1+1)
           var strMonth=dtStr.substring(0,pos1)
           var strDay=dtStr.substring(pos1+1,pos2)
           var strYear=dtStr.substring(pos2+1)
           strYr=strYear
           if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
           if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
           for (var i = 1; i <= 3; i++) {
               if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
           }
           month=parseInt(strMonth)
           day=parseInt(strDay)
           year=parseInt(strYr)
           if (pos1==-1 || pos2==-1){
               return "format"
           }
           if (month<1 || month>12){
               return "month"
           }
           if (day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
               return "day"
           }
           if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
               return "year"
           }
           if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
               return "date"
           }
       return true
       }


       function checkTypeIn(obj) {
         if(!checkTypeNum(obj.value) ) {
             alert ("You must type in a number in the field.");
           }
       }

       function valDate(dateBox)
       {
           try
           {
               var dateString = dateBox.value;
               if(dateString == "")
               {
       //            alert('dateString'+dateString);
                   return true;
               }
               var dt = dateString.split('/');
               var y = dt[0];
               var m = dt[1];
               var d = dt[2];
               var orderString = m + '/' + d + '/' + y;
               var pass = isDate(orderString);

               if(pass!=true)
               {
                   alert('Invalid '+pass+' in field ' + dateBox.name);
                   dateBox.focus();
                   return false;
               }
           }
           catch (ex)
           {
               alert('Catch Invalid Date in field ' + dateBox.name);
               dateBox.focus();
               return false;
           }
           return true;
       }

       function checkAllDates()
       {
           var b = true;
           if(valDate(document.forms[0].c_fedb)==false){
               b = false;
           }else
//           if(valDate(document.forms[0].c_date)==false){
//               b = false;
//           }
           return b;
       }
       
   function calToday(field) {
   	var calDate=new Date();
   	varMonth = calDate.getMonth()+1;
   	varMonth = varMonth>9? varMonth : ("0"+varMonth);
   	varDate = calDate.getDate()>9? calDate.getDate(): ("0"+calDate.getDate());
   	field.value = calDate.getFullYear() + '/' + (varMonth) + '/' + varDate;
   }
   function calByLMP(obj) {
           if (document.forms[0].pg1_lmp.value!="" && valDate(document.forms[0].pg1_lmp)==true) {
                   var str_date = document.forms[0].pg1_lmp.value;
           var yyyy = str_date.substring(0, str_date.indexOf("/"));
           var mm = eval(str_date.substring(eval(str_date.indexOf("/")+1), str_date.lastIndexOf("/")) - 1);
           var dd  = str_date.substring(eval(str_date.lastIndexOf("/")+1));
                   var calDate=new Date();
                   calDate.setFullYear(yyyy);
                   calDate.setDate(dd);
                   calDate.setMonth(mm);
                   calDate.setHours("0");

                   calDate.setDate(calDate.getDate() + 280);

                   varMonth1 = calDate.getMonth()+1;
                   varMonth1 = varMonth1>9? varMonth1 : ("0"+varMonth1);
                   varDate1 = calDate.getDate()>9? calDate.getDate(): ("0"+calDate.getDate());
                   obj.value = calDate.getFullYear() + '/' + varMonth1 + '/' + varDate1;

           }
   }

   	function commentMode (checked) {
/*   		
   		var visible = checked ? "" : "none";
   		var span = checked ? "1" : "4";	
   		for (var n=2; n<=4; n++) {
   			document.getElementById("pg1_comment"+n).style.display = visible;
   		}
   		document.getElementById("pg1_cmt1").colSpan = span; 
*/   		
   	}

   	jQuery(document).ready(function() {
   		var formNo = '<%= formId %>';		
//removed default checkbox checking
   		commentMode(false);
   		window.resizeTo(screen.availWidth-20,screen.availHeight-20);
   		
   		var lockValue = "<%= props.getProperty("pg1_lockPage", "") %>";
        wasLocked = (lockValue.length > 0 ? true : false);
        setLock(wasLocked);

        if(formNo == 0) {
            $("input.noCheckbox").attr("checked", true);
   		}
   	});
   </script>
</head>
<body>
<html:form action="/form/formname">
	<input type="hidden" name="c_lastVisited"
		value=<%=props.getProperty("c_lastVisited", "pg1")%> />
	<input type="hidden" name="demographic_no"
		value="<%= props.getProperty("demographic_no", "0") %>" />
	<input type="hidden" name="formCreated"
		value="<%= props.getProperty("formCreated", "") %>" />
	<input type="hidden" name="form_class" value="<%=formClass%>" />
	<input type="hidden" name="form_link" value="<%=formLink%>" />
	<input type="hidden" name="formId" value="<%=formId%>" />
	<!--input type="hidden" name="ID" value="<%= props.getProperty("ID", "0") %>" /-->
	<input type="hidden" name="provider_no"
		value=<%=request.getParameter("provNo")%> />
	<input type="hidden" name="provNo"
		value="<%= request.getParameter("provNo") %>" />
	<input type="hidden" name="submit" value="exit" />

<table class="Head" class="hidePrint">
	<tr>
		<td align="left">
		<%if (!bView) {%> 
			<input type="submit" value="Save" onclick="javascript:return onSave();" /> 
			<input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" />
		<%} %> 
			<input type="submit" value="Exit" onclick="javascript:return onExit();" /> 
			<input type="submit" value="Print" onclick="javascript:return onPrint();" />
			<input type="submit" value="Print All" onclick="javascript:return onPrintAll();" />
		</td>
		<%if (!bView) {%>
		<td align="right">
			<b>View:</b> 
			<a href="javascript: popupPage('formAR2017Record2.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR2
			</a> | 
			<a href="javascript: popupPage('formAR2017Record3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR3
			</a> &nbsp;
			</a> | 
			<a href="javascript: popupPage('formAR2017Record4.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR4&nbsp;
		</td>
		<td align="right">
			<b>Edit:</b>			
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record2.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR2
			</a> | 
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record3.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR3
			</a> |
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record4.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR4
			</a> |
			<%if(rec != null && ((FrmAR2017Record)rec).isSendToPing(""+demoNo)) {	%> 
				<a href="study/ar2ping.jsp?demographic_no=<%=demoNo%>">Send to PING</a>
			<% }	%>
			</td>
			<%
		}
			%>
		</tr>
	</table>
	<div class="container" >
		<div class="ontario_record_wrap">
			<div class="ontario_record_header">
				<div class="row">
<!--  					<div class="col-md-3"><img src="<%= request.getContextPath()%>/images/formonarrecord1.jpg"></div> -->
					<div class="col-md-9">
						<p>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ministry of Health and Long-Term Care</span>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ontario Perinatal Record 1
						<% if (!bView) { %>
			&nbsp;&nbsp;(<input type="checkbox" name="pg1_lockPage" id="pg1_lockPage" onClick="setLock(this.checked);"
			<%= props.getProperty("pg1_lockPage", "") %> /> Lock )
			<% } %></span></p>
					</div>
				</div>
			</div>
			<div class="ontario_record_content">
				<table width="60%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" width="50%">Last Name<br>
							<input type="text" style="width: 90%" name="c_ln" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ln","")) %>" maxlength="50" />
						</td>
						<td valign="top" colspan='3'>First Name<br>
							<input type="text" style="width: 90%" name="c_fn" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fn","")) %>" maxlength="50" />
						</td>
					</tr>
					<tr>
						<td colspan='2'>Address - street number, street name<br>
							<input type="text" style="width: 90%" name="c_addr" value="<%= UtilMisc.htmlEscape(props.getProperty("c_addr","")) %>" maxlength="50" />
						</td>
						<td width="25%">Apt/Suite/Unit<br>
							<input type="text" style="width: 90%"  name="c_apt" value="<%= UtilMisc.htmlEscape(props.getProperty("c_apt","")) %>" maxlength="12" />
						</td>
						<td width="25%">Buzzer No<br>
							<input type="text" style="width: 90%" name="c_buz" value="<%= UtilMisc.htmlEscape(props.getProperty("c_buz", "")) %>" maxlength="12" />
						</td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" colspan='2'>City/Town<br>
							<input type="text" style="width: 90%" name="c_city" value="<%= UtilMisc.htmlEscape(props.getProperty("c_city","")) %>" maxlength="25" />
						</td>
						<td valign="top" width="12%">Province<br>
							<input type="text" style="width: 90%" name="c_prv" value="<%= UtilMisc.htmlEscape(props.getProperty("c_prv","")) %>" maxlength="18" />
						</td>
						<td width="12%">Postal Code<br>
							<input type="text" style="width: 90%" name="c_pst" value="<%= UtilMisc.htmlEscape(props.getProperty("c_pst","")) %>" maxlength="7" />
						</td>
						<td colspan="2" width="25%">Partner's Last Name<br>
							<input type="text" style="width: 90%" name="c_pln" value="<%= UtilMisc.htmlEscape(props.getProperty("c_pln","")) %>" maxlength="30" /></td>
						<td colspan="2" width="25%">Partner's First Name<br>
							<input type="text" style="width: 90%" name="c_pfn" value="<%= UtilMisc.htmlEscape(props.getProperty("c_pfn","")) %>" maxlength="30" /></td>
					</tr>
					<tr>
						<td width="15%">Contact - Preferred<br>
							<input type="text" style="width:90%" name="c_cpr" value="<%= UtilMisc.htmlEscape(props.getProperty("c_cpr","")) %>" maxlength="22" />
						</td>
						<td width="12%" align="right">Leave Message<br>
							<input type="checkbox" name="pg1_lmsgY" <%= props.getProperty("pg1_lmsgY") %> />Y 
							<input type="checkbox" name="pg1_lmsgN" class="noCheckbox" <%= props.getProperty("pg1_lmsgN") %> />N 
						</td>
						<td colspan='2'>Contact - Alternate/E-mail<br>
							<input type="text" style="width: 90%" name="c_calt"  value="<%= UtilMisc.htmlEscape(props.getProperty("c_calt","")) %>" maxlength="28"/>
						</td>
						<td width="20%">Partner's Occupation<br>
							<input type="text" style="width: 90%" name="pg1_pocc"  value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pocc","")) %>" maxlength="30" />
						</td>
						<td colspan="2">Partner's Education Level<br>
							<input type="text" style="width: 90%" name="pg1_pedl"  value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pedl","")) %>" maxlength="30" />
						</td>
						<td width="8%">Age<br>
							<input type="text" style="width: 70%" name="c_pAge"  value="<%= UtilMisc.htmlEscape(props.getProperty("c_pAge","")) %>" maxlength="3" />
						</td>
					</tr>
				</table>	
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" width="12%">Date of Birth<br>
							<input type="text" placeholder="YYYY/MM/DD" name="c_dob"  style="width: 90%"  value="<%= UtilMisc.htmlEscape(props.getProperty("c_dob","")) %>" 
							readonly=true  /></td>
						<td width="10%">Age at EDB<br>
							<input type="text" placeholder="number" style="width: 90%" name="pg1_ageb"  value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ageb","")) %>" maxlength="3" /></td>
						<td width="10%">Language<br>
							<input type="text" style="width: 90%" name="c_lang"  value="<%= UtilMisc.htmlEscape(props.getProperty("c_lang","")) %>" maxlength="25" />
						</td>
						<td width="15%" align="center">Interpreter Required<br/>
							 <input type="checkbox" name="pg1_irY" <%= props.getProperty("pg1_irY") %>/>Y
							 <input type="checkbox" name="pg1_irN" class="noCheckbox" <%= props.getProperty("pg1_irN") %>/>N
						</td>
						<td>Occupation<br>
							<input type="text" style="width: 90%" name="pg1_occ" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_occ","")) %>" maxlength="15"/>
						</td>
						<td width="15%">Education Level<br>
							<input type="text" style="width: 90%" name="pg1_edl"  value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_edl","")) %>" maxlength="15"/>
						</td>
						<td width="15%">Relationship Status<br>
							<input type="radio" name="pg1_mars" value="M" <%= props.getProperty("pg1_mars", "").equals("M")?"checked":"" %> />M 
							<input type="radio" name="pg1_mars" value="CL" <%= props.getProperty("pg1_mars", "").equals("CL")?"checked":"" %> />CL 
							<input type="radio" name="pg1_mars" value="S" <%= props.getProperty("pg1_mars", "").equals("S")?"checked":"" %> />S
						</td>
						<td width="15%">Sexual Orientation <br>
							<input type="text" style="width: 90%" name="pg1_sexo" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sexo","")) %>" maxlength="12" />
						</td>
					</tr>
					<tr>
						<td colspan="2" width="20%">OHIP Number<br>
							<input type="text" style="width: 90%" name="c_ohip" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ohip")) %>" maxlength="16" />
						</td>
						<td width="15%">Patient File Number<br>
							<input type="text" style="width: 90%" name="c_chrt" value="<%= UtilMisc.htmlEscape(props.getProperty("c_chrt")) %>" maxlength="20" />
						</td>
						<td width="15%" nowrap>Disability Requiring<br>Accommodation
							<input type="checkbox" name="pg1_dsraY" <%= props.getProperty("pg1_dsraY") %>/>Y						
							<input type="checkbox" name="pg1_dsraN" class="noCheckbox" <%= props.getProperty("pg1_dsraN") %>/>N						
						</td>
						<td colspan="2" width="17%">Planned Place of Birth<br>
							<input type="text" style="width: 90%" name="pg1_plPOB" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_plPOB","")) %>" maxlength="30" />
						</td>
						<td colspan="2" width="17%">Planned Birth Attendant<br>
							<input type="text" style="width: 90%" name="c_pba" value="<%= UtilMisc.htmlEscape(props.getProperty("c_pba", "")) %>" maxlength="30"/>
						</td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td width="50%" colspan="2">Newborn Care Provider
							<div>
								<span>In Hospital<input type="text" name="c_nbcph" style="width: 30%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_nbcph","")) %>" maxlength="25" /></span>
								<span style="margin-left: 10px;">In Community<input type="text" style="width: 30%" name="c_nbcpc" value="<%= UtilMisc.htmlEscape(props.getProperty("c_nbcpc","")) %>" maxlength="20" /></span>
							</div>
						</td>
						<td width="50%" colspan="2">Family Physician/Primary Care Provider
							<input type="text" style="width: 90%" name="c_fph" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fph","")) %>" maxlength="75" />
						</td>
					</tr>
					<tr>
						<td width="35%">Allergies or Sensitivities (include reaction)<br>
							<input type="text" style="width: 70%" name="c_alrg" value="<%= UtilMisc.htmlEscape(props.getProperty("c_alrg", "")) %>" maxlength="72"/>
						</td>
						<td width="65%" colspan="3">Medications (include Rx/OTC, complementary/alternative/vitamins and dosage)<br>
							<input type="text" style="width: 70%" name="c_medc" value="<%= UtilMisc.htmlEscape(props.getProperty("c_medc", "")) %>" maxlength="130"/>
						</td>
					</tr>
				</table>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr bgcolor="#99FF99">
						<td bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;color: #fff;">
						<div align="center"><b>Pregnancy Summary</b></div>
						</td>
					</tr>
				</table>
				<table width="100%" cellspacing="0" cellpadding="0" border="1" class="record_table">
					<tr>
						<td style="width:48%">
							<span>LMP<input type="text" name="pg1_lmp" id="pg1_lmp" placeholder="YYYY/MM/DD" style="width: 20%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lmp","")) %>" maxlength="10"/><img src="../images/cal.gif" id="pg1_lmp_cal"></span>							
							<span>Cycle q <input type="text" name="pg1_cycleQ" style="width: 10%;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cycleQ","")) %>" maxlength="7" /></span>
							<span style="margin-left: 15px;">Certain<span style="margin-left: 5px;"><input type="checkbox" name="pg1_crtY" <%= props.getProperty("pg1_crtY") %> />Y</span>
							<span><input type="checkbox" name="pg1_crtN" class="noCheckbox" <%= props.getProperty("pg1_crtN") %> />N</span></span>
							<span style="margin-left: 15px;">Regular<span style="margin-left: 5px;"><input type="checkbox" name="pg1_rglY" <%= props.getProperty("pg1_rglY") %>/>Y</span>
							<span><input type="checkbox" name="pg1_rglN" class="noCheckbox" <%= props.getProperty("pg1_rglN") %>/>N</span></span>
							<br/>
							<span>Planned Preg
							<input type="checkbox" name="pg1_pprgY" <%= props.getProperty("pg1_pprgY") %>/>Y
							<input type="checkbox"  name="pg1_pprgN" class="noCheckbox" <%= props.getProperty("pg1_pprgN") %>/>N</span>
							<span style="margin-left: 10px;">Contraceptive Type<input type="text" name="pg1_cctp" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cctp","")) %>" style="width: 10%;" maxlength="12" /></span>
							<span>Last Used<input type="text" name="pg1_luse" id="pg1_luse" placeholder="YYYY/MM" style="width: 9%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_luse","")) %>" maxlength="10" /><img src="../images/cal.gif" id="pg1_luse_cal"></span>
							<br/>
							<span>Conception: Assisted<input type="checkbox"  name="pg1_cptaY" style="margin-left: 10px;" <%= props.getProperty("pg1_cptaY") %> />Y
							<input type="checkbox" name="pg1_cptaN" class="noCheckbox" <%= props.getProperty("pg1_cptaN") %>/>N</span>
							<span style="margin-left: 20px;">Details<input type="text" name="pg1_det" style="width: 10%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_det", ""))%>" maxlength="40"/></span>
						</td>
						<td style="width: 12%">
							EDB By LMP<br/>
							<input type="text" name="pg1_edbLm" id="pg1_edbLm" placeholder="YYYY/MM/DD" style="width: 80%" class="spe" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_edbLm","")) %>" maxlength="10"
								onDblClick="calByLMP(this);" /><img src="../images/cal.gif" id="pg1_edbLm_cal"><br/>
							Final EDB<br/>
							<input type="text" name="c_fedb" id="c_fedb" placeholder="YYYY/MM/DD" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fedb", ""))%>" maxlength="10" /><img src="../images/cal.gif" id="c_fedb_cal">						
						</td>
						<td>
										Dating Method
										<br/>
										<input type="checkbox" name="pg1_t1Us" <%= props.getProperty("pg1_t1Us") %>/>T 1 US
						<input type="checkbox" name="pg1_t2Us" <%= props.getProperty("pg1_t2Us") %>/>T 2 US
						<input type="checkbox" name="pg1_datL" <%= props.getProperty("pg1_datL") %>/>LMP
										<br/>
										<input type="checkbox" name="pg1_iui" <%= props.getProperty("pg1_iui") %>/> IUI
						<input type="text" name="pg1_iuid" id="pg1_iuid" placeholder="YYYY/MM/DD" style="width: 22%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_iuid", "")) %>" maxlength="10"/><img src="../images/cal.gif" id="pg1_iuid_cal">
						<input type="checkbox" name="pg1_embT" <%= props.getProperty("pg1_embT") %>/> Embryo Transfer
						<input type="text" name="pg1_embTd" id="pg1_embTd" placeholder="YYYY/MM/DD" style="width:22%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_embTd","")) %>" maxlength="10" /><img src="../images/cal.gif" id="pg1_embTd_cal">			
										<br/>
										<input type="checkbox" name="pg1_oth" <%= props.getProperty("pg1_oth") %> /> Other							
						</td>	
					</tr>
					<tr>
						<td style="width: 90%" colspan="3">
							<table style="width: 90%">
								<tr>
									<td style="width: 14%"> Gravida<br>
										<input type="text" name="c_g" value="<%= UtilMisc.htmlEscape(props.getProperty("c_g", "")) %>" style="width: 80%" maxlength="15"/>
									</td>
									<td style="width: 14%">Term<br>
										<input type="text" name="c_t" value="<%= UtilMisc.htmlEscape(props.getProperty("c_t", "")) %>" style="width: 80%" maxlength="20"/>
									</td>
									<td style="width: 14%">Preterm<br>
										<input type="text" name="c_p" value="<%= UtilMisc.htmlEscape(props.getProperty("c_p", "")) %>" style="width: 80%" maxlength="20" />
									</td>
									<td style="width: 14%">Abortus<br>
										<input type="text" name="c_a" value="<%= UtilMisc.htmlEscape(props.getProperty("c_a", "")) %>" style="width: 80%" maxlength="20" />
									</td>
									<td style="width: 14%">Living Children<br>
										<input type="text" name="c_l" value="<%= UtilMisc.htmlEscape(props.getProperty("c_l", "")) %>" style="width: 80%" maxlength="20" />
									</td>
									<td style="width: 14%">Stillbirth(s)<br>
										<input type="text" name="c_s" value="<%= UtilMisc.htmlEscape(props.getProperty("c_s", "")) %>" style="width: 80%" maxlength="20" />
									</td>
									<td>Neonatal / Child Death<br>
										<input type="text" name="pg1_neon" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_neon", "")) %>" style="width: 80%" maxlength="20" />
									</td>
								</tr>
							</table>
						</td>			
					</tr>
				</table>	
				<table width="100%" border="0">
					<tr bgcolor="#99FF99">
						<td align="center" colspan="2" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;color: #fff;"><b>Obstetrical History</b></td>
					</tr>
					<tr>
						<td valign="top">
							<table width="100%" border="1" cellspacing="0" cellpadding="0">
								<tr align="center">
									<td width="7%">Year/<br>
Month</td>
									<td width="7%">Place<br>
of Birth</td>
									<td width="5%">Gest.<br>
(wks)</td>
									<td width="5%">Labour<br>
Length</td>
									<td width="5%">Type of<br>
Birth</td>
									<td>Comments regarding abortus, pregnancy, birth, and newborn<br>
(e.g. GDM, HTN, IUGR, shoulder dystocia, PPH, OASIS, neonatal jaundice)</td>
									<td width="5%">Sex<br>
									M/F</td>
									<td width="5%">Birth<br>
									Weight</td>
									<td width="7%">Breastfed /<br>Duration</td>
									<td width="9%">Child's Current<br>Health</td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym1" id="pg1_ym1" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym1",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym1_cal"></td>
									<td align="center"><input type="text" name="pg1_pl1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl1",""))%>" maxlength="7"/></td>
									<td align="center"><input type="text" name="pg1_gst1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst1",""))%>" maxlength="4"/></td>
									<td align="center"><input type="text" name="pg1_lb1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb1",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob1",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt1" name="pg1_cmt1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt1",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex1" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex1",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw1",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd1",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh1" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh1",""))%>" maxlength="12" /></td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym2" id="pg1_ym2" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym2",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym2_cal"></td>
									<td align="center"><input type="text" name="pg1_pl2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl2",""))%>" maxlength="7"/></td>
									<td align="center"><input type="text" name="pg1_gst2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst2",""))%>" maxlength="4" /></td>
									<td align="center"><input type="text" name="pg1_lb2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb2",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob2",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt2" name="pg1_cmt2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt2",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex2" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex2",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw2",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd2",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh2" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh2",""))%>" maxlength="12" /></td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym3" id="pg1_ym3" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym3",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym3_cal"></td>
									<td align="center"><input type="text" name="pg1_pl3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl3",""))%>" maxlength="7"/></td>
									<td align="center"><input type="text" name="pg1_gst3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst3",""))%>" maxlength="4" /></td>
									<td align="center"><input type="text" name="pg1_lb3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb3",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob3",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt3" name="pg1_cmt3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt3",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex3" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex3",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw3",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd3",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh3" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh3",""))%>" maxlength="12" /></td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym4" id="pg1_ym4" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym4",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym4_cal"></td>
									<td align="center"><input type="text" name="pg1_pl4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl4",""))%>" maxlength="7"/></td>
									<td align="center"><input type="text" name="pg1_gst4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst4",""))%>" maxlength="4" /></td>
									<td align="center"><input type="text" name="pg1_lb4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb4",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob4",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt4" name="pg1_cmt4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt4",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex4" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex4",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw4",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd4",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh4" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh4",""))%>" maxlength="12" /></td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym5" id="pg1_ym5" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym5",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym5_cal"></td>
									<td align="center"><input type="text" name="pg1_pl5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl5",""))%>" maxlength="7"/></td>
									<td align="center"><input type="text" name="pg1_gst5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst5",""))%>" maxlength="4" /></td>
									<td align="center"><input type="text" name="pg1_lb5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb5",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob5",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt5" name="pg1_cmt5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt5",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex5" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex5",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw5",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd5",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh5" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh5",""))%>" maxlength="12" /></td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym6" id="pg1_ym6" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym6",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym6_cal"></td>
									<td align="center"><input type="text" name="pg1_pl6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl6",""))%>" maxlength="7"/></td>
									<td align="center"><input type="text" name="pg1_gst6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst6",""))%>" maxlength="4" /></td>
									<td align="center"><input type="text" name="pg1_lb6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb6",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob6",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt6" name="pg1_cmt6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt6",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex6" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex6",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw6",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd6",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh6" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh6",""))%>" maxlength="12" /></td>
								</tr>
								<tr>
									<td align="center"><input type="text" name="pg1_ym7" id="pg1_ym7" placeholder="YYYY/MM" style="width: 65%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ym7",""))%>" maxlength="7" /><img src="../images/cal.gif" id="pg1_ym7_cal"></td>
									<td align="center"><input type="text" name="pg1_pl7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_pl7",""))%>" maxlength="7" /></td>
									<td align="center"><input type="text" name="pg1_gst7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_gst7",""))%>" maxlength="4" /></td>
									<td align="center"><input type="text" name="pg1_lb7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_lb7",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_tob7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_tob7",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" id="pg1_cmt7" name="pg1_cmt7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cmt7",""))%>" maxlength="95" /></td>
									<td align="center"><input type="text" name="pg1_sex7" style="width: 35%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sex7",""))%>" maxlength="1" /></td>
									<td align="center"><input type="text" name="pg1_brw7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_brw7",""))%>" maxlength="6" /></td>
									<td align="center"><input type="text" name="pg1_bfd7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_bfd7",""))%>" maxlength="8" /></td>
									<td align="center"><input type="text" name="pg1_curh7" style="width: 80%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_curh7",""))%>" maxlength="12" /></td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<table class="shrinkMe" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr bgcolor="#99FF99">
						<td align="center" colspan="3" bgcolor="#437bb7" style="height: 26px;color: #fff;"><b>Medical History (provide details in comments)</b></td>
					</tr>
				</table>
				<div class="clearfix medical_history_wrap">
					<div style="width: 25%; float: left;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Current Pregnancy</b></td>
							</tr>
							<tr>
								<td width="5%" align="center">1</td>
								<td>Bleeding</td>
								<td style="width:11%"><input type="checkbox" name="pg1_bldY" <%= props.getProperty("pg1_bldY") %>/>Y</td>
								<td style="width:11%"><input type="checkbox" name="pg1_bldN" class="noCheckbox" <%= props.getProperty("pg1_bldN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">2</td>
								<td>Nausea/vomiting</td>
								<td><input type="checkbox" name="pg1_nasY" <%= props.getProperty("pg1_nasY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_nasN" class="noCheckbox" <%= props.getProperty("pg1_nasN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">3</td>
								<td>Rash/fever/illness</td>
								<td><input type="checkbox" name="pg1_rashY" <%= props.getProperty("pg1_rashY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_rashN" class="noCheckbox" <%= props.getProperty("pg1_rashN") %>/>N</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Nutrition</b></td>
							</tr>
							<tr>
								<td width="5%" align="center">4</td>
								<td>Calcium adequate</td>
								<td><input type="checkbox" name="pg1_clcY" <%= props.getProperty("pg1_clcY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_clcN"  class="noCheckbox" <%= props.getProperty("pg1_clcN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">5</td>
								<td>Vitamin D adequate</td>
								<td><input type="checkbox" name="pg1_vDAY" <%= props.getProperty("pg1_vDAY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_vDAN" class="noCheckbox" <%= props.getProperty("pg1_vDAN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">6</td>
								<td>Folic acid preconception</td>
								<td><input type="checkbox" name="pg1_acPY" <%= props.getProperty("pg1_acPY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_acPN" class="noCheckbox" <%= props.getProperty("pg1_acPN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">7</td>
								<td>Prenatal vitamin</td>
								<td><input type="checkbox" name="pg1_prVY" <%= props.getProperty("pg1_prVY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_prVN" class="noCheckbox" <%= props.getProperty("pg1_prVN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">8</td>
								<td>Food access/quality adequate</td>
								<td><input type="checkbox" name="pg1_fAQY" <%= props.getProperty("pg1_fAQY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_fAQN" class="noCheckbox" <%= props.getProperty("pg1_fAQN") %>/>N</td>
							</tr>
							<tr>
								<td width="5%" align="center">9</td>
								<td>Dietary restrictions</td>
								<td><input type="checkbox" name="pg1_dRstY" <%= props.getProperty("pg1_dRstY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_dRstN" class="noCheckbox" <%= props.getProperty("pg1_dRstN") %>/>N</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Surgical History</b></td>
							</tr>
							<tr>
								<td width="6%" align="center">10</td>
								<td>Surgery</td>
								<td><input type="checkbox" name="pg1_sSrgY" <%= props.getProperty("pg1_sSrgY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_sSrgN" class="noCheckbox" <%= props.getProperty("pg1_sSrgN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">11</td>
								<td>Anaesthetic complications</td>
								<td><input type="checkbox" name="pg1_srgACY" <%= props.getProperty("pg1_srgACY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_srgACN" class="noCheckbox" <%= props.getProperty("pg1_srgACN") %>/>N</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Medical History</b></td>
							</tr>
							<tr>
								<td width="8%" align="center">12</td>
								<td>Hypertension</td>
								<td><input type="checkbox" name="pg1_htY" <%= props.getProperty("pg1_htY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_htN" class="noCheckbox" <%= props.getProperty("pg1_htN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">13</td>
								<td>Cardiac / Pulmonary</td>
								<td><input type="checkbox" name="pg1_cpY" <%= props.getProperty("pg1_cpY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_cpN" class="noCheckbox" <%= props.getProperty("pg1_cpN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">14</td>
								<td>Endocrine</td>
								<td><input type="checkbox" name="pg1_edcY" <%= props.getProperty("pg1_edcY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_edcN" class="noCheckbox" <%= props.getProperty("pg1_edcN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">15</td>
								<td>GI / Liver</td>
								<td><input type="checkbox" name="pg1_giLY" <%= props.getProperty("pg1_giLY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_giLN" class="noCheckbox" <%= props.getProperty("pg1_giLN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">16</td>
								<td>Breast (incl. surgery)</td>
								<td><input type="checkbox" name="pg1_brsY" <%= props.getProperty("pg1_brsY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_brsN" class="noCheckbox" <%= props.getProperty("pg1_brsN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">17</td>
								<td>Gynecological (incl. surgery)</td>
								<td><input type="checkbox" name="pg1_gcY" <%= props.getProperty("pg1_gcY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_gcN" class="noCheckbox" <%= props.getProperty("pg1_gcN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">18</td>
								<td>Urinary tract</td>
								<td><input type="checkbox" name="pg1_urY" <%= props.getProperty("pg1_urY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_urN" class="noCheckbox" <%= props.getProperty("pg1_urN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">19</td>
								<td>MSK/Rheumatology</td>
								<td><input type="checkbox" name="pg1_rmY" <%= props.getProperty("pg1_rmY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_rmN" class="noCheckbox" <%= props.getProperty("pg1_rmN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">20</td>
								<td>Hematological</td>
								<td><input type="checkbox" name="pg1_hmY" <%= props.getProperty("pg1_hmY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_hmN" class="noCheckbox" <%= props.getProperty("pg1_hmN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">21</td>
								<td>Thromboembolic/coag</td>
								<td><input type="checkbox" name="pg1_thrY" <%= props.getProperty("pg1_thrY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_thrN" class="noCheckbox" <%= props.getProperty("pg1_thrN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">22</td>
								<td>Blood transfusion</td>
								<td><input type="checkbox" name="pg1_btY" <%= props.getProperty("pg1_btY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_btN" class="noCheckbox" <%= props.getProperty("pg1_btN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">23</td>
								<td>Neurological</td>
								<td><input type="checkbox" name="pg1_nrY" <%= props.getProperty("pg1_nrY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_nrN" class="noCheckbox" <%= props.getProperty("pg1_nrN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">24</td>
								<td>Other</td>
								<td><input type="checkbox" name="pg1_oth4Y" <%= props.getProperty("pg1_oth4Y") %>/>Y</td>
								<td><input type="checkbox" name="pg1_oth4N" class="noCheckbox" <%= props.getProperty("pg1_oth4N") %>/>N</td>
							</tr>
							<tr>
								<td colspan="4">
									&nbsp;<br/>&nbsp;<br/>&nbsp;<br/>
								</td>
							</tr>
						</table>
					</div>
					<div style="width: 45%; float: left;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Family History</b></td>
							</tr>
							<tr>
								<td width="6%" align="center">25</td>
								<td>Medical Conditions</td>
								<td width="6%"><input type="checkbox" name="pg1_mcY" <%= props.getProperty("pg1_mcY") %> />Y</td>
								<td width="6%"><input type="checkbox" name="pg1_mcN" class="noCheckbox" <%= props.getProperty("pg1_mcN") %> />N</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3">(e.g. diabetes, thyroid, hypertension, thromboembolic, anaesthetic,</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3">mental health).</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Genetic History of Gametes</b></td>
							</tr>
							<tr>
								<td width="6%" align="center">26</td>
								<td colspan="3">Ethnic/racial background:</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3">
									<span>Egg<input type="text" name="pg1_egg" style="width: 30%;margin-left: 17px;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_egg","")) %>" maxlength="18"/></span>
									<span style="margin-left: 20px;">Age<input type="text" name="pg1_fhAge" maxlength="3" style="width: 20%;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_fhAge","")) %>" maxlength="3" />Yrs</span>
								</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3">
									Sperm<input type="text" name="pg1_sperm" style="width: 30%;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sperm","")) %>" maxlength="18"/>
								</td>
							</tr>
							<tr>
								<td width="6%" align="center">27</td>
								<td>Carrier screening: at risk? </td>
								<td><input type="checkbox" name="pg1_csY" <%= props.getProperty("pg1_csY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_csN" class="noCheckbox" <%= props.getProperty("pg1_csN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td>Hemoglobinopathy screening (Asian, African, Middle Eastern,</td>
								<td><input type="checkbox" name="pg1_hsY" <%= props.getProperty("pg1_hsY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_hsN" class="noCheckbox" <%= props.getProperty("pg1_hsN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td colspan="7">Mediterranean, Hispanic, Caribbean)</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td>Tay-Sachs disease screening (Ashkenazi Jewish,</td>
								<td><input type="checkbox" name="pg1_tsY" <%= props.getProperty("pg1_tsY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_tsN" class="noCheckbox" <%= props.getProperty("pg1_tsN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td colspan="7">French Canadian, Acadian, Cajun)</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td>Ashkenazi Jewish screening panel </td>
								<td><input type="checkbox" name="pg1_espY" <%= props.getProperty("pg1_espY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_espN" class="noCheckbox" <%= props.getProperty("pg1_espN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%" align="center">28</td>
								<td>Genetic Family History</td>
								<td><input type="checkbox" name="pg1_fmY" <%= props.getProperty("pg1_fmY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_fmN" class="noCheckbox" <%= props.getProperty("pg1_fmN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td>Genetic conditions (e.g. CF, muscular dystrophy,</td>
								<td><input type="checkbox" name="pg1_cdY" <%= props.getProperty("pg1_cdY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_cdN" class="noCheckbox" <%= props.getProperty("pg1_cdN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td colspan="7">chromosomal disorder)</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td>Other (e.g. intellectual, birth defect, congenital heart,</td>
								<td><input type="checkbox" name="pg1_oth2Y" <%= props.getProperty("pg1_oth2Y") %>/>Y</td>
								<td><input type="checkbox" name="pg1_oth2N" class="noCheckbox" <%= props.getProperty("pg1_oth2N") %>/>N</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td colspan="7">developmental delay, recurrent pregnancy loss, stillbirth)</td>
							</tr>
							<tr>
								<td width="6%"></td>
								<td>Consanguinity</td>
								<td><input type="checkbox" name="pg1_csyY" <%= props.getProperty("pg1_csyY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_csyN" class="noCheckbox" <%= props.getProperty("pg1_csyN") %>/>N</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Infectious Disease</b></td>
							</tr>
							<tr>
								<td width="6%" align="center">29</td>
								<td>Varicella disease</td>
								<td width="6%"><input type="checkbox" name="pg1_vdsY" <%= props.getProperty("pg1_vdsY") %>/>Y</td>
								<td width="6%"><input type="checkbox" name="pg1_vdsN" class="noCheckbox" <%= props.getProperty("pg1_vdsN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%" align="center">30</td>
								<td>Varicella vaccine</td>
								<td><input type="checkbox" name="pg1_vvcY" <%= props.getProperty("pg1_vvcY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_vvcN" class="noCheckbox" <%= props.getProperty("pg1_vvcN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%" align="center">31</td>
								<td>HIV</td>
								<td><input type="checkbox" name="pg1_hivY" <%= props.getProperty("pg1_hivY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_hivN" class="noCheckbox" <%= props.getProperty("pg1_hivN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%" align="center">32</td>
								<td colspan="3">HSV <span>Self<input type="checkbox" name="pg1_hsvY" <%= props.getProperty("pg1_hsvY") %>/>Y
								<input type="checkbox" name="pg1_hsvN" class="noCheckbox" <%= props.getProperty("pg1_hsvN") %>/>N</span>
								<span style="padding-left:10px">Partner<input type="checkbox" name="pg1_hsvPY" <%= props.getProperty("pg1_hsvPY") %>/>Y
								<input type="checkbox" name="pg1_hsvPN" class="noCheckbox" <%= props.getProperty("pg1_hsvPN") %>/>N</span></td>
							</tr>
							<tr>
								<td width="6%" align="center">33</td>
								<td>STIs</td>
								<td><input type="checkbox" name="pg1_stiY" <%= props.getProperty("pg1_stiY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_stiN" class="noCheckbox" <%= props.getProperty("pg1_stiN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%" align="center">34</td>
								<td>At risk population (Hep C, TB, Parvo, Toxo)</td>
								<td><input type="checkbox" name="pg1_atRY" <%= props.getProperty("pg1_atRY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_atRN" class="noCheckbox" <%= props.getProperty("pg1_atRN") %>/>N</td>
							</tr>
							<tr>
								<td width="6%" align="center">35</td>
								<td>Other</td>
								<td><input type="checkbox" name="pg1_oth3Y" <%= props.getProperty("pg1_oth3Y") %>/>Y</td>
								<td><input type="checkbox" name="pg1_oth3N" class="noCheckbox" <%= props.getProperty("pg1_oth3N") %>/>N</td>
							</tr>
							<tr>
								<td colspan="4"> <br/><br/> </td>
							</tr>
						</table>
					</div>
					<div style="width: 30%; float: left;" class="medical_history_wrap_right">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="8" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Mental Health / Substance Use</b></td>
							</tr>
							<tr>
								<td width="8%" align="center">36</td>
								<td>Anxiety</td>
								<td>Past</td>
								<td width="10%"><input type="checkbox" name="pg1_apY" <%= props.getProperty("pg1_apY") %>/>Y</td>
								<td width="10%"><input type="checkbox" name="pg1_apN" class="noCheckbox" <%= props.getProperty("pg1_apN") %>/>N</td>
								<td>Present</td>
								<td width="10%"><input type="checkbox" name="pg1_aprY" <%= props.getProperty("pg1_aprY") %>/>Y</td>
								<td width="10%"><input type="checkbox" name="pg1_aprN" class="noCheckbox" <%= props.getProperty("pg1_aprN") %>/>N</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="7" align="right"><span>GAD-2 Score<input type="text" name="pg1_g2s" style="width: 30%;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_g2s","")) %>" maxlength="10"></span></td>
							</tr>
							<tr>
								<td width="8%" align="center">37</td>
								<td>Depression</td>
								<td>Past</td>
								<td><input type="checkbox" name="pg1_dpY" <%= props.getProperty("pg1_dpY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_dpN" class="noCheckbox" <%= props.getProperty("pg1_dpN") %>/>N</td>
								<td>Present</td>
								<td><input type="checkbox" name="pg1_dprY" <%= props.getProperty("pg1_dprY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_dprN" class="noCheckbox" <%= props.getProperty("pg1_dprN") %>/>N</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="7" align="right">PHQ-2 Score<input type="text" name="pg1_ph2s" style="width: 30%;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ph2s","")) %>" maxlength="10"></td>
							</tr>
							<tr>
								<td width="8%" align="center">38</td>
								<td colspan="5">Eating disorder</td>
								<td width="6%"><input type="checkbox" name="pg1_edY" <%= props.getProperty("pg1_edY") %>/>Y</td>
								<td width="6%"><input type="checkbox" name="pg1_edN" class="noCheckbox" <%= props.getProperty("pg1_edN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">39</td>
								<td colspan="5">Bipolar</td>
								<td><input type="checkbox" name="pg1_bplY" <%= props.getProperty("pg1_bplY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_bplN" class="noCheckbox" <%= props.getProperty("pg1_bplN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">40</td>
								<td colspan="5">Schizophrenia</td>
								<td><input type="checkbox" name="pg1_szY" <%= props.getProperty("pg1_szY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_szN" class="noCheckbox" <%= props.getProperty("pg1_szN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">41</td>
								<td colspan="5">Other</td>
								<td><input type="checkbox" name="pg1_oth4Y2" <%= props.getProperty("pg1_oth4Y2") %>/>Y</td>
								<td><input type="checkbox" name="pg1_oth4N2" class="noCheckbox" <%= props.getProperty("pg1_oth4N2") %>/>N</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="7">(e.g. PTSD, ADD, personality disorders)</td>
							</tr>
							<tr>
								<td width="8%" align="center">42</td>
								<td colspan="5">Smoked cig within past 6 months</td>
								<td><input type="checkbox" name="pg1_s6mY" <%= props.getProperty("pg1_s6mY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_s6mN" class="noCheckbox" <%= props.getProperty("pg1_s6mN") %>/>N</td>
							</tr>
							<tr>
								<td colspan="2"></td>
								<td colspan="6">Current smoking<span><input type="text" name="pg1_smk" style="width: 26%;margin-left: 20px;margin-right: 5px;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_smk","")) %>" maxlength="5"/>cig/day</span></td>
							</tr>
							<tr>
								<td width="8%" align="center">43</td>
								<td>Alcohol:</td>
								<td colspan="4">Ever drink alcohol?</td>
								<td><input type="checkbox" name="pg1_aleY" <%= props.getProperty("pg1_aleY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_aleN" class="noCheckbox" <%= props.getProperty("pg1_aleN") %>/>N</td>
							</tr>
							<tr>
								<td></td>
								<td>If Yes:</td>
								<td colspan="6"><span></span><span>Last drink: (when)</span><input type="text" name="pg1_ld" style="width: 40%;margin-left: 25px;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ld","")) %>" maxlength="10" /></td>
							</tr>
							<tr>
								<td colspan="2"></td>
								<td colspan="6"><span>Current drinking</span><span><input type="text" name="pg1_cd" style="width: 26%;margin-left: 15px;margin-right: 5px;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cd","")) %>" maxlength="10"/>drink/wk</span></td>
							</tr>
							<tr>
								<td colspan="2"></td>
								<td colspan="6"><span>T-ACE Score</span><span><input type="text" name="pg1_ts" style="width: 40%;margin-left: 54px;border-bottom: 1px solid #333;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_ts","")) %>"  maxlength=10"/></span></td>
							</tr>
							<tr>
								<td width="8%" align="center">44</td>
								<td colspan="5">Marijuana</td>
								<td><input type="checkbox" name="pg1_mjY" <%= props.getProperty("pg1_mjY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_mjN" class="noCheckbox" <%= props.getProperty("pg1_mjN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">45</td>
								<td colspan="5">Non-prescribed substances/drugs</td>
								<td><input type="checkbox" name="pg1_npsY" <%= props.getProperty("pg1_npsY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_npsN" class="noCheckbox" <%= props.getProperty("pg1_npsN") %>/>N</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td colspan="4" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>
								Lifestyle/Social</b></td>
							</tr>
							<tr>
								<td width="8%" align="center">46</td>
								<td>Occupational risks</td>
								<td><input type="checkbox" name="pg1_ocrY" <%= props.getProperty("pg1_ocrY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_ocrN" class="noCheckbox" <%= props.getProperty("pg1_ocrN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">47</td>
								<td>Financial/housing issues</td>
								<td><input type="checkbox" name="pg1_fhY" <%= props.getProperty("pg1_fhY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_fhN" class="noCheckbox" <%= props.getProperty("pg1_fhN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">48</td>
								<td>Poor social support</td>
								<td><input type="checkbox" name="pg1_ssY" <%= props.getProperty("pg1_ssY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_ssN" class="noCheckbox" <%= props.getProperty("pg1_ssN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">49</td>
								<td>Beliefs/practices affecting care</td>
								<td><input type="checkbox" name="pg1_bpY" <%= props.getProperty("pg1_bpY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_bpN" class="noCheckbox" <%= props.getProperty("pg1_bpN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">50</td>
								<td>Relationship problems</td>
								<td><input type="checkbox" name="pg1_rpY" <%= props.getProperty("pg1_rpY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_rpN" class="noCheckbox" <%= props.getProperty("pg1_rpN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">51</td>
								<td>Intimate partner/family violence</td>
								<td><input type="checkbox" name="pg1_pvY" <%= props.getProperty("pg1_pvY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_pvN" class="noCheckbox" <%= props.getProperty("pg1_pvN") %>/>N</td>
							</tr>
							<tr>
								<td width="8%" align="center">52</td>
								<td>Parenting concerns</td>
								<td><input type="checkbox" name="pg1_pcoY" <%= props.getProperty("pg1_pcoY") %>/>Y</td>
								<td><input type="checkbox" name="pg1_pcoN" class="noCheckbox" <%= props.getProperty("pg1_pcoN") %>/>N</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3">(e.g. developmental disability, family trauma)</td>
							</tr>
							<tr>
								<td width="8%" align="center">53</td>
								<td>Other</td>
								<td><input type="checkbox" name="pg1_oth5Y" <%= props.getProperty("pg1_oth5Y") %>/>Y</td>
								<td><input type="checkbox" name="pg1_oth5N" class="noCheckbox" <%= props.getProperty("pg1_oth5N") %>/>N</td>
							</tr>
						</table>
					</div>
				</div>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td colspan="4" align="center" bgcolor="#437bb7" style="color: #fff;"><b><font
							face="Verdana, Arial, Helvetica, sans-serif"> Comments</font></b></td>
					</tr>
					<tr>
 						<td colspan="4"><textarea name="pg1_cm1" class="form-control" style="width:98%;resize: none;border: 0;" rows="6" cols="160" maxlength="960" ><%= UtilMisc.htmlEscape(props.getProperty("pg1_cm1","")) %></textarea></td>
					</tr>
					<tr>
						<td colspan="2">Completed By<br><input type="text" name="pg1_cb" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_cb","")) %>"  maxlength="52"></td>
						<td colspan="2">Reviewed By<br><input type="text" name="pg1_rb" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_rb","")) %>" maxlength="52"></td>
					</tr>
					<tr>
						<td style="vertical-align: text-top;">Signature<br/>
						<!--  <input type="text" name="pg1_sign" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_sign","")) %>"> -->
						</td>
						<td>Date<br><input type="text" name="pg1_date" id="pg1_date" placeholder="YYYY/MM/DD" style="width: 90%" class="spe" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_date","")) %>" 
							maxlength="10" onDblClick="calToday(this)"><img src="../images/cal.gif" id="pg1_date_cal"></td>
						<td style="vertical-align: text-top;">MRP Signature<br>
<!--  						<input type="text" name="pg1_mrps" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_mrps","")) %>"> -->
						</td>
						<td>Date<br><input type="text" name="pg1_mrpd" id="pg1_mrpd" placeholder="YYYY/MM/DD" style="width: 90%" class="spe" value="<%= UtilMisc.htmlEscape(props.getProperty("pg1_mrpd","")) %>"  
							maxlength="10" onDblClick="calToday(this)"><img src="../images/cal.gif" id="pg1_mrpd_cal"></td>
					</tr>
				</table>
			</div>
		</div>
	</div>
	</html:form>
	<% if (bView || (props.getProperty("pg1_lockPage", "") != "")) { %>
<script type="text/javascript">
window.onload= function() {
	setLock(true);
}
</script>
<% } %>
			
</body>
</html:html>
<script type="text/javascript">
Calendar.setup({ inputField : "pg1_lmp", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_lmp_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_luse", ifFormat : "%Y/%m", showsTime :false, button : "pg1_luse_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_edbLm", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_edbLm_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "c_fedb", ifFormat : "%Y/%m/%d", showsTime :false, button : "c_fedb_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_iuid", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_iuid_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_embTd", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_embTd_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym1", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym1_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym2", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym2_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym3", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym3_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym4", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym4_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym5", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym5_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym6", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym6_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_ym7", ifFormat : "%Y/%m", showsTime :false, button : "pg1_ym7_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_date", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_date_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg1_mrpd", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg1_mrpd_cal", singleClick : true, step : 1 });
</script>