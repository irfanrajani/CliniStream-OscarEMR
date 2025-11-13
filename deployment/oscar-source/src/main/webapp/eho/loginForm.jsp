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
<%
	String nameId = (String)session.getAttribute("nameId");
	String email = (String)session.getAttribute("email");
	String encryptedOneIdToken = (String)session.getAttribute("encryptedOneIdToken");
	Long ts = (Long)session.getAttribute("ts");
	String signature = (String)session.getAttribute("signature");
	String oauth2 = (String)session.getAttribute("oauth2");
	
%>
<html>
<head></head>

<body onLoad="document.forms[0].submit()">

<form enctype="application/x-www-form-urlencoded" method="post"  action="<%=request.getContextPath()%>/ssoLogin.do">
	<input type="hidden" name="method" value="ssoLogin"/>
	<input type="hidden" name="nameId" value="<%=nameId%>"/>
	<input type="hidden" name="email" value="<%=email%>"/>
	<textarea name="encryptedOneIdToken"><%=encryptedOneIdToken %></textarea>
	<input type="hidden" name="ts" value="<%=ts%>"/>
	<input type="hidden" name="signature" value="<%=signature%>"/>
	<input type="hidden" name="oauth2" value="<%=oauth2%>"/>
</form>
</body>
</html>