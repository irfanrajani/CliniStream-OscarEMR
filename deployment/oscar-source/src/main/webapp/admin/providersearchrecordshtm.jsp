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
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>

<%
    String curProvider_no = (String) session.getAttribute("user");
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");

    boolean isSiteAccessPrivacy=false;
    boolean authed=true;
%>

<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.userAdmin" rights="*" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.userAdmin");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<security:oscarSec objectName="_site_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%isSiteAccessPrivacy=true; %>
</security:oscarSec>


<html:html locale="true">
<head>
<title><bean:message key="admin.providersearchrecordshtm.title" /></title>
<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->

<script>

	function setfocus() {
		  document.searchprovider.keyword.focus();
		  document.searchprovider.keyword.select();
	}

    function onsub() {
      // make keyword lower case
      var keyword = document.searchprovider.keyword.value;
      var keywordLowerCase = keyword.toLowerCase();
      document.searchprovider.keyword.value = keywordLowerCase;
    }
	function upCaseCtrl(ctrl) {
		ctrl.value = ctrl.value.toUpperCase();
	}

</script>

</head>

<body onLoad="setfocus()" >
<h4>
<i class="icon-search" title="Patient Search"></i>&nbsp;<bean:message key="admin.providersearchrecordshtm.description" /></h4>

<div class="well">
<form method="post" action="providersearchresults.jsp" name="searchprovider" onsubmit="return onsub()">
<table style="width:100%">
	<tr>
		<td rowspan="2"  style="text-align:right; vertical-align:middle">
			<b class="blue-text"><i><bean:message key="admin.search.formSearchCriteria" /></i></b>
		</td>
		<td style="white-space: nowrap;">
				<input type="radio" checked="checked" name="search_mode"
					   value="search_name" onclick="document.forms['searchprovider'].keyword.focus();">
				<bean:message key="admin.providersearch.formLastName" />
		</td>
		<td style="white-space: nowrap;">
				<input type="radio"	name="search_mode"
					   value="search_providerno" onclick="document.forms['searchprovider'].keyword.focus();">
				<bean:message key="admin.providersearch.formNo" />
		</td>
		<td style="white-space: nowrap;">
				<input type="radio" name="search_status" value="All">
				<bean:message key="admin.providersearch.formAllStatus" />
            <br/>
				<input type="radio" name="search_status" value="1" checked="checked">
				<bean:message key="admin.providersearch.formActiveStatus" />
			<br/>
				<input type="radio" name="search_status" value="0">
				<bean:message key="admin.providersearch.formInactiveStatus" />
		</td>
		<td style="vertical-align:middle; text-align:left" rowspan="2" >
            <div class="input-append">
			    <input type="text" name="keyword" class="input input-large" maxlength="100">
                <button type="submit" name="button" class="btn add-on" style="height:30px; width:30px" >
                    <i class="icon-search" title="<bean:message key="admin.search.btnSubmit"/>"></i></button>
            </div>
			<input type="hidden" name="orderby" value="last_name">
			<input type="hidden" name="limit1" value="0">
			<input type="hidden" name="limit2" value="10000">
		</td>
	</tr>
</table>
</form>
</div>
</body>
</html:html>