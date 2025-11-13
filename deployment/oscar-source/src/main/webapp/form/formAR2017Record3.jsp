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
String formLink = "formAR2017Record3.jsp";

boolean bView = false;
if (request.getParameter("view") != null && request.getParameter("view").equals("1")) bView = true; 

int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
int formId = Integer.parseInt(request.getParameter("formId"));
int provNo = Integer.parseInt((String) session.getAttribute("user"));

FrmRecord rec = (new FrmRecordFactory()).factory(formClass);
Properties props = rec.getFormRecord(LoggedInInfo.getLoggedInInfoFromSession(request), demoNo, formId);

//get project_home
String project_home = request.getContextPath().substring(1); 

if(props.getProperty("sv_num", "0").equals("")) props.setProperty("sv_num","0");
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
<title>Antenatal Record 3</title>
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

	function setInput(id,type,val) {
		jQuery("input[name='"+type+id+"']").each(function() {
			jQuery(this).val(val);
		});
	}

	function reset() {        
        document.forms[0].target = "";
        document.forms[0].action = "/<%=project_home%>/form/formname.do" ;
	}
    
    function setLock (checked) {
    	formElems = document.forms[0].elements;
    	for (var i=0; i<formElems.length; i++) {
    		if (formElems[i].type == "text" || formElems[i].type == "textarea") {
            		formElems[i].readOnly = checked;
       		} else if ((formElems[i].type == "checkbox")/* && (formElems[i].id != "pg3_lockPage") && (formElems[i].id != "pg1_4ColCom")*/) {
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
                document.forms[0].action = "../form/createpdf?__title=Antenatal+Record+Part+3&__cfgfile=ar2017PrintCfgPg3&__template=ar2017pg3";
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
        
         //  var ret = checkAllDates();         
        //	  if(ret==true)
        //   {
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
         //  }
           
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
        if(valDate(document.forms[0].pg3_lp)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_cdDate)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_nod)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_ud1)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate2)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate3)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate4)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate5)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate6)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate7)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate8)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate9)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate10)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate11)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate12)==false){
            b = false;
        }else
        if(valDate(document.forms[0].pg3_usDate13)==false){
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
		<% } %>
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
		value=<%=props.getProperty("c_lastVisited", "pg3")%> />
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
			</a> | 
			<a href="javascript: popupPage('formAR2017Record4.jsp?demographic_no=<%=demoNo%>&formId=<%=formId%>&provNo=<%=provNo%>&view=1');">
				AR4&nbsp;
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
					<div class="col-md-8">
						<p>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ministry of Health and Long-Term Care</span>
						<span style="padding-left:50px"></span>
						<span style="font-size:large;">Ontario Perinatal Record 3</span>
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
							<input type="text" name="c_alrg" style="width:75%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_alrg",""))%>" maxlength="80" /></td>
					</tr>
					<tr>
						<td valign="top" colspan="7" width="45%">Family Physician/Primary Care Provider<br><input type="text" name="c_fph" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("c_fph",""))%>" maxlength="" /></td>
						<td rowspan="2" valign="top" width="55%">Medications  (include Rx/OTC, complementary/alternative/vitamins, include dosage)<br>
						<textarea name="c_medc" style="margin-left:5px;resize: none;border: 1;height: 50px;width:75%;" rows="1" cols="90" maxlength="90"><%= props.getProperty("c_medc") %></textarea>
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
					<tr>
						<td colspan="6" align="center" bgcolor="#437bb7" nowrap style="border-bottom: 1px solid #333;height: 26px;color: #fff;"><b>Issues  (abnormal results, medical/social problems)</b></td>
						<td colspan="2" align="center" bgcolor="#437bb7" nowrap style="border-bottom: 1px solid #333;height: 26px;color: #fff;"><b>Plan of Management / Medication Change / Consultations</b></td>
					</tr>
					<tr>
						<td colspan="6"><input type="text" name="pg3_iss1" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_iss1",""))%>" maxlength="52" /></td>
						<td colspan="2"><input type="text" name="pg3_pl1" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_pl1",""))%>" maxlength="85" /></td>
					</tr>
					<tr>
						<td colspan="6"><input type="text" name="pg3_iss2" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_iss2",""))%>" maxlength="52" /></td>
						<td colspan="2"><input type="text" name="pg3_pl2" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_pl2",""))%>" maxlength="85" /></td>
					</tr>
					<tr>
						<td colspan="6"><input type="text" name="pg3_iss3" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_iss3",""))%>" maxlength="52" /></td>
						<td colspan="2"><input type="text" name="pg3_pl3" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_pl3",""))%>" maxlength="85" /></td>
					</tr>
					<tr>
						<td colspan="6"><input type="text" name="pg3_iss4" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_iss4",""))%>" maxlength="52" /></td>
						<td colspan="2"><input type="text" name="pg3_pl4" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_pl4",""))%>" maxlength="85" /></td>
					</tr>
					<tr>
						<td colspan="6"><input type="text" name="pg3_iss5" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_iss5",""))%>" maxlength="52" /></td>
						<td colspan="2"><input type="text" name="pg3_pl5" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_pl5",""))%>" maxlength="85" /></td>
					</tr>
					<tr>
						<td colspan="6"><input type="text" name="pg3_iss6" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_iss6",""))%>" maxlength="52" /></td>
						<td colspan="2"><input type="text" name="pg3_pl6" style="width:95%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_pl6",""))%>" maxlength="85" /></td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr>
						<td align="center" bgcolor="#437bb7" nowrap style="border-bottom: 1px solid #333;height: 26px;color: #fff;"><b>Special Circumstances</b></td>
						<td align="center" bgcolor="#437bb7" nowrap style="border-bottom: 1px solid #333;height: 26px;color: #fff;"><b>GBS</b></td>
					</tr>
					<tr>
						<td><span>Low dose ASA indicated <input type="checkbox" name="pg3_lasa" <%= props.getProperty("pg3_lasa") %>/></span>
						<span style="margin-left: 20px;">Progesterone indicated (PTB Prevention) <input type="checkbox" name="pg3_pid" <%= props.getProperty("pg3_pid") %>></span>
						<span style="margin-left: 20px;">HSV supression indicated <input type="checkbox" name="pg3_hsi" <%= props.getProperty("pg3_hsi") %>></span></td>
						<td rowspan="2">
							<div><span>Rectovaginal swab</span><span style="margin-left: 10px;"><input type="checkbox" name="pg3_swp" <%= props.getProperty("pg3_swp") %>> 
							pos</span><span style="margin-left: 10px;"><input type="checkbox" name="pg3_swn"  <%= props.getProperty("pg3_swn") %>> neg</span></div>
							<div><span>Other indications for prophylaxis</span><span style="margin-left: 10px;"><input type="checkbox" name="pg3_prY" <%= props.getProperty("pg3_prY") %>> Y</span>
							<span style="margin-left: 10px;"><input type="checkbox" name="pg3_prN" class="noCheckbox" <%= props.getProperty("pg3_prN") %>> N</span></div>
						</td>
					</tr>
					<tr>
						<td>Social (e.g. child protection, adoption, surrogacy)<br><input type="text" name="pg3_soc" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_soc",""))%>" maxlength="100"></td>
					</tr>
				</table>
				<table width="100%" border="1" cellspacing="0" cellpadding="0" class="record_table">
					<tr bgcolor="#99FF99">
						<td colspan="5" bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;color: #fff;">
						<div align="center"><b>Recommended Immunoprophylaxis</b></div>
						</td>
					</tr>
					<tr>
						<td width="24%">
							<div>Rh(D) neg <input type="checkbox" name="pg3_rhn" <%= props.getProperty("pg3_rhn") %>></div>
							<div>Rh(D) IG given <input type="text" name="pg3_rhl" id="pg3_rhl" placeholder="YYYY/MM/DD" style="width: 40%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_rhl",""))%>" maxlength="10"><img src="../images/cal.gif" id="pg3_rhl_cal"></div>
							<div>Additional dose given <input type="text" name="pg3_add" id="pg3_add" placeholder="YYYY/MM/DD" style="width: 40%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_add",""))%>" maxlength="10"><img src="../images/cal.gif" id="pg3_add_cal"></div>
						</td>
						<td width="16%">
							<div>Influenza Discussed <input type="checkbox" name="pg3_id" <%= props.getProperty("pg3_id") %>></div> 
							<div><span><input type="checkbox" name="pg3_ir" <%= props.getProperty("pg3_ir") %>> Received</span>
							<span style="margin-left: 10px;"><input type="checkbox" name="pg3_idc" <%= props.getProperty("pg3_idc") %>> Declined</span></div>
						</td>
						<td>
							<div>Pertussis Discussed <input type="checkbox" name="pg3_prd" <%= props.getProperty("pg3_prd") %>></div> 
							<div><span>Up-to-date <input type="checkbox" name="pg3_pru2" <%= props.getProperty("pg3_pru2") %>> Y</span>
							<span><input type="checkbox" name="pg3_pru2n" class="noCheckbox" <%= props.getProperty("pg3_pru2n") %>> N</span>
							<span style="margin-left: 10px;">Year <input type="text" name="pg3_prY2" id="pg3_prY2" style="border-bottom: 1px solid #333; width: 20%" placeholder="YYYY" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_prY2",""))%>" maxlength="4"></span><img src="../images/cal.gif" id="pg3_prY2_cal"></div>
							<div><span><input type="checkbox" name="pg3_prr" <%= props.getProperty("pg3_prr") %>> Received</span><span style="margin-left: 10px;"><input type="checkbox" name="pg3_prdc" <%= props.getProperty("pg3_prdc") %>> Declined</span></div>
						</td>
						<td width="23%">
							<div>Post-partum vaccines discussed</div>
							<div><input type="checkbox" name="pg3_rubd" <%= props.getProperty("pg3_rubd") %>>  Rubella</div>
							<div><span><input type="checkbox" name="pg3_vOth" <%= props.getProperty("pg3_vOth") %>> Other <input type="text" name="pg3_vOthS" style="border-bottom: 1px solid #333; width: 30%" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_vOthS",""))%>" maxlength="22"></span></div>
						</td>
						<td width="15%">
							<div>Newborn needs</div>
							<div><input type="checkbox" name="pg3_nhp" <%= props.getProperty("pg3_nhp") %>>  Hep B prophylaxis</div>
							<div><input type="checkbox" name="pg3_nhv" <%= props.getProperty("pg3_nhv") %>>   HIV prophylaxis</div>
						</td>
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
						<th style="text-align: center;" width="6%">GA<br>(wks+days)</th>
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
						<td align="center"><input type="text" name="pg3_svd1" id="pg3_svd1" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd1",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg1')" onChange="calcWeek('pg3_svg1')"><img src="../images/cal.gif" id="pg3_svd1_cal"></td>
						<td align="center"><input type="text" name="pg3_svg1" id="pg3_svg1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg1",""))%>","") maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw1",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc1" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc1",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn1",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi1" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi1",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd2" id="pg3_svd2" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd2",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg2')" onChange="calcWeek('pg3_svg2')"><img src="../images/cal.gif" id="pg3_svd2_cal"></td>
						<td align="center"><input type="text" name="pg3_svg2" id="pg3_svg2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw2",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc2" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc2",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn2",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi2" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi2",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd3" id="pg3_svd3" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd3",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg3')" onChange="calcWeek('pg3_svg3')"><img src="../images/cal.gif" id="pg3_svd3_cal"></td>
						<td align="center"><input type="text" name="pg3_svg3" id="pg3_svg3"style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw3",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc3" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc3",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn3",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi3" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi3",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd4" id="pg3_svd4" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd4",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg4')" onChange="calcWeek('pg3_svg4')"><img src="../images/cal.gif" id="pg3_svd4_cal"></td>
						<td align="center"><input type="text" name="pg3_svg4" id="pg3_svg4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw4",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc4" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc4",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn4",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi4" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi4",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd5" id="pg3_svd5" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd5",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg5')" onChange="calcWeek('pg3_svg5')"><img src="../images/cal.gif" id="pg3_svd5_cal"></td>
						<td align="center"><input type="text" name="pg3_svg5" id="pg3_svg5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw5",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc5" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc5",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn5",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi5" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi5",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd6" id="pg3_svd6" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd6",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg6')" onChange="calcWeek('pg3_svg6')"><img src="../images/cal.gif" id="pg3_svd6_cal"></td>
						<td align="center"><input type="text" name="pg3_svg6" id="pg3_svg6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw6",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc6" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc6",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn6",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi6" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi6",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd7" id="pg3_svd7" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd7",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg7')" onChange="calcWeek('pg3_svg7')"><img src="../images/cal.gif" id="pg3_svd7_cal"></td>
						<td align="center"><input type="text" name="pg3_svg7" id="pg3_svg7"style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw7",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc7" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc7",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn7",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi7" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi7",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd8" id="pg3_svd8" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd8",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg8')" onChange="calcWeek('pg3_svg8')"><img src="../images/cal.gif" id="pg3_svd8_cal"></td>
						<td align="center"><input type="text" name="pg3_svg8" id="pg3_svg8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw8",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc8" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc8",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn8",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi8" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi8",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd9" id="pg3_svd9" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd9",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg9')" onChange="calcWeek('pg3_svg9')"><img src="../images/cal.gif" id="pg3_svd9_cal"></td>
						<td align="center"><input type="text" name="pg3_svg9" id="pg3_svg9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw9",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc9" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc9",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn9",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi9" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi9",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd10" id="pg3_svd10" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd10",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg10')" onChange="calcWeek('pg3_svg10')"><img src="../images/cal.gif" id="pg3_svd10_cal"></td>
						<td align="center"><input type="text" name="pg3_svg10" id="pg3_svg10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw10",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc10" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc10",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn10",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi10" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi10",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd11" id="pg3_svd11" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd11",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg11')" onChange="calcWeek('pg3_svg11')"><img src="../images/cal.gif" id="pg3_svd11_cal"></td>
						<td align="center"><input type="text" name="pg3_svg11" id="pg3_svg11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg11",""))%>" maxlength="7""></td>
						<td align="center"><input type="text" name="pg3_svw11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw11",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc11" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc11",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn11",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi11" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi11",""))%>" maxlength="8"></td>
					</tr>
					<tr>
						<td align="center"><input type="text" name="pg3_svd12" id="pg3_svd12" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd12",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg12')" onChange="calcWeek('pg3_svg12')"><img src="../images/cal.gif" id="pg3_svd12_cal"></td>
						<td align="center"><input type="text" name="pg3_svg12" id="pg3_svg12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp12",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
                        <td align="center"><input type="text" name="pg3_svb12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc12" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc12",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn12",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi12" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi12",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg3_svd13" id="pg3_svd13" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd13",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg13')" onChange="calcWeek('pg3_svg13')"><img src="../images/cal.gif" id="pg3_svd13_cal"></td>
						<td align="center"><input type="text" name="pg3_svg13" id="pg3_svg13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw13",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc13" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc13",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn13",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi13" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi13",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg3_svd14" id="pg3_svd14" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd14",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg14')" onChange="calcWeek('pg3_svg14')"><img src="../images/cal.gif" id="pg3_svd14_cal"></td>
						<td align="center"><input type="text" name="pg3_svg14" id="pg3_svg14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw14",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc14" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc14",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn14",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi14" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi14",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg3_svd15" id="pg3_svd15" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd15",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg15')" onChange="calcWeek('pg3_svg15')"><img src="../images/cal.gif" id="pg3_svd15_cal"></td>
						<td align="center"><input type="text" name="pg3_svg15" id="pg3_svg15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw15",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc15" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc15",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn15",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi15" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi15",""))%>" maxlength="8"></td>
					</tr>					
					<tr>
						<td align="center"><input type="text" name="pg3_svd16" id="pg3_svd16" placeholder="YY/MM/DD" size="8" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svd16",""))%>" maxlength="8" class="spe" onDblClick="calToday(this);calcWeek('pg3_svg16')" onChange="calcWeek('pg3_svg16')"><img src="../images/cal.gif" id="pg3_svd16_cal"></td>
						<td align="center"><input type="text" name="pg3_svg16" id="pg3_svg16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svg16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svw16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svw16",""))%>" maxlength="7" onDblClick="wtEnglish2Metric(this)" title="Enter a value in pounds(lbs) then double click to convert to kilograms(kg)"></td>
						<td align="center"><input type="text" name="pg3_svb16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svb16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svu16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svu16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svs16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svs16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svp16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svp16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfh16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfh16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svfm16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svfm16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svc16" style="width: 80%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svc16",""))%>" maxlength="82"></td>
						<td align="center"><input type="text" name="pg3_svn16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svn16",""))%>" maxlength="7"></td>
						<td align="center"><input type="text" name="pg3_svi16" style="width: 90%;" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_svi16",""))%>" maxlength="8"></td>
					</tr>					
					
				</table>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr bgcolor="#99FF99">
						<td bgcolor="#437bb7" style="border-left: 1px solid #333;border-right: 1px solid #333;height: 26px;color: #fff;">
						<div align="center"><b>Discussion Topics</b></div>
						</td>
					</tr>
				</table>
				<div class="clearfix medical_history_wrap">
					<div style="width: 40%; float: left;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="record_table">
							<tr>
								<td colspan="2" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>1 st Trimester</b></td>
							</tr>
							<tr>
								<td colspan="2"><input type="checkbox" name="pg3_nsa" <%= props.getProperty("pg3_nsa") %>> Nausea/Vomiting</td>
							</tr>
							<tr>
								<td colspan="2"><input type="checkbox" name="pg3_rpc" <%= props.getProperty("pg3_rpc") %>> Routine prenatal care/Emergency contact/On call  providers</td>
							</tr>
							<tr>
								<td colspan="2"><input type="checkbox" name="pg3_sf" <%= props.getProperty("pg3_sf") %>> Safety: food, medication, environment, infections, pets</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_hwg" <%= props.getProperty("pg3_hwg") %>> Healthy weight gain</td>
								<td><input type="checkbox" name="pg3_bf" <%= props.getProperty("pg3_bf") %>> Breastfeeding</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_pha" <%= props.getProperty("pg3_pha") %>> Physical activity</td>
								<td><input type="checkbox" name="pg3_trvl" <%= props.getProperty("pg3_trvl") %>> Travel</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_sbu" <%= props.getProperty("pg3_sbu") %>> Seatbelt use</td>
								<td><input type="checkbox" name="pg3_qi" <%= props.getProperty("pg3_qi") %>> Quality information sources</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_sx" <%= props.getProperty("pg3_sx") %>> Sexual activity</td>
								<td><input type="checkbox" name="pg3_vbac" <%= props.getProperty("pg3_vbac") %>> VBAC counseling</td>
							</tr>
						</table>
					</div>
					<div style="width: 15%; float: left;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="record_table">
							<tr>
								<td align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>2 nd  Trimester</b></td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_2tpc" <%= props.getProperty("pg3_2tpc") %>> Prenatal classes</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_2tplb" <%= props.getProperty("pg3_2tplb") %>> Preterm labour</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_2tpr" <%= props.getProperty("pg3_2tpr") %>> PROM</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_2tbl" <%= props.getProperty("pg3_2tbl") %>> Bleeding</td>
							</tr> 
							<tr>
								<td><input type="checkbox" name="pg3_2tfm" <%= props.getProperty("pg3_2tfm") %>> Fetal movement</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_2tmh" <%= props.getProperty("pg3_2tmh") %>> Mental health</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_2tvb" <%= props.getProperty("pg3_2tvb") %>> VBAC consent</td>
							</tr>
						</table>
					</div>
					<div style="width: 45%; float: left;" class="medical_history_wrap_right">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="record_table">
							<tr>
								<td colspan="2" align="center" bgcolor="#CCCCCC" nowrap style="border-bottom: 1px solid #333;"><b>3 rd Trimester</b></td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_3tfm" <%= props.getProperty("pg3_3tfm") %>> Fetal movement</td>
								<td><input type="checkbox" name="pg3_3twp" <%= props.getProperty("pg3_3twp") %>> Work plan/Maternity leave</td>
							</tr>
							<tr>
								<td colspan="2"><input type="checkbox" name="pg3_3tbp" <%= props.getProperty("pg3_3tbp") %>> Birth plan: pain management, labour support</td>
							</tr>
							<tr>
								<td colspan="2"><input type="checkbox" name="pg3_3tvb" <%= props.getProperty("pg3_3tvb") %>> Type of birth, potential interventions, VBAC plan</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_3tat" <%= props.getProperty("pg3_3tat") %>> Admission timing</td>
								<td><input type="checkbox" name="pg3_3tmh" <%= props.getProperty("pg3_3tmh") %>> Mental health</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_3tbf" <%= props.getProperty("pg3_3tbf") %>> Breastfeeding and support</td>
								<td><input type="checkbox" name="pg3_3tct" <%= props.getProperty("pg3_3tct") %>> Contraception</td>
							</tr>
							<tr>
								<td colspan="2"><input type="checkbox" name="pg3_3tnbc" <%= props.getProperty("pg3_3tnbc") %>> Newborn care / Screening tests / Circumcision / Follow-up appt.</td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pg3_3tdp" <%= props.getProperty("pg3_3tdp") %>> Discharge planning / Car seat safety</td>
								<td><input type="checkbox" name="pg3_3tpc" <%= props.getProperty("pg3_3tpc") %>> Postpartum care</td>
							</tr>
						</table>
					</div>
				</div>
				<table border="0" cellspacing="0" cellpadding="0" class="record_table" width="100%">
					<tr>
						<td valign="top" colspan="2" style="border-top: 1px solid #333;border-left: 1px solid #333;border-right: 1px solid #333;">Comments
						<br>
						<textarea name="pg3_comm" class="form-control" style="resize:none;border:1;margin-bottom:6px;margin-left:8px;margin-right:8px;width:98%" rows="5" cols="160" maxlength="800"> <%= UtilMisc.htmlEscape(props.getProperty("pg3_comm",""))%></textarea></td>
					</tr>
					<tr>
						<td style="border-left: 1px solid #333;"></td>
						<td align="center" style="border: 1px solid #333;border-bottom: 0;width: 58%;height: 25px;"><span>Approx 36 wks: Copy of OPR 2 (updated) & OPR 3 to hospital 
						<input type="checkbox" name="pg3_opr2h" <%= props.getProperty("pg3_opr2h") %>></span>
						<span style="margin-left: 20px;">and/or to pt/client <input type="checkbox" name="pg3_opr2c" <%= props.getProperty("pg3_opr2c") %>></span></td>
					</tr>
				</table>
				<table border="1" cellspacing="0" cellpadding="0" class="record_table" width="100%">
					<tr>
						<td>1.Name/Initials<br><input type="text" name="pg3_ni1" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_ni1",""))%>" maxlength="25"></td>
						<td>2.Name/Initials <br><input type="text" name="pg3_ni2" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_ni2",""))%>" maxlength="25"></td>
						<td>3.Name/Initials <br><input type="text" name="pg3_ni3" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_ni3",""))%>" maxlength="25"></td>
						<td>4.Name/Initials<br><input type="text" name="pg3_ni4" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_ni4",""))%>" maxlength="25"></td>
						<td>5.Name/Initials<br><input type="text" name="pg3_ni5" value="<%= UtilMisc.htmlEscape(props.getProperty("pg3_ni5",""))%>" maxlength="25"></td>
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
Calendar.setup({ inputField : "pg3_rhl", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg3_rhl_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_add", ifFormat : "%Y/%m/%d", showsTime :false, button : "pg3_add_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_prY2", ifFormat : "%Y", showsTime :false, button : "pg3_prY2_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd1", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd1_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd2", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd2_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd3", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd3_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd4", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd4_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd5", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd5_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd6", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd6_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd7", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd7_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd8", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd8_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd9", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd9_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd10", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd10_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd11", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd11_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd12", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd12_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd13", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd13_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd14", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd14_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd15", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd15_cal", singleClick : true, step : 1 });
Calendar.setup({ inputField : "pg3_svd16", ifFormat : "%y/%m/%d", showsTime :false, button : "pg3_svd16_cal", singleClick : true, step : 1 });
</script>