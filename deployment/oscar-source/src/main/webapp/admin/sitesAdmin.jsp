<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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

--%>
<!DOCTYPE HTML>
<%-- This JSP is the multi-site admin page --%>
<%@ include file="/taglibs.jsp"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
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

<%@page import="org.oscarehr.common.model.Site"%>
<html:html locale="true">
<head>
<title>Clinic</title>
    <script src="${pageContext.request.contextPath}/js/global.js"></script>
    <script	src="${pageContext.request.contextPath}/share/javascript/Oscar.js"></script>
    <link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->
</head>
<body class="BodyStyle">
<h4><bean:message key="admin.admin.sitesAdmin" /></h4>

<nested:form action="/admin/ManageSites?method=add">
<nested:submit styleClass="btn">Add New Site</nested:submit>
</nested:form>

  <display-el:table name="sites" id="site" class="table table-striped table-hover" >
     <display-el:column title="Active" ><c:choose ><c:when test="${site.status==0}">No</c:when><c:otherwise>Yes</c:otherwise></c:choose></display-el:column>
     <display-el:column title="Site Name">
     <a href="<%= request.getContextPath() %>/admin/ManageSites.do?method=update&siteId=<c:out value='${site.siteId}'/>" ><c:out value="${site.name}" /></a></display-el:column>
     <display-el:column property="shortName" title="Short Name" />
     <display-el:column property="bgColor" title="Color" style="background-color:${site.bgColor}" />
     <display-el:column property="phone" title="Telephone" />
     <display-el:column property="fax" title="FAX" />
     <display-el:column property="address" title="Address" style="width: 200px;" />
     <display-el:column property="city" title="City" />
     <display-el:column property="province" title="Province" />
     <display-el:column property="postal" title="Postal Code" />
   <% if (org.oscarehr.common.IsPropertiesOn.isProviderFormalizeEnable()) { %>
     <display-el:column property="providerIdFrom" title="ProviderID From" />
     <display-el:column property="providerIdTo" title="ProviderID To" />
   <% } %>
  </display-el:table>




</html:html>