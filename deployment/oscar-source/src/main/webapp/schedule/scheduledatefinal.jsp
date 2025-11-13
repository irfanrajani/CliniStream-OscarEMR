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

  String user_no = (String) session.getAttribute("user");
  String creator = (String) session.getAttribute("userlastname")+","+ (String) session.getAttribute("userfirstname");
%>
<%@ page
	import="java.util.*, java.sql.*, oscar.*, java.text.*, java.lang.*,java.net.*"
	errorPage="../appointment/errorpage.jsp"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>

<jsp:useBean id="scheduleDateBean" class="java.util.Hashtable"
	scope="session" />
<%
  //String provider_name = URLDecoder.decode(request.getParameter("provider_name"));
  String sdate ="";
  String provider_no = request.getParameter("provider_no");
  String available = "";
  String priority = "c";
  String reason = "";
  String hour = "";

%>

<%@page import="org.oscarehr.util.MiscUtils"%><html:html locale="true">
<head>
<title><bean:message key="schedule.scheduledatefinal.title" /></title>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->

<script language="JavaScript">
<!--
function setfocus() {
  this.focus();
  //document.schedule.keyword.focus();
  //document.schedule.keyword.select();
}
function upCaseCtrl(ctrl) {
	ctrl.value = ctrl.value.toUpperCase();
}


//-->
</script>
</head>
<body onLoad="setfocus()">
<form method="post" name="schedule" action="schedulecreatedate.jsp">
<h4><bean:message key="schedule.schedulecreatedate.msgMainLabel" /></h4>
<div class="alert">
<bean:message key="schedule.scheduledatefinal.msgStepOne" />
</div>
<div class="alert alert-success">
<bean:message key="schedule.scheduledatefinal.msgSettingFinished" /></td>
</div>
<div style="align:left"><input type="button" name="Button" clas="btn"
					value='<bean:message key="schedule.scheduledatefinal.btnDoAgain"/>'
					onclick="self.location.href='scheduletemplatesetting.jsp'">
</div>


</form>


</body>
</html:html>