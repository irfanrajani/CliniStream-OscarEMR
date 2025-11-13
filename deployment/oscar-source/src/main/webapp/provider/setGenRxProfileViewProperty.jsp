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

<%@ include file="/casemgmt/taglibs.jsp"%>
<%@page import="java.util.*" %>
<%
if(session.getValue("user") == null)
    response.sendRedirect("../logout.htm");
  String curUser_no;
  curUser_no = (String) session.getAttribute("user");
   String tite = (String) request.getAttribute("provider.title");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<c:set var="ctx" value="${pageContext.request.contextPath}"
	scope="request" />
<html:html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<html:base />
<title><bean-el:message key="${providertitle}" /></title>

<link rel="stylesheet" type="text/css"
	href="../oscarEncounter/encounterStyles.css">


<!-- jQuery for radio fields -->
<script src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>

<script>
$(document).ready(function() {

    $('input[type="checkbox"]').addClass("only-one-");

	$('[class^="only-one-"]').on( "click", function() {
		if ( $(this).is('input:checkbox') ){
			$('.'+$(this).attr('class')).prop('checked', false);
			$(this).prop('checked', true);
		}

	});
});
</script>
</head>

<body class="BodyStyle" vlink="#0000FF" onBlur="this.focus();">

<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><bean-el:message
			key="${providermsgPrefs}" /></td>
		<td style="color: white" class="MainTableTopRowRightColumn"><bean-el:message
			key="${providermsgProvider}" /></td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn">&nbsp;</td>
		<td class="MainTableRightColumn">
		<%if( request.getAttribute("status") == null ){%>
                <bean-el:message key="${providermsgEdit}" />
                <html:form action="/setProviderStaleDate.do">
			<input type="hidden" name="method" value="<c:out value="${method}"/>">
                   <logic:iterate name="viewChoices" id="viewChoice">
                       <html:multibox property="rxProfileViewProperty.valueArray">
                           <bean:write name="viewChoice" property="value"/>
                       </html:multibox>
                       <bean:write name="viewChoice" property="label"/>
                   </logic:iterate>
                   <br/>
                   <input type="submit" value="<bean-el:message key="${providerbtnSubmit}" />" />
		</html:form> <%}else {%> <bean-el:message key="${providermsgSuccess}" /> <br>
		<%}%>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>
</body>
</html:html>