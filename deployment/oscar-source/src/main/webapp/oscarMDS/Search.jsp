<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
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
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="oscar.oscarMDS.data.ProviderData, java.util.ArrayList"%>
<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="org.owasp.encoder.Encode" %>
<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	String firstName = loggedInInfo.getLoggedInProvider().getFirstName();
	String lastName = loggedInInfo.getLoggedInProvider().getLastName();
	String providerNo = request.getParameter("providerNo");

%>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="<%= request.getContextPath() %>/js/global.js"></script>
<script src="<%= request.getContextPath() %>/js/checkDate.js"></script>

<link href="${pageContext.request.contextPath}/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">

<script src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js"></script>
<script src="${pageContext.request.contextPath}/library/jquery/jquery-migrate-3.4.0.js"></script>

<script src="${pageContext.request.contextPath}/library/jquery/jquery-ui-1.12.1.min.js"></script>
<script src="<%=request.getContextPath() %>/js/bootstrap.min.js" ></script>

<link href="<%=request.getContextPath() %>/css/bootstrap.min.css" rel="stylesheet"> <!-- v2.3.1 -->
<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/font-awesome.min.css" rel="stylesheet" >


<script>


var readOnly=false;
function onSubmitCheck(){
	if(!check_date('startDate')){
		return false;
	}
	if(!check_date('endDate')){
		return false;
	}

	var url = "../dms/inboxManage.do?method=prepareForIndexPage&providerNo=<%=providerNo%>";
	if( $("#provfind").val().trim() != "" ) {
		url += "&searchProviderNo=" + $("#provfind").val().trim();
	}
	else {
		url += "&searchProviderNo=-1";
	}
	if( $("#lname").val().trim() != "" ) {
		url += "&lname=" + $("#lname").val().trim();
	}
	if( $("#fname").val().trim() != "" ) {
		url += "&fname=" + $("#fname").val().trim();
	}
	if( $("#hnum").val().trim() != "" ) {
		url += "&hnum=" + $("#hnum").val().trim();
	}
	if( $("#startDate").val().trim() != "" ) {
		url += "&startDate=" + $("#startDate").val().trim();
	}
	if( $("#endDate").val().trim() != "" ) {
		url += "&endDate=" + $("#endDate").val().trim();
	}
	if( $("input[name='searchProviderAll']").is(':checked')) {
		url+= "&searchProviderAll=" + $("input[name='searchProviderAll']:checked").val();
	}
	if( $("input[name='status']").is(':checked')) {
		url+= "&status=" + $("input[name='status']:checked").val();
	}
    if( $("input[name='abnormalStatus']").is(':checked')) {
        url+= "&abnormalStatus=" + $("input[name='abnormalStatus']:checked").val();
    }

	$("#searchFrm").attr("action",url);

}

$(function() {

    $( "#autocompleteprov" ).autocomplete({
      source: "<%= request.getContextPath() %>/provider/SearchProvider.do?method=labSearch",
      minLength: 2,
      focus: function( event, ui ) {
    	  $( "#autocompleteprov" ).val( ui.item.label );
          return false;
      },
      select: function(event, ui) {
    	  $( "#autocompleteprov" ).val(ui.item.label);
    	  $( "#provfind" ).val(ui.item.value);
    	  return false;
      },
        response: function(event, ui) {
            if (ui.content.length === 1) {
                $("#provfind").val(ui.content[0].value);
            } else {
                $("#provfind").val("0");
            }
        }
    });
    $("span.ui-helper-hidden-accessible").text("<%=providerNo%>");
});
$( document ).ready(function() {
    console.log( "ready!" );
    var startDate = $("#startDate").datepicker({
    	dateFormat: "yy-mm-dd"
    }); // ISO 8601
    var endDate = $("#endDate").datepicker({
    	dateFormat: "yy-mm-dd"
    });
});

</script>

<title><bean:message key="oscarMDS.search.title" /></title>
</head>

<body>
<h4><bean:message
	key="oscarMDS.search.title" /></h4>
<div class="container-fluid well" >
    <div class ="span8">
    <form class="form-horizontal" id="searchFrm" method="POST" onSubmit="return onSubmitCheck();">
        <input type="hidden" name="method" value="prepareForIndexPage">
      <div class="control-group">
        <label class="control-label" for="lname"><bean:message key="oscarMDS.search.formPatientLastName" />:</label>
        <div class="controls">
          <input type="text" id="lname" name="lname" placeholder="<bean:message key="oscarMDS.search.formPatientLastName" />">
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for="fname"><bean:message key="oscarMDS.search.formPatientFirstName" />:</label>
        <div class="controls">
          <input type="text" id="fname" name="fname" placeholder="<bean:message key="oscarMDS.search.formPatientFirstName" />">
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for="hnum"><bean:message key="oscarMDS.search.formPatientHealthNumber" />:</label>
        <div class="controls">
          <input type="text" id="hnum" name="hnum" placeholder="<bean:message key="oscarMDS.search.formPatientHealthNumber" />">
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for="startDate">Start Date:</label>
        <div class="controls">
            <div class="input-append">
          <input type="text" id="startDate" name="startDate" style="width: 100px;" pattern="^\d{4}-((0\d)|(1[012]))-(([012]\d)|3[01])$" autocomplete="off" >
            <span class="add-on"><i class="icon-calendar"></i></span>
            </div>
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for="endDate">End Date:</label>
        <div class="controls">
          <div class="input-append">
            <input type="text" id="endDate" name="endDate" style="width: 100px;" pattern="^\d{4}-((0\d)|(1[012]))-(([012]\d)|3[01])$" autocomplete="off" >
            <span class="add-on"><i class="icon-calendar"></i></span>
          </div>
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" ><bean:message
					key="oscarMDS.search.formPhysician" />:</label>
        <div class="controls">
          <input type="radio" name="searchProviderAll" value="-1" ondblclick="this.checked = false;">&nbsp;<bean:message key="oscarMDS.search.formPhysicianAll" />
          <input type="radio" name="searchProviderAll" value="0" ondblclick="this.checked = false;">&nbsp;<bean:message key="oscarMDS.search.formPhysicianUnclaimed" />
          <input type="hidden" name="providerNo" value="<%= request.getParameter("providerNo") %>">
          <input type="hidden" name="searchProviderNo" id="provfind" >
          <input type="hidden" value="true" name="isSearchPage" id="isSearchPage" >
          <br>
          <input type="text" value="<%= Encode.forHtmlAttribute(lastName + ", " + firstName) %>" id="autocompleteprov" name="demographicKeyword">
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" ><bean:message
					key="oscarMDS.search.formReportStatus" />: </label>
        <div class="controls">
          <input type="radio"
					name="status" value=""><bean:message
					key="oscarMDS.search.formReportStatusAll" /> <input type="radio"
					name="status" value="N" checked><bean:message
					key="oscarMDS.search.formReportStatusNew" /> <input type="radio"
					name="status" value="A"><bean:message
					key="oscarMDS.search.formReportStatusAcknowledged" /> <input
					type="radio" name="status" value="F">Filed
        </div>
      </div>
      <!--<div class="control-group">
        <label class="control-label" >Abnormal status: </label>
        <div class="controls">
          <label>
				<input type="radio" name="abnormalStatus" value="all" checked="checked">All
					</label>
					<label>
						<input type="radio" name="abnormalStatus" value="abnormalOnly">Abnormal Only
					</label>
					<label>
						<input type="radio" name="abnormalStatus" value="normalOnly">Normal Only
					</label>
        </div>
      </div>-->
      <div class="control-group">
        <div class="controls">
          <input type="submit" class="btn btn-primary"
					value=" <bean:message key="oscarMDS.search.btnSearch"/> ">
          <input type="button" class="btn btn-link"
					value=" <bean:message key="global.btnClose"/> "
					onClick="window.close();">
        </div>
      </div>
    </form>
    </div>
</div>



</body>
</html>