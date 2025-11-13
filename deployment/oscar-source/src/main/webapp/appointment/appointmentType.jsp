<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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

--%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="java.util.*, java.sql.*, oscar.*, java.text.*, java.lang.*,java.net.*, oscar.appt.*, org.oscarehr.common.dao.AppointmentTypeDao, org.oscarehr.common.model.AppointmentType, org.oscarehr.util.SpringUtils" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
	AppointmentTypeDao appDao = (AppointmentTypeDao) SpringUtils.getBean("appointmentTypeDao");
	List<AppointmentType> types = appDao.listAll();
%>
<html>
<head>
<title>Appointment Type</title>
<script type="text/javascript">
var dur = '';
var reason = '';
var loc = '';
var notes = '';
var resources = '';
var names = '';
<%   for(int j = 0;j < types.size(); j++) { %>
		dur = dur + '<%= types.get(j).getDuration() %>'+',';
		reason = reason + '<%= types.get(j).getReason() %>'+',';
		loc = loc + '<%= types.get(j).getLocation() %>'+',';
		notes = notes + '<%= types.get(j).getNotes() %>'+',';
		resources = resources + '<%= types.get(j).getResources() %>'+',';
		names = names + '<%=StringEscapeUtils.escapeJavaScript(types.get(j).getName()) %>'+',';
<%   } %>
	var durArray = dur.split(",");
	var reasonArray = reason.split(",");
	var locArray = loc.split(",");
	var notesArray = notes.split(",");
	var resArray = resources.split(",");
	var nameArray = names.split(",");
	
	var typeSel = '';
	var reasonSel = '';
	var locSel = '';
	var durSel = 15;
	var notesSel = '';
	var resSel = '';

function getFields(idx) {
	if(idx>0) {
		typeSel = document.getElementById('durId').innerHTML = nameArray[idx-1];
		durSel = document.getElementById('durId').innerHTML = durArray[idx-1];
		reasonSel = document.getElementById('reasonId').innerHTML = reasonArray[idx-1];
		locSel = document.getElementById('locId').innerHTML = locArray[idx-1];
		notesSel = document.getElementById('notesId').innerHTML = notesArray[idx-1];
		resSel = document.getElementById('resId').innerHTML = resArray[idx-1];
	}	
}

// function to save the values from this page to the appt page on submission

function saveValues(typeSel, reasonSel, locSel, durSel, notesSel, resSel) {
	// get any value for reason already set on appointment page
	var origReason = window.opener.jQuery("[name=reason").val();
	
	reasonSel = reasonSel.concat(" -- ".concat(origReason));
	
	window.opener.setType(typeSel,reasonSel,locSel,durSel,notesSel,resSel);
}


</script>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">


<link rel="stylesheet" href="../css/helpdetails.css" type="text/css">
</head>
<body bgcolor="#EEEEFF" bgproperties="fixed" topmargin="0" leftmargin="0" rightmargin="0">
<table class="table table-hover table-condensed">
	<tr>
		<td width="100">Type</td>
		<td width="200">
			<select id="typesId" width="25" maxsize="50" onchange="getFields(this.selectedIndex)">
				<option value="-1">Select type</option>
<%   for(int i = 0;i < types.size(); i++) { 
%>
				<option value="<%= i %>" <%= (request.getParameter("type").equals(types.get(i).getName())?" selected":"") %>><%= types.get(i).getName() %></option>
<%   } %>
			</select>
		</td>
		<td><input type="button" name="Select" value="<bean:message key="global.btnAdd" />" class="btn btn-primary" style="margin-bottom:10px;" onclick="saveValues(typeSel,reasonSel,locSel,durSel,notesSel,resSel); window.close()"><INPUT TYPE="RESET" id="backButton" class="btn btn-link" style="margin-bottom:10px;" VALUE="<bean:message key="global.btnCancel" />" onClick="window.close();">
	</tr>
	<tr>
		<td><bean:message key="Appointment.formDuration" /></td>
		<td colspan="2"><div id="durId"></div></td>
	</tr>
	<tr>
		<td><bean:message key="Appointment.formReason" /></td>
		<td colspan="2"><span id="reasonId"/></td>
	</tr>
	<tr>
		<td><bean:message key="Appointment.formLocation" /></td>
		<td colspan="2"><span id="locId"/></td>
	</tr>
	<tr>
		<td><bean:message key="Appointment.formNotes" /></td>
		<td colspan="2"><span id="notesId"/></td>
	</tr>
	<tr>
		<td><bean:message key="Appointment.formResources" /></td>
		<td colspan="2"><span id="resId"/></td>
	</tr>
</table>
</body>
<script type="text/javascript">
	getFields(document.getElementById('typesId').selectedIndex);
</script>
</html>
