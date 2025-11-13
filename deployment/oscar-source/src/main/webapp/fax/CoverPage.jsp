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


<%@ page import="org.oscarehr.common.dao.ClinicDAO"%>
<%@ page import="org.oscarehr.common.dao.ProfessionalSpecialistDao"%>
<%@ page import="org.oscarehr.common.model.Clinic"%>
<%@ page import="org.oscarehr.common.model.ProfessionalSpecialist"%>
<%@ page import="org.oscarehr.util.MiscUtils"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="oscar.OscarProperties"%>

<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>

<%
    ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
	Clinic clinic = clinicDao.getClinic();
    String clinicName = "OSCAR";
    String clinicAddress = "";
    String clinicPhone = "";
    String clinicFax = "";

    if( clinic != null ) {
        clinicName = clinic.getClinicName();
        clinicAddress = clinic.getClinicAddress() +","+  clinic.getClinicCity()  +","+ clinic.getClinicProvince() +" "+  clinic.getClinicPostal();
        clinicPhone = clinic.getClinicPhone();
        clinicFax = clinic.getClinicFax();
    }

    String specialistId = request.getParameter("specialist");
    String specialistName = "";
    String specialistPhone = "";
    String specialistFax = "";

    if (specialistId != null && !specialistId.isEmpty() && !specialistId.equals("-1")) {
        ProfessionalSpecialistDao professionalSpecialistDao = SpringUtils.getBean(ProfessionalSpecialistDao.class);
        ProfessionalSpecialist specialist = professionalSpecialistDao.find(Integer.parseInt(specialistId));
        specialistName = specialist.getFormattedTitle();
        specialistPhone = specialist.getPhoneNumber();
        specialistFax = specialist.getFaxNumber();
    }
%>
<html>
<head>
<title><bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.addCover" /></title>

<link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!--  bootstrap 2.3 -->
<style>
.header {
    font-size:28px;
    font-weight:bold;
}

.mediumHeader {
    font-size:16px;
    font-weight:bold;
}

.info {
    font-size:12px;
}

th, td {
    border-bottom: 1px solid #ddd;
    padding: 24px;
}
</style>

</head>
<body style="text-align:center" onload="document.getElementById('note').focus();
    <oscar:oscarPropertiesCheck property="faxCover" value="false">document.getElementById('coverpage').submit();</oscar:oscarPropertiesCheck>">

<h3><bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.addCover" /></h3>
<form id="coverpage" action="<%=request.getContextPath() + "/oscarEncounter/oscarConsultationRequest/ConsultationFormFax.do"%>" method="post">

<input type="hidden" name="reqId" value="<%=request.getAttribute("reqId")==null ? request.getParameter("reqId") : request.getAttribute("reqId") %>">
<input type="hidden" name="transType" value="<%=request.getAttribute("transType") %>">
<input type="hidden" name="demographicNo" value="<%=request.getParameter("demographicNo")%>">
<input type="hidden" name="letterheadFax" value="<%=request.getParameter("letterheadFax")%>">
<input type="hidden" name="fax" value="<%=request.getParameter("fax")%>">
<input type="hidden" name="specialist" value="<%=request.getParameter("specialist")%>">
<%
	String consultResponsePage = request.getParameter("consultResponsePage");
	if (consultResponsePage!=null) {
	%>
		<input type="hidden" name="consultResponsePage" value="<%=consultResponsePage%>"/>
	<%
	}
%>

<%
	String[] faxRecipients = request.getParameterValues("faxRecipients");
	if( faxRecipients != null ) {
		for( String fax : faxRecipients ) {
%>
			<input type="hidden" name="faxRecipients" value="<%=fax%>">
<%
		}
	}
%>


<div class="well">
    <div class="row">
	<bean:message key="consultationList.btn.newConsult" />&nbsp;<bean:message key="global.yes" /><input type="radio" name="coverpage" value="true" id="yes">&nbsp;<bean:message key="global.no" /><input type="radio" checked="checked" name="coverpage" value="false">
    </div>
    <div style="margin-top:25px; align:center; width:600px; margin:auto;">

        <table style= "width: 600px; height:300px; border: 1px solid; text-align:left; background:white;">
            <tr>
                <td>
                    <span class="header"><%=Encode.forHtmlContent(clinicName)%></span><br>
                    <span class="mediumHeader"><%=Encode.forHtmlContent(clinicAddress)%><br>
                    <bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formPhone" />:&nbsp;<%=Encode.forHtmlContent(clinicPhone)%>
                    <bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formFax" />:&nbsp;<%=Encode.forHtmlContent(clinicFax)%></span>
                </td>
            </tr>
            <tr>
                <td>
                    <span class="mediumHeader"><bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formFax" /></span><br>
                    <span class="info"><bean:message key="oscarMessenger.DisplayMessages.msgTo" />:&nbsp;
<%=Encode.forHtmlContent(specialistName) %>
                    <br><bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formPhone" />:&nbsp;
                    <%=Encode.forHtmlContent(specialistPhone)%>
                    <br><bean:message key="oscarEncounter.oscarConsultationRequest.ConsultationFormRequest.formFax" />:&nbsp;
                    <%=Encode.forHtmlContent(specialistFax)%><br><br><br><bean:message key="caseload.msgNotes" />
                    </span><br>
                    <textarea name="note" id="note" style="width:98%; height:100px;" oninput="document.getElementById('yes').checked = true;" ></textarea>
                </td>
            </tr>
            <tr>
                <td>
                    <span class="info"><bean:message key="oscarEncounter.oscarConsultationRequest.consultationFormPrint.msgFaxFooterMessage" /></span>
                </td>
            </tr>
        </table>
<br>
	<input class="btn btn-primary" type="submit" value="<bean:message key="global.btnSubmit" />">
    </div>
</div>

</form>


</body>
</html>