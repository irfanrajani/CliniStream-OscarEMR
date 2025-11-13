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
<%@ page import="oscar.OscarProperties"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
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
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

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
<%
oscar.oscarMessenger.pageUtil.MsgSessionBean bean = (oscar.oscarMessenger.pageUtil.MsgSessionBean)pageContext.findAttribute("bean");
%>

<title><bean:message key="oscarMessenger.SentMessage.title" /></title>


<script type="text/javascript">
function BackToOscar()
{
    if (opener.callRefreshTabAlerts) {
	opener.callRefreshTabAlerts("oscar_new_msg");
        setTimeout("window.close()", 100);
    } else {
        window.close();
    }
}
</script>

<style>
.TopStatusBar{
width:100% !important;
height:100% !important;
}
</style>

</head>

<body class="BodyStyle" vlink="#0000FF">
<!--  -->
<table class="MainTable" id="scrollNumber1" name="encounterTable" width="100%">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><h4><bean:message
			key="oscarMessenger.SentMessage.msgMessenger" />: <bean:message
					key="oscarMessenger.SentMessage.msgMessageSent" /><h4></td>
		<td class="MainTableTopRowRightColumn" align="left">
		<table class="TopStatusBar" width=100%>
			<tr>
				<td align="right" >
            <i class=" icon-question-sign"></i> 
            <a href="javascript:void(0)" onClick ="popupPage(700,960,'<%=(OscarProperties.getInstance()).getProperty("HELP_SEARCH_URL")%>'+'Messenger sent')"><bean:message key="app.top1"/></a>
            <i class=" icon-info-sign" style="margin-left:10px;"></i> 
            <a href="javascript:void(0)"  onClick="window.open('<%=request.getContextPath()%>/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,left=0,top=0')" ><bean:message key="global.about" /></a>
        </td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		
		<td class="MainTableRightColumn">
		<table>
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>
				<table cellspacing=3>
					<tr>
						<td>
						<table class=messButtonsA cellspacing=0 cellpadding=3>
							<tr>
								<td class="messengerButtonsA"><html:link
									page="/oscarMessenger/CreateMessage.jsp"
									styleClass="btn">
									<bean:message key="oscarMessenger.SentMessage.btnCompose" />
								</html:link></td>
							</tr>
						</table>
						</td>
						<td>
						<table class=messButtonsA cellspacing=0 cellpadding=3>
							<tr>
								<td class="messengerButtonsA"><html:link
									page="/oscarMessenger/DisplayMessages.jsp"
									styleClass="btn">
									<bean:message key="oscarMessenger.SentMessagebtnBack" />
								</html:link></td>
							</tr>
						</table>
						</td>
						<td>
						<table class=messButtonsA cellspacing=0 cellpadding=3>
							<tr>
								<td class="messengerButtonsA"><a
									href="javascript:BackToOscar()" class="btn"><bean:message
									key="oscarMessenger.SentMessage.btnExit" /></a></td>
							</tr>
						</table>
						</td>
					</tr>
				</table>
				</td>
			</tr>
			<tr>
				<td><bean:message
					key="oscarMessenger.SentMessage.msgMessageSentTo" /> <%= request.getAttribute("SentMessageProvs") %>
				</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>
</body>
</html:html>