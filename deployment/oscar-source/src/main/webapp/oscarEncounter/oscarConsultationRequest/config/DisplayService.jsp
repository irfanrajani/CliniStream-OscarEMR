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

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.consult" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../../securityError.jsp?type=_admin&type=_admin.consult");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ page import="java.util.ResourceBundle"%>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>

<!DOCTYPE html>
<html:html locale="true">
<jsp:useBean id="displayServiceUtil" scope="request"
	class="oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConDisplayServiceUtil" />
<%
displayServiceUtil.estSpecialistVector();
String serviceId = (String) request.getAttribute("serviceId");
String serviceDesc = Encode.forHtml(displayServiceUtil.getServiceDesc(serviceId));
%>
<head>

<title><bean:message
	key="oscarEncounter.oscarConsultationRequest.config.DisplayService.title" />
</title>
<html:base />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/DT_bootstrap.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/bootstrap-responsive.css" rel="stylesheet">

<script src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js"></script>
<script src="${pageContext.request.contextPath}/library/DataTables/datatables.min.js"></script><!-- 1.13.4 -->

<style>
.dtable{
    table-layout: fixed;
    word-wrap:break-word;
    font-size: 12px;
}
.MainTableLeftColumn td{
    font-size: 12px;

}
</style>

<script>
function BackToOscar()
{
       window.close();
}
</script>
</head>
<body class="BodyStyle">
<html:errors />
<!--  -->
<html:form action="/oscarEncounter/UpdateServiceSpecialists">
<table class="MainTable" id="scrollNumber1">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><h4>Consultation</h4></td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td class="Header"><h4><bean:message
					key="oscarEncounter.oscarConsultationRequest.config.DisplayService.title" /></h4>
				</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr style="vertical-align: top">
		<td class="MainTableLeftColumn">
		<%oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConTitlebar titlebar = new oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConTitlebar();
                    out.print(titlebar.estBar(request));
                 %>
		</td>
		<td class="MainTableRightColumn">
		<table style="border-collapse: collapse; width: 100%; height: 100%; border-color:#111111;">

			<!----Start new rows here-->
			<tr>
				<td><bean:message
					key="oscarEncounter.oscarConsultationRequest.config.DisplayService.msgCheckOff"
					arg0="<%=Encode.forHtml(serviceDesc) %>" /></td>
			</tr>
			<tr>
				<td>
					<input type="hidden" name="serviceId" value="<%=serviceId %>">
					<input type="submit" class="btn btn-primary"
						value="<bean:message key="oscarEncounter.oscarConsultationRequest.config.DisplayService.btnUpdateServices"/>"
onclick=" var table= $('#specialistsTbl').DataTable(); table.search('').draw();"> <!-- DataTables removes DOM elements for display, restore them prior to submit or you will loose checks on those not in view-->
					<div class="ChooseRecipientsBox1">
					<table class="table table-condensed table-striped dtable" id="specialistsTbl">
                        <thead>
						    <tr>
							<th style="width: 30px;">&nbsp;</th>
							<th><bean:message
								key="oscarEncounter.oscarConsultationRequest.config.DisplayService.specialist" />
							</th>
							<th style="width: 300px;"><bean:message
								key="oscarEncounter.oscarConsultationRequest.config.DisplayService.address" />
							</th>
							<th><bean:message
								key="oscarEncounter.oscarConsultationRequest.config.DisplayService.phone" />
							</th>
							<th><bean:message
								key="oscarEncounter.oscarConsultationRequest.config.DisplayService.fax" />
                            </th>
                            </tr>
                        </thead>
                        <tbody>

							<div class="ChooseRecipientsBox1"> <%
                                 java.util.Vector  specialistInField = displayServiceUtil.getSpecialistInField(serviceId);
                                 for(int i=0;i < displayServiceUtil.specIdVec.size(); i++){
                                 String  specId     = displayServiceUtil.specIdVec.elementAt(i);
                                 String  fName      = Encode.forHtml(displayServiceUtil.fNameVec.elementAt(i));
                                 String  lName      = Encode.forHtml(displayServiceUtil.lNameVec.elementAt(i));
                                 String  proLetters = displayServiceUtil.proLettersVec.elementAt(i);
                                 proLetters = (proLetters==null?"":Encode.forHtml(displayServiceUtil.proLettersVec.elementAt(i)));
                                 String  address    = Encode.forHtml(displayServiceUtil.addressVec.elementAt(i));
                                 String  phone      = Encode.forHtml(displayServiceUtil.phoneVec.elementAt(i));
                                 String  fax        = Encode.forHtml(displayServiceUtil.faxVec.elementAt(i));

                              %>
							<tr>
						    <td>
							<%if (specialistInField.contains(specId)){ %> <input type=checkbox
								name="specialists" value=<%=specId%> checked> <%}else{%>
							<input type=checkbox name="specialists" value=<%=specId%>>
							<%}%>
							</td>
							<td>
							<% out.print(lName+" "+fName + (proLetters == null ? "" : " " + proLetters)); %>
							</td>
							<td style="overflow:hidden; white-space: nowrap; text-overflow:ellipsis" title="<%=address%>"><%=address %></td>
							<td><%=phone%></td>
							<td><%=fax%></td>
						</tr>
						<% }%>
                        </tbody>
					</table>
					</div>
				</td>
			</tr>
			<!----End new rows here-->

			<tr style="height:100%">
				<td></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>
</html:form>
<script>
$(document).ready(function() {
    $('#specialistsTbl').DataTable({
       "paging": false,
        "language": {
                        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
    } );

} );
</script>
</body>
</html:html>