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
<%@page import="java.net.URLEncoder,oscar.OscarProperties"%>
<%@page import="org.oscarehr.integration.TokenExpiredException"%>
<%@page import="org.oscarehr.integration.OneIDTokenUtils"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.dao.DemographicDao"%>
<%@page import="org.oscarehr.common.model.Demographic"%>

<%@page import="org.oscarehr.integration.OneIdGatewayData"%>
<%@page import="org.oscarehr.util.LoggedInInfo,org.oscarehr.util.LoggedInUserFilter"%>
<%@page import="org.oscarehr.util.SessionConstants"%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<% boolean authed=true; %>
<security:oscarSec roleName='${ sessionScope[userrole] }, ${ sessionScope[user] }' rights="w" objectName="_prevention">
	<c:redirect url="securityError.jsp?type=_prevention" />
	<%authed=false; %>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
OneIdGatewayData oneIdGatewayData= loggedInInfo.getOneIdGatewayData();
try  {
	OneIDTokenUtils.verifyAccessTokenIsValid(loggedInInfo,oneIdGatewayData);



	////user/Immunization.read user/Immunization.write user/Patient.read
	boolean hasNeededScope = oneIdGatewayData.hasScope(oneIdGatewayData.fullScope);//"openid", "user/MedicationDispense.read", "toolbar", "user/Context.read", "user/Context.write",  "user/Consent.write");
	//http://ehealthontario.ca/StructureDefinition/ca-on-dhir-profile-Immunization http://ehealthontario.ca/StructureDefinition/ca-on-dhir-profile-Patient
	boolean hasNeededProfile = oneIdGatewayData.hasProfile(oneIdGatewayData.fullProfile);//"http://ehealthontario.ca/StructureDefinition/ca-on-dhdr-profile-MedicationDispense","http://ehealthontario.ca/fhir/StructureDefinition/ca-on-consent-pcoi-profile-Consent");
	if(hasNeededScope && hasNeededProfile && oneIdGatewayData.howLongSinceRefreshTokenWasIssued() < 2){
		//All good
	}else{

		response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(OneIDTokenUtils.getCompleteURL(request),"UTF-8") );
		return;
	}


} catch(TokenExpiredException e) {
	if(oneIdGatewayData == null){
		oneIdGatewayData = new OneIdGatewayData();
		session.setAttribute(SessionConstants.OH_GATEWAY_DATA,oneIdGatewayData);
		loggedInInfo = LoggedInUserFilter.generateLoggedInInfoFromSession(request);
	}
	loggedInInfo = LoggedInUserFilter.generateLoggedInInfoFromSession(request);
	oneIdGatewayData.hasScope(oneIdGatewayData.fullScope);
	oneIdGatewayData.hasProfile(oneIdGatewayData.fullProfile);
	response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(OneIDTokenUtils.getCompleteURL(request),"UTF-8") );
	return;
} catch(NullPointerException e2) {
	if(oneIdGatewayData == null){
		oneIdGatewayData = new OneIdGatewayData();
		session.setAttribute(SessionConstants.OH_GATEWAY_DATA,oneIdGatewayData);
		loggedInInfo = LoggedInUserFilter.generateLoggedInInfoFromSession(request);
	}
	oneIdGatewayData.hasScope(oneIdGatewayData.fullScope);
	oneIdGatewayData.hasProfile(oneIdGatewayData.fullProfile);
	response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(OneIDTokenUtils.getCompleteURL(request),"UTF-8") );
	return;
}



	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
	Demographic demographic = demographicDao.getDemographic(request.getParameter("demographic_no"));
	SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
	String startDate = request.getParameter("startDate");
	String endDate = request.getParameter("endDate");
	String dobDate = fmt.format(demographic.getBirthDay().getTime());
	if(StringUtils.isEmpty(startDate)) {
		Calendar c = Calendar.getInstance();
		c.add(Calendar.YEAR,-10);

		startDate = fmt.format(c.getTime());
	}

	if(StringUtils.isEmpty(endDate)) {
		Calendar c = Calendar.getInstance();
		//SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
		endDate = fmt.format(c.getTime());
	}

	String emrStartDate = dobDate;
	String emrEndDate = endDate;

	try  {
		OneIDTokenUtils.getValidAccessToken(session);
	} catch(TokenExpiredException e) {
		response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(getCompleteURL(request),"UTF-8") );

	}
%>
<!DOCTYPE html >
<html:html locale="true" >
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>
EMR / DHIR View
</title>
	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/library/bootstrap/3.0.0/css/bootstrap.min.css" />
 	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" />
	 <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"> -->
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/all.min.css">

	<script>var ctx = "${pageContext.request.contextPath}"</script>
	<script src="${ pageContext.request.contextPath }/js/jquery-1.12.3.js"></script>
        <script src="${ pageContext.request.contextPath }/library/jquery/jquery-migrate-1.4.1.js"></script>
	<script src="${ pageContext.request.contextPath }/library/bootstrap/3.0.0/js/bootstrap.min.js" ></script>
	<script src="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/js/dataTables.bootstrap.min.js" ></script>
	<script src="${ pageContext.request.contextPath }/library/DataTables/datatables.min.js"></script><!-- 1.13.4 -->

	<script src="<%=request.getContextPath() %>/js/bootstrap-datepicker.js"></script>

	<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

	<style>
	.recItem {border:2px solid black}
	#forecastByStatusTbl tbody tr {background-color:#ccffff}
	</style>

	<script>

		var hideDisclaimer = <%=(session.getAttribute("dhir.disclaimer.hide") != null && (Boolean)session.getAttribute("dhir.disclaimer.hide")) ? session.getAttribute("dhir.disclaimer.hide") : "false"  %>;

		function emptyIfNull(item) {
			if(item == null) {
				return {};
			}
			return item;
		}

		var renderFuncVaccine= function(data, type, row, meta) {
			//console.log("data=" +JSON.stringify(data));

			if(data.forecastStatus == null) {
				return "&nbsp;";
			}

			if(data.targetDisease != null && data.targetDisease.length>0) {
				return "&nbsp;";
			}

			//console.log('cc=' + JSON.stringify(data.forecastStatus));
			var color = "";
			if(data.forecastStatus.display == "Overdue") {color = "#f2dede";};
			if(data.forecastStatus.display == "Due") {color = "#fff3cd";};
			if(data.forecastStatus.display == "Eligible but not due") {color = "#d4edda";};
			if(data.forecastStatus.display == "Up to date") {color = "#d1ecf1";};


			var renderedText = "<div class=\"recItem\" style=\"background-color:"+color+" \">";


			//if(data.targetDisease != null && data.targetDisease.length>0) {
			//	renderedText += "<b>" + data.targetDisease + "</b>" ;
			//}
			if(data.vaccineCodes != null && data.vaccineCodes.length>0) {
				renderedText += "<b>" + data.vaccineCodes[0].display + "</b>";
			}
			if(data.vaccineCodes != null && data.vaccineCodes.length>1) {
				renderedText += "<br/><b>" + data.vaccineCodes[1].display + "</b>";
			}
			if(data.date != null) {
				renderedText += "<br/>" + data.date ;
			}

			renderedText += "</div>";

			return renderedText;
		}


		var renderFuncDisease = function(data, type, row, meta) {
			//console.log("data=" +JSON.stringify(data));

			if(data.forecastStatus == null) {
				return "&nbsp;";
			}

			if(data.vaccineCodes != null && data.vaccineCodes.length>0) {
				return "&nbsp;";
			}

			//console.log('cc=' + JSON.stringify(data.forecastStatus));
			var color = "";
			if(data.forecastStatus.display == "Overdue") {color = "#f2dede";};
			if(data.forecastStatus.display == "Due") {color = "#fff3cd";};
			if(data.forecastStatus.display == "Eligible but not due") {color = "#d4edda";};
			if(data.forecastStatus.display == "Up to date") {color = "#d1ecf1";};


			var renderedText = "<div class=\"recItem\" style=\"background-color:"+color+" \">";


			if(data.targetDisease != null && data.targetDisease.length>0) {
				renderedText += "<b>" + data.targetDisease + "</b>" ;
			}
			//if(data.vaccineCodes != null && data.vaccineCodes.length>0) {
			//	renderedText += "<b>" + data.vaccineCodes[0].display + "</b>";
			//}
			//if(data.vaccineCodes != null && data.vaccineCodes.length>1) {
			//	renderedText += "<br/><b>" + data.vaccineCodes[1].display + "</b>";
			//}
			if(data.date != null) {
				renderedText += "<br/>" + data.date ;
			}

			renderedText += "</div>";

			return renderedText;
		}


		$(document).ready(function(){

			$("#disclaimer").hide();



			$("#summaryTbl").DataTable({
				//orderCellsTop: true,
				//fixedHeader: true,
				"order" : [[0,"desc"]],

				"columns" : [
					{"title": "Immunization Date", "data" : "immunizationDate"},
					{"title": "Valid Flag","data" : "validFlag"},
					{"title": "Agent","data" : "agent"},
					{"title": "Trade Name","data" : "tradeName"},
					{"title": "Lot Number","data" : "lotNumber"},
					{"title": "Expiration Date","data" : "expirationDate"},
					{"title": "Status","data" : "status"},
					{"title": "PHU","data" : "PHU"},
					{"title": "Performer","data" : "performerName"},

				],

				"language": {
				      "emptyTable": "No events found for the search time period."
				    }

			});

			<%-- this is the new part
			$('#summaryTbl thead tr').clone(true).appendTo( '#summaryTbl thead' );
		    $('#summaryTbl thead tr:eq(1) th').each( function (i) {
		        var title = $(this).text();
		        $(this).html( '<input type="text" placeholder="Search '+title+'" />' );

		        $( 'input', this ).on( 'keyup change', function () {
		            if ( table.column(i).search() !== this.value ) {
		                table
		                    .column(i)
		                    .search( this.value )
		                    .draw();
		            }
		        } );
		    } );
			 end --%>



			$("#compTbl").DataTable({


				"columns" : [
					{"title": "Name", 			"data" : "name"},
					{"title": "Code",			"data" : "code"},
					{"title": "Type",			"data" : "type"},
					{"title": "Manufacturer",	"data" : "manufacturer"},
					{"title": "Lot Number",		"data" : "lotNumber"},
					{"title": "Route",			"data" : "route"},
					{"title": "Site",			"data" : "site"},
					{"title": "Dose",			"data" : "dose"},
					{"title": "Date",			"data" : "date"},
					{"title": "Refused",		"data" : "refused"},
					{"title": "Preformer",		"data" : "preformer"},
					{"title": "Notes",			"data" : "notes"}
				],

				"language": {
				      "emptyTable": "No events found for the search time period."
				    },
				    "order": [[ 8, "desc" ]]


			});






			$("#forecastByStatusTblVaccine").DataTable({
				"columns" : [
					{"title": "Overdue","width": "25%", "render" : renderFuncVaccine },
					{"title": "Due" ,"width": "25%", "render" : renderFuncVaccine},
					{"title": "Eligible but not due","width": "25%", "render" : renderFuncVaccine},
					{"title": "Up to date","width": "25%", "render" : renderFuncVaccine }
				],

				"language": {
				      "emptyTable": "No forecast items."
				},
				paging: false,
				searching:false,
				info:false,

				"order": [],
			    "columnDefs": [ {
			      "targets"  : [0,1,2,3],
			      "orderable": false,
			    }]

			});

			$("#forecastByStatusTblDisease").DataTable({
				"columns" : [
					{"title": "Overdue","width": "25%", "render" : renderFuncDisease },
					{"title": "Due" ,"width": "25%", "render" : renderFuncDisease},
					{"title": "Eligible but not due","width": "25%", "render" : renderFuncDisease},
					{"title": "Up to date","width": "25%", "render" : renderFuncDisease }
				],

				"language": {
				      "emptyTable": "No forecast items."
				},
				paging: false,
				searching:false,
				info:false,

				"order": [],
			    "columnDefs": [ {
			      "targets"  : [0,1,2,3],
			      "orderable": false,
			    }]

			});


			function getDHIRData() {
				var dt = $("#summaryTbl").DataTable();


				$("#dhir_loading").show();
				$("#dhirError").hide();
				$("#disclaimer").hide();
				dt.clear();
		    	$("#summaryPeriod").html("<b>Search period:</b>");

		    	var dtFV = $("#forecastByStatusTblVaccine").DataTable();
		    	dtFV.clear();
		    	var dtFD = $("#forecastByStatusTblDisease").DataTable();
		    	dtFD.clear();

				$.ajax({
					url: "<%=request.getContextPath()%>/dhir/summary.do?demographic_no=<%=demographic.getDemographicNo()%>&startDate=" + $("#startDate").val() + "&endDate=" + $("#endDate").val(),
				    type: 'GET',
				  	dataType: 'json',
				    success: function(data) {
				    	if(data.error != null) {
				    		$("#dhirError").html(data.error);
				    		$("#dhirError").show();
				    	}
				    	if(data.searchParams != null){
				    		var searchParamsText = "";
				    		var first = true;
				    		for (i = 0; i < data.searchParams.length; i++) {
				    			  if(!first){
				    				  searchParamsText += ", ";
				    			  }
				    			  first = false;
				    			  searchParamsText += data.searchParams[i];
				    		}
				    		$("#summaryParams").html("<b>Search params:</b> <i>" +searchParamsText +"</i>");
				    	}

				    	if(data.immunizations != null) {
					    	var dt = $("#summaryTbl").DataTable();
					    	dt.rows.add(data.immunizations);
					    	dt.draw();

					    	$("#summaryPeriod").html("<b>Search period:</b>" + data.startDate + " - " + data.endDate);
					    	if(!hideDisclaimer) {
					    		$("#disclaimer").show();
					    	}

				    	}

				    	if(data.patient != null){
				    		/*
				    		{"patient":{
				    			"resourceType":"Patient",
				    			"id":"1003327923",
				    			"identifier":[{"system":"https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn","value":"7361544534"},{"system":"http://ehealthontario.ca/fhir/NamingSystem/ca-on-panorama-immunization-id","value":"MKMVB3JFB6"}],
				    			"name":[{"family":"David","given":["Alice","EMROne"]}],
				    			"telecom":[{"system":"phone","value":"+1-747-440-6320","use":"home"}],
				    			"gender":"male",
				    			"birthDate":"2000-01-14"}}
				    		*/
				    		document.getElementById('dhir_last_name').textContent = data.patient.name[0].family;
				    		document.getElementById('dhir_first_name').textContent = data.patient.name[0].given[0];
				    		document.getElementById('dhir_dob').textContent = data.patient.birthDate;
				    		document.getElementById('dhir_hin').textContent = data.patient.identifier[0].value;
				    		document.getElementById('dhir_sex').textContent = data.patient.gender;

				    		var dhirDemoDataMatches = true;

				    		if('<%=demographic.getLastName()%>'.localeCompare(data.patient.name[0].family, undefined, { sensitivity: 'accent' }) != 0){
				    			alert("DHIR Demographic Data does not match Local Demographic Data <%=demographic.getLastName()%> does not equal "+data.patient.name[0].family);
				    			dhirDemoDataMatches = false;
				    		}

				    		if('<%=demographic.getFirstName()%>'.localeCompare(data.patient.name[0].given[0], undefined, { sensitivity: 'accent' }) != 0){
				    			alert("DHIR Demographic Data does not match Local Demographic Data <%=demographic.getFirstName()%> does not equal "+data.patient.name[0].given[0]);
				    			dhirDemoDataMatches = false;
				    		}

				    		var sexMatch = false;
						if('<%=demographic.getSex() %>' === 'M' && data.patient.gender === 'male'){
							sexMatch = true;
						}else if('<%=demographic.getSex() %>' === 'F' && data.patient.gender === 'female'){
							sexMatch = true;
						}else if('<%=demographic.getSex() %>' === 'O' && data.patient.gender === 'other'){
							sexMatch = true;
						}else if('<%=demographic.getSex() %>' === 'U' && data.patient.gender === 'unknown'){
							sexMatch = true;
						}
						if(!sexMatch){
							alert("DHIR Demographic Data does not match Local Demographic Data for gender :<%=demographic.getSex() %>");
							dhirDemoDataMatches = false;
						}

				    		if(!dhirDemoDataMatches){
				    			$("#dhir_demo_info_warning").show();
				    			$("#dhir_demo_info").show();
				    		}


				    	}
				    	if(data.immunizationsRecommendationDateGenerated != null){
				    		document.getElementById('immunizationsRecommendationDateGenerated').textContent = data.immunizationsRecommendationDateGenerated;
				    	}

				    	if(data.recommendationsByStatus != null) {
				    		var forecastByStatusTableVaccine = $("#forecastByStatusTblVaccine").DataTable();
				    		var forecastByStatusTableDisease = $("#forecastByStatusTblDisease").DataTable();
				    		var recs = data.recommendationsByStatus;
				    		console.log("recs",recs);
				    		var a1Vaccine = []; //recs["Overdue"];
				    		var a2Vaccine = []; //recs["Due"];
				    		var a3Vaccine = []; //recs["Eligible but not due"];
				    		var a4Vaccine = []; //recs["Up to date"];

				    		var a1Disease = []; //recs["Overdue"];
				    		var a2Disease = []; //recs["Due"];
				    		var a3Disease = []; //recs["Eligible but not due"];
				    		var a4Disease = []; //recs["Up to date"];

				    		filterFor(recs["Overdue"],a1Vaccine,a1Disease);
				    		filterFor(recs["Due"],a2Vaccine,a2Disease);
				    		filterFor(recs["Eligible but not due"],a3Vaccine,a3Disease);
				    		filterFor(recs["Up to date"],a4Vaccine,a4Disease);

				    		var maxSizeV = Math.max(a1Vaccine.length,a2Vaccine.length,a3Vaccine.length,a4Vaccine.length);
				    		console.log("maxSizeV",maxSizeV);

				    		for(var x=0;x<maxSizeV;x++) {
				    			var r = [emptyIfNull(a1Vaccine[x]),emptyIfNull(a2Vaccine[x]),emptyIfNull(a3Vaccine[x]),emptyIfNull(a4Vaccine[x])];
				    			console.log("r",r);
				    				forecastByStatusTableVaccine.rows.add([r]);
				    		}

				    		var maxSizeD = Math.max(a1Disease.length,a2Disease.length,a3Disease.length,a4Disease.length);
					    	console.log("maxSizeD",maxSizeD);
				    		for(var x=0;x<maxSizeD;x++) {
				    			var r = [emptyIfNull(a1Disease[x]),emptyIfNull(a2Disease[x]),emptyIfNull(a3Disease[x]),emptyIfNull(a4Disease[x])];
				    			console.log("r",r);
				    				forecastByStatusTableDisease.rows.add([r]);
				    		}

				    		forecastByStatusTableVaccine.draw();
				    		forecastByStatusTableDisease.draw();

				    	}

				    	$("#dhir_loading").hide();

				    }, error: function() {
				    	$("#dhir_loading").hide();
				    	$("#dhirError").html("A system error occurred.");
				    }
				});
			}

			function filterFor(list,vaccineList,diseaseList){

				for(var x=0;x<list.length;x++) {
					if(list[x].vaccineCodes != null && list[x].vaccineCodes.length > 0){
						vaccineList.push(list[x]);
    					}else{
    						diseaseList.push(list[x]);
    					}
				}
				console.log("lists ",list.length,vaccineList.length,diseaseList.length);

			}

			function getEMRData() {
				$("#emr_loading").show();
				$("#emrError").hide();
				$("#compTbl").DataTable().clear();

				$.ajax({
					url: "<%=request.getContextPath()%>/dhir/summary.do?method=emrData&demographic_no=<%=demographic.getDemographicNo()%>&startDate=" + $("#emrStartDate").val() + "&endDate=" + $("#emrEndDate").val(),
				    type: 'GET',
				  //  data: param,
				  	dataType: 'json',
				    success: function(data) {
				    	var dt = $("#compTbl").DataTable();
				    	dt.clear();
				    	dt.rows.add(data.immunizations);
				    	dt.draw();

				    	$("#emr_loading").hide();
				    }
				});
			}



			getDHIRData();
			getEMRData();

			var startDate = $("#startDate").datepicker({
		        format : "yyyy-mm-dd"
		    });

			$("#startDate").on('change',function(){
				getDHIRData();
			});
			$("#endDate").on('change',function(){
				getDHIRData();
			});
			$("#dobDate").on('click',function(){
				getDHIRData();
			});

			$("#emrStartDate").on('change',function(){
				getEMRData();
			});
			$("#emrEndDate").on('change',function(){
				getEMRData();
			});

			$('.btn').button();

			$('.showing').on('change',function(){
				console.log('testing');
				if($("#showDHIR").is(":checked")) {
					$("#dhirDiv").show();
				} else {
					$("#dhirDiv").hide();
				}
				if($("#showEMR").is(":checked")) {
					$("#emrDiv").show();
				} else {
					$("#emrDiv").hide();
				}
				if($("#showForecast").is(":checked")) {
					$("#forecastDiv").show();
				} else {
					$("#forecastDiv").hide();
				}
				if($("#showDHIRDemoData").is(":checked")) {
					$("#dhir_demo_info").show();
				} else {
					$("#dhir_demo_info").hide();
				}

			});

			$("#disclaimerDismiss").on("click",function(){
				//update preference on server
				hideDisclaimer = true;

				$("#disclaimer").hide();

				$.ajax({
					url: "<%=request.getContextPath()%>/dhir/summary.do?method=hideDisclaimer",
				    type: 'GET',
				  	dataType: 'json',
				    success: function(data) {

				    }, error: function() {

				    }
				});
			})
		});


		function doPrint() {
			var includeEMR = $("#showEMR").is(":checked");
			var includeDHIR = $("#showDHIR").is(":checked");
			var includeForecast = $("#showForecast").is(":checked");

			window.location.href='<%=request.getContextPath()%>/dhir/printSummary.do?includeEMR='+includeEMR+'&includeDHIR='+includeDHIR+'&includeForecast='+includeForecast+'&demographicNo=<%=demographic.getDemographicNo()%>&startDate='+$("#startDate").val()+'&endDate='+$("#endDate").val()+'&emrStartDate='+$("#emrStartDate").val()+'&emrEndDate=' + $("#emrEndDate").val();
		}
	</script>
</head>
<body>

	<div class="container">
		<div class="row" style="margin-bottom:8px;margin-top:8px">
			<div class="col-sm-6" style="border:1px black solid;background-color:lightgray">
				<h4><%=demographic.getFormattedName() %></h4>
				<h5><%=demographic.getFormattedDob() %></h5>
				<h5><%=demographic.getHin() %> , <%=demographic.getSex() %></h5>
			</div>
			<div class="col-sm-6">
				<div class="btn-group" data-toggle="buttons">
				  <label class="btn btn-primary active">
				    <input type="checkbox" class="showing" id="showDHIRDemoData"> DHIR Patient Demographics
				  </label>
				  <label class="btn btn-primary">
				    <input type="checkbox"  class="showing" id="showEMR"> EMR Immunizations
				  </label>
				  <label class="btn btn-primary active">
				    <input type="checkbox" checked class="showing" id="showDHIR"> DHIR Immunizations
				  </label>

				  <label class="btn btn-primary active">
				    <input type="checkbox" checked class="showing" id="showForecast">Immunization Forecast
				  </label>

				   <label class="btn btn-primary" onClick="doPrint()">
				    <input type="checkbox" checked class="showing" id="printDHIR">Print
				  </label>
				</div>
			</div>
		</div>

		<div class="row">
			<div class="col-sm-12">
				<div id="disclaimer" class="alert alert-warning alert-dismissible" >
					<button type="button" class="close" id="disclaimerDismiss"><span aria-hidden="true">&times;</span></button>
				<b>Warning:</b> <%=OscarProperties.getInstance().get("dhir.disclaimer") %>
				</div>
			</div>
		</div>

		<div class="row" style="display:none;" id="dhir_demo_info">
			<div class="col-sm-12">
				<div id="disclaimer" class="alert alert-info" >
				<h4>Demographic information from DHIR</h4>
					<h5><span id="dhir_last_name"></span>,<span id="dhir_first_name"></span></h5>
					<h6><span id="dhir_dob"></span></h6>
					<h6><span id="dhir_hin"></span> , <span id="dhir_sex"></span></h6>

					<div style="display:none; color:red;" id="dhir_demo_info_warning"><b>Warning:</b> Local Demographic Information does not match Demographic Information from DHIR.</div>

				</div>
			</div>
		</div>


		<div class="row">
			<div style="background-color:#ccffeb;border: 1px black solid; display:none" id="emrDiv">

				<div class="col-sm-12"  style="padding-top:10px; padding-left:10px;padding-bottom:5px">
					<span class="h4"><b><u>Immunization Event(s) in EMR</u></b><br/></span>
				</div>

				<div class="col-sm-12">
					<div class="alert alert-danger" id="emrError" role="alert">
					</div>
				</div>

				<div class="col-sm-12">
					<div>
						<b>Date Range:</b> From <input type="text" name="emrStartDate" id="emrStartDate" value="<%=emrStartDate %>" /> to <input type="text" name="emrEndDate" id="emrEndDate" value="<%=emrEndDate %>"/>
						<span id="emr_loading"><i style="color:blue" class="fa fa-circle-notch fa-spin" aria-hidden="true"></i></span>
					</div>
				</div>

				<div class="col-sm-12">
					<table id="compTbl" class="stripe">

					</table>
				</div>

			</div>
		</div>

		<div class="row">
			<div class="col-sm-12" style="height:40px"></div>
		</div>

		<div class="row">
		<div style="background-color:#ccffff;border: 1px black solid"  id="dhirDiv">

			<div class="col-sm-12"  style="padding-top:10px; padding-left:10px;padding-bottom:5px">
				<span class="h4"><b><u>Immunization Event(s) from DHIR</u></b><br/></span>
			</div>
			<div class="col-sm-12">
				<div class="alert alert-danger" id="dhirError" role="alert">
				</div>
			</div>

			<div class="col-sm-12">
				<div>
					<b>Date Range:</b> From <input type="text" name="startDate" id="startDate" value="<%=startDate %>" /> to <input type="text" name="endDate" id="endDate" value="<%=endDate %>"/>
					<a id="dobDate" onclick="document.getElementById('startDate').value = '<%=dobDate%>';  console.log('table',document.getElementById('summaryTbl'));">-ALL-</a>
					<span id="dhir_loading"><i style="color:blue" class="fa fa-circle-notch fa-spin" aria-hidden="true"></i></span>
				</div>
			</div>

			<div class="col-sm-12">
				<table id="summaryTbl" class="stripe">
				</table>
				<div id="summaryPeriod"></div>
				<div id="summaryParams"></div>

			</div>
		</div>


		<div class="col-sm-12" style="height:40px"></div>


		<div style="background-color:#ccffff;border: 1px black solid"  id="forecastDiv">


			<div class="col-sm-12"  style="padding-top:10px; padding-left:10px;padding-bottom:5px">
					<span class="h4"><b><u>Immunization Forecast</u></b> <small>Generated on: <span id="immunizationsRecommendationDateGenerated"></span></small><br/></span>
				</div>
			<div class="col-sm-12">
				<h6>By Vaccine</h6>
				<table id="forecastByStatusTblVaccine">

				</table>
				<h6>By Disease</h6>
				<table id="forecastByStatusTblDisease">

				</table>
			</div>

			<div class="col-sm-12" style="height:5px"></div>

		</div>
		</div>



			<div class="col-sm-12" style="height:15px"></div>

	</div>
</body>
</html:html>
<%!
 String getCompleteURL(HttpServletRequest request) {
	StringBuffer requestURL = request.getRequestURL();
	if (request.getQueryString() != null) {
	    requestURL.append("?").append(request.getQueryString());
	}
	String completeURL = requestURL.toString();

	return completeURL;
}
%>