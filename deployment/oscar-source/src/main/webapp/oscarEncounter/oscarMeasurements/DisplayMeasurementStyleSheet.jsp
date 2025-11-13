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
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<html:html locale="true">
<head>
<html:base />
    <title><bean:message
	key="oscarEncounter.Measurements.msgDisplayMeasurementStyleSheets" /></title>
<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">
</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />
    <html:form
	    action="/oscarEncounter/oscarMeasurements/DeleteMeasurementStyleSheet">
        <h3><bean:message key="oscarEncounter.Measurements.msgDisplayMeasurementStyleSheets" /></h3>
        <div class="container">
            <table class="table table-striped">
	            <tr>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.Measurements.headingStyleSheetName" />
		            </th>
		            <th><bean:message
			            key="oscarEncounter.oscarMeasurements.MeasurementAction.headingDelete" />
		            </th>
	            </tr>
	            <logic:iterate id="styleSheet" name="styleSheets"
		            property="styleSheetNameVector" indexId="ctr">
		            <tr class="data">
			            <td><bean:write name="styleSheet"
				            property="styleSheetName" /></td>
			            <td><input type="checkbox" name="deleteCheckbox"
				            value="<bean:write name="styleSheet" property="cssId" />"></td>
		            </tr>
	            </logic:iterate>
            </table>
            <table>
	            <tr>
		            <td><!--<input type="button" name="Button" class="btn"
			            value="<bean:message key="global.btnClose"/>"
			            onClick="window.close()">--></td>
		            <td><input type="button" name="Button" class="btn"
			            value="<bean:message key="oscarEncounter.oscarMeasurements.displayHistory.headingDelete"/>"
			            onclick="submit();" ></td>
	            </tr>
            </table>
        </div>
    </html:form>
</body>
</html:html>