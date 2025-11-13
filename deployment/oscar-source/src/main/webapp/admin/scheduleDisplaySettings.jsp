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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin" rights="r" reverse="<%=true%>">
    <%authed=false; %>
    <%response.sendRedirect("../securityError.jsp?type=_admin");%>
</security:oscarSec>
<%
    if(!authed) {
        return;
    }
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="oscar.util.StringUtils" %>
<%@ page import="org.oscarehr.util.MiscUtils" %>
<%@ page import="org.oscarehr.common.dao.AppointmentTypeDao" %>
<%@ page import="org.oscarehr.common.model.AppointmentType" %>
<%@ page import="oscar.OscarProperties" %>

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    AppointmentTypeDao appointmentTypeDao = SpringUtils.getBean(AppointmentTypeDao.class);
    List<AppointmentType> appointmentTypeList = appointmentTypeDao.listAll();
    OscarProperties oscarProps = OscarProperties.getInstance();


%>

<html:html locale="true">
    <head>
        <title><bean:message key="admin.admin.scheduleDisplay.pagetitle" /></title>
        <script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="<%=request.getContextPath() %>/js/global.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
        <script type="text/javascript" src="<%=request.getContextPath() %>/js/bootstrap.js"></script>
        <script type="text/javascript" language="JavaScript" src="<%=request.getContextPath() %>/share/javascript/Oscar.js"></script>

        <script type="text/javascript" language="JavaScript">
            function toggleThirdPartyInputs(){
                var thirdPartyInputsEnabled = document.getElementById('schedule_tp_link_enabled-true');
                var thirdPartyAppointmentTypeSelect = document.getElementById('schedule_tp_link_type-select');
                var thirdPartyAppointmentTypeText = document.getElementById('schedule_tp_link_type-text');
                var thirdPartyDisplay = document.getElementById('schedule_tp_link_display-text');
                if(thirdPartyInputsEnabled != null && thirdPartyInputsEnabled.checked){
                    thirdPartyAppointmentTypeSelect.disabled = false;
                    thirdPartyAppointmentTypeText.disabled = false;
                    thirdPartyDisplay.disabled = false;
                } else {
                    thirdPartyAppointmentTypeSelect.disabled = true;
                    thirdPartyAppointmentTypeText.disabled = true;
                    thirdPartyDisplay.disabled = true;
                }
            }

            function defaultTypeSelect() {
                var thirdPartyInputsEnabled = document.getElementById('schedule_tp_link_enabled-true');
                if(thirdPartyInputsEnabled != null && thirdPartyInputsEnabled.checked) {
                    var thirdPartyAppointmentTypeSelect = document.getElementById('schedule_tp_link_type-select');
                    var thirdPartyAppointmentTypeText = document.getElementById('schedule_tp_link_type-text');
                    if (thirdPartyAppointmentTypeSelect.value === 'Custom') {
                        thirdPartyAppointmentTypeText.readOnly = false;
                        thirdPartyAppointmentTypeText.value = "";
                    } else {
                        thirdPartyAppointmentTypeText.readOnly = true;
                        thirdPartyAppointmentTypeText.value = thirdPartyAppointmentTypeSelect.value;
                    }
                }
            }

            defaultTypeSelect();
        </script>
    </head>

    <%
        List<SystemPreferences> preferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.SCHEDULE_PREFERENCE_KEYS);
        for(SystemPreferences preference : preferences) {
            dataBean.setProperty(preference.getName(), preference.getValue());
        }

        String tpLinkType = dataBean.getProperty("schedule_tp_link_type", "");
    %>

    <body vlink="#0000FF" class="BodyStyle">
    <h4><bean:message key="admin.admin.scheduleDisplay.pagetitle" /></h4>
    <form name="displaySettingsForm" method="post" action="scheduleDisplaySettings.jsp">
        <input type="hidden" name="dboperation" value="">
        <table id="displaySettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.oldSchedule" />: </td>
	                <td>
	                    <input id="old_schedule_enabled-true" type="radio" value="true" name="old_schedule_enabled"
	                            <%=(dataBean.getProperty("old_schedule_enabled", "false").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="old_schedule_enabled-false" type="radio" value="false" name="old_schedule_enabled"
	                            <%=(dataBean.getProperty("old_schedule_enabled", "false").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.timeLine" />: </td>
	                <td>
	                    <input id="display_timeline-true" type="radio" value="true" name="display_timeline"
	                            <%=(dataBean.getProperty("display_timeline", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="display_timeline-false" type="radio" value="false" name="display_timeline"
	                            <%=(dataBean.getProperty("display_timeline", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr> 
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.eye" />: </td>
	                <td>
	                    <input id="new_eyeform_enabled-true" type="radio" value="true" name="new_eyeform_enabled"
	                            <%=(dataBean.getProperty("new_eyeform_enabled", "false").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="new_eyeform_enabled-false" type="radio" value="false" name="new_eyeform_enabled"
	                            <%=(dataBean.getProperty("new_eyeform_enabled", "false").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>
	            <td><bean:message key="admin.admin.scheduleDisplay.intake" />: </td>
	                <td>
	                    <input id="appt_intake_form-true" type="radio" value="true" name="appt_intake_form"
	                            <%=(dataBean.getProperty("appt_intake_form", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="appt_intake_form-false" type="radio" value="false" name="appt_intake_form"
	                            <%=(dataBean.getProperty("appt_intake_form", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.fullName" />: </td>
	                <td>
	                    <input id="appt_show_full_name-true" type="radio" value="true" name="appt_show_full_name"
	                            <%=(dataBean.getProperty("appt_show_full_name", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="appt_show_full_name-false" type="radio" value="false" name="appt_show_full_name"
	                            <%=(dataBean.getProperty("appt_show_full_name", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>            
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.reason" />: </td>
	                <td>
	                    <input id="show_appt_reason-true" type="radio" value="true" name="show_appt_reason"
	                            <%=(dataBean.getProperty("show_appt_reason", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="show_appt_reason-false" type="radio" value="false" name="show_appt_reason"
	                            <%=(dataBean.getProperty("show_appt_reason", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>            
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.allDays" />: </td>
	                <td>
	                    <input id="show_NonScheduledDays_In_WeekView-true" type="radio" value="true" name="show_NonScheduledDays_In_WeekView"
	                            <%=(dataBean.getProperty("show_NonScheduledDays_In_WeekView", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="show_NonScheduledDays_In_WeekView-false" type="radio" value="false" name="show_NonScheduledDays_In_WeekView"
	                            <%=(dataBean.getProperty("show_NonScheduledDays_In_WeekView", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>            
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.recepAlt" />: </td>
	                <td>
	                    <input id="receptionist_alt_view-true" type="radio" value="true" name="receptionist_alt_view"
	                            <%=(dataBean.getProperty("receptionist_alt_view", "false").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="receptionist_alt_view-false" type="radio" value="false" name="receptionist_alt_view"
	                            <%=(dataBean.getProperty("receptionist_alt_view", "false").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>            
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.typeReason" />: </td>
	                <td>
	                    <input id="show_appt_type_with_reason-true" type="radio" value="true" name="show_appt_type_with_reason"
	                            <%=(dataBean.getProperty("show_appt_type_with_reason", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="show_appt_type_with_reason-false" type="radio" value="false" name="show_appt_type_with_reason"
	                            <%=(dataBean.getProperty("show_appt_type_with_reason", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>            
<!--            <tr>
	                <td>appt_show_short_letters: </td>
	                <td>
	                    <input id="appt_show_short_letters-true" type="radio" value="true" name="appt_show_short_letters"
	                            <%=(dataBean.getProperty("appt_show_short_letters", "false").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="appt_show_short_letters-false" type="radio" value="false" name="appt_show_short_letters"
	                            <%=(dataBean.getProperty("appt_show_short_letters", "false").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>
-->	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.alert" />: </td>
	                <td>
	                    <input id="displayAlertsOnScheduleScreen-true" type="radio" value="true" name="displayAlertsOnScheduleScreen"
	                            <%=(dataBean.getProperty("displayAlertsOnScheduleScreen", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="displayAlertsOnScheduleScreen-false" type="radio" value="false" name="displayAlertsOnScheduleScreen"
	                            <%=(dataBean.getProperty("displayAlertsOnScheduleScreen", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>            
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.notes" />: </td>
	                <td>
	                    <input id="displayNotesOnScheduleScreen-true" type="radio" value="true" name="displayNotesOnScheduleScreen"
	                            <%=(dataBean.getProperty("displayNotesOnScheduleScreen", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="displayNotesOnScheduleScreen-false" type="radio" value="false" name="displayNotesOnScheduleScreen"
	                            <%=(dataBean.getProperty("displayNotesOnScheduleScreen", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>  
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.bigCalendar" />: </td>
	                <td>
	                    <input id="display_large_calendar-true" type="radio" value="true" name="display_large_calendar"
	                            <%=(dataBean.getProperty("display_large_calendar", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="display_large_calendar-false" type="radio" value="false" name="display_large_calendar"
	                            <%=(dataBean.getProperty("display_large_calendar", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.quickDate" />: </td>
	                <td>
	                    <input id="display_quick_date_picker-true" type="radio" value="true" name="display_quick_date_picker"
	                            <%=(dataBean.getProperty("display_quick_date_picker", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="display_quick_date_picker-false" type="radio" value="false" name="display_quick_date_picker"
	                            <%=(dataBean.getProperty("display_quick_date_picker", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>  
	            <tr>
	                <td><bean:message key="admin.admin.scheduleDisplay.multiplier" />: </td>
	                <td>
	                    <input id="display_quick_date_multiplier-true" type="radio" value="true" name="display_quick_date_multiplier"
	                            <%=(dataBean.getProperty("display_quick_date_multiplier", "true").equals("true")) ? "checked" : ""%> />
	                    <bean:message key="global.yes" />
	                    &nbsp;&nbsp;&nbsp;
	                    <input id="display_quick_date_multiplier-false" type="radio" value="false" name="display_quick_date_multiplier"
	                            <%=(dataBean.getProperty("display_quick_date_multiplier", "true").equals("false")) ? "checked" : ""%> />
	                    <bean:message key="global.no" />
	                    &nbsp;&nbsp;&nbsp;
	                </td>
	            </tr>     
                <tr>
                    <td><bean:message key="admin.admin.scheduleDisplay.type" />: </td>
                    <td>
                        <input id="schedule_display_type-true" type="radio" value="true" name="schedule_display_type"
                                <%=(dataBean.getProperty("schedule_display_type", "false").equals("true")) ? "checked" : ""%> />
                        Yes
                        &nbsp;&nbsp;&nbsp;
                        <input id="schedule_display_type-false" type="radio" value="false" name="schedule_display_type"
                                <%=(dataBean.getProperty("schedule_display_type", "false").equals("false")) ? "checked" : ""%> />
                        No
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
        <!--        <tr>
                    <td>Display custom roster status: </td>
                    <td>
                        <input id="schedule_display_custom_roster_status-true" type="radio" value="true" name="schedule_display_custom_roster_status"
                                <%=(dataBean.getProperty("schedule_display_custom_roster_status", "false").equals("true")) ? "checked" : ""%> />
                        Yes
                        &nbsp;&nbsp;&nbsp;
                        <input id="schedule_display_custom_roster_status-false" type="radio" value="false" name="schedule_display_custom_roster_status"
                                <%=(dataBean.getProperty("schedule_display_custom_roster_status", "false").equals("false")) ? "checked" : ""%> />
                        No
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>Display Third Party Link from Appointment Notes: </td>
                    <td>
                        <input id="schedule_tp_link_enabled-true" type="radio" value="true" onclick="toggleThirdPartyInputs()" name="schedule_tp_link_enabled"
                                <%=(dataBean.getProperty("schedule_tp_link_enabled", "false").equals("true")) ? "checked" : ""%> />
                        Yes
                        &nbsp;&nbsp;&nbsp;
                        <input id="schedule_tp_link_enabled-false" type="radio" value="false" onclick="toggleThirdPartyInputs()" name="schedule_tp_link_enabled"
                                <%=(dataBean.getProperty("schedule_tp_link_enabled", "false").equals("false")) ? "checked" : ""%> />
                        No
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>Appointment Type for Third Party Link: </td>
                    <td>
                        <select id="schedule_tp_link_type-select" name="schedule_tp_link_type-sel" onchange="defaultTypeSelect()" <%= dataBean.getProperty("schedule_tp_link_enabled", "false").equals("false") ? "disabled" : ""%>>
                            <option value="Custom">Custom</option>
                            <%
                                Boolean appointmentTypeExists = false;
                                for (AppointmentType appointmentType : appointmentTypeList)
                                {
                                    appointmentTypeExists = tpLinkType.equals(appointmentType.getName());
                            %>
                            <option value="<%=Encode.forHtmlAttribute(appointmentType.getName())%>" <%=tpLinkType.equals(appointmentType.getName()) ? " selected" : ""%>><%=Encode.forHtmlAttribute(appointmentType.getName())%></option>
                            <%
                                }
                            %>
                        </select>
                        <input type="text" id="schedule_tp_link_type-text" name="schedule_tp_link_type" value="<%= Encode.forHtmlAttribute(tpLinkType)%>" <%= dataBean.getProperty("schedule_tp_link_enabled", "false").equals("false") ? "disabled" : ""%> <%= appointmentTypeExists ? "readOnly" : ""%>/>
                        
                    </td>
                </tr>
                <tr>
                    <td>Display Name for Third Party Link: </td>
                    <td>
                        <input type="text" id="schedule_tp_link_display-text" name="schedule_tp_link_display" value="<%= Encode.forHtmlAttribute(StringUtils.isNullOrEmpty(dataBean.getProperty("schedule_tp_link_display")) ? "" : dataBean.getProperty("schedule_tp_link_display"))%>" <%= dataBean.getProperty("schedule_tp_link_enabled", "false").equals("false") ? "disabled" : ""%>/>
                    </td>
                </tr>
                <% if(oscarProps.getProperty("billregion", "").equals("BC")){ %>
                <tr>
                    <td>Display Teleplan Eligibility next to each appointment: </td>
                    <td>
                        <input id="schedule_eligibility_enabled-true" type="radio" value="true" name="schedule_eligibility_enabled"
                                <%=(dataBean.getProperty("schedule_eligibility_enabled", "false").equals("true")) ? "checked" : ""%> />
                        Yes
                        &nbsp;&nbsp;&nbsp;
                        <input id="schedule_eligibility_enabled-false" type="radio" value="false" name="schedule_eligibility_enabled"
                                <%=(dataBean.getProperty("schedule_eligibility_enabled", "false").equals("false")) ? "checked" : ""%> />
                        No
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <% } %>
                <tr>
                    <td><bean:message key="admin.schedule.display.settings.enrollment"/>: </td>
                     <td>
                        <input id="schedule_display_enrollment_dr_enabled-true" type="radio" value="true" name="schedule_display_enrollment_dr_enabled"
                                <%=(dataBean.getProperty("schedule_display_enrollment_dr_enabled", "false").equals("true")) ? "checked" : ""%> />
                        Yes
                        &nbsp;&nbsp;&nbsp;
                        <input id="schedule_display_enrollment_dr_enabled-false" type="radio" value="false" name="schedule_display_enrollment_dr_enabled"
                                <%=(dataBean.getProperty("schedule_display_enrollment_dr_enabled", "false").equals("false")) ? "checked" : ""%> />
                        No
                        &nbsp;&nbsp;&nbsp;
                    </td>                   
                </tr>
    -->            
            </tbody>
        </table>

        <input type="button" class="btn btn-primary" onclick="document.forms['displaySettingsForm'].dboperation.value='Save'; document.forms['displaySettingsForm'].submit();" name="saveDisplaySettings" value="<bean:message key="global.btnSave" />"/>
    </form>
<%

    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        try { 
            for(String key : SystemPreferences.SCHEDULE_PREFERENCE_KEYS) {
                SystemPreferences preference = systemPreferencesDao.findPreferenceByName(key);
                String newValue = request.getParameter(key);
                
                if (preference != null) {
                    if (!preference.getValue().equals(newValue)) {
                        preference.setUpdateDate(new Date());
                        preference.setValue(newValue);
                        systemPreferencesDao.merge(preference);
                    }
                } else {
                    preference = new SystemPreferences();
                    preference.setName(key);
                    preference.setUpdateDate(new Date());
                    preference.setValue(newValue);
                    systemPreferencesDao.persist(preference);
                }
            }
%>
    <div class="alert alert-success">
    <bean:message key="admin.admin.scheduleDisplay.success" />
    </div>
<%
        } catch(Exception ex){
            MiscUtils.getLogger().error("Error", ex);
%>
    <div class="alert alert-error">
    <bean:message key="admin.admin.scheduleDisplay.error" />
    </div>
<%
        }
    }
%>

    </body>
</html:html>