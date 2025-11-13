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
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>

<jsp:useBean id="dataBean" class="java.util.Properties"/>
<%
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    Boolean bSaved = false;
    if (request.getParameter("dboperation") != null && !request.getParameter("dboperation").isEmpty() && request.getParameter("dboperation").equals("Save")) {
        bSaved = true;
        for(String key : SystemPreferences.ECHART_PREFERENCE_KEYS) {
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
    }
%>
<html:html locale="true">
<head>
    <html:base />
        <title><bean:message key="admin.admin.echartDisplaySettings"/></title>
        <script src="<%=request.getContextPath()%>/JavaScriptServlet"></script> <!-- OWASP CSRFGuard -->
        <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
</head>
<body class="BodyStyle">
    <%
        List<SystemPreferences> preferences = systemPreferencesDao.findPreferencesByNames(SystemPreferences.ECHART_PREFERENCE_KEYS);
        for(SystemPreferences preference : preferences) {
            dataBean.setProperty(preference.getName(), preference.getValue());
        }
    %>
    <h4><bean:message key="admin.admin.echartDisplaySettings.manage"/></h4>
    <form name="displaySettingsForm" method="post" action="echartDisplaySettings.jsp">
<% if (bSaved) { %>
    <div class="alert alert-success" id="alert1"><bean:message key="inboxmanager.document.SuccessfullySavedMsg"/></div>
<% } %>
        <input type="hidden" name="dboperation" value="">
        <table id="displaySettingsTable" class="table table-bordered table-striped table-hover table-condensed">
            <tbody>
                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_timer"/>:</td>
                    <td>
                        <input id="echart_show_timer-true" type="radio" value="true" name="echart_show_timer"
                                <%=(dataBean.getProperty("echart_show_timer", "true").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input id="echart_show_timer-false" type="radio" value="false" name="echart_show_timer"
                                <%=(dataBean.getProperty("echart_show_timer", "true").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.groupDocumentByType"/>:</td>
                    <td>
                        <input type="radio" value="true" name="echart_show_group_document_by_type"
                                <%=(dataBean.getProperty("echart_show_group_document_by_type", "false").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input type="radio" value="false" name="echart_show_group_document_by_type"
                                <%=(dataBean.getProperty("echart_show_group_document_by_type", "false").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_DOB"/>:</td>
                    <td>
                        <input id="echart_show_DOB-true" type="radio" value="true" name="echart_show_DOB"
                                <%=(dataBean.getProperty("echart_show_DOB", "false").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input id="echart_show_DOB-false" type="radio" value="false" name="echart_show_DOB"
                                <%=(dataBean.getProperty("echart_show_DOB", "false").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_OLIS"/>:</td>
                    <td>
                        <input id="echart_show_OLIS-true" type="radio" value="true" name="echart_show_OLIS"
                                <%=(dataBean.getProperty("echart_show_OLIS", "false").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input id="echart_show_OLIS-false" type="radio" value="false" name="echart_show_OLIS"
                                <%=(dataBean.getProperty("echart_show_OLIS", "false").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_cell"/>:</td>
                    <td>
                        <input id="echart_show_cell-true" type="radio" value="true" name="echart_show_cell"
                                <%=(dataBean.getProperty("echart_show_cell", "true").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input id="echart_show_cell-false" type="radio" value="false" name="echart_show_cell"
                                <%=(dataBean.getProperty("echart_show_cell", "true").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_HIN"/>:</td>
                    <td>
                        <input id="echart_show_HIN-true" type="radio" value="true" name="echart_show_HIN"
                                <%=(dataBean.getProperty("echart_show_HIN", "false").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input id="echart_show_HIN-false" type="radio" value="false" name="echart_show_HIN"
                                <%=(dataBean.getProperty("echart_show_HIN", "false").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>

                <tr>
                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_email_indicator"/>:</td>
                    <td>
                        <input id="echart_email_indicator-true" type="radio" value="true" name="echart_email_indicator"
                                <%=(dataBean.getProperty("echart_email_indicator", "false").equals("true")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                        &nbsp;&nbsp;&nbsp;
                        <input id="echart_email_indicator-false" type="radio" value="false" name="echart_email_indicator"
                                <%=(dataBean.getProperty("echart_email_indicator", "false").equals("false")) ? "checked" : ""%> >
                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                <oscar:oscarPropertiesCheck property="DEMOGRAPHIC_PATIENT_CLINIC_STATUS" value="true">
                    <tr>
                        <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_fam_doc_widget"/>:</td>
                        <td>
                            <input type="radio" value="true" name="echart_show_fam_doc_widget"
                                    <%=(dataBean.getProperty("echart_show_fam_doc_widget", "false").equals("true")) ? "checked" : ""%> >
                            <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                            &nbsp;&nbsp;&nbsp;
                            <input type="radio" value="false" name="echart_show_fam_doc_widget"
                                    <%=(dataBean.getProperty("echart_show_fam_doc_widget", "false").equals("false")) ? "checked" : ""%> >
                            <bean:message key="admin.admin.echartDisplaySettings.no"/>
                            &nbsp;&nbsp;&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_ref_doc_widget"/>:</td>
                        <td>
                            <input type="radio" value="true" name="echart_show_ref_doc_widget"
                                    <%=(dataBean.getProperty("echart_show_ref_doc_widget", "false").equals("true")) ? "checked" : ""%> >
                            <bean:message key="admin.admin.echartDisplaySettings.yes"/>
                            &nbsp;&nbsp;&nbsp;
                            <input type="radio" value="false" name="echart_show_ref_doc_widget"
                                    <%=(dataBean.getProperty("echart_show_ref_doc_widget", "false").equals("false")) ? "checked" : ""%> >
                            <bean:message key="admin.admin.echartDisplaySettings.no"/>
                            &nbsp;&nbsp;&nbsp;
                        </td>
                    </tr>
                </oscar:oscarPropertiesCheck>
	                <tr>
	                    <td><bean:message key="admin.admin.echartDisplaySettings.echart_show_ocean"/>:</td>
	                    <td>
	                        <input id="echart_show_ocean-true" type="radio" value="true" name="echart_show_ocean"
	                                <%=(dataBean.getProperty("echart_show_ocean", "false").equals("true")) ? "checked" : ""%> >
	                        <bean:message key="admin.admin.echartDisplaySettings.yes"/>
	                        &nbsp;&nbsp;&nbsp;
	                        <input id="echart_show_ocean-false" type="radio" value="false" name="echart_show_ocean"
	                                <%=(dataBean.getProperty("echart_show_ocean", "false").equals("false")) ? "checked" : ""%> >
	                        <bean:message key="admin.admin.echartDisplaySettings.no"/>
	                        &nbsp;&nbsp;&nbsp;
	                    </td>
	                </tr>
            </tbody>
        </table>

        <input type="button" class="btn btn-primary" onclick="document.forms['displaySettingsForm'].dboperation.value='Save'; document.forms['displaySettingsForm'].submit();" name="saveDisplaySettings" value="<bean:message key="admin.admin.echartDisplaySettings.save"/>">
    </form>
</body>
</html:html>