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

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="org.oscarehr.caisi_integrator.ws.CachedDemographicLabResult"%>
<%@ page import="org.oscarehr.managers.DemographicManager" %>
<%@ page import="org.oscarehr.common.model.Demographic"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.Serializable"%>

<%@ page import="org.w3c.dom.Document"%>

<%@ page import="oscar.oscarLab.ca.on.*"%>
<%@ page import="oscar.oscarLab.ca.all.web.LabDisplayHelper"%>

<%@ page import="org.owasp.encoder.Encode"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%

String labType = request.getParameter("labType");
String demographicNo = request.getParameter("demo");
String testName = request.getParameter("testName");
String identifier = request.getParameter("identifier");
String remoteFacilityIdString = request.getParameter("remoteFacilityId");
String remoteLabKey = request.getParameter("remoteLabKey");

if (identifier == null) identifier = "NULL";

String highlight = "#E0E0FF";

LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

DemographicManager demographicManager = SpringUtils.getBean( DemographicManager.class );
Demographic demographic = demographicManager.getDemographic(loggedInInfo, demographicNo);

ArrayList list = null;

if (! (demographicNo == null || "null".equals(demographicNo) || "undefined".equals(demographicNo)) ){
	if(remoteFacilityIdString==null)
	{
		list = CommonLabTestValues.findValuesForTest(labType, Integer.valueOf(demographicNo), testName, identifier);
	}
	else
	{
		CachedDemographicLabResult remoteLab=LabDisplayHelper.getRemoteLab(loggedInInfo, Integer.parseInt(remoteFacilityIdString), remoteLabKey,Integer.parseInt(demographicNo));
		Document labContentsAsXml=LabDisplayHelper.getXmlDocument(remoteLab);
		HashMap<String, ArrayList<Map<String, Serializable>>> mapOfTestValues=LabDisplayHelper.getMapOfTestValues(labContentsAsXml);
		list=mapOfTestValues.get(identifier);
	}
}



%>
<!DOCTYPE html>
<html:html locale="true">
<head>
<html:base />
<title><bean:message key="oscarMDS.segmentDisplay.title" /></title>
    <script src="${pageContext.request.contextPath}/js/global.js"></script>

    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet"> <!-- Bootstrap 2.3.1 -->
    <link href="${pageContext.request.contextPath}/css/DT_bootstrap.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet" >
    <script src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="${pageContext.request.contextPath}/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->

    <script>
    // NOTE
    // if 404 eg offline, no translation available at data tables eg en-CA, no properties file entry for this langauge, etc
    // the english default will automatically be used
    // I am ordering by date descending (column 5)

	    jQuery(document).ready( function () {
	        jQuery('#tblDiscs').DataTable({
            "columnDefs": [
                { searchable: false,
                   orderable:false,
                    targets: 0,
                },],
            "lengthMenu": [ [10, 25, 50, -1], [10, 25, 50, "<bean:message key="oscarEncounter.LeftNavBar.AllLabs"/>"] ],
            "order": [5],
            "searching": false,
            "language": {
                        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
            });
	    });
    </script>

    <style>
        .AbnormalRes {
            color: orange;
        }
        .LoRes {
            color: blue;
        }
        .HiRes {
            color: red;
        }
    </style>

    <style media="print">
         .DoNotPrint {
	        display:none;
         }
     </style>



<script>
function getComment() {
    var commentVal = prompt('<bean:message key="oscarMDS.segmentDisplay.msgComment"/>', '');
    document.acknowledgeForm.comment.value = commentVal;
    return true;
}

function popupStart(vheight,vwidth,varpage,windowname) {
    var page = varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    var popup=window.open(varpage, windowname, windowprops);
}
</script>
</head>
<body>

  <%  if(demographic==null){%>

<script>
alert("The demographic number is not valid");
window.close();
</script>

    <%} else{%>
<form name="acknowledgeForm" method="post"
	action="../../../oscarMDS/UpdateStatus.do">

<table style="page-break-inside: avoid; width: 100%;">
	<tr>
		<td>

		<table style="width: 100%; border-spacing: 0px; border-collapse: collapse;">
			<tr style= "border-width: 1px; border-color:black; border-style: solid;">
				<td style="width: 100%; text-align: center;" class="Cell">
				<div class="Field2"><bean:message
					key="oscarMDS.segmentDisplay.formDetailResults" /></div>
				</td>
			</tr>
			<tr style="border-width: 1px; border-color:black; border-style: solid;">
				<td>
						<table style="width: 100%; border-spacing: 0px; ">
							<tr>
								<td>

								<table style="width: 66%; border-spacing: 0px;">
									<tr>
										<td>
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formPatientName" />: </strong> <%=Encode.forHtml(demographic.getFormattedName())%></div>

										</td>
										<td>
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formSex" />: </strong><%=Encode.forHtml(demographic.getSex())%>
										</div>
										</td>
									</tr>
									<tr>
										<td >
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formDateBirth" />: </strong> <%=Encode.forHtml(demographic.getFormattedDob())%>
										</div>
										</td>
										<td >
										<div class="FieldData"><strong><bean:message
											key="oscarMDS.segmentDisplay.formAge" />: </strong><%=Encode.forHtml(demographic.getAge())%>
										</div>
										</td>
									</tr>
								</table>

								</td>
								<td style="width: 33%;"></td>
							</tr>
						</table>
						</td>
					</tr>
			<tr style= "border-width: 1px; border-color:black; border-style: solid; ">
				<td style="width: 100%; text-align: center;" class="Cell">
				<div class="Field2">&nbsp;</div>
				</td>
			</tr>
				</table>
				</td>
			</tr>
		</table>


		<table style="width: 100%;"
			id="tblDiscs" class= "table table-condensed table-striped">
            <thead>
			<tr class="Field2">
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formTestName" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formResult" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formAbn" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formReferenceRange" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formUnits" /></th>
				<th class="Cell"><bean:message
					key="oscarMDS.segmentDisplay.formDateTimeCompleted" /></th>
			</tr>
            </thead>
			<%  int linenum = 0;

                            if (list != null){
                               for (int i = 0 ;  i < list.size(); i++){
                                   Map h = (Map) list.get(i);
                                   String lineClass = "NormalRes";
                                   if ( h.get("abn") != null && (h.get("abn").toString().length() > 0) ){
                                      lineClass = "AbnormalRes";
                                   }
                                   if ( h.get("abn") != null && (h.get("abn").toString().toLowerCase().contains("l")) ){
                                      lineClass = "LoRes";
                                   }
                                   if ( h.get("abn") != null && (h.get("abn").toString().toLowerCase().contains("h")) ){
                                      lineClass = "HiRes";
                                   }
%>

			<tr	class="<%=lineClass%>">
				<td><%=h.get("testName") %></td>
				<td><%=h.get("result") %></td>
				<td><%=h.get("abn") %></td>
				<td><%=h.get("range")%></td>
				<td><%=h.get("units") %></td>
				<td><%=h.get("collDate")%></td>
			</tr>

			<%     }
                            } %>

		</table>

		<table style="width: 100%;"
			class="MainTableBottomRowRightColumn" >
			<tr>
				<td><input type="button" class="btn DoNotPrint btn-primary"
					value=" <bean:message key="global.btnClose"/> "
					onClick="window.close()"> <input type="button" class="btn DoNotPrint"
					value=" <bean:message key="global.btnPrint"/> "
					onClick="window.print()">
                               <%-- <input type="button" value="Plot"
                                onclick="window.open('../../../oscarEncounter/GraphMeasurements.do?method=actualLab&demographic_no=<%=demographicNo%>&labType=<%=labType%>&identifier=<%=identifier%>&testName=<%=testName%>');">
                                --%>
                               <input type="button" value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.plot"/>" class="btn DoNotPrint"
                                onclick="window.location = 'labValuesGraph.jsp?demographic_no=<%=demographicNo%>&labType=<%=labType%>&identifier=<%=identifier%>&testName=<%=testName%>';"/>
                                </td>
			</tr>
		</table>


</form>
<%}%>
</body>
</html:html>