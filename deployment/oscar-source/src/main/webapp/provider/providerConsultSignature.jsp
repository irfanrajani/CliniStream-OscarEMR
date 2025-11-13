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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ page import="oscar.oscarProvider.data.*" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.model.UserProperty" %>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="javax.imageio.ImageIO" %>
<%@ page import="oscar.OscarProperties" %>

<%
	UserPropertyDAO userPropertyDAO = SpringUtils.getBean(UserPropertyDAO.class);
	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	if (session.getValue("user") == null)
		response.sendRedirect("../logout.htm");
	String curUser_no;
	curUser_no = (String) session.getAttribute("user");

	UserProperty prop = userPropertyDAO.getProp(curUser_no, UserProperty.PROVIDER_CONSULT_SIGNATURE);
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>

<html:html locale="true">
	<head>
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
		<title><bean:message key="provider.consultSignatureStamp.title"/></title>
	</head>

	<body>
	<table class=" MainTable" id="scrollNumber1" name="encounterTable" >
		<tr class="MainTableTopRow" width="100%">
			<td class="MainTableTopRowLeftColumn"><H4>&nbsp;<i class="icon-cogs"></i>&nbsp;<bean:message
					key="provider.providerSignature.msgPrefs"/>&nbsp;</h4></td>
			<td class="MainTableTopRowRightColumn">
				<table class="table TopStatusBar">
					<tr>
						<td><strong><bean:message key="provider.consultSignatureStamp.title"/></strong>
						</td>
						<td>&nbsp;</td>
						<td style="text-align: right">
							<oscar:help keywords="signature" key="app.top1"/> 
							<a href="<%= request.getContextPath() %>/oscarEncounter/About.jsp" target="_blank"><bean:message key="global.about"/></a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="MainTableLeftColumn">&nbsp;</td>
			<td class="MainTableRightColumn">
				<html:form action="/eform/imageUpload" enctype="multipart/form-data" method="post">
					<input type="hidden" name="<csrf:tokenname/>" value="<csrf:tokenvalue/>"/>
					<input type="hidden" id="method" name="method" value="uploadProviderImage">
					<%
						boolean hasSig = (prop != null);
						if (hasSig) {
					%>
						<bean:message key="provider.providerSignature.msgCurrentSignature"/>:
						<br/>
						<img src="<%=request.getContextPath()%>/eform/displayImage.do?imagefile=<%=prop.getValue()%>"/>
					<% } else { %>
						<bean:message key="provider.providerSignature.msgSigNotSet"/>
					<% } %>
                    <br/>
					<br/>
					<bean:message key="provider.consultSignatureStamp.edit"/>
                    <br/>
					<br/>
					<input type="file"  id="image" name="image" onchange="changeSignature()"/>
					<br/>
					<img id="consult_signature_img" src="" style="border: 1px solid black;"/>
					<br/>
					<span title="<bean:message key="global.uploadWarningBody"/>" style="vertical-align:middle;font-family:arial;font-size:20px;font-weight:bold;color:#ABABAB;cursor:pointer"><img border="0" src="<%=request.getContextPath()%>/images/icon_alertsml.gif"/></span>
					<input type="submit" name="submit" class="btn" id="submit" value="<bean:message key="provider.editSignature.btnUpdate"/>" disabled/>
					<input type="submit" name="submit" class="btn" value="Remove Signature" onclick="document.getElementById('method').value = 'removeProviderImage'"/<%= hasSig ? "":"disabled"%>>
				</html:form>
				<script type="application/javascript">

					function changeSignature() {
						var reader = new FileReader();

						reader.onload = function (e) {
							document.getElementById("consult_signature_img").src = e.target.result;
						};
						reader.readAsDataURL(document.getElementById("image").files[0]);
						if (document.getElementById("image").value != '') {
							document.getElementById("submit").disabled = false;
						}
						
					}
				</script>
			</td>
		</tr>
		<tr>
			<td class="MainTableBottomRowLeftColumn"></td>
			<td class="MainTableBottomRowRightColumn"></td>
		</tr>
	</table>
	</body>
</html:html>