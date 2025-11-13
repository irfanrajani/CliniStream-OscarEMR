<%--

    Copyright (c) 2007 Peter Hutten-Czapski based on OSCAR general requirements
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

--%>
<%@page import="oscar.log.LogAction"%>
<%@page import="oscar.log.LogConst"%>
<%@page import="oscar.OscarProperties"%>

<%@page import="org.oscarehr.managers.CanadianVaccineCatalogueManager2"%>
<%@page import="org.oscarehr.managers.SecurityInfoManager"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="org.oscarehr.util.SessionConstants"%>
<%@page import="org.oscarehr.util.MiscUtils"%>

<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="org.apache.logging.log4j.Logger"%>
<%@page import="org.owasp.encoder.Encode"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    Logger logger = MiscUtils.getLogger();
    logger.info("starting loading CVC lot editor");

    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_prevention"
	rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_prevention");%>
</security:oscarSec>
<security:oscarSec roleName="<%=roleName$%>" objectName="_prevention.updateCVC"
	rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_prevention");%>
</security:oscarSec>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>
<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
%>
<!DOCTYPE html>
<html:html locale="true">
<head>
<title><bean:message
		key="oscarprevention.index.oscarpreventiontitre" /></title>
<script src="<%= request.getContextPath() %>/js/global.js"></script>
<script src="<%=request.getContextPath()%>/share/javascript/Oscar.js"></script>

<link href="${pageContext.request.contextPath}/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet"> <!-- Bootstrap 2.3.1 -->
<link href="${pageContext.request.contextPath}/css/bootstrap-responsive.css" rel="stylesheet"> <!-- Bootstrap 2.3.1 -->
<script src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js"></script>
<script src="${pageContext.request.contextPath}/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->

<script src="<%=request.getContextPath()%>/share/yui/js/yahoo-dom-event.js"></script>
<script src="<%=request.getContextPath()%>/share/yui/js/connection-min.js"></script>
<script src="<%=request.getContextPath()%>/share/yui/js/animation-min.js"></script>
<script src="<%=request.getContextPath()%>/share/yui/js/datasource-min.js"></script>
<script src="<%=request.getContextPath()%>/share/yui/js/autocomplete-min.js"></script>

<link rel="stylesheet" type="text/css"
	href="<%=request.getContextPath()%>/share/yui/css/fonts-min.css" >
<link rel="stylesheet" type="text/css"
	href="<%=request.getContextPath()%>/share/yui/css/autocomplete.css" >

<link rel="stylesheet" type="text/css" media="all"
	href="<%=request.getContextPath()%>/share/css/demographicProviderAutocomplete.css" >

<!-- calendar stylesheet -->
<link rel="stylesheet" type="text/css" media="all"
	href="${ pageContext.request.contextPath }/share/calendar/calendar.css" title="win2k-cold-1" />
<!-- main calendar program -->
<script type="text/javascript" src="${ pageContext.request.contextPath }/share/calendar/calendar.js"></script>
<!-- language for the calendar -->
<script src="${ pageContext.request.contextPath }/share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
<!-- the following script defines the Calendar.setup helper function, which makes
       adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript"
	src="${ pageContext.request.contextPath }/share/calendar/calendar-setup.js"></script>
<script>
var table
$(document).ready(function(){
    Calendar.setup( { inputField : "expiryDate", ifFormat : "%Y-%m-%d", showsTime :false, button : "cal", singleClick : true, step : 1 } );
    $('#addAlot').hide();
    $('#deleteLot').hide();
        table=$('#lotTbl').DataTable({
            "paging": false,
	        "aaSorting": [[ 2, "asc" ]],
            "language": {
                        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
            });

});

</script>
</head>
<body>
<h3>&nbsp;&nbsp;<bean:message key="admin.admin.add_lot_nr.description" /></h3>
<div id="alert"></div>
    <div class="container-fluid  form-horizontal span12" id="editWrapper">
        <div class="row well">
            <div class="span5">
              <fieldset>
                <legend><bean:message key="admin.lotnrsearchrecordshtm.description" /></legend>

                <div class="controls">
                    <label class="control-label" for="lotNumberToAdd2" style="text-align:left;"><bean:message key="ChooseDrug.brandDrugBox" />:</label><input type="text" id="lotNumberToAdd2" name="lotNumberToAdd2">
		            <div id="lotNumberToAdd2_choices" class="autocomplete input-medium"></div>
                    <span id="unknownName" style="display:none"><label for="name">Name</label> <input type="text" id="name" name="name" value=""> </span>
                    <input id="cvcName" name="cvcName" type="hidden"><!-- container for snomed code for the brandname -->
                    <span id="cvcDetail" style="background-color: #eeeeee; height:100px;"></span>
                    <div id="actions">
                        <br>
                    </div>
                </div> <!-- class="controls" -->
              </fieldset>
            </div> <!-- class="span" -->
            <div class="span5">
              <fieldset id="addAlot">
                <legend><bean:message key="admin.admin.add_lot_nr.description" /></legend>
                <div class="controls">
                    <label for="lot"><bean:message key="admin.admin.add_lot_nr.lotnr" />:</label> <input type="text" name="lot" id="lot">
                    <label for="expiryDate"><bean:message key="admin.securityrecord.formExpiryDate" />:</label>
                    <div class="input-append" id="cal">
                    <input type="text" name="expiryDate" style="width:90px" id="expiryDate" pattern="^\d{4}-((0\d)|(1[012]))-(([012]\d)|3[01])$" autocomplete="off" required="">
                    <span class="add-on"><i class="icon-calendar"></i></span>
                    <div><br><input type="button" class="btn" value="<bean:message key="admin.lotaddrecordhtm.btnlotAddRecord" />" onclick="addCvcLot();"></div>
                </div> <!-- class="controls" -->
              </fieldset>
            </div> <!-- class="span" -->
            <div class="span5">
              <fieldset id="deleteLot">
                <legend><bean:message key="admin.admin.add_lot_nr.lotnr" /></legend>

                <div class="controls">
                    <label class="control-label" style="text-align:left;"><bean:message key="admin.lotdeleterecordhtm.btnlotDeleteRecord" /> <bean:message key="billing.batchbilling.msgSelection" />:</label>
                    <div id="actions">
                         <input  type="button" class="btn" value="<bean:message key="admin.lotdeleterecordhtm.btnlotDeleteRecord" />" onclick="deleteLot();">
                    </div>
                </div> <!-- class="controls" -->
              </fieldset>
            </div> <!-- class="span" -->
        </div> <!-- class="row" -->
    </div> <!-- end editWrapper -->
    <div>
    <table id="lotTbl">
        <thead>
            <th> <bean:message key="ChooseDrug.brandDrugBox" /></th>
            <th> <bean:message key="admin.admin.add_lot_nr.lotnr" /> </th>
            <th> <bean:message key="admin.securityrecord.formExpiryDate" /> </th>
            <th> <input type="checkbox" onclick="$('[name=deleteme]').prop('checked', $(this).prop('checked'));">&nbsp;<bean:message key="marc-hi.patientDocuments.links.selectAll" /> </th>
        </thead>
        <tbody>
        </tbody>
    </table>
    </div>

	<script>
//basic..just makes the brand name ones bold
var resultFormatter2 = function(oResultData, sQuery, sResultMatch) {
	var output = '';

	if(!oResultData[1]) {
		output = '<b>' + oResultData[0] + '</b>';
	} else {
		return;
	}
   	return output;
}

YAHOO.example.BasicRemote = function() {
    if($("lotNumberToAdd2") && $("lotNumberToAdd2_choices")){
          var url = "../cvc.do?method=query";
          var oDS = new YAHOO.util.XHRDataSource(url,{connMethodPost:true,connXhrMode:'ignoreStaleResponses'});
          oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
          oDS.responseSchema = {
              resultsList : "results",
              fields : ["name","generic","genericSnomedId","snomedId","lotNumber"]
          };
          oDS.maxCacheEntries = 0;
          var oAC = new YAHOO.widget.AutoComplete("lotNumberToAdd2","lotNumberToAdd2_choices",oDS);
          oAC.queryMatchSubset = true;
          oAC.minQueryLength = 3;
          oAC.maxResultsDisplayed = 25;
          oAC.formatResult = resultFormatter2;
          oAC.queryMatchContains = true;
          oAC.itemSelectEvent.subscribe(function(type, args) {
        	  var myAC = args[0]; // reference back to the AC instance
        	  var elLI = args[1]; // reference to the selected LI element eg
        	  var oData = args[2]; // object literal of selected item's result data
                // oData[0] eg Adacel(R) (Tdap)
                // oData[1] eg false (ie generic false)
                // oData[2] eg 7851000087109 generic Snomedid
                // oData[3] eg 7431000087103 Snomedid
                // oData[4] eg C6000A  lot number or ''
        	  console.log('args:' + oData[0] + ',' + oData[1] + ',' + oData[2] + ',' + oData[3] + ',' + oData[4]);
        	  document.getElementById("name").value=oData[0];
        	  document.getElementById("cvcName").value=oData[3];
        	  table.clear();
        	  changeCVCName();
        	  getDIN();

          });

           return {
               oDS: oDS,
               oAC: oAC
           };
       }
}();

function getDIN() {
    var conceptId =  $("#cvcName").val();
    if(conceptId == "") {
        alert("pick a brand before adding a lot");
        return;
	} else {
		 $.ajax({
             type: "POST",
             url: "<%=request.getContextPath()%>/cvc.do",
             data: { method:"getDIN", snomedConceptId: conceptId},
             success: function(data) {
            	 if(data != null) {
                    const obj = JSON.parse(data);
                    $("#cvcDetail").html("SNOMED: " + conceptId + "<br>DIN: " + obj.din + "<br>" + obj.manufacture + "<br>" + obj.status);
                    table.clear();
                    changeCVCName();
            	} else {
                    $("#alert").append('<div class="alert alert-error"><bean:message key="UnexpectedError" /> '+data+'</div>');
                    $("#alert").hide().slideDown().delay(4000).fadeOut();
                }
             }
          });
    }
}

function changeCVCName() {
	 lots = null;
	 var snomedId = $("#cvcName").val();
	 if(snomedId != "-1" && snomedId != "0" && snomedId != "") {
		 $("#addAlot").show();
		 $("#deleteLot").show();
		 $("#unknownName").hide();
		 $.ajax({
             type: "POST",
             url: "<%=request.getContextPath()%>/cvc.do",
             data: { method : "getLotNumberAndExpiryDates", snomedConceptId: snomedId},
             dataType: 'json',
             success: function(data,textStatus) {
            	 if(data != null && data.lots != null && data.lots instanceof Array && data.lots.length > 0) {
            		 $("#cvcLot").show();
                     table.clear();
         			 data.lots.sort(GetSortOrder("lotNumber")); //Pass the attribute to be sorted
            		 for(var x=0;x<data.lots.length;x++) {
            			 var item = data.lots[x];
            			 var d = new Date(data.lots[x].expiryDate.time);
            			 var month = ((d.getMonth()+1) > 9) ? (d.getMonth()+1) : ("0" + (d.getMonth()+1));
            			 var day = ((d.getDate()) > 9) ? (d.getDate()) : ("0" + (d.getDate()));
            			 var output = d.getFullYear() + "-" + month + "-" + day;
            			 table.row.add([document.getElementById("name").value,
            			     item.lotNumber,output,
            			     "<input type='checkbox' name='deleteme' value='"+item.lotNumber+"'>&nbsp;delete"]).draw();
            		 }
            	 } else {
            		 $("#cvcLot").hide();
            		 $("#cvcLot").find("option").remove().end();
            		 $("#lot").show();
            	 }
             }
          });

	 }
}

function GetSortOrder(prop) {
    return function(a, b) {
        if (a[prop] > b[prop]) {
            return -1;
        } else if (a[prop] < b[prop]) {
            return 1;
        }
        return 0;
    }
}

function escapeHtml(unsafe1) {
	var unsafe = String(unsafe1);
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
 }

function addCvcLot() {
	var lotCode = $("#lot").val();
    var expiryString = $("#expiryDate").val(); //format yyy-MM-dd
    var conceptId =  $("#cvcName").val();
    if(conceptId == "") {
        alert("pick a brand before adding a lot");
        return;
	} else {
		 $.ajax({
             type: "POST",
             url: "<%=request.getContextPath()%>/cvc.do",
             data: { method:"addLotNumberAndExpiryDates", snomedConceptId: conceptId, lot: lotCode, expiry: expiryString},
             success: function(data) {
            	 if(data != null && data.length > 0) {
                    $("#alert").append('<div class="alert alert-success"><bean:message
		key="admin.lotaddrecord.msgAdditionSuccess" /> '+data+'</div>');
                    table.clear();
                    changeCVCName();
            	} else {
                    $("#alert").append('<div class="alert alert-error"><bean:message
		key="UnexpectedError" /> '+data+'</div>');
                }
                $("#alert").hide().slideDown().delay(4000).fadeOut();
             }
          });
    }
}

function deleteLot(){
	var lotCodes = "";
    $("input[name='deleteme']:checked").each(function ()
    {
        lotCodes += $(this).val()+",";
    });
    var conceptId =  $("#cvcName").val();
    if(conceptId == "") {
        alert("pick a brand before deleting a lot");
        return;
	} else {
		 $.ajax({
             type: "POST",
             url: "<%=request.getContextPath()%>/cvc.do",
             data: { method:"deleteLotNumbers", snomedConceptId: conceptId, lots: lotCodes},
             success: function(data) {
            	 if(data != null && data.length > 0) {
                    $("#alert").append('<div class="alert alert-success"><bean:message
		key="oscarEncounter.immunization.config.administrativeImmunizationSets.btnDelList" /> '+data+'</div>');
                    table.clear();
                    changeCVCName();
            	} else {
                    $("#alert").append('<div class="alert alert-error"><bean:message
		key="UnexpectedError" /> '+data+'</div>');
                }
                $("#alert").hide().slideDown().delay(4000).fadeOut();
             }
          });
    }
}

</script>
</body>
</html:html>