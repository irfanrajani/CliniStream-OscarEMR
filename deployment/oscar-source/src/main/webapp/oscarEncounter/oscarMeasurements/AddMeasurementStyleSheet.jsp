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
<!DOCTYPE html>
<%
  if(session.getValue("user") == null) response.sendRedirect("../../logout.jsp");
%>
<%@ page import="java.util.*,oscar.oscarReport.pageUtil.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<html:html locale="true">
<head>
<html:base />
    <title><bean:message
	key="oscarEncounter.Measurements.msgAddMeasurementStyleSheet" /></title>

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="<%=request.getContextPath()%>/js/jquery-ui-1.10.2.custom.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/js/jquery_css/smoothness/jquery-ui-1.10.2.custom.min.css"" rel="stylesheet">

<script>
$(function() {
    $( document ).tooltip();
  });
</script>

</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />
    <html:form
	    action="/oscarEncounter/oscarMeasurements/AddMeasurementStyleSheet.do"
	    method="POST" enctype="multipart/form-data">
        <h3><bean:message key="oscarEncounter.Measurements.msgAddMeasurementStyleSheet" /></h3>
        <div class="well">
			<table>
				<tr>
					<td>
					<table>
						<tr>
					        <td>
                                <logic:present name="messages">
						            <logic:iterate id="msg" name="messages">
                                        <div class="alert alert-success">
							                <bean:write name="msg" />
							                <a class="close" data-dismiss="alert" href="#">&times;</a>
                                        </div>
							            <br>
						            </logic:iterate>
					            </logic:present>
                            </td>
						<tr>
							<td align="left"><bean:message
								key="oscarEncounter.oscarMeasurements.createNewMeasurementStyleSheet" />
							</td>
						</tr>
						<tr>
							<td><html:file property="file" size="35" />
							<span title="<bean:message key="global.uploadWarningBody"/>" style="vertical-align:middle;font-family:arial;font-size:20px;font-weight:bold;color:#ABABAB;cursor:pointer"><img border="0" src="../../images/icon_alertsml.gif"/></span></span>

							</td>
						</tr>
						<tr>
							<td>
							<table>
								<tr>
									<td><!--<input type="button" name="Button"
										value="<bean:message key="global.btnClose"/>"
										onClick="window.close()">--></td>
									<td><input type="button" name="Button"
										value="<bean:message key="oscarEncounter.oscarMeasurements.MeasurementsAction.continueBtn"/>"
										onclick="submit();" /></td>
								</tr>
							</table>
							</td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
        </div>
    </html:form>
</body>
</html:html>