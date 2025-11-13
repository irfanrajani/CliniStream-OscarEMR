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
	key="oscarEncounter.Measurements.msgSelectMeasurementGroup" /></title>

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">


<script type="text/javascript">
    function set(target) {
     document.forms[0].forward.value=target;
};

function confirmDelete(target) {

    var selected = document.forms[0].selectedGroupName.options[document.forms[0].selectedGroupName.selectedIndex].value;
    var answer = confirm("Are you sure you want to delete " + selected + " group?");
    if(answer){
        set(target);
        document.forms[0].submit();
    }
};

</script>

</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />
    <html:form
	action="/oscarEncounter/oscarMeasurements/SelectMeasurementGroup.do">
		<input type="hidden" name="forward" value="error" >
        <h3><bean:message key="oscarEncounter.Measurements.msgSelectMeasurementGroup" /></h3>
        <div class="well">
			<table>
				<tr>
					<td>
					<table>
						<tr>
							<td><bean:message
								key="oscarEncounter.oscarMeasurements.SelectMeasurementGroup.selectGroup" />
							<html:select property="selectedGroupName">
								<html:options collection="groups" property="groupName"
									labelProperty="groupName" />
							</html:select></td>
						</tr>
						<tr>
							<td>
							<table>
								<tr>
									<td><!--<input type="button" name="Button" class="btn"
										value="<bean:message key="global.btnClose"/>"
										onClick="window.close()">--></td>
									<td><input type="button" name="Button" class="btn"
										value="<bean:message key="oscarEncounter.oscarMeasurements.MeasurementsAction.modifyMeasurementTypeBtn"/>"
										onclick="set('type');submit();" ></td>
									<td><input type="button" name="Button" class="btn"
										value="<bean:message key="oscarEncounter.oscarMeasurements.MeasurementsAction.modifyMeasurementStyleBtn"/>"
										onclick="set('style');submit();" ></td>
									<td><input type="button" name="Button" class="btn"
										value="Modify Decision Support for Group"
										onclick="set('dsHTML');submit();" ></td>
									<td><input type="button" name="Button" class="btn"
										value="<bean:message key="oscarEncounter.oscarMeasurements.MeasurementsAction.deleteBtn"/>"
										onclick="confirmDelete('delete');" ></td>
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