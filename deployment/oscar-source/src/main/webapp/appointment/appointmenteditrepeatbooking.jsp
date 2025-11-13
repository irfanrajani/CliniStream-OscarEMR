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
<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment" rights="u" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_appointment");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%
  if(session.getAttribute("user") == null) response.sendRedirect("../logout.jsp");
  boolean bEdit = request.getParameter("appointment_no") != null ? true : false;
%>

<%@page import="java.sql.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.*" %>
<%@page import="org.oscarehr.common.dao.AppointmentArchiveDao" %>
<%@page import="org.oscarehr.common.dao.OscarAppointmentDao" %>
<%@page import="org.oscarehr.common.model.Appointment" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="oscar.*" %>
<%@page import="oscar.util.*" %>
<%@page errorPage="/errorpage.jsp"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>

<!DOCTYPE html>
<html:html locale="true">
<head>
<script src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message
	key="appointment.appointmentgrouprecords.title" /></title>
<script>
<!--

function onCheck(a, b) {
    if (a.checked) {
		document.getElementById("everyUnit").value = b;
		//document.groupappt.everyUnit.value = b;
    }
}

function onExit() {
    if (confirm("<bean:message key="appointment.appointmentgrouprecords.msgExitConfirmation"/>")) {
        window.close()
	}
}

var saveTemp=0;
function onButDelete() {
  saveTemp=1;
}
function onSub(e) {
    e.preventDefault
    if( saveTemp==1 ) {
        return (confirm("<bean:message key="appointment.appointmentgrouprecords.msgDeleteConfirmation"/>")) ;
    } else {
        return true;
    }
}
//-->
</script>

<!-- i18n calendar -->
    <script src="<%=request.getContextPath()%>/share/calendar/calendar.js"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/lang/<bean:message key='global.javascript.calendar'/>"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/calendar-setup.js"></script>
    <link href="<%=request.getContextPath()%>/share/calendar/calendar.css" title="win2k-cold-1" rel="stylesheet" media="all" >

<!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" >

</head>
<body>


<%
	AppointmentArchiveDao appointmentArchiveDao = (AppointmentArchiveDao)SpringUtils.getBean("appointmentArchiveDao");
	OscarAppointmentDao appointmentDao = (OscarAppointmentDao)SpringUtils.getBean("oscarAppointmentDao");
	SimpleDateFormat dayFormatter = new SimpleDateFormat("yyyy-MM-dd");
	SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
	SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
%>
<%!
  GregorianCalendar addDateByYMD(GregorianCalendar cal, String unit, int n) {
	if (unit.equals("day")) {
		cal.add(Calendar.DATE, n);
	} else if (unit.equals("month")) {
		cal.add(Calendar.MONTH, n);
	} else if (unit.equals("year")) {
		cal.add(Calendar.YEAR, n);
	}
	return cal;
  }
%>
<%
  if (request.getParameter("groupappt") != null) {
    boolean bSucc = false;
	String createdDateTime = UtilDateUtilities.DateToString(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");
	String userName =  (String) session.getAttribute("userlastname") + ", " + (String) session.getAttribute("userfirstname");
	String everyNum = request.getParameter("everyNum")!=null? request.getParameter("everyNum") : "0";
	String everyUnit = request.getParameter("everyUnit")!=null? request.getParameter("everyUnit") : "day";
	String endDate = request.getParameter("endDate")!=null? request.getParameter("endDate") : UtilDateUtilities.DateToString(new java.util.Date(),"dd/MM/yyyy");
	int delta = Integer.parseInt(everyNum);
	if (everyUnit.equals("week") ) {
		delta = delta*7;
		everyUnit = "day";
	}
	GregorianCalendar gCalDate = new GregorianCalendar();
	GregorianCalendar gEndDate = (GregorianCalendar) gCalDate.clone();
	gEndDate.setTime(UtilDateUtilities.StringToDate(endDate, "dd/MM/yyyy"));

    // repeat adding
    if (request.getParameter("groupappt").equals("Add Group Appointment") ) {
        String[] param = new String[19];
        int rowsAffected=0, datano=0;

  	    java.util.Date iDate = ConversionUtils.fromDateString(request.getParameter("appointment_date"));

		while (true) {
			Appointment a = new Appointment();
			a.setProviderNo(request.getParameter("provider_no"));
			a.setAppointmentDate(iDate);
			a.setStartTime(ConversionUtils.fromTimeStringNoSeconds(request.getParameter("start_time")));
			a.setEndTime(ConversionUtils.fromTimeStringNoSeconds(request.getParameter("end_time")));
			a.setName(request.getParameter("keyword"));
			a.setNotes(request.getParameter("notes"));
			a.setReason(request.getParameter("reason"));
			a.setLocation(request.getParameter("location"));
			a.setResources(request.getParameter("resources"));
			a.setType(request.getParameter("type"));
			a.setStyle(request.getParameter("style"));
			a.setBilling(request.getParameter("billing"));
			a.setStatus(request.getParameter("status"));
			a.setCreateDateTime(new java.util.Date());
			a.setCreator(userName);
			a.setRemarks(request.getParameter("remarks"));
			if (request.getParameter("demographic_no")!=null && !(request.getParameter("demographic_no").equals(""))) {
				a.setDemographicNo(Integer.parseInt(request.getParameter("demographic_no")));
		    } else {
		    	a.setDemographicNo(0);
		    }

			a.setProgramId(Integer.parseInt((String)request.getSession().getAttribute("programId_oscarView")));
			a.setUrgency(request.getParameter("urgency"));
			a.setReasonCode(Integer.parseInt(request.getParameter("reasonCode")));
			appointmentDao.persist(a);


			gCalDate.setTime(UtilDateUtilities.StringToDate(param[1], "yyyy-MM-dd"));
			gCalDate = addDateByYMD(gCalDate, everyUnit, delta);

			if (gCalDate.after(gEndDate))
				break;
			else
				iDate = gCalDate.getTime();
		}
        bSucc = true;
	}


    // repeat updating
    if (request.getParameter("groupappt").equals("Group Update") || request.getParameter("groupappt").equals("Group Cancel") ||
    		request.getParameter("groupappt").equals("Group Delete")) {
        int rowsAffected=0, datano=0;

        Object[] paramE = new Object[10];
        Appointment aa = appointmentDao.find(Integer.parseInt(request.getParameter("appointment_no")));
        if (aa != null) {
                paramE[0]=ConversionUtils.toDateString(aa.getAppointmentDate());
                paramE[1]=aa.getProviderNo();
                paramE[2]=ConversionUtils.toTimeStringNoSeconds(aa.getStartTime());
                paramE[3]=ConversionUtils.toTimeStringNoSeconds(aa.getEndTime());
                paramE[4]=aa.getName();
                paramE[5]=aa.getNotes();
                paramE[6]=aa.getReason();
                paramE[7]=ConversionUtils.toTimestampString(aa.getCreateDateTime());
                paramE[8]=aa.getCreator();
                paramE[9]=String.valueOf(aa.getDemographicNo());

        }

        // group cancel
        if (request.getParameter("groupappt").equals("Group Cancel")) {
        	Object[] param = new Object[13];
            param[0]="C";
            param[1]=createdDateTime;
 	        param[2]=userName;
 	        for (int k=0; k<paramE.length; k++) param[k+3] = paramE[k];

			// repeat doing
			while (true) {
				Appointment appt = appointmentDao.find(Integer.parseInt(request.getParameter("appointment_no")));
			    appointmentArchiveDao.archiveAppointment(appt);

			    List<Appointment> appts = appointmentDao.find(dayFormatter.parse((String)param[3]), (String)param[4], ConversionUtils.fromTimeStringNoSeconds((String)param[5]), ConversionUtils.fromTimeStringNoSeconds((String)param[6]), (String)param[7], (String)param[8], (String)param[9], Integer.parseInt((String)param[12]));


            	for(Appointment a:appts) {
            		a.setStatus("C");
            		a.setUpdateDateTime(ConversionUtils.fromTimestampString(createdDateTime));
            		a.setLastUpdateUser(loggedInInfo.getLoggedInProviderNo());
            		appointmentDao.merge(a);
            		rowsAffected++;
            	}

				gCalDate.setTime(UtilDateUtilities.StringToDate((String)param[3], "yyyy-MM-dd"));
				gCalDate = addDateByYMD(gCalDate, everyUnit, delta);

				if (gCalDate.after(gEndDate)) break;
				else param[3] = UtilDateUtilities.DateToString(gCalDate.getTime(), "yyyy-MM-dd");
			}
        	bSucc = true;
		}

		// group delete
		if (request.getParameter("groupappt").equals("Group Delete")) {
			Object[] param = new Object[10];
 	        for(int k=0; k<paramE.length; k++) param[k] = paramE[k];

			// repeat doing
			while (true) {

				List<Appointment> appts = appointmentDao.find(dayFormatter.parse((String)param[0]), (String)param[1], ConversionUtils.fromTimeStringNoSeconds((String)param[2]), ConversionUtils.fromTimeStringNoSeconds((String)param[3]), (String)param[4], (String)param[5], (String)param[6], Integer.parseInt((String)param[9]));

				for(Appointment appt:appts) {
					appointmentArchiveDao.archiveAppointment(appt);
					appointmentDao.remove(appt.getId());
					rowsAffected++;
				}

				gCalDate.setTime(UtilDateUtilities.StringToDate((String)param[0], "yyyy-MM-dd"));
				gCalDate = addDateByYMD(gCalDate, everyUnit, delta);

				if (gCalDate.after(gEndDate)) break;
				else param[0] = UtilDateUtilities.DateToString(gCalDate.getTime(), "yyyy-MM-dd");
			}
        	bSucc = true;
		}

		if (request.getParameter("groupappt").equals("Group Update")) {

			Object[] param = new Object[24];
            param[0]=MyDateFormat.getTimeXX_XX_XX(request.getParameter("start_time"));
            param[1]=MyDateFormat.getTimeXX_XX_XX(request.getParameter("end_time"));
            param[2]=request.getParameter("keyword");
            param[3]=request.getParameter("demographic_no");
            param[4]=request.getParameter("notes");
            param[5]=request.getParameter("reason");
            param[6]=request.getParameter("location");
            param[7]=request.getParameter("resources");
            param[8]=createdDateTime;
            param[9]=userName;
            param[10]=request.getParameter("urgency");
            param[11]=request.getParameter("reasonCode");
 	        for(int k=0; k<paramE.length; k++)
 	        	param[k+12] = paramE[k];

			// repeat doing
			while (true) {

				List<Appointment> appts = appointmentDao.find(dayFormatter.parse((String)param[12]), (String)paramE[1], ConversionUtils.fromTimeStringNoSeconds((String)paramE[2]), ConversionUtils.fromTimeStringNoSeconds((String)paramE[3]), (String)paramE[4], (String)paramE[5], (String)paramE[6], Integer.parseInt((String)paramE[9]));

				for(Appointment appt:appts) {
					appointmentArchiveDao.archiveAppointment(appt);
					appt.setStartTime(ConversionUtils.fromTimeString(MyDateFormat.getTimeXX_XX_XX(request.getParameter("start_time"))));
					appt.setEndTime(ConversionUtils.fromTimeString(MyDateFormat.getTimeXX_XX_XX(request.getParameter("end_time"))));
					appt.setName(request.getParameter("keyword"));
					appt.setDemographicNo(Integer.parseInt((String)paramE[9]));
					appt.setNotes(request.getParameter("notes"));
					appt.setReason(request.getParameter("reason"));
					appt.setLocation(request.getParameter("location"));
					appt.setResources(request.getParameter("resources"));
					appt.setUpdateDateTime(ConversionUtils.fromTimestampString(createdDateTime));
					appt.setLastUpdateUser(loggedInInfo.getLoggedInProviderNo());
					appt.setUrgency(request.getParameter("urgency") != null ? request.getParameter("urgency") : "");
					appt.setReasonCode(Integer.parseInt(request.getParameter("reasonCode")));
					appointmentDao.merge(appt);
					rowsAffected++;
				}
                if(appts.isEmpty()){
                    //groupappt: "Group+Update"
                    //everyNum: "1"
                    //everyUnit: "day"
                    //dateUnit: "Day"
                    //endDate: "07/04/2024"
                    //appointment_date: "2024-04-06"
                    //start_time: "07:00"
                    //end_time: "07:29"
                    //duration: "30"
                    //orderby: "last_name,+first_name"
                    //originalpage: "/oscar/appointment/editappointment.jsp"
                    //limit1: "0"
                    //limit2: "5"
                    //ptstatus: "active"
                    //keyword: "PATIENT,NOT A"
                    //reasonCode: "14"
                    //reason: "inpatient+April+1+Endocarditis"
                    //location: "Temiskaming+Hospital"
                    //user_id: "Hutten-Czapski,+Peter"
                    //createDate: "2024-04-06+12:47:20"
                    //status: "B"
                    //type: ""
                    //doctorNo: "Hutten-Czapski,+Peter"
                    //demographic_no: "5209"
                    //notes: ""
                    //resources: ""
                    //lastcreatedatetime: "2024-04-06+12:47:20"
                    //createdatetime: "2024-4-6+13:2:30"
                    //provider_no: "101"
                    //creator: "Hutten-Czapski,+Peter"
                    //remarks: ""
                    //appointment_no: "769897"
                    //printReceipt: ""
			        Appointment appointment = new Appointment();
			        appointment.setProviderNo(request.getParameter("provider_no") != null ? request.getParameter("provider_no"):"-1"); //String
			        appointment.setAppointmentDate(gCalDate.getTime()); // Date
			        appointment.setStartTime(ConversionUtils.fromTimeStringNoSeconds(request.getParameter("start_time"))); // Date
			        appointment.setEndTime(ConversionUtils.fromTimeStringNoSeconds(request.getParameter("end_time"))); // Date
			        appointment.setName(request.getParameter("keyword"));
			        appointment.setNotes(request.getParameter("notes"));
			        appointment.setReason(request.getParameter("reason"));
			        appointment.setLocation(request.getParameter("location"));
			        appointment.setResources(request.getParameter("resources"));
			        appointment.setType(request.getParameter("type"));
			        appointment.setStyle(request.getParameter("style"));
			        appointment.setBilling(request.getParameter("billing"));
			        appointment.setStatus(request.getParameter("status"));
			        appointment.setCreateDateTime(new java.util.Date());
			        appointment.setCreator(userName);
			        appointment.setRemarks(request.getParameter("remarks"));
			        if (request.getParameter("demographic_no")!=null && !(request.getParameter("demographic_no").equals(""))) {
				        appointment.setDemographicNo(Integer.parseInt(request.getParameter("demographic_no")));
		            } else {
		            	appointment.setDemographicNo(0); //int
		            }

			        appointment.setProgramId(Integer.parseInt((String)request.getSession().getAttribute("programId_oscarView")));
			        appointment.setUrgency(request.getParameter("urgency") != null ? request.getParameter("urgency") : "");
			        appointment.setReasonCode(Integer.parseInt(request.getParameter("reasonCode")));
			        appointmentDao.persist(appointment);
                }

				gCalDate.setTime(UtilDateUtilities.StringToDate((String)param[12], "yyyy-MM-dd"));
				gCalDate = addDateByYMD(gCalDate, everyUnit, delta);

				if (gCalDate.after(gEndDate)) break;
				else param[12] = UtilDateUtilities.DateToString(gCalDate.getTime(), "yyyy-MM-dd");
			}
        	bSucc = true;
		}
	}

    if (bSucc) {
%>
<div class="alert alert-success">
<h4><bean:message
	key="appointment.appointmentgrouprecords.msgAddSuccess" /></h4>
</div>
<script>
	self.opener.refresh();
	setTimeout("self.close()",2000);
</script>
</body>
</html>
<%
    } else {
%>
<p>
<div class="alert alert-error" >
<h4>&nbsp;<bean:message
	key="appointment.appointmentgrouprecords.msgAddFailure" /></h4>
</div>
</body>
</html>
<%
    }
    return;
  }
%>

<form name="groupappt" method="POST"
	action="appointmenteditrepeatbooking.jsp" onsubmit="return onSub(event);">
<input type="hidden" name="groupappt" value="">

<h4>&nbsp;<bean:message key="appointment.appointmenteditrepeatbooking.title"/></h4>

<div class="container-fluid well" >


		<h5 style="white-space: nowrap;"><bean:message key="appointment.appointmenteditrepeatbooking.howoften"/></h5>


<table style="width:100%">
	<tr>
		<td style="width:20%"></td>
		<td style="width:16%; white-space: nowrap;"><bean:message key="appointment.appointmenteditrepeatbooking.every"/></td>
		<td style="white-space: nowrap;"><select name="everyNum" style="width: 70px">
			<%
for (int i = 1; i < 12; i++) {
%>
			<option value="<%=i%>"><%=i%></option>
			<%
}
%>
		</select> <input type="hidden" name="everyUnit" id="everyUnit"
			value="<%="day"%>" ></td>
	</tr>
	<tr>
		<td></td>
		<td></td>
		<td style="white-space: nowrap;">&nbsp;&nbsp;

		<input type="radio" name="dateUnit" value="<bean:message key="day"/>"   <%="checked"%> onclick='onCheck(this, "day")'><bean:message key="day"/> &nbsp;&nbsp;
		<input type="radio" name="dateUnit" value="<bean:message key="week"/>"  <%=""%>        onclick='onCheck(this, "week")'><bean:message key="week"/> &nbsp;&nbsp;
		<input type="radio" name="dateUnit" value="<bean:message key="month"/>" <%=""%>        onclick='onCheck(this, "month")'><bean:message key="month"/> &nbsp;&nbsp;
		<input type="radio" name="dateUnit" value="<bean:message key="year"/>"  <%=""%>        onclick='onCheck(this, "year")'><bean:message key="year"/>
<br><br></td>
	</tr>
	<tr>
		<td></td>
		<td><bean:message key="appointment.appointmenteditrepeatbooking.endon"/> &nbsp;&nbsp;
        </td>
        <td class="input-append" id="invoke-cal">
            <!-- tempting to replace with a date field however the expected format for the value is the non ISO dd/MM/yyyy
                way easier to obtain with a i18n calander -->
		    <input type="text" name="endDate"
                class="input-small"
			    id="endDate"
                title="<bean:message key="ddmmyyyy"/>"
			    value="<%=UtilDateUtilities.DateToString(new java.util.Date(),"dd/MM/yyyy")%>"
                pattern="^(([012]\d)|3[01])(/)((0\d)|(1[012]))(/)\d{4}$" autocomplete="off"
			    >
             <span class="add-on"><i class="icon-calendar"></i></span>
        </td>
	</tr>
</table>
<br>
<table style="width:100%" >
	<tr>
		<td>
		<%    if (bEdit) {    %>
        <input type="button" class="btn btn-primary"
			onclick="document.forms['groupappt'].groupappt.value='Group Update'; document.forms['groupappt'].requestSubmit();"
			VALUE="<bean:message key="appointment.appointmentgrouprecords.btnGroupUpdate"/>">
		<input type="button" class="btn"
			onclick="document.forms['groupappt'].groupappt.value='Group Cancel'; document.forms['groupappt'].requestSubmit();"
			VALUE="<bean:message key="appointment.appointmentgrouprecords.btnGroupCancel"/>">
		<input type="submit" class="btn btn-danger"
			onclick="onButDelete(); document.forms['groupappt'].groupappt.value='Group Delete';"
			VALUE="<bean:message key="appointment.appointmentgrouprecords.btnGroupDelete"/>">
        <%    } else {    %>
        <input type="button" class="btn btn-primary"
			onclick="document.forms['groupappt'].groupappt.value='Add Group Appointment'; document.forms['groupappt'].requestSubmit();"
			VALUE="<bean:message key="appointment.appointmentgrouprecords.btnAddGroupAppt"/>">
		<%    }    %>
		</td>
		<td style="text-align: right">
            <input type="button" class="btn"
    			value=" <bean:message key="global.btnBack"/> "
    			onClick="window.history.go(-1);return false;">
            <input type="button"class="btn btn-link"
                value=" <bean:message key="global.btnExit"/> "
			    onClick="onExit()">
        </td>
	</tr>
</table>

<%
String temp = null;
for (Enumeration e = request.getParameterNames() ; e.hasMoreElements() ;) {
	temp=e.nextElement().toString();
	if(temp.equals("dboperation") ||temp.equals("displaymode") ||temp.equals("search_mode") ||temp.equals("chart_no")) continue;
	out.println("<input type='hidden' name='"+temp+"' value=\"" + UtilMisc.htmlEscape(request.getParameter(temp)) + "\">");
}
%>
</div>
</form>

<script>
    Calendar.setup({
        inputField     :    "endDate",      // id of the input field
        ifFormat       :    "%d/%m/%Y",       // format of the input field
        showsTime      :    false,            // will display a time selector
        button         :    "invoke-cal",   // trigger for the calendar (button ID)
        singleClick    :    true,           // double-click mode
        step           :    1                // show all years in drop-down boxes (instead of every other year as default)
    });
</script>
</body>
</html:html>