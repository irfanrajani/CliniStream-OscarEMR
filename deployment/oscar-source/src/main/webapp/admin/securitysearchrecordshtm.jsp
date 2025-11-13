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
<title><bean:message key="admin.securitysearchrecordshtm.title" /></title>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

<script>
<!--

	function setfocus() {
	  document.searchprovider.keyword.focus();
	  document.searchprovider.keyword.select();
	}

  function onsub() {
    // check input data in the future
  }
	function upCaseCtrl(ctrl) {
		ctrl.value = ctrl.value.toUpperCase();
	}

//-->
    </script>
</head>

<body onLoad="setfocus()">
<h4><i class="icon-search" title=""></i>&nbsp;<bean:message key="admin.securitysearchrecordshtm.description" /></h4>
<div class="well">
<form method="post" action="securitysearchresults.jsp" name="searchprovider" onsubmit="return onsub()">
    <table style="width:100%">
	    <tr>
		    <td style="text-align:right; vertical-align:middle"><b><i><bean:message
			    key="admin.securitysearchrecordshtm.msgCriteria" /></i></b>&nbsp;&nbsp;</td>
		    <td style="white-space: nowrap;">
		    <input type="radio" name="search_mode" value="search_username">
		    <bean:message key="admin.securityrecord.formUserName" /></td>
		    <td style="white-space: nowrap;">
		    <input type="radio" checked name="search_mode"
			    value="search_providerno"> <bean:message
			    key="admin.securityrecord.formProviderNo" /></td>
		    <td style="vertical-align:middle; text-align:left" >
                <div class="input-append" name="keywordwrap">
			        <input type="text" name="keyword" class="input input-large" maxlength="100" >
                    <button type="submit" name="button" class="btn add-on" style="height:30px; width:30px;" >
                    <i class="icon-search" title="<bean:message key="admin.securitysearchrecordshtm.btnSearch"/>" ></i></button>
                </div>
			    <input type="hidden" name="orderby" value="user_name">
			    <input type="hidden" name="limit1" value="0">
			    <input type="hidden" name="limit2" value="10000">
			    </td>
	    </tr>
    </table>
	</form>
</div>

</body>
</html:html>