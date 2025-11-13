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

<%@ page import="oscar.OscarProperties"%>
<%@ page import="java.util.*"%>

<%
Properties oscarVariables = OscarProperties.getInstance();
String help_url = (oscarVariables.getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/")).trim();
%>
<html:html locale="true">
<head>
<html:base />
<title><bean:message
	key="oscarEncounter.Measurements.msgCustomization" /></title>

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="${pageContext.servletContext.contextPath}/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->


<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />

        <h3><bean:message key="oscarEncounter.Measurements.msgCustomization" /></h3>
        <div class="well alert">
<strong><bean:message key="global.warning" /></strong>&nbsp;
<bean:message key="global.First" />
<bean:message key="oscarMessenger.DisplayMessages.msgStatusRead" />
<a href="<%=help_url%>customize-measurements/" target="_help" ><bean:message key="global.help" /></a>


</body>
</html:html>