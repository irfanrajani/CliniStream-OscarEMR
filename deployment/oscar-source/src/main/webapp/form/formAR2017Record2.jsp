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
String formLink = "formAR2017Record2.jsp";

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
//TODO
    		} else if ((formElems[i].type == "checkbox")/* && (formElems[i].id != "pg2_lockPage") && (formElems[i].id != "pg1_4ColCom")*/) {
            		formElems[i].disabled = checked;
    		}
    	}
    }
    
    function refreshOpener() {
   		if (window.opener && window.opener.name=="inboxDocDetails") {
   			window.opener.location.reload(true);
   		}	
    }
       
       
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
                document.forms[0].action = "../form/createpdf?__title=Antenatal+Record+Part+2&__cfgfile=ar2017PrintCfgPg2&__template=ar2017pg2";
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
          
       //    var ret = checkAllDates();         
      //  	  if(ret==true)
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
        //   }
           
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
//in this form, kg is hardcoded as measure unit: so dont need it?
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
//in this form, sm is hardcoded as measure unit: so dont need it?
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
        }else
        if(valDate(document.forms[0].pg2_lp)==false){
            b = false;
        }else
//        if(valDate(document.forms[0].pg2_cdDate)==false){
//           b = false;
//       }else
        if(valDate(document.forms[0].pg2_nod)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_ud1)==false){
            b = false;
        } /* else
        if(valDate(document.forms[0].pg2_usDate2)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate3)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate4)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate5)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate6)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate7)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate8)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate9)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate10)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate11)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate12)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg2_usDate13)==false){
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
			    var delta = 0;
		        var str_date = getDateField(source.attr('name'));
		        if (str_date.length < 8) return;
		        var yyyy = str_date.substring(0, str_date.indexOf("/"));
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
		<% } %>
		}
	
	function getDateField(name) {
		var temp = ""; //pg2_gest1 - pg2_date1
		var n1 = name.substring(eval(name.indexOf("_ug")+3));
		var n2 = name.substring(0,eval(name.indexOf("_ug")));
		
		name = n2 + '_ud' + n1;
/*
		if(name.indexOf("ar2_")>=0) {
			n1 = name.substring(eval(name.indexOf("A")+1));
			name = "ar2_uDate" + n1;
		} else if (n1>36) {
			name = "pg4_date" + n1;
		} else if (n1<=36 && n1>18) {
			name = "pg3_date" + n1;
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
		field.value = calDate.getFullYear() + '/' + (varMonth) + '/' + varDate;
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
		value=<%=props.getProperty("c_lastVisited", "pg2")%> />
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
			<a href="javascript: popupPage('formAR2017Record3.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR3&nbsp;
			</a> | 
			<a href="javascript: popupPage('formAR2017Record4.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR4&nbsp;
		</td>
		<td align="right">
			<b>Edit:</b>
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record1.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR1
			</a> | 
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record3.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR3
			</a> |
			<a href="javascript:void(0)" onclick="onPageChange('formAR2017Record4.jsp?demographic_no=<%=demoNo%>&formId=#id&provNo=<%=provNo%>');">
				AR4
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
<!--  					<div class="col-md-3"><img src="<%= request.getContextPath()%>/images/formonarrecord1.jpg"></div> -->
					<div class="col-md-9">
						<p>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ministry of Health and Long-Term Care</span>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ontario Perinatal Record 2</span>
						</p>
					</div>
				</div>
			</div>
			<div class="ontario_record_content">
				<table width="60%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" width="50%">Last Name<br>
							<input type="text" name="c_ln" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_ln","")) %>" maxlength="35" />
						</td>
						<td valign="top" colspan='3'>First Name<br>
							<input type="text" name="c_fn" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fn","")) %>" maxlength="40" />
						</td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td valign="top" colspan="8">Planned Birth Attendant<br>
							<input type="text" name="c_pba" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_pba","")) %>" maxlength="30" />
						</td>
					</tr>
					<tr>
						<td valign="top" colspan="8">Newborn Care Provider<br>
							<span>In Hospital<input type="text" name="c_nbcph" style="width: 30%;margin-left: 10px;margin-right: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_nbcph","")) %>" maxlength="25"/></span>
							<span>In Community<input type="text" name="c_nbcpc" style="width: 30%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_nbcpc")) %>" maxlength="25"/></span>
						</td>
					</tr>
					<tr>
						<td width="6%">G<br>
							<input type="text" name="c_g" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_g","")) %>" maxlength="7" />
						</td>
						<td width="6%">T<br>
							<input type="text" name="c_t" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_t","")) %>" maxlength="9" />
						</td>
						<td width="6%">P<br>
							<input type="text" name="c_p" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_p","")) %>" maxlength="9" />
						</td>
						<td width="6%">A<br>
							<input type="text" name="c_a" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_a","")) %>" maxlength="9" />
						</td>
						<td width="6%">L<br>
							<input type="text" name="c_l" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_l","")) %>" maxlength="9" />
						</td>
						<td width="6%">S<br>
							<input type="text" name="c_s" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_s","")) %>" maxlength="9" />
						</td>
						<td>Final EDB<br>
							<input type="text" name="c_fedb" id="c_fedb" style="width: 90%" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fedb","")) %>" maxlength="10" /><img src="../images/cal.gif" id="c_fedb_cal">
						</td>
						<td>Family Physician/Primary Care Provider<br>
							<input type="text" name="c_fph" style="width: 90%" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fph","")) %>" maxlength="55" />
						</td>
					</tr>
				</table>
				<div class="clearfix medical_history_wrap">
					<div style="width: 40%; float: left;">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="record_table">
							<tr bgcolor="#99FF99">
								<td align="center" colspan="2" bgcolor="#437bb7" style="border-left: 1px solid #333;height: 26px;border-bottom: 1px solid #333;color: #fff;"><b>Physical Exam</b></td>
							</tr>
							<tr>
								<td>Ht &nbsp;<input type="text" name="c_ppht" id="c_ppht" style="border-bottom: 1px solid #333; width: 60%;" 
									value="<%= UtilMisc.htmlEscape(props.getProperty("c_ppht","")) %>" maxlength="6" onchange="calcBMIMetric($('input[name=c_ppbmi]').get(0))"> cm</td>
								<td>Pre-pregnancy Wt &nbsp;&nbsp;<input type="text" id="c_ppwt" name="c_ppwt" style="border-bottom: 1px solid #333; width: 30%;" 
									value="<%= UtilMisc.htmlEscape(props.getProperty("c_ppwt","")) %>" maxlength="4" onchange="calcBMIMetric($('input[name=c_ppbmi]').get(0))"> kg</td>
							</tr>
							<tr>
								<td>BP <input type="text" name="pg2_bp"  style="border-bottom: 1px solid #333; width: 60%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_bp","")) %>" maxlength="7"></td>
								<td>Pre-pregnancy BMI 
									<input type="text" name="c_ppbmi" style="border-bottom: 1px solid #333; width: 30%;"
										value="<%= UtilMisc.htmlEscape(props.getProperty("c_ppbmi","")) %>" maxlength="5" onDblClick="calcBMIMetric(this);">
								</td>
							</tr>
						</table>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="record_table">
							<tr bgcolor="#99FF99">
								<td align="center" colspan="2" bgcolor="#CCCCCC" style="border-left: 1px solid #333;height: 26px;border-bottom: 1px solid #333;"><b>Exam As Indicated</b></td>
							</tr>
							<tr>
								<td width="25%">Head and neck</td>
								<td width="25%"><input type="text" name="pg2_hn" style="width: 70%; margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_hn","")) %>" maxlength="10"></td>
								<td width="25%">MSK</td>
								<td><input type="text" name="pg2_msk" style="width: 70%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_msk","")) %>" maxlength="7"></td>
							</tr>
							<tr>
								<td>Breast/nipples</td>
								<td><input type="text" name="pg2_bnp" style="width: 70%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_bnp","")) %>" maxlength="10"></td>
								<td>Pelvic</td>
								<td><input type="text" name="pg2_plv" style="width: 70%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_plv","")) %>" maxlength="7"></td>
							</tr>
							<tr>
								<td>Heart/lungs</td>
								<td><input type="text" name="pg2_hl" style="width: 70%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_hl","")) %>" maxlength="10"></td>
								<td>Other</td>
								<td><input type="text" name="pg2_oth" style="width: 70%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_oth","")) %>" maxlength="7"></td>
							</tr>
							<tr>
								<td>Abdomen</td>
								<td colspan="3'"><input type="text" name="pg2_abd" style="width: 90%;margin-left: 10px;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_abd","")) %>" maxlength="20"></td>
							</tr>
						</table>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="record_table">
							<tr bgcolor="#99FF99">
								<td align="center" colspan="4" bgcolor="#CCCCCC" style="border-left: 1px solid #333;border-bottom: 1px solid #333;height: 26px;"><b>Exam Comments</b></td>
							</tr>
							<tr>
						  		<td colspan="2"><textarea name="pg2_ec" class="form-control" style="resize: none;border: 0;height: 77px;" rows="4" cols="45" maxlength="180"><%= UtilMisc.htmlEscape(props.getProperty("pg2_ec","")) %></textarea></td> 
							</tr>
							<tr>
								<td valign="top" style="border-top: 1px solid #333;height: 52px;">Last Pap<br><input type="text" name="pg2_lp" id="pg2_lp" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_lp","")) %>" maxlength="10"><img src="../images/cal.gif" id="pg2_lp_cal"></td>
								<td valign="top" style="border-top: 1px solid #333;border-left: 1px solid #333;">Result<br><input type="text" name="pg2_res" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res","")) %>" maxlength="23"></td>
							</tr>
						</table>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="record_table">
							<tr bgcolor="#99FF99">
								<td align="center" bgcolor="#CCCCCC" style="border-left: 1px solid #333;height: 26px;border-bottom: 1px solid #333;"><b>Additional investigations as indicated</b></td>
							</tr>
							<tr>
								<td rowspan="2" valign="top">
									TSH, Diabetes screen, Hb Electrophoresis/ HPLC,<br/>
Ferritin, B12, Infectious diseases (e.g. Hep C, Parvo<br/>
B19, Varicella, Toxo, CMV), Drug screen, repeat STI<br/>
screen.</td>
							</tr>
						</table>
					</div>
					<div style="width: 30%; float: left;">
						<table width="100%" border="1" cellpadding="0" cellspacing="0" class="record_table">
							<tr bgcolor="#99FF99">
								<td colspan="2" align="center" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;color: #fff;"><b>Initial Laboratory Investigations</b></td>
							</tr>
							<tr>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Test</b></td>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Result </b></td>
							</tr>
							<tr>
								<td>Hb</td>
								<td><input type="text" name="pg2_iHb" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_iHb","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>ABO/Rh(D)</td>
								<td><input type="text" name="pg2_aRh" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_aRh","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>MCV</td>
								<td><input type="text" name="pg2_mcv" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_mcv","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>Antibody screen</td>
								<td><input type="text" name="pg2_asc" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_asc","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>Platelets</td>
								<td><input type="text" name="pg2_plt" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_plt","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>Rubella immune</td>
								<td><input type="text" name="pg2_rim" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_rim","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>HBsAg</td>
								<td><input type="text" name="pg2_hbsa" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_hbsa","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>Syphilis</td>
								<td><input type="text" name="pg2_syp" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_syp","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>HIV</td>
								<td><input type="text" name="pg2_hiv" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_hiv","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>GC</td>
								<td><input type="text" name="pg2_gc" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_gc","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>Chlamydia</td>
								<td><input type="text" name="pg2_chl" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_chl","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td>Urine C&S</td>
								<td><input type="text" name="pg2_urcs" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_urcs","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Test</b></td>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Result </b></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst1","")) %>" maxlength="30"></td>
								<td><input type="text" name="pg2_res1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res1","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst2","")) %>" maxlength="30"></td>
								<td><input type="text" name="pg2_res2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res2","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst3","")) %>" maxlength="30"></td>
								<td><input type="text" name="pg2_res3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res3","")) %>" maxlength="24"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst4","")) %>" maxlength="30"></td>
								<td><input type="text" name="pg2_res4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res4","")) %>" maxlength="24"></td>
							</tr>
						</table>
					</div>
					<div style="width: 30%; float: left;">
						<table width="100%" border="1" cellpadding="0" cellspacing="0" class="record_table">
							<tr bgcolor="#99FF99">
								<td colspan="2" align="center" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;color: #fff;"><b>Second and Third Trimester Lab Investigations</b></td>
							</tr>
							<tr>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Test</b></td>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Result </b></td>
							</tr>
							<tr>
								<td>Hb</td>
								<td><input type="text" name="pg2_hb" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_hb","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td>Platelets</td>
								<td><input type="text" name="pg2_plt2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_plt2","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td>ABO/Rh(D)</td>
								<td><input type="text" name="pg2_aRh2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_aRh2","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td>Repeat Antibodies</td>
								<td><input type="text" name="pg2_rabd" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_rabd","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td>1hr GCT</td>
								<td><input type="text" name="pg2_1g" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_1g","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td>2 hr GTT</td>
								<td><input type="text" name="pg2_2g" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_2g","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst5","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res5","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst6","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res6","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst7","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res7","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst8","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res8","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst9","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res9","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst10","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res10","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Test</b></td>
								<td width="50%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Result </b></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst11","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res11","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst12","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res12","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst13","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res13","")) %>" maxlength="28"></td>
							</tr>
							<tr>
								<td><input type="text" name="pg2_tst14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_tst14","")) %>" maxlength="28"></td>
								<td><input type="text" name="pg2_res14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_res14","")) %>" maxlength="28"></td>
							</tr>
						</table>
					</div>
				</div>
				<table width="100%" border="1" cellpadding="0" cellspacing="0" class="record_table">
					<tr bgcolor="#99FF99">
						<td colspan="4" align="center" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;color: #fff;"><b>Prenatal Genetic Investigations</b></td>
					</tr>
					<tr>
						<td width="40%"><strong>Screening Offered <input type="checkbox" name="pg2_soY" style="margin-left: 10px;" <%= props.getProperty("pg2_soY") %>>Yes 
						<input type="checkbox" name="pg2_soN" class="noCheckbox" <%= props.getProperty("pg2_soN") %>>No</strong></td>
						<td width="15%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Result</b></td>
						<td width="30%"></td>
						<td width="15%" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>Result</b></td>
					</tr>
					<tr>
						<td><input type="checkbox" name="pg2_fts" <%= props.getProperty("pg2_fts") %>> FTS (between 11-13+6wks)</td>
						<td><input type="text" name="pg2_ftsc" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ftsc","")) %>" maxlength="20"></td>
						<td><span>CVS/Amnio</span><span style="margin-left: 120px;margin-right: 10px;">Offered</span>
						<input type="checkbox" name="pg2_caY" <%= props.getProperty("pg2_caY") %>>Y 
						<input type="checkbox" name="pg2_caN" class="noCheckbox" <%= props.getProperty("pg2_caN") %>>N</td>
						<td><input type="text" name="pg2_cac" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_cac","")) %>" maxlength="18"></td>
					</tr>
					<tr>
						<td><input type="checkbox" name="pg2_ips1" <%= props.getProperty("pg2_ips1","") %>> IPS Part 1(between 11-13+6wks) 
						<input type="checkbox" name="pg2_ips2" style="margin-left: 10px;" <%= props.getProperty("pg2_ips2","") %>> 2(between 15-20+6wks)</td>
						<td><input type="text" name="pg2_ipsres" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ipsres","")) %>" maxlength="20"></td>
						<td><span>Other genetic testing</span><span style="margin-left: 57px;margin-right: 10px;">Offered</span>
						<input type="checkbox" name="pg2_oGTY" <%= props.getProperty("pg2_oGTY") %>>Y 
						<input type="checkbox" name="pg2_oGTN" class="noCheckbox" <%= props.getProperty("pg2_oGTN") %>>N</td>
						<td><input type="text" name="pg2_oGT" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_oGT","")) %>" maxlength="18"></td>
					</tr>
					<tr>
						<td><input type="checkbox" name="pg2_mss" <%= props.getProperty("pg2_mss") %>> MSS (between 15-20+6wks) 
						<input type="checkbox" name="pg2_afp" style="margin-left: 10px;" <%= props.getProperty("pg2_afp") %>> AFP (between 15-20+6wks)</td>
						<td><input type="text" name="pg2_afpc" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_afpc","")) %>" maxlength="20"></td>
						<td>NT Risk Assessment 11-13+6wk (multiples)</td>
						<td><input type="text" name="pg2_nra" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_nra","")) %>" maxlength="18"></td>
					</tr>
					<tr>
						<td><span>Cell-free fetal DNA (NIPT)</span><span style="margin-left: 10px;">Offered</span><input type="checkbox" name="pg2_dnaoY" style="margin-left: 10px;" <%= props.getProperty("pg2_dnaoY") %>> Y 
						<input type="checkbox" name="pg2_dnaoN" class="noCheckbox" <%= props.getProperty("pg2_dnaoN")%>> N</td>
						<td><input type="text" name="pg2_dna" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_dna","")) %>" maxlength="20"></td>
						<td>Abnormal Placental Biomarkers</td>
						<td><input type="text" name="pg2_apb" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_apb","")) %>" maxlength="18"></td>
					</tr>
				</table>
				<table width="100%" border="1" cellpadding="0" cellspacing="0" class="record_table">
					<tr bgcolor="#99FF99">
						<td colspan="4" align="center" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;color: #fff;"><b>No Screening Tests</b></td>
					</tr>
					<tr>
						<td valign="top" style="height: 40px;"><input type="checkbox" name="pg2_cd" <%= props.getProperty("pg2_cd") %>>  Counseled and declined </td>
						<td valign="top">Date <input type="text" name="pg2_cdd" id="pg2_cdd" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_cdd",""))%>"><img src="../images/cal.gif" id="pg2_cdd_cal"></td>
						<td valign="top"><input type="checkbox" name="pg2_p206" <%= props.getProperty("pg2_p206") %>>  Presentation > 20+6wk 
						<span style="margin-left: 10px;margin-right: 10px;">NIPT offered</span>
						<input type="checkbox" name="pg2_noY" <%= props.getProperty("pg2_noY") %>> Y <input type="checkbox" name="pg2_noN" class="noCheckbox" <%= props.getProperty("pg2_noN") %>> N</td>
						<td valign="top">Date <input type="pg2_nod" name="pg2_nod" id="pg2_nod" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_nod","")) %>" maxlength="10"><img src="../images/cal.gif" id="pg2_nod_cal"></td>
					</tr>
				</table>
				<table width="100%" border="1" cellpadding="0" cellspacing="0" class="record_table">
					<tr bgcolor="#99FF99">
						<td colspan="5" align="center" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;color: #fff;"><b>No Ultrasound</b></td>
					</tr>
					<tr bgcolor="#99FF99">
						<td width="15%" align="center" bgcolor="#CCCCCC" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;"><b>Date</b></td>
						<td width="15%" align="center" bgcolor="#CCCCCC" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;"><b>GA</b></td>
						<td colspan="3" align="center" bgcolor="#CCCCCC" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;border-bottom: 1px solid #333;"><b>Result</b></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud1" id="pg2_ud1" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud1","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug1')" onChange="calcWeek('pg2_ug1')"><img src="../images/cal.gif" id="pg2_ud1_cal"></td>
						<td><input type="text" name="pg2_ug1" id="pg2_ug1" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug1","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur1","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud2" id="pg2_ud2" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud2","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug2')" onChange="calcWeek('pg2_ug2')"><img src="../images/cal.gif" id="pg2_ud2_cal"></td>
						<td><input type="text" name="pg2_ug2" id="pg2_ug2" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug1","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur2" placeholder="NT Ultrasound (between 11-13+6 weeks)" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur2","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td ><input type="text" name="pg2_ud3" id="pg2_ud3" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud3","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug3')" onChange="calcWeek('pg2_ug3')"><img src="../images/cal.gif" id="pg2_ud3_cal"></td>
						<td><input type="text" name="pg2_ug3" id="pg2_ug3" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug3","")) %>" maxlength="8"></td>
						<td><input type="text" name="pg2_as" placeholder="Anatomy scan (between 18-22wks)" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_as","")) %>" maxlength="42"></td>
						<td><input type="text" name="pg2_plcl" placeholder="Placental Location" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_plcl","")) %>" maxlength="28"></td>
						<td><input type="text" name="pg2_smks" placeholder="Soft Markers" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_smks","")) %>" maxlength="32"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud4" id="pg2_ud4" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud4","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug4')" onChange="calcWeek('pg2_ug4')"><img src="../images/cal.gif" id="pg2_ud4_cal"></td>
						<td><input type="text" name="pg2_ug4" id="pg2_ug4" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug4","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur4","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud5" id="pg2_ud5" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud5","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug5')" onChange="calcWeek('pg2_ug5')"><img src="../images/cal.gif" id="pg2_ud5_cal"></td>
						<td><input type="text" name="pg2_ug5" id="pg2_ug5" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug5","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur5","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud6" id="pg2_ud6" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud6","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug6')" onChange="calcWeek('pg2_ug6')"><img src="../images/cal.gif" id="pg2_ud6_cal"></td>
						<td><input type="text" name="pg2_ug6" id="pg2_ug6" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug6","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur6","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud7" id="pg2_ud7" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud7","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug7')" onChange="calcWeek('pg2_ug7')"><img src="../images/cal.gif" id="pg2_ud7_cal"></td>
						<td><input type="text" name="pg2_ug7" id="pg2_ug7" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug7","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur7","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud8" id="pg2_ud8" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud8","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug8')" onChange="calcWeek('pg2_ug8')"><img src="../images/cal.gif" id="pg2_ud8_cal"></td>
						<td><input type="text" name="pg2_ug8" id="pg2_ug8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug8","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur8","")) %>" maxlength="110"></td>
					</tr>
					<tr style="text-align: left;">
						<td><input type="text" name="pg2_ud9" id="pg2_ud9" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud9","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug9')" onChange="calcWeek('pg2_ug9')"><img src="../images/cal.gif" id="pg2_ud9_cal"></td>
						<td><input type="text" name="pg2_ug9" id="pg2_ug9" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug9","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur9","")) %>" maxlength="110"></td>
					</tr>
					<tr style="text-align: left;">
						<td><input type="text" name="pg2_ud10" id="pg2_ud10" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud10","")) %>" size="10" maxlength="10" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug10')" onChange="calcWeek('pg2_ug10')"><img src="../images/cal.gif" id="pg2_ud10_cal"></td>
						<td><input type="text" name="pg2_ug10" id="pg2_ug10" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug10","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur10","")) %>" maxlength="110"></td>
					</tr>
					<tr style="text-align: left;">
						<td><input type="text" name="pg2_ud11" id="pg2_ud11" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud11","")) %>" size="10" maxlength="10"  style="text-align: left;" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug11')" onChange="calcWeek('pg2_ug11')"><img src="../images/cal.gif" id="pg2_ud11_cal"></td>
						<td><input type="text" name="pg2_ug11" id="pg2_ug11" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug11","")) %>" maxlength="8"></td>
						<td colspan="3"><input type="text" name="pg2_ur11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur11","")) %>" maxlength="110"></td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud12" id="pg2_ud12" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud12","")) %>" size="10" maxlength="10"  style="text-align: left;" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug12')" onChange="calcWeek('pg2_ug12')"><img src="../images/cal.gif" id="pg2_ud12_cal"></td>
						<td><input type="text" name="pg2_ug12" id="pg2_ug12" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug12","")) %>" maxlength="8"></td>
						<td><input type="text" name="pg2_ur12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur12","")) %>" maxlength="42"></td>
						<td colspan="2" rowspan="2">
							<div>Genetic screening result reviewed with pt/client <input type="checkbox" name="pg2_gsrr" <%= props.getProperty("pg2_gsrr") %>></div>
							<div>Approx 22 wks: Copy of OPR 1 & 2 to hospital <input type="checkbox" name="pg2_oc2h" style="margin-right: 10px;" <%= props.getProperty("pg2_oc2h") %>>  and/or to pt/client 
							<input type="checkbox" name="pg2_u2cl" <%= props.getProperty("pg2_u2cl") %>></div>
						</td>
					</tr>
					<tr>
						<td><input type="text" name="pg2_ud13" id="pg2_ud13" placeholder="YYYY/MM/DD" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ud13","")) %>" size="10" maxlength="10"  style="text-align: left;" class="spe" onDblClick="calToday(this);calcWeek('pg2_ug13')" onChange="calcWeek('pg2_ug13')"><img src="../images/cal.gif" id="pg2_ud13_cal"></td>
						<td><input type="text" name="pg2_ug13" id="pg2_ug13" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ug13","")) %>" maxlength="8"></td>
						<td><input type="text" name="pg2_ur13" value="<%= UtilMisc.htmlEscape(props.getProperty("pg2_ur13","")) %>" maxlength="42"></td>
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
Calendar.setup({ inputField : "pg2_lp", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_lp_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_cdd", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_cdd_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_nod", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_nod_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud1", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud1_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud2", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud2_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud3", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud3_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud4", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud4_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud5", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud5_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud6", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud6_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud7", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud7_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud8", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud8_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud9", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud9_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud10", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud10_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud11", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud11_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud12", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud12_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg2_ud13", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg2_ud13_cal", singleClick : true, step : 1 });
</script>
