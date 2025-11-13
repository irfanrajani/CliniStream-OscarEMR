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
<!DOCTYPE html>
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

String formClass = "AR2017";
String formLink = "formAR2017Record4.jsp";

boolean bView = false;
if (request.getParameter("view") != null && request.getParameter("view").equals("1")) bView = true; 

int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
int formId = Integer.parseInt(request.getParameter("formId"));
int provNo = Integer.parseInt((String) session.getAttribute("user"));

FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
Properties props = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request), demoNo, formId);

//get project_home
String project_home = request.getContextPath().substring(1); 

%>
<%@page import="oscar.OscarProperties"%>
<%@ page import="oscar.form.graphic.*, oscar.util.*, oscar.form.*, oscar.form.data.*"%>
<%@ page import="java.util.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<!--add for con report-->
<%@ taglib uri="http://www.caisi.ca/plugin-tag" prefix="plugin" %>
<%@page import="org.oscarehr.util.LoggedInInfo" %>


<html>
<head>
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
</head>

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
       		} else if ((formElems[i].type == "checkbox")/* && (formElems[i].id != "pg4_lockPage") && (formElems[i].id != "pg4_4ColCom")*/) {
           		formElems[i].disabled = checked;
    		}
    	}
    }
    
    function refreshOpener() {
   		if (window.opener && window.opener.name=="inboxDocDetails") {
   			window.opener.location.reload(true);
   		}	
    }
       
//    window.onunload=refreshOpener;
       
    function onPrint() {
        document.forms[0].submit.value="print"; 
        var ret = checkAllDates();
		ret = true;
        setLock(false);
        if(ret==true)
        {
        	if( document.forms[0].c_fedb.value == "" /*&& !confirm("<bean:message key="oscarEncounter.formOnar.msgNoEDB"/>")*/) {
                alert('Please set Final EDB before printing');
                ret = false;
            }
            else {
                document.forms[0].action = "../form/createpdf?__title=Antenatal+Record+Part+3+Appendix&__cfgfile=ar2017PrintCfgPg4&__template=ar2017pg4";
                document.forms[0].target="_blank";       
            }
                
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

    function onSave() {
        document.forms[0].submit.value="save";
//evktest        var ret = checkAllDates();
var ret = true;
        if(ret==true) {
            reset();
            ret = confirm("Are you sure you want to save this form?");
        }
        return ret;
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
        document.forms[0].submit.value="exit";
      //evktest        var ret = checkAllDates();
        var ret = true;
        if(ret == true) {
            reset();
            ret = confirm("Are you sure you wish to save and close this window?");
        }
        return ret;
    }
    
    function onPageChange(url) {
       	var result = false;
       	var newID = 0;
       	document.forms[0].submit.value="save";
          
           //var ret = checkAllDates();      
        //	  if(ret==true)
       //    {
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
      //     }
           
           if(result == true) {
           	url = url.replace('#id',newID);
           	location.href=url;
           }
             
          return;
       }
    
    function popupPage(varpage) {
        windowprops = "height=960,width=1280"+
            ",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=no,screenX=50,screenY=50,top=20,left=20";
        var popup = window.open(varpage, "ar1", windowprops);
        if (popup.opener == null) {
            popup.opener = self;
        }
    }
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
/*    
function popupFixedPage(vheight,vwidth,varpage) { 
  var page = "" + varpage;
  windowprop = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=10,screenY=0,top=0,left=0";
  var popup=window.open(page, "planner", windowprop);
}
*/
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
		
		//if(isNumber(feet) && isNumber(inch) )
			height = Math.round((feet * 30.48 + inch * 2.54) * 10) / 10 ;
			if(confirm("Are you sure you want to change " + feet + " feet " + inch + " inch(es) to " + height +"cm?") ) {
				obj.value = height;
			}
		//}
	}
}

function calcBMIMetric(obj) {
   	if(isNumber(document.forms[0].c_ppwt) && isNumber(document.forms[0].c_ppht)) {
   		weight = document.forms[0].c_ppwt.value / 1;
   		height = document.forms[0].c_ppht.value / 100;
   		if(weight!="" && weight!="0" && height!="" && height!="0") {
   			obj.value = Math.round(weight * 10 / height / height) / 10;
   		} else obj.value = '0.0';
   	}
}

/**
 * DHTML date validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
 */
// Declaring valid date character, minimum year and maximum year
var dtCh= "/";
var minYear=1900;
var maxYear=9900;

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
        } /* else
        if(valDate(document.forms[0].pg4_lp)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_cdDate)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_nod)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_ud1)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate2)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate3)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate4)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate5)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate6)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate7)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate8)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate9)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate10)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate11)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate12)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg4_usDate13)==false){
            b = false;
        }
*/        
        return b;
    }

function calcWeek(id) {
	source = $("#"+id);
	<%
	String fedb = props.getProperty("c_fedb", "");
	String sDate = "";
	if (!fedb.equals("") && fedb.length()==10 ) {
		FrmGraphicAR arG = new FrmGraphicAR();
		java.util.Date edbDate = arG.getStartDate(fedb);
	    sDate = UtilDateUtilities.DateToString(edbDate, "MMMMM dd, yyyy"); //"yy,MM,dd");
	%>
		    var fedb = "<%=fedb%>";
		    if(fedb == '') return;
			var delta = 0;
	        var str_date = getDateField(source.attr('name'));
	        if (str_date.length < 8) return;
	        var yyyy = "20"+str_date.substring(0, str_date.indexOf("/"));
	        var mm = eval(str_date.substring(eval(str_date.indexOf("/")+1), str_date.lastIndexOf("/")) - 1);
	        var dd = str_date.substring(eval(str_date.lastIndexOf("/")+1));
	        var check_date=new Date(yyyy,mm,dd);
	        var start=new Date("<%=sDate%>");

			if (check_date.getUTCHours() != start.getUTCHours()) {
				if (check_date.getUTCHours() > start.getUTCHours()) {
				    delta = -1 * 60 * 60 * 1000;
				} else {
				    delta = 1 * 60 * 60 * 1000;
				}
			} 
			var day = eval((check_date.getTime() - start.getTime() + delta) / (24*60*60*1000));
			if(isNaN(day)) return;
	        var week = Math.floor(day/7);
			var weekday = day%7;
	        source.val(week + "w+" + weekday);
<%    }  %>
	}


			function getDateField(name) {
				var temp = ""; //pg2_gest1 - pg2_date1
				var n1 = name.substring(eval(name.indexOf("_svg")+4));
				var n2 = name.substring(0,eval(name.indexOf("_svg")));
				
				name = n2 + '_svd' + n1;
		/*
				if(name.indexOf("ar2_")>=0) {
					n1 = name.substring(eval(name.indexOf("A")+1));
					name = "ar2_uDate" + n1;
				} else if (n1>36) {
					name = "pg4_date" + n1;
				} else if (n1<=36 && n1>18) {
					name = "pg4_date" + n1;
				} else {
					name = "pg2_date" + n1;
				}
		*/        
		        for (var i =0; i <document.forms[0].elements.length; i++) {
		            if (document.forms[0].elements[i].name == name) {
		               return document.forms[0].elements[i].value;
		    	    }
			    }
		        return temp;
		    }
	
	function calToday(field) {
		var calDate=new Date();
		varMonth = calDate.getMonth()+1;
		varMonth = varMonth>9? varMonth : ("0"+varMonth);
		varDate = calDate.getDate()>9? calDate.getDate(): ("0"+calDate.getDate());
		var year = calDate.getFullYear()+'';
		field.value = year.substring(0,2) + '/' + varMonth + '/' + varDate;
	}
	
	jQuery(document).ready(function() {
   		window.resizeTo(screen.availWidth-20,screen.availHeight-20);
        
   		window.onunload=refreshOpener;

   		var lockValue = "<%= props.getProperty("pg1_lockPage", "") %>";
        wasLocked = (lockValue.length > 0 ? true : false);
        setLock(wasLocked);

   		var formNo = '<%= formId %>';		
        if(formNo == 0) {
            $("input.noCheckbox").attr("checked", true);
   		}
   	});

</script>

<body>
	<html:form action="/form/formname">

	<input type="hidden" name="commonField" value="ar2_" />
	<input type="hidden" name="c_lastVisited"
		value=<%=props.getProperty("c_lastVisited", "pg4")%> />
	<input type="hidden" name="demographic_no"
		value="<%= props.getProperty("demographic_no", "0") %>" />
	<input type="hidden" name="formCreated"
		value="<%= props.getProperty("formCreated", "") %>" />
	<input type="hidden" name="form_class" value="<%=formClass%>" />
	<input type="hidden" name="form_link" value="<%=formLink%>" />
	<input type="hidden" name="formId" value="<%=formId%>" />
	<input type="hidden" name="ID"
		value="<%= props.getProperty("ID", "0") %>" />
	<input type="hidden" name="provider_no"
		value=<%=request.getParameter("provNo")%> />
	<input type="hidden" name="provNo"
		value="<%= request.getParameter("provNo") %>" />
	<input type="hidden" name="submit" value="exit" />
	<input type="hidden" name="c_ppht" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ppht","")) %>"/>

<table class="Head" class="hidePrint">
	<tr>
		<td align="left">
		<%if (!bView) {%> 
			<input type="submit" value="Save" onclick="javascript:return onSave();" /> 
			<input type="submit" value="Save and Exit" onclick="javascript:return onSaveExit();" /> 
		<%}%> 
			<input type="submit" value="Exit" onclick="javascript:return onExit();" /> 
			<input type="submit" value="Print" onclick="javascript:return onPrint();" />
			<input type="submit" value="Print All" onclick="javascript:return onPrintAll();" />
		</td>
		<%if (!bView) {%>
		<td align="right">
			<b>View:</b> 
			<a href="javascript: popupPage('formAR2017Record1.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR1
			</a> | 
			<a href="javascript: popupPage('formAR2017Record2.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR2 
			</a> &nbsp;
			</a> | 
			<a href="javascript: popupPage('formAR2017Record3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR3 
			</a> &nbsp;
		</td>
		<td align="right">
			<b>Edit:</b>
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record1.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR1
			</a> | 
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record2.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR2
			</a> |
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record3.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR3
			</a>
			 |
			<%if(((FrmAR2017Record)rec).isSendToPing(""+demoNo)) {	%> 
				<a href="study/ar2ping.jsp?demographic_no=<%=demoNo%>">Send to PING</a>
			<% }	%>
			</td>
			<%
  			}
			%>
		</tr>
	</table>
	<div class="container">
		<div class="ontario_record_wrap">
			<div class="ontario_record_header">
				<div class="row">
					<div class="col-md-8">
						<p>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ministry of Health and Long-Term Care</span>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ontario Perinatal Record 3 Appendix</span>
						</p>
					</div>	
				</div>
			</div>
			<div class="ontario_record_content">
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" width="30%">Last Name<br>
							<input type="text" name="c_fn" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ln",""))%>" maxlength="35" />
						</td>
						<td valign="top" width="30%">First Name<br>
							<input type="text" name="c_ln" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fn",""))%>" maxlength="40" />
						</td>
						<td valign="top">Planned Birth Attendant<br>
							<input type="text" name="c_pba" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_pba",""))%>" maxlength="30" />
						</td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" colspan="7">Newborn Care Provider<br>
							<span>In Hospital<input type="text" name="c_nbcph" style="width: 30%; margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_nbcph",""))%>" maxlength="25"/></span>
							<span>In Community<input type="text" name="c_nbcpc" style="width: 30%; margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_nbcpc",""))%>" maxlength="25"/></span>
						</td>
						<td valign="top">Allergies or Sensitivities (include reaction)<br>
							<input type="text" name="c_alrg" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_alrg",""))%>" maxlength="65" /></td>
					</tr>
					<tr>
						<td valign="top" colspan="7" width="45%">Family Physician/Primary Care Provider<br><input type="text" name="c_fph" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fph",""))%>" maxlength="" /></td>
						<td rowspan="2" valign="top" width="55%">Medications  (include Rx/OTC, complementary/alternative/vitamins, include dosage)<br>
						<textarea name="c_medc" style="margin-left:5px;resize: none;border: 1;height: 50px;width:95%" rows="1" cols="95" maxlength="95"><%= props.getProperty("c_medc") %></textarea>
						</td>
					</tr>
					<tr>
						<td>G<br><input type="text" name="c_g" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_g",""))%>" maxlength="7" /></td>
						<td>T<br><input type="text" name="c_t" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_t",""))%>" maxlength="9" /></td>
						<td>P<br><input type="text" name="c_p" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_p",""))%>" maxlength="9" /></td>
						<td>A<br><input type="text" name="c_a" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_a",""))%>" maxlength="9" /></td>
						<td>L<br><input type="text" name="c_l" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_l",""))%>" maxlength="9" /></td>
						<td>S<br><input type="text" name="c_s" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_s",""))%>" maxlength="9" /></td>
						<td>Final EDB<br><input type="text" name="c_fedb" id="c_fedb" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fedb",""))%>" size="10" maxlength="10" /><img src="../images/cal.gif" id="c_fedb_cal"></td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td colspan="6">Pre-pregnancy Wt <input type="text" name="c_ppwt" style="border-bottom: 1px solid #333; width: 30%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ppwt",""))%>" onchange="calcBMIMetric($('input[name=c_ppbmi]').get(0))">
						<span style="padding-left:20px"/>
						BMI <input type="text" name="c_ppbmi" style="border-bottom: 1px solid #333; width: 30%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ppbmi",""))%>" ></strong></td>
						<td colspan="6" bgcolor="#CCCCCC" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;">
						<div align="center"><b>Subsequent Visits</b></div>
						</td>
					</tr>
					<tr>
						<th style="text-align: center;" width="6%">Date</th>
						<th style="text-align: center;" width="6%">GA<br>(wks/days)</th>
						<th style="text-align: center;" width="6%">Weight<br>(kg)</th>
						<th style="text-align: center;" width="6%">BP</th>
						<th style="text-align: center;" width="6%">Urine<br>Prot.</th>
						<th style="text-align: center;" width="5%">SFH</th>
						<th style="text-align: center;" width="6%">Pres.</th>
						<th style="text-align: center;" width="5%">FHR</th>
						<th style="text-align: center;" width="5%">FM</th>
						<th style="text-align: center;">Comments</th>
						<th style="text-align: center;" width="6%">Next<br>Visit</th>
						<th style="text-align: center;" width="6%">Initial(s)</th>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd1" id="pg4_svd1" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd1",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg1')" onChange="calcWeek('pg4_svg1')"><img src="../images/cal.gif" id="pg4_svd1_cal"></td>
						<td align="center"><input type="text" name="pg4_svg1" id="pg4_svg1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg1",""))%>","") maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc1" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc1",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi1",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd2" id="pg4_svd2" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd2",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg2')" onChange="calcWeek('pg4_svg2')"><img src="../images/cal.gif" id="pg4_svd2_cal"></td>
						<td align="center"><input type="text" name="pg4_svg2" id="pg4_svg2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg2",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc2" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc2",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi2",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd3" id="pg4_svd3" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd3",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg3')" onChange="calcWeek('pg4_svg3')"><img src="../images/cal.gif" id="pg4_svd3_cal"></td>
						<td align="center"><input type="text" name="pg4_svg3" id="pg4_svg3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg3",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc3" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc3",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi3",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd4" id="pg4_svd4" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd4",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg4')" onChange="calcWeek('pg4_svg4')"><img src="../images/cal.gif" id="pg4_svd4_cal"></td>
						<td align="center"><input type="text" name="pg4_svg4" id="pg4_svg4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg4",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc4" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc4",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi4",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd5" id="pg4_svd5" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd5",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg5')" onChange="calcWeek('pg4_svg5')"><img src="../images/cal.gif" id="pg4_svd5_cal"></td>
						<td align="center"><input type="text" name="pg4_svg5" id="pg4_svg5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg5",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc5" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc5",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi5",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd6" id="pg4_svd6" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd6",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg6')" onChange="calcWeek('pg4_svg6')"><img src="../images/cal.gif" id="pg4_svd6_cal"></td>
						<td align="center"><input type="text" name="pg4_svg6" id="pg4_svg6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg6",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc6" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc6",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi6",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd7" id="pg4_svd7" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd7",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg7')" onChange="calcWeek('pg4_svg7')"><img src="../images/cal.gif" id="pg4_svd7_cal"></td>
						<td align="center"><input type="text" name="pg4_svg7" id="pg4_svg7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg7",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc7" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc7",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi7",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd8" id="pg4_svd8" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd8",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg8')" onChange="calcWeek('pg4_svg8')"><img src="../images/cal.gif" id="pg4_svd8_cal"></td>
						<td align="center"><input type="text" name="pg4_svg8" id="pg4_svg8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg8",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc8" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc8",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi8",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd9" id="pg4_svd9" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd9",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg9')" onChange="calcWeek('pg4_svg9')"><img src="../images/cal.gif" id="pg4_svd9_cal"></td>
						<td align="center"><input type="text" name="pg4_svg9" id="pg4_svg9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg9",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc9" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc9",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi9",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd10" id="pg4_svd10" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd10",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg10')" onChange="calcWeek('pg4_svg10')"><img src="../images/cal.gif" id="pg4_svd10_cal"></td>
						<td align="center"><input type="text" name="pg4_svg10" id="pg4_svg10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg10",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc10" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc10",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi10",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd11" id="pg4_svd11" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd11",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg11')" onChange="calcWeek('pg4_svg11')"><img src="../images/cal.gif" id="pg4_svd11_cal"></td>
						<td align="center"><input type="text" name="pg4_svg11" id="pg4_svg11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg11",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc11" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc11",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi11",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg4_svd12" id="pg4_svd12" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd12",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg12')" onChange="calcWeek('pg4_svg12')"><img src="../images/cal.gif" id="pg4_svd12_cal"></td>
						<td align="center"><input type="text" name="pg4_svg12" id="pg4_svg12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg12",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc12" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc12",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi12",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd13" id="pg4_svd13" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd13",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg13')" onChange="calcWeek('pg4_svg13')"><img src="../images/cal.gif" id="pg4_svd13_cal"></td>
						<td align="center"><input type="text" name="pg4_svg13" id="pg4_svg13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg13",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc13" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc13",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi13",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd14" id="pg4_svd14" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd14",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg14')" onChange="calcWeek('pg4_svg14')"><img src="../images/cal.gif" id="pg4_svd14_cal"></td>
						<td align="center"><input type="text" name="pg4_svg14" id="pg4_svg14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg14",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc14" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc14",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi14",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd15" id="pg4_svd15" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd15",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg15')" onChange="calcWeek('pg4_svg15')"><img src="../images/cal.gif" id="pg4_svd15_cal"></td>
						<td align="center"><input type="text" name="pg4_svg15" id="pg4_svg15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg15",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc15" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc15",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi15",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd16" id="pg4_svd16" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd16",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg16')" onChange="calcWeek('pg4_svg16')"><img src="../images/cal.gif" id="pg4_svd16_cal"></td>
						<td align="center"><input type="text" name="pg4_svg16" id="pg4_svg16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg16",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc16" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc16",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi16",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd17" id="pg4_svd17" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd17",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg17')" onChange="calcWeek('pg4_svg17')"><img src="../images/cal.gif" id="pg4_svd17_cal"></td>
						<td align="center"><input type="text" name="pg4_svg17" id="pg4_svg17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg17",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc17" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc17",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn17",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi17" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi17",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd18" id="pg4_svd18" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd18",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg18')" onChange="calcWeek('pg4_svg18')"><img src="../images/cal.gif" id="pg4_svd18_cal"></td>
						<td align="center"><input type="text" name="pg4_svg18" id="pg4_svg18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg18",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc18" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc18",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn18",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi18" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi18",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd19" id="pg4_svd19" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd19",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg19')" onChange="calcWeek('pg4_svg19')"><img src="../images/cal.gif" id="pg4_svd19_cal"></td>
						<td align="center"><input type="text" name="pg4_svg19" id="pg4_svg19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg19",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc19" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc19",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn19",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi19" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi19",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd20" id="pg4_svd20" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd20",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg20')" onChange="calcWeek('pg4_svg20')"><img src="../images/cal.gif" id="pg4_svd20_cal"></td>
						<td align="center"><input type="text" name="pg4_svg20" id="pg4_svg20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg20",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc20" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc20",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn20",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi20" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi20",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd21" id="pg4_svd21" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd21",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg21')" onChange="calcWeek('pg4_svg21')"><img src="../images/cal.gif" id="pg4_svd21_cal"></td>
						<td align="center"><input type="text" name="pg4_svg21" id="pg4_svg21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg21",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc21" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc21",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn21",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi21" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi21",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd22" id="pg4_svd22" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd22",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg22')" onChange="calcWeek('pg4_svg22')"><img src="../images/cal.gif" id="pg4_svd22_cal"></td>
						<td align="center"><input type="text" name="pg4_svg22" id="pg4_svg22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg22",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc22" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc22",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn22",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi22" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi22",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd23" id="pg4_svd23" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd23",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg23')" onChange="calcWeek('pg4_svg23')"><img src="../images/cal.gif" id="pg4_svd23_cal"></td>
						<td align="center"><input type="text" name="pg4_svg23" id="pg4_svg23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg23",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc23" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc23",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn23",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi23" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi23",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd24" id="pg4_svd24" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd24",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg24')" onChange="calcWeek('pg4_svg24')"><img src="../images/cal.gif" id="pg4_svd24_cal"></td>
						<td align="center"><input type="text" name="pg4_svg24" id="pg4_svg24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg24",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc24" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc24",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn24",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi24" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi24",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg4_svd25" id="pg4_svd25" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svd25",""))%>" maxlength="8" class="spe" onDblClick="calToday(this); calcWeek('pg4_svg25')" onChange="calcWeek('pg4_svg25')"><img src="../images/cal.gif" id="pg4_svd25_cal"></td>
						<td align="center"><input type="text" name="pg4_svg25" id="pg4_svg25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svg25",""))%>" maxlength="7" ></td>
						<td align="center"><input type="text" name="pg4_svw25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svw25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svb25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svb25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svu25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svu25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svs25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svs25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svp25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svp25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfh25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfh25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svfm25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svfm25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svc25" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svc25",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg4_svn25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svn25",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg4_svi25" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg4_svi25",""))%>" maxlength="8"></td>
					</tr>					
				</table>
			</div>
		</div>
	</div>
	</html:form>
<% if (bView) { %>
<script type="text/javascript">
window.onload= function() {
	setLock(true);
}
</script>
<% } %>	
</body>
</html>
<script type="text/javascript">
Calendar.setup({ inputField : "c_fedb", ifFormat : "%Y/%m/%d", showsTime :false, button : "c_fedb_cal", singleClick : true, step : 1 });
//Calendar.setup({ inputField : "pg4_rhl", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_rhl_cal", singleClick : true, step : 1 });
//Calendar.setup({ inputField : "pg4_add", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_add_cal", singleClick : true, step : 1 });
//Calendar.setup({ inputField : "pg4_prY2", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_prY2_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd1", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd1_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd2", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd2_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd3", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd3_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd4", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd4_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd5", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd5_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd6", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd6_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd7", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd7_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd8", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd8_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd9", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd9_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd10", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd10_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd11", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd11_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd12", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd12_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd13", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd13_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd14", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd14_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd15", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd15_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd16", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd16_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd17", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd17_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd18", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd18_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd19", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd19_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd20", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd20_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd21", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd21_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd22", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd22_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd23", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd23_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd24", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd24_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg4_svd25", ifFormat : "%y/%m/%d", showsTime :false, button : "pg4_svd25_cal", singleClick : true, step : 1 });
</script>
