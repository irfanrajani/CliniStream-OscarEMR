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

<%@ page
	import="oscar.oscarMessenger.docxfer.send.*, oscar.oscarMessenger.docxfer.util.*, oscar.util.*"%>
<%@ page import="java.util.*, org.w3c.dom.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_msg" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_msg");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>


<logic:notPresent name="msgSessionBean" scope="session">
	<logic:redirect href="index.jsp" />
</logic:notPresent>
<logic:present name="msgSessionBean" scope="session">
	<bean:define id="bean"
		type="oscar.oscarMessenger.pageUtil.MsgSessionBean"
		name="msgSessionBean" scope="session" />
	<logic:equal name="bean" property="valid" value="false">
		<logic:redirect href="index.jsp" />
	</logic:equal>
</logic:present>

<!--<link rel="stylesheet" type="text/css" href="encounterStyles.css">-->
<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
<%
    String pdfAttch = (String) request.getAttribute("PDFAttachment");
    
    session.setAttribute("PDFAttachment", pdfAttch);
%>

<title>Document Transfer</title>
</head>


<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />

<body class="BodyStyle" vlink="#0000FF">
<!--  -->

<table class="MainTable" id="scrollNumber1" name="encounterTable" width="100%">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn">&nbsp;<h4><i class="icon-envelope"></i>&nbsp;&nbsp;<bean:message key="oscarMessenger.ViewMessage.msgMessenger" /></h4></td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td><bean:message key="oscarMessenger.ViewMessage.msgAttachments" /></td>
				<td></td>
				<td style="text-align: right; width:100%;" ><oscar:help keywords="message" key="app.top1"/> <i class="icon-question-sign"></i> <a
					href="javascript:popupStart(300,400,'About.jsp')"><bean:message key="global.about" /></a> <i class="icon-info-sign"></i> <a
					href="javascript:popupStart(300,400,'License.jsp')"><bean:message key="global.license" /></a></td>
			</tr>
		</table>
		</td>
	</tr>


	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>

		<html:form action="/oscarMessenger/ViewPDFFile">
			<td class="MainTableBottomRowRightColumn">
			<table cellspacing=3>
				<tr>
					<td>
					<table  cellspacing=0 cellpadding=3>
						<tr>
							<td ><a href="#" class="btn btn-link"
								onclick="javascript:top.window.close()" class="messengerButtons">
							<bean:message key="global.btnClose" /> </a></td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
			<table class="table table-striped">

				<% Vector attVector = Doc2PDF.getXMLTagValue(pdfAttch, "TITLE" ); %>
				<% for ( int i = 0 ; i < attVector.size(); i++) { %>
				<tr>
					<td bgcolor="#DDDDFF"><%=(String) attVector.get(i)%></td>
					<td bgcolor="#DDDDFF"><input type=submit
                        class="btn"
						onclick=" document.forms[0].file_id.value = <%=i%>"
						value="<bean:message key="marc-hi.patientDocuments.button.downloadSelected" />" /></td>
				</tr>
				<% }  %>
				<html:hidden property="file_id" />
				<html:hidden property="attachment" value="<%=pdfAttch%>" />

				<table>
					</td>
					</html:form>
					</tr>
				</table>
</body>
</html>