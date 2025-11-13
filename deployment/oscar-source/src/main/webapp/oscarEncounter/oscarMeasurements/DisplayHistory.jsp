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

<%
  if(session.getValue("user") == null) response.sendRedirect("../../logout.jsp");
  String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="oscar.oscarEncounter.pageUtil.*"%>
<%@ page import="oscar.oscarEncounter.oscarMeasurements.pageUtil.*"%>
<%@ page import="oscar.oscarEncounter.oscarMeasurements.bean.*"%>
<%@ page import="java.util.Vector"%>

<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="org.oscarehr.managers.DemographicManager" %>
<%@ page import="org.oscarehr.common.model.Demographic"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>

<%@ page import="org.owasp.encoder.Encode"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>

<%
    String demo = ((Integer) request.getAttribute("demographicNo")).toString();
    LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    DemographicManager demographicManager = SpringUtils.getBean( DemographicManager.class );
    Demographic demographic = demographicManager.getDemographic(loggedInInfo, demo);

%>
<!DOCTYPE html>
<html:html locale="true">

<head>
<title><bean:message key="oscarEncounter.Index.oldMeasurements" />
</title>
<html:base />

    <script src="${ pageContext.request.contextPath }/js/global.js"></script>

    <link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->
    <link href="${ pageContext.request.contextPath }/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
    <script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="${ pageContext.request.contextPath }/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->

    <script>
    // NOTE
    // DataTables 1.13.4 language plugin is tested compatible with 1.10.11
    // and allows for specific use of tag global.i18nLanguagecode=fr-FR  pt-BR
    // if 404 eg offline, no translation available at data tables eg en-CA, no properties file entry for this langauge, etc
    // the english default will automatically be used

	    jQuery(document).ready( function () {
	        jQuery('#tblDiscs').DataTable({
            "order": [],
	        "bPaginate": false,
            "searching": false,
            "language": {
                        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
            });
	    });
    </script>

    <style type="text/css" media="print">
         .DoNotPrint {
	        display:none;
         }
     </style>
</head>
<body
	onload="window.focus();">
<html:errors />
<html:form action="/oscarEncounter/oscarMeasurements/DeleteData" >

<table style="border-width: 2px; width: 100%; border-spacing: 0px; ">
        <logic:present name="messages">
            <tr>
                <td>
                    <logic:iterate id="msg" name="messages">
                        <div class="alert">
							<bean:write name="msg" />
						</div>
                    </logic:iterate>
				</td>
            </tr>
        </logic:present>
	<tr>
		<td>

		<table style="width: 100%; border-spacing: 0px; border-collapse: collapse;">
			<tr style="border-width: 1px; border-color:black; border-style: solid;">
				<td style="width: 100%; text-align: center;" class="Cell">
				<div class="Field2"><bean:message
					key="oscarMDS.segmentDisplay.formDetailResults" /></div>
				</td>
			</tr>
			<tr style="border-width: 1px; border-color:black; border-style: solid;">
				<td>
                    <table style="width: 100%; border-spacing: 0px;">
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
    <tr>
        <td>

        <table id="tblDiscs" class= "table table-condensed table-striped">
            <thead>
			    <tr>
					<th class="Header" ><bean:message
							key="oscarEncounter.oscarMeasurements.displayHistory.headingType" />
					</th>
					<th class="Header" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingProvider" />
					</th>
					<th class="Header" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingMeasuringInstruction" />
					</th>
					<th class="Header" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingData" />
					</th>
					<th class="Header" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingComments" />
					</th>
					<th class="Header" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingObservationDate" />
					</th>
					<th class="Header" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingDateEntered" />
					</th>
					<security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="w">
					<th class="Header DoNotPrint" ><bean:message
						key="oscarEncounter.oscarMeasurements.displayHistory.headingDelete" />
					</th>
					</security:oscarSec>

			    </tr>
            </thead>
            <tbody>
			<logic:iterate id="data" name="measurementsData" property="measurementsDataVector" indexId="ctr">
				<logic:present name="data" property="remoteFacility">
					<tr class="data" style="background-color:#ffcccc" >
				</logic:present>
				<logic:notPresent name="data" property="remoteFacility">
					<tr class="data" >
				</logic:notPresent>
						<td><a title="<bean:write name="data" property="typeDescription" />"><bean:write name="data" property="type" /></a></td>
						<td>
								<bean:write name="data" property="providerFirstName" />
								<bean:write name="data" property="providerLastName" />
								<logic:present name="data" property="remoteFacility">
									<br /><span style="color:#990000"> @: <bean:write name="data" property="remoteFacility" /><span>
								</logic:present>
						</td>
						<td>
                            <logic:match name="data" property="measuringInstrc" value="NULL" >&nbsp;</logic:match>
                            <logic:notMatch name="data" property="measuringInstrc" value="NULL" ><bean:write name="data" property="measuringInstrc" /></logic:notMatch>
                        </td>
						<td title="data"><bean:write name="data" property="dataField" /></td>
						<td title="comments"><bean:write name="data" property="comments" /></td>
						<td title="observed date"><bean:write name="data" property="dateObservedAsDate" format="yyyy-MM-dd" /></td>
						<td title="entered date"><bean:write name="data" property="dateEnteredAsDate" format="yyyy-MM-dd"/></td>
						<security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="w">
						<td class="DoNotPrint" >
						    <logic:present name="data" property="remoteFacility">
                                &nbsp;
                            </logic:present>
						    <logic:notPresent name="data" property="remoteFacility">
					    	    <input type="checkbox" name="deleteCheckbox" value="<bean:write name="data" property="id" />">
						    </logic:notPresent>
                        </td>
                        </security:oscarSec>
					</tr>
				</logic:iterate>
			    </tbody>
            </table>
        <tr><td>
			<table>
				<tr>
					<td><input type="button" name="Button" class="btn DoNotPrint"
						value="<bean:message key="oscarEncounter.oscarMeasurements.oldmesurementindex"/>"
						onClick="javascript: popupPage(300,800,'SetupHistoryIndex.do')"></td>
					<td><input type="button" name="Button" class="btn DoNotPrint"
						value="<bean:message key="global.btnPrint"/>"
						onClick="window.print()"></td>
					<td><input type="button" name="Button" class="btn DoNotPrint"
						value="<bean:message key="global.btnClose"/>"
						onClick="window.close()"></td>
					<security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="w">
					<td><input type="button" name="Button" class="btn DoNotPrint"
						value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.headingDelete"/>"
						onclick="submit();" ></td>
					</security:oscarSec>
					<logic:present name="data" property="canPlot">
						<td><input type="button" name="Button" class="btn DoNotPrint" value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.plot"/>"
							onClick="javascript: popupPage(600,1000,'../../oscarEncounter/GraphMeasurements.do?demographic_no=<%=demo%>&type=<bean:write name="type" />')" >
						</td>
					</logic:present>
				</tr>
			</table>

        </td>
    </tr>
   </tbody>
</table>
    <logic:present name="type">
	    <input type="hidden" name="type"
		    value="<bean:write name="type" />" >
    </logic:present>
</html:form>
</body>
</html:html>