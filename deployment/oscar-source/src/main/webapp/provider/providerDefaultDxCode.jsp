<%--


    Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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

    This software was written for
    Centre for Research on Inner City Health, St. Michael's Hospital,
    Toronto, Ontario, Canada

--%>
<!DOCTYPE html>
<%@page import="org.oscarehr.common.model.ProviderPreference"%>
<%@page import="org.oscarehr.common.dao.ProviderPreferenceDao"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="java.util.List"%>


<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.apache.commons.lang.time.DateFormatUtils" %>

<%@ include file="/casemgmt/taglibs.jsp"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"	scope="request" />
<html:html>
	<head>
		<html:base />
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title><bean:message key="billing.billingDigSearch.title" /></title>
        <script src="<c:out value="${ctx}"/>/js/global.js"></script>
        <link href="<c:out value="${ctx}"/>/css/bootstrap.css" rel="stylesheet" type="text/css"><!-- Bootstrap 2.3.1 -->

        <script type="text/javascript">
        var remote=null;
        var awnd=null;
        function rs(n,u,w,h,x) {
            args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,top=60,left=30";
            remotew=window.open(u,n,args);
        }
        function dxScriptAttach(name2) {
	        ff = eval("document.forms[0].elements['" +name2+"']");
            f0 = ff.value;
	        f1 = escape("document.forms[0].elements[\'"+name2+"\'].value");
	        awnd=rs('atts','<c:out value="${ctx}"/>/billing/CA/ON/billingDigSearch.jsp?name='+f0 + '&search=&name2='+f1,800,800,1);
	        //awnd.focus();

        }

        function callChangeCodeDesc() {
            changeCodeDesc()
        };

        function changeCodeDesc() {
            var url  = "<c:out value="${ctx}"/>/billing/CA/ON/billingON_dx_desc.jsp";
            var pars = "diagnostic_code=" + document.forms[0].dxCode.value;

            fetch(url+"?"+pars, {method:"get"})
            .then(function (response){ return response.text();
            }).then(function(data) {
                document.getElementById("code_desc").innerHTML=data;
            });


        }

        </script>
	</head>

<body class="BodyStyle" onload="changeCodeDesc();">


<%
	/*
	String start_hour=null;
	String end_hour = null;
	String every_min = null;
	String mygroup_no=null;
	String color_template=null;
	String new_tickler_warning_window=null;
	String default_servicetype=null;
	String default_caisi_pmm=null;
	String default_new_oscar_cme=null;
	boolean defaultDoNotDeleteBilling=false;
	*/
	String provider_no=null;
	String defaultDxCode="";

	provider_no=request.getParameter("provider_no");

	ProviderPreferenceDao preferenceDao = (ProviderPreferenceDao) SpringUtils.getBean("providerPreferenceDao");
	ProviderPreference preference = null;
	preference=preferenceDao.find(provider_no);
	if(preference!=null) {
		defaultDxCode = preference.getDefaultDxCode();
	}
	if(defaultDxCode==null || "null".equalsIgnoreCase(defaultDxCode)) {
		defaultDxCode="";
	}
%>

<form id="preference_form" name="preference_form" action="preference_action.jsp" method="post">
	<input type="hidden" name="provider_no" id="provider_no" value="<%=provider_no%>" />
	<input type="hidden" name="new_tickler_warning_window" id="new_tickler_warning_window" value="<%=request.getParameter("new_tickler_warning_window")%>" />

<h4><bean:message key="provider.providerpreference.title" /></h4>
<br>
<%if( request.getParameter("success") == null ){%>
	<table style="margin-left:auto;margin-right:auto;border-collapse:collapse">
		<tr>
		<td><b><bean:message key="provider.pref.billing.diag_code" /></b> </td>
        </tr>
        <tr><td>

			 <input type="text" name="dxCode" size="5" maxlength="5" ondblClick="dxScriptAttach('dxCode')" onchange="changeCodeDesc();"
					 value="<%=defaultDxCode%>" />
					<button class="btn btn-link" onclick="dxScriptAttach('dxCode');"><bean:message key="global.search" /></button>
                    <div id="code_desc"></div>
		</td>
		</tr>
		<tr>
		<td>
			<input type="submit" name="submit" class="btn btn-primary" value="Save"/>
			<input type="button" name="close" class="btn btn-link" value="<bean:message key="Close" />" onclick="window.close()" />
		</td>
		</tr>
	</table>
		<%}else {%>
			<div class="alert alert-success" ><%=defaultDxCode%>&nbsp;<bean:message key="system_message.saved" /> </div><br>
		<%}%>
</form>
</body>
</html:html>