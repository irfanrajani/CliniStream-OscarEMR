<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>

<%--

	Copyright (c) 2013-2015. Department of Computer Science, University of Victoria. All Rights Reserved.
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
	Department of Computer Science
	LeadLab
	University of Victoria
	Victoria, Canada

--%>

<%@ include file="/casemgmt/taglibs.jsp"%>
<%@page import="java.util.*" %>
<%@page import="org.apache.logging.log4j.Logger" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Provider,org.oscarehr.PMmodule.dao.ProviderDao"%>
<%
Logger logger = org.oscarehr.util.MiscUtils.getLogger();
//Get list of providers           
String curProviderNo = (String) session.getAttribute("user"); 
ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
Provider provider = providerDao.getProvider(curProviderNo);

logger.info("user: " + curProviderNo);
List<Provider> providerList = null;
providerList = providerDao.getBillableProviders();
// for (Provider p: providerList) {
//      logger.info("provider: " + p.getFullName());
// }
%>

<%
//   String curUser_no;
//   curUser_no = (String) session.getAttribute("user");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
<html:html>
<head>
 <meta name="viewport" content="width=device-width, initial-scale=1.0">

<html:base />
<title><bean:message key="provider.dashboardUserPrefs" /></title>

<!-- Bootstrap -->
<link rel="stylesheet" type="text/css" media="all" href="<c:out value="${ctx}"/>/library/bootstrap/3.0.0/css/bootstrap.min.css">
<script src="<c:out value="${ctx}"/>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
<!-- Include all compiled plugins (below) -->
<script src="<c:out value="${ctx}"/>/library/bootstrap/3.0.0/js/bootstrap.min.js"></script>

<script>
	jQuery.noConflict();
</script>
<style>
.MainTableTopRow {
background-color: gainsboro;
}
</style>

</head>

<body class="BodyStyle" vlink="#0000FF">

<table class="MainTable" width="100%" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><H4>&nbsp;<bean:message key="provider.setNoteStaleDate.msgPrefs" /></H4></td>
		<td style="text-align:center;" class="MainTableTopRowRightColumn"><bean:message key="provider.dashboardUserPrefs" /></td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn">&nbsp;</td>
		<td class="MainTableRightColumn">
			<!-- form starts here -->
			<form action="<c:out value="${ctx}"/>/provider/DashboardUserPreference.do?method=save" method="post" class="form-horizontal">

<div class="container"><br>

<%
String method = request.getParameter("method");
if (method != null) {
%>
<div class="alert alert-success">Success!</div>
<% } %>

 <div class="form-group">
    <label for="dashboardUser" class="col-md-4 control-label">Default Dashboard User</label>
    <div class="col-md-3">
      <%
						String val1 = (String)request.getAttribute("dashboardUser");
						if(val1 == null) val1 = curProviderNo;
					%>
					<select id="dashboardUser" name="dashboardUser" class="form-control">
					<option value="" <%=(val1.equals("")?"selected=\"selected\"":"") %>></option>
					<%for(Provider p: providerList) {%>
						<option value="<%=p.getProviderNo()%>"<%=(val1.equals(p.getProviderNo())?"selected=\"selected\"":"") %>><%=p.getFullName()%></option>
						<%}%>
					</select>
    </div>
  </div>
    <oscar:oscarPropertiesCheck property="billregion" value="ON">
        <div class="form-group">
            <label for="shareDashboard" class="col-md-4 control-label">Share With Ontario Common Dashboard</label>
            <div class="col-md-3">
					<%
						val1 = (String)request.getAttribute("shareDashboard");
						if(val1 == null) val1 = "false";
					%>
					<select id="shareDashboard" name="shareDashboard" class="form-control">
						<option value="" <%=(val1.equals("")?"selected=\"selected\"":"") %>></option>
						<option value="true" <%=(val1.equals("true")?"selected=\"selected\"":"") %>>YES</option>
						<option value="false" <%=(val1.equals("false")?"selected=\"selected\"":"") %>>NO</option>
					</select>
            </div>
        </div>
    </oscar:oscarPropertiesCheck>
  <div class="form-group">
    <div class="col-md-offset-4 col-md-4"><br>
        <input type="submit" class="btn btn-primary" value="Save Changes"/>&nbsp;
        <input type="button" class="btn" value="Close" onclick="window.close();"/>
    </div>
  </div>

</body>
</html:html>