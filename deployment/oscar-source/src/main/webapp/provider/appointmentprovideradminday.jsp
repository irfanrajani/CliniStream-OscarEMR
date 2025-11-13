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

<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.apache.commons.text.WordUtils"%>
<%@ page import="org.oscarehr.phr.util.MyOscarUtils"%>
<%@ page import="org.oscarehr.common.model.Appointment.BookingSource"%>
<%@ page import="org.oscarehr.common.model.Provider,org.oscarehr.common.model.BillingONCHeader1"%>
<%@ page import="org.oscarehr.common.model.ProviderPreference"%>
<%@ page import="org.oscarehr.common.dao.ProviderPreferenceDao"%>
<%@ page import="org.oscarehr.web.admin.ProviderPreferencesUIBean"%>
<%@ page import="org.oscarehr.common.dao.DemographicDao, org.oscarehr.common.model.Demographic" %>
<%@ page import="org.oscarehr.common.dao.DemographicCustDao, org.oscarehr.common.model.DemographicCust" %>
<%@ page import="org.oscarehr.common.dao.MyGroupAccessRestrictionDao" %>
<%@ page import="org.oscarehr.common.model.MyGroupAccessRestriction" %>
<%@ page import="org.oscarehr.common.dao.DemographicStudyDao" %>
<%@ page import="org.oscarehr.common.model.DemographicStudy" %>
<%@ page import="org.oscarehr.common.dao.StudyDao" %>
<%@ page import="org.oscarehr.common.model.Study" %>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO" %>
<%@ page import="org.oscarehr.common.model.UserProperty" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.common.dao.SiteDao" %>
<%@ page import="org.oscarehr.common.model.Site" %>
<%@ page import="org.oscarehr.common.dao.MyGroupDao" %>
<%@ page import="org.oscarehr.common.model.MyGroup" %>
<%@ page import="org.oscarehr.common.dao.ScheduleTemplateCodeDao" %>
<%@ page import="org.oscarehr.common.model.ScheduleTemplateCode" %>
<%@ page import="org.oscarehr.common.dao.ScheduleDateDao" %>
<%@ page import="org.oscarehr.common.model.ScheduleDate" %>
<%@ page import="org.oscarehr.common.dao.ProviderSiteDao" %>
<%@ page import="org.oscarehr.common.model.ScheduleTemplate" %>
<%@ page import="org.oscarehr.common.dao.OscarAppointmentDao" %>
<%@ page import="org.oscarehr.common.model.Appointment" %>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO" %>
<%@ page import="org.oscarehr.common.model.UserProperty" %>
<%@ page import="org.oscarehr.common.model.Tickler" %>
<%@ page import="org.oscarehr.common.model.AppointmentDxLink" %>
<%@ page import="org.oscarehr.managers.AppointmentDxLinkManager" %>
<%@ page import="org.oscarehr.managers.TicklerManager" %>
<%@ page import="org.oscarehr.managers.ProgramManager2"%>
<%@ page import="org.oscarehr.PMmodule.model.ProgramProvider"%>
<%@ page import="org.oscarehr.managers.LookupListManager" %>
<%@ page import="org.oscarehr.common.model.LookupList" %>
<%@ page import="org.oscarehr.common.model.LookupListItem" %>
<%@ page import="org.oscarehr.managers.SecurityInfoManager" %>
<%@ page import="org.oscarehr.managers.AppManager" %>
<%@ page import="org.oscarehr.managers.DashboardManager" %>
<%@ page import="org.oscarehr.common.model.Dashboard" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.util.MiscUtils" %>
<%@ page import="org.oscarehr.util.SessionConstants" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.io.File"%>
<%@ page import="java.io.FileNotFoundException"%>
<%@ page import="java.util.Map" %>
<%@ page import="org.owasp.encoder.Encode" %>

<!-- add by caisi -->
<%@ taglib uri="http://www.caisi.ca/plugin-tag" prefix="plugin" %>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>
<%@ taglib uri="/WEB-INF/special_tag.tld" prefix="special" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/indivo-tag.tld" prefix="myoscar" %>
<%@ taglib uri="/WEB-INF/phr-tag.tld" prefix="phr" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	LoggedInInfo loggedInInfo1=LoggedInInfo.getLoggedInInfoFromSession(request);
	SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);

	TicklerManager ticklerManager= SpringUtils.getBean(TicklerManager.class);
	DemographicStudyDao demographicStudyDao = SpringUtils.getBean(DemographicStudyDao.class);
	StudyDao studyDao = SpringUtils.getBean(StudyDao.class);
    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    Map<String, Boolean> schedulePreferences = systemPreferencesDao.findByKeysAsMap(SystemPreferences.SCHEDULE_PREFERENCE_KEYS);

    boolean showFullName = schedulePreferences.getOrDefault("appt_show_full_name", true);
    boolean showApptReason = schedulePreferences.getOrDefault("show_appt_reason", true);
    boolean showRecView = schedulePreferences.getOrDefault("receptionist_alt_view", false);
    boolean showNonScheduled = schedulePreferences.getOrDefault("show_NonScheduledDays_In_WeekView", true);
    boolean showTypeReason = schedulePreferences.getOrDefault("show_appt_type_with_reason", true);
    boolean showShortLetters = schedulePreferences.getOrDefault("appt_show_short_letters", false);
    boolean showAlerts = schedulePreferences.getOrDefault("displayAlertsOnScheduleScreen", true);
    boolean showNotes = schedulePreferences.getOrDefault("displayNotesOnScheduleScreen", true);
    boolean showQuickDateMultiplier = schedulePreferences.getOrDefault("display_quick_date_multiplier", true);
    boolean showQuickDatePicker = schedulePreferences.getOrDefault("display_quick_date_picker", true);
    boolean showLargeCalendar = schedulePreferences.getOrDefault("display_large_calendar", true);
    boolean bShortcutIntakeForm =  schedulePreferences.getOrDefault("appt_intake_form", true);

    boolean showClassicSchedule = schedulePreferences.getOrDefault("old_schedule_enabled", false);
    boolean showEyeForm = schedulePreferences.getOrDefault("new_eyeform_enabled", false);
    boolean isTimeline = schedulePreferences.getOrDefault("display_timeline", true);

	UserPropertyDAO userPropertyDao = SpringUtils.getBean(UserPropertyDAO.class);
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	SiteDao siteDao = SpringUtils.getBean(SiteDao.class);
	MyGroupDao myGroupDao = SpringUtils.getBean(MyGroupDao.class);
	DemographicDao demographicDao = (DemographicDao)SpringUtils.getBean("demographicDao");
	ScheduleTemplateCodeDao scheduleTemplateCodeDao = SpringUtils.getBean(ScheduleTemplateCodeDao.class);
	ScheduleDateDao scheduleDateDao = SpringUtils.getBean(ScheduleDateDao.class);
	ProviderSiteDao providerSiteDao = SpringUtils.getBean(ProviderSiteDao.class);
	OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
	DemographicCustDao demographicCustDao = SpringUtils.getBean(DemographicCustDao.class);
	ProgramManager2 programManager = SpringUtils.getBean(ProgramManager2.class);
	AppManager appManager = SpringUtils.getBean(AppManager.class);
	AppointmentDxLinkManager appointmentDxLinkManager = SpringUtils.getBean(AppointmentDxLinkManager.class);

	LookupListManager lookupListManager = SpringUtils.getBean(LookupListManager.class);
	LookupList reasonCodes = lookupListManager.findLookupListByName(loggedInInfo1, "reasonCode");
	Map<Integer,LookupListItem> reasonCodesMap = new  HashMap<Integer,LookupListItem>();
	for(LookupListItem lli:reasonCodes.getItems()) {
		reasonCodesMap.put(lli.getId(),lli);
	}

	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");

    boolean isSiteAccessPrivacy=false;
    boolean isTeamAccessPrivacy=false;

    MyGroupAccessRestrictionDao myGroupAccessRestrictionDao = SpringUtils.getBean(MyGroupAccessRestrictionDao.class);
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment,_day" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_appointment");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<security:oscarSec objectName="_site_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%
		isSiteAccessPrivacy=true;
	%>
</security:oscarSec>
<security:oscarSec objectName="_team_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%
		isTeamAccessPrivacy=true;
	%>
</security:oscarSec>

<%!//multisite starts =====================
private boolean bMultisites = org.oscarehr.common.IsPropertiesOn.isMultisitesEnable();
private JdbcApptImpl jdbc = new JdbcApptImpl();
private List<Site> sites = new ArrayList<Site>();
private List<Site> curUserSites = new ArrayList<Site>();
private List<String> siteProviderNos = new ArrayList<String>();
private List<String> siteGroups = new ArrayList<String>();
private String selectedSite = null;
private HashMap<String,String> siteBgColor = new HashMap<String,String>();
private HashMap<String,String> CurrentSiteMap = new HashMap<String,String>();%>

<%
	if (bMultisites) {
	sites = siteDao.getAllActiveSites();
	selectedSite = (String)session.getAttribute("site_selected");

	if (selectedSite != null) {
		//get site provider list
		siteProviderNos = siteDao.getProviderNoBySiteLocation(selectedSite);
		siteGroups = siteDao.getGroupBySiteLocation(selectedSite);
	}

	if (isSiteAccessPrivacy || isTeamAccessPrivacy) {
		String siteManagerProviderNo = (String) session.getAttribute("user");
		curUserSites = siteDao.getActiveSitesByProviderNo(siteManagerProviderNo);
		if (selectedSite==null) {
	siteProviderNos = siteDao.getProviderNoBySiteManagerProviderNo(siteManagerProviderNo);
	siteGroups = siteDao.getGroupBySiteManagerProviderNo(siteManagerProviderNo);
		}
	}
	else {
		curUserSites = sites;
	}

	for (Site s : curUserSites) {
		CurrentSiteMap.put(s.getName(),"Y");
	}

	//get all sites bgColors
	for (Site st : sites) {
		siteBgColor.put(st.getName(),st.getBgColor());
	}
}
//multisite ends =======================
%>



<!-- add by caisi end<style>* {border:1px solid black;}</style> -->

<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>

<%
	long loadPage = System.currentTimeMillis();
    if(session.getAttribute("userrole") == null )  response.sendRedirect("../logout.jsp");
    //String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment" rights="r" reverse="<%=true%>" >
<%
	response.sendRedirect("../logout.jsp");
%>
</security:oscarSec>

<!-- caisi infirmary view extension add -->
<caisi:isModuleLoad moduleName="caisi">
<%
	if (request.getParameter("year")!=null && request.getParameter("month")!=null && request.getParameter("day")!=null)
	{
		java.util.Date infirm_date=new java.util.GregorianCalendar(Integer.valueOf(request.getParameter("year")).intValue(), Integer.valueOf(request.getParameter("month")).intValue()-1, Integer.valueOf(request.getParameter("day")).intValue()).getTime();
		session.setAttribute("infirmaryView_date",infirm_date);

	}else
	{
		session.setAttribute("infirmaryView_date",null);
	}
	String reqstr =request.getQueryString();
	if (reqstr == null)
	{
		//Hack:: an unknown bug of struts or JSP causing the queryString to be null
		String year_q = request.getParameter("year");
	    String month_q =request.getParameter("month");
	    String day_q = request.getParameter("day");
	    String view_q = request.getParameter("view");
	    String displayMode_q = request.getParameter("displaymode");
	    reqstr = "year=" + year_q + "&month=" + month_q
           + "&day="+ day_q + "&view=" + view_q + "&displaymode=" + displayMode_q;
	}
	session.setAttribute("infirmaryView_OscarQue",reqstr);
%>
<c:import url="/infirm.do?action=showProgram" />
</caisi:isModuleLoad>
<!-- caisi infirmary view extension add end -->

<%@ page import="java.util.*,java.text.*,java.sql.*,java.net.*,oscar.*,oscar.util.*,org.oscarehr.provider.model.PreventionManager" %>

<%@ page import="org.apache.commons.lang.*" %>

<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<jsp:useBean id="providerBean" class="java.util.Properties" scope="session" />
<jsp:useBean id="as" class="oscar.appt.ApptStatusData" scope="page" />
<jsp:useBean id="dateTimeCodeBean" class="java.util.Hashtable" scope="page" />
<%
	Properties oscarVariables = OscarProperties.getInstance();
	String help_url = (oscarVariables.getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/")).trim();
    String econsultUrl = oscarVariables.getProperty("backendEconsultUrl");

	//Gets the request URL
	StringBuffer oscarUrl = request.getRequestURL();
	//Sets the length of the URL, found by subtracting the length of the servlet path from the length of the full URL, that way it only gets up to the context path
	oscarUrl.setLength(oscarUrl.length() - request.getServletPath().length());
%>

<!-- Struts for i18n -->
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%
	PreventionManager prevMgr = (PreventionManager)SpringUtils.getBean("preventionMgr");
%>
<%!/**
Checks if the schedule day is patients birthday
**/
public boolean isBirthday(String schedDate,String demBday){
	return schedDate.equals(demBday);
}
public boolean patientHasOutstandingPrivateBills(String demographicNo){
	oscar.oscarBilling.ca.bc.MSP.MSPReconcile msp = new oscar.oscarBilling.ca.bc.MSP.MSPReconcile();
	return msp.patientHasOutstandingPrivateBill(demographicNo);
}%>
<%
	if(session.getAttribute("user") == null )
        response.sendRedirect("../logout.jsp");

	String curUser_no = (String) session.getAttribute("user");

    UserProperty tabViewProp = userPropertyDao.getProp(curUser_no, UserProperty.OPEN_IN_TABS);
    boolean openInTabs = false;
    if ( tabViewProp == null ) {
        openInTabs = oscar.OscarProperties.getInstance().getBooleanProperty("open_in_tabs", "true");
    } else {
        openInTabs = oscar.OscarProperties.getInstance().getBooleanProperty("open_in_tabs", "true") || Boolean.parseBoolean(tabViewProp.getValue());
    }


    ProviderPreference providerPreference2=(ProviderPreference)session.getAttribute(SessionConstants.LOGGED_IN_PROVIDER_PREFERENCE);

    String mygroupno = providerPreference2.getMyGroupNo();
    if(mygroupno == null){
    	mygroupno = ".default";
    }
    String caisiView = null;
    caisiView = request.getParameter("GoToCaisiViewFromOscarView");
    boolean notOscarView = "false".equals(session.getAttribute("infirmaryView_isOscar"));
    if((caisiView!=null && "true".equals(caisiView)) || notOscarView) {
    	mygroupno = ".default";
    }
    String userfirstname = (String) session.getAttribute("userfirstname");
    String userlastname = (String) session.getAttribute("userlastname");
    String prov= (oscarVariables.getProperty("billregion","")).trim().toUpperCase();

    int startHour=providerPreference2.getStartHour();
    int endHour=providerPreference2.getEndHour();
    int everyMin=providerPreference2.getEveryMin();
    String defaultServiceType = (String) session.getAttribute("default_servicetype");
	ProviderPreference providerPreference=ProviderPreferencesUIBean.getProviderPreference(loggedInInfo1.getLoggedInProviderNo());
    if( defaultServiceType == null && providerPreference!=null) {
    	defaultServiceType = providerPreference.getDefaultServiceType();
    }

    if( defaultServiceType == null ) {
        defaultServiceType = "";
    }

    Collection<Integer> eforms = providerPreference2.getAppointmentScreenEForms();
    StringBuilder eformIds = new StringBuilder();
    for( Integer eform : eforms ) {
    	eformIds = eformIds.append("&eformId=" + eform);
    }

    Collection<String> forms = providerPreference2.getAppointmentScreenForms();
    StringBuilder ectFormNames = new StringBuilder();
    for( String formName : forms ) {
    	ectFormNames = ectFormNames.append("&encounterFormName=" + formName);
    }

	boolean erx_enable = providerPreference2.isERxEnabled();
	boolean erx_training_mode = providerPreference2.isERxTrainingMode();

    String newticklerwarningwindow=null;
    String default_pmm=null;
    String programId_oscarView=null;
	String ocanWarningWindow=null;
	String cbiReminderWindow=null;
	String caisiBillingPreferenceNotDelete = null;
	String tklerProviderNo = null;

	UserPropertyDAO propDao =(UserPropertyDAO)SpringUtils.getBean("UserPropertyDAO");
	UserProperty userprop = propDao.getProp(curUser_no, UserProperty.PROVIDER_FOR_TICKLER_WARNING);
	if (userprop != null) {
		tklerProviderNo = userprop.getValue();
	} else {
		tklerProviderNo = curUser_no;
	}

	if (org.oscarehr.common.IsPropertiesOn.isCaisiEnable() && org.oscarehr.common.IsPropertiesOn.propertiesOn("OCAN_warning_window") ) {
        ocanWarningWindow = (String)session.getAttribute("ocanWarningWindow");
	}

	if (org.oscarehr.common.IsPropertiesOn.isCaisiEnable() && org.oscarehr.common.IsPropertiesOn.propertiesOn("CBI_REMINDER_WINDOW") ) {
        cbiReminderWindow = (String)session.getAttribute("cbiReminderWindow");
	}

	//Hide old echart link
	boolean showOldEchartLink = true;
	UserProperty oldEchartLink = propDao.getProp(curUser_no, UserProperty.HIDE_OLD_ECHART_LINK_IN_APPT);
	if (oldEchartLink!=null && "Y".equals(oldEchartLink.getValue())) showOldEchartLink = false;

	SimpleDateFormat appointmentDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

if (org.oscarehr.common.IsPropertiesOn.isCaisiEnable() && org.oscarehr.common.IsPropertiesOn.isTicklerPlusEnable()){
	newticklerwarningwindow = (String) session.getAttribute("newticklerwarningwindow");
	default_pmm = (String)session.getAttribute("default_pmm");

	caisiBillingPreferenceNotDelete = String.valueOf(session.getAttribute("caisiBillingPreferenceNotDelete"));
    if(caisiBillingPreferenceNotDelete==null) {
    	ProviderPreference pp = ProviderPreferencesUIBean.getProviderPreferenceByProviderNo(curUser_no);
    	if(pp!=null) {
    		caisiBillingPreferenceNotDelete = String.valueOf(pp.getDefaultDoNotDeleteBilling());
    	}

    }

	//Disable schedule view associated with the program
	//Made the default program id "0";
	//programId_oscarView= (String)session.getAttribute("programId_oscarView");
	programId_oscarView = "0";
} else {
	programId_oscarView="0";
	session.setAttribute("programId_oscarView",programId_oscarView);
}
    int lenLimitedL=11; //L - long
    if(showFullName) {
    	lenLimitedL = 25;
    }
    int lenLimitedS=3; //S - short
    int len = lenLimitedL;
    int view = request.getParameter("view")!=null ? Integer.parseInt(request.getParameter("view")) : 0; //0-multiple views, 1-single view
    //// THIS IS THE VALUE I HAVE BEEN LOOKING FOR!!!!!
	boolean bDispTemplatePeriod = ( showRecView ); // true - display as schedule template period, false - display as preference
%>
<%
	String tickler_no="", textColor="", tickler_note="";
    String ver = "", roster="";
    String yob = "";
    String mob = "";
    String dob = "";
    String demBday = "";
    StringBuffer study_no=null, study_link=null,studyDescription=null;
	String studySymbol = "\u03A3", studyColor = "red";

    // List of statuses that are excluded from the schedule appointment count for each provider
    List<String> noCountStatus = Arrays.asList("C","CS","CV","N","NS","NV");

    String resourcebaseurl =  oscarVariables.getProperty("resource_base_url");

    UserProperty rbu = userPropertyDao.getProp("resource_baseurl");
    if(rbu != null) {
    	resourcebaseurl = rbu.getValue();
    }

    String resourcehelpHtml = oscarVariables.getProperty("HELP_SEARCH_URL");
    UserProperty rbuHtml = userPropertyDao.getProp("resource_helpHtml");
    if(rbuHtml != null) {
    	resourcehelpHtml = rbuHtml.getValue();
    }


    boolean isWeekView = false;
    String provNum = request.getParameter("provider_no");
    if (provNum != null) {
        isWeekView = true;
    }
    if(caisiView!=null && "true".equals(caisiView)) {
    	isWeekView = false;
    }
int nProvider;

boolean caseload = "1".equals(request.getParameter("caseload"));

GregorianCalendar cal = new GregorianCalendar();
int curYear = cal.get(Calendar.YEAR);
int curMonth = (cal.get(Calendar.MONTH)+1);
int curDay = cal.get(Calendar.DAY_OF_MONTH);

int year = Integer.parseInt(request.getParameter("year"));
int month = Integer.parseInt(request.getParameter("month"));
int day = Integer.parseInt(request.getParameter("day"));

//verify the input date is really existed
cal = new GregorianCalendar(year,(month-1),day);

if (isWeekView) {
cal.add(Calendar.DATE, -(cal.get(Calendar.DAY_OF_WEEK)-1)); // change the day to the current weeks initial sunday
}

int week = cal.get(Calendar.WEEK_OF_YEAR);
year = cal.get(Calendar.YEAR);
month = (cal.get(Calendar.MONTH)+1);
day = cal.get(Calendar.DAY_OF_MONTH);

String strDate = year + "-" + month + "-" + day;
String monthDay = String.format("%02d", month) + "-" + String.format("%02d", day);
SimpleDateFormat inform = new SimpleDateFormat ("yyyy-MM-dd", request.getLocale());
String formatDate;
try {
java.util.ResourceBundle prop = ResourceBundle.getBundle("oscarResources", request.getLocale());
formatDate = UtilDateUtilities.DateToString(inform.parse(strDate), prop.getString("date.EEEyyyyMMdd"),request.getLocale());
} catch (Exception e) {
	MiscUtils.getLogger().error("Error", e);
formatDate = UtilDateUtilities.DateToString(inform.parse(strDate), "EEE, yyyy-MM-dd");
}
String strYear=""+year;
String strMonth=month>9?(""+month):("0"+month);
String strDay=day>9?(""+day):("0"+day);


Calendar apptDate = Calendar.getInstance();
apptDate.set(year, month-1 , day);
Calendar minDate = Calendar.getInstance();
minDate.set( minDate.get(Calendar.YEAR), minDate.get(Calendar.MONTH), minDate.get(Calendar.DATE) );
String allowDay = "";
if (apptDate.equals(minDate)) {
    allowDay = "Yes";
    } else {
    allowDay = "No";
}
minDate.add(Calendar.DATE, 7);
String allowWeek = "";
if (apptDate.before(minDate)) {
    allowWeek = "Yes";
    } else {
    allowWeek = "No";
}


Map<String, Boolean> generalSettingsMap = systemPreferencesDao.findByKeysAsMap(SystemPreferences.GENERAL_SETTINGS_KEYS);
boolean replaceNameWithPreferred = generalSettingsMap.getOrDefault("replace_demographic_name_with_preferred", false);

%>

<%

    ProviderPreference providerPreference1 = null;
    ProviderPreferenceDao providerPreferenceDao = (ProviderPreferenceDao) SpringUtils.getBean("providerPreferenceDao");

    //otherwise, use the preferences of the logged in user
    providerPreference1 = providerPreferenceDao.find(curUser_no);

    String providerDefaultBillForm = oscarVariables.getProperty("default_view");

    if ( (providerPreference1 != null) && (providerPreference1.getDefaultServiceType() != null) && !(providerPreference1.getDefaultServiceType().equalsIgnoreCase("no")) ) {
        providerDefaultBillForm = providerPreference1.getDefaultServiceType();
    }

%>


<%@page import="oscar.util.*"%>
<%@page import="oscar.oscarDB.*"%>

<%@page import="oscar.appt.JdbcApptImpl"%>
<%@page import="oscar.appt.ApptUtil"%>
<%@page import="org.oscarehr.common.dao.SiteDao"%>
<%@page import="org.oscarehr.common.model.Site"%>
<%@page import="org.oscarehr.web.admin.ProviderPreferencesUIBean"%>
<%@page import="org.oscarehr.common.model.ProviderPreference"%>
<%@page import="org.oscarehr.web.AppointmentProviderAdminDayUIBean"%>
<%@page import="org.oscarehr.common.model.EForm"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<html:html locale="true">

<head>
<link rel="shortcut icon" href="<%=request.getContextPath()%>/images/Oscar.ico">
<script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
<title><%=WordUtils.capitalize(userlastname + ", " +  org.apache.commons.lang.StringUtils.substring(userfirstname, 0, 1)) + "-"%><bean:message key="provider.appointmentProviderAdminDay.title"/></title>

<!-- Determine which stylesheet to use: mobile-optimized or regular -->
<%
	boolean isMobileOptimized = session.getAttribute("mobileOptimized") != null;
if (isMobileOptimized) {
%>
    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width"/>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/mobile/receptionistapptstyle.css" type="text/css">
<%
	} else {
%>
<!-- <link rel="stylesheet" href="<%=request.getContextPath()%>/css/receptionistapptstyle.css" type="text/css">-->
<!-- <link rel="stylesheet" href="<%=request.getContextPath()%>/css/helpdetails.css" type="text/css"> -->
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
<style>
body {
	font-family: "Arial";
}

table {
    border: 0px;
    padding: 0px;
    border-spacing: 0px;
}

th, td {
    padding: 0px;
}

#logo {
    width: 50px;
    vertical-align: top;
    text-align: center;
    padding-top: 8px;
}

.topbar {
	font-family: "Arial";
	font-size: 13px;
    color: <%=(showClassicSchedule? "black;" : "white;")%>
    font-weight: bold;
    background-color: <%=(showClassicSchedule? "ivory;" : "steelblue;")%>
    height: 30px;
    padding: 5px 0px 0px 0px;
}

.topbar a {
    color: <%=(showClassicSchedule? "black;" : "white;")%>
    text-decoration: none;
}

.redArrow i {
    color: <%=(showClassicSchedule? "red" : "white")%>;
    font-weight: bold;
}

.topbar a:hover {
    color: <%=(showClassicSchedule? "red" : "black")%>;
}

.tabalert {
	color: <%=(showClassicSchedule? "red" : "#97ff00")%>;
}

.quick {
    border:none;
    width:20px;
    font-size:8pt;
    padding:0px;
    font-weight: bold;
    color: <%=(showClassicSchedule? "black" : "white")%>;
    background-color: <%=(showClassicSchedule? "ivory" : "steelblue")%>;
}

.quick:hover {
    color: <%=(showClassicSchedule? "red" : "black")%>;
    cursor: pointer;
}

#theday {
    color: <%=(showClassicSchedule? "black" : "white")%>;
}

#theday:hover {
    color: <%=(showClassicSchedule? "red" : "black")%>;
    cursor: pointer;
}


#navlist{
    margin: 0;
    padding: 0;
    white-space: nowrap;
}

#navlist li {
    padding-top: 0.5px;
    padding-bottom: 0.5px;
    padding-left: 3px;
    padding-right: 3px;
    display: inline;
}

#navlist li:hover { color:  <%=(showClassicSchedule? "red" : "red")%>; }
#navlist li a:hover { color:  <%=(showClassicSchedule? "red" : "black")%>; }
#navlist #logoutMobile { display:none; }

.dropdown {
	display: inline-block !important;
	position: relative;
}

.dashboardDropdown {
    display: none;
    position: absolute;
    background-color: #f9f9f9;
    min-width: 160px;
    box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
}

.dashboardDropdown a {
    color: black;
    text-decoration: none;
    display: block;
    text-align: left;
	padding:2px 5px;
}

.dropdown:hover .dashboardDropdown {
    display: block;
}


#providerSchedule {
    background-color: <%=(showClassicSchedule? "#486ebd;" : "gainsboro;")%>
	font-weight: bold;
	font-size: 13px;
    border-spacing: 0px 1px;
}

#providerSchedule a {
    text-decoration: none;
}

#integratorMessageCount {
	color: #bf6cf7 !important;
	font-weight: bold !important;
}

.infirmaryView {
	font-size: 15px;
    padding: 2px;
}
.infirmaryView a {
    color: black;
    text-decoration: none;
}

.scheduleTime00, .scheduleTimeNot00{
    width:3%;
    padding: 2px 4px;
}

.scheduleTime00 {
    background-color: <%=(showClassicSchedule? "#3EA4E1;" : "gainsboro;")%>
}
.scheduleTimeNot00 {
    background-color: <%=(showClassicSchedule? "#00A488;" : "#E8E8E8;")%>
}

.scheduleTime00 a, .scheduleTimeNot00 a {
    color: <%=(showClassicSchedule? "white" : "#606060")%>
}
.appt a { color: black; }  //best to leave it black

.dateAppointment a {

	hover: black!important;

}

.bottombar {
    font-family: "Arial";
	font-size: 13px;
    color: <%=(showClassicSchedule? "black;" : "white;")%>
    font-weight: bold;
    height: 30px;
    padding: 3px;
    background-color: <%=(showClassicSchedule? "ivory;" : "steelblue;")%>
}
.Cancelled.hideMe {
    display:none !important;
}
@media print {
 .noprint {display:none !important;}
}

</style>
<%

	}
%>

<%
	if (!caseload) {
%>
<c:if test="${empty sessionScope.archiveView or sessionScope.archiveView != true}">
<%!String refresh = oscar.OscarProperties.getInstance().getProperty("refresh.appointmentprovideradminday.jsp", "-1");%>
	<%
		String thisRequestUrl = request.getRequestURL().toString() + (StringUtils.isEmpty(request.getQueryString()) ? "" : "?" + request.getQueryString());
		if (!thisRequestUrl.contains("&autoRefresh=true")) {
			thisRequestUrl += "&autoRefresh=true";
		}
	%>
<%="-1".equals(refresh)?"":"<meta http-equiv=\"refresh\" content=\""+refresh+"; url="+thisRequestUrl+"\">"%>
</c:if>
<%
	}
%>

<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/Oscar.js" ></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/javascript/prototype.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/phr/phr.js"></script>

<script src="<c:out value="../library/jquery/jquery-3.6.4.min.js"/>"></script>
<script>
	jQuery.noConflict();
</script>

<oscar:customInterface section="main"/>

<script type="text/javascript" src="schedulePage.js.jsp?autoRefresh=true"></script>


<script type="text/javascript">

function pop1(url) {
  return pop4(700, 1024, url, "oscar_appt");
}

function pop2(url, windowName) {
  return pop4(700, 1024, url, windowName);
}

function pop3(vheight, vwidth, varpage) {
  return pop4(vheight, vwidth, varpage, "oscar_appt");
}

function pop4(vheight, vwidth, varpage, windowName) { //open a new popup window
    windowName  = typeof(windowName)!= 'undefined' ? windowName : 'apptProviderSearch';
<% if (!openInTabs) { %>
    vheight     = typeof(vheight)   != 'undefined' ? vheight : '700px';
    vwidth      = typeof(vwidth)    != 'undefined' ? vwidth : '1024px';
    var page = "" + varpage;
    var page = varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
    var popup=window.open(varpage, windowName, windowprops);
    if (popup != null) {
        if (popup.opener == null) {
            popup.opener = self;
        }
    }
<% } else { %>
  window.open(varpage,windowName);
<% } %>
}

function pop4WithApptNo(vheight,vwidth,varpage,windowName,apptNo) {
    if (apptNo) storeApptNo(apptNo);
    pop4(vheight, vwidth, varpage, windowName);
}

function goDate(aDate){
    if (calendar.dateClicked) {
        //OK this was not just a change in the month/year
	// initialize array and get values
	initializeQSArray();
	getQSValues();

    // parse the date string
    var res = aDate.split('-');
    if (res.length!=3) { alert("BAD Date"); return;}

	// build the new location string
	destination  = 'providercontrol.jsp?year=' + res[0] + '&month='+ res[1] +'&day='+res[2]+'&view=' +qsParm['view']+ '&curProvider='+qsParm['curProvider']+'&curProviderName='+qsParm['curProviderName'] + '&displaymode='+qsParm['displaymode']+'&dboperation='+qsParm['dboperation']

	// move the calendar to the new date
	window.location = destination;
}

}



// calendar shortcuts
function getLocation(ID,Multiplier){
	// initialize array
	initializeQSArray();

	// get query string values
	getQSValues();

	// create the current date - note months are 0 based --> 0-11
	var dateSelected=new Date(qsParm['year'],qsParm['month']-1,qsParm['day']);

	// set the item type and value to be added
	switch (ID)
	{
		case 'dayForward':
			itemType = 'd';
			valueToAdd = Multiplier;
			break;
		case 'weekBackward':
			itemType = 'w';
			// negative * 7 days * weeks
			valueToAdd = -1 * Multiplier;
			break;
		case 'weekForward':
			itemType = 'w';
			valueToAdd = Multiplier;
			break;
		case 'monthBackward':
			itemType = 'm';
			valueToAdd = -1 * Multiplier;
			break;
		case 'monthForward':
			itemType = 'm';
			valueToAdd = Multiplier;
			break;
	}

    //get new date
        dateDestination = DateAdd(itemType, dateSelected, valueToAdd);


    if (ID == "m"){
	    // check the day of the new date - if Saturday or Sunday move to the following Monday
	    var DayID = dateDestination.getDay();
	    switch (DayID)
	    {
		    case 0: // Sunday
			    dateDestination = DateAdd('d', dateDestination, 1);
			    break;
		    case 6: // Saturday
			    dateDestination = DateAdd('d', dateDestination, 2);
			    break;
	    }
    }

	// build the new location string
	destination  = 'providercontrol.jsp?year=' + dateDestination.getFullYear() + '&month='+ getMonthNumber(dateDestination.getMonth()) +'&day='+dateDestination.getDate()+'&view=' +qsParm['view']+ '&curProvider='+qsParm['curProvider']+'&curProviderName='+qsParm['curProviderName'] + '&displaymode='+qsParm['displaymode']+'&dboperation='+qsParm['dboperation']
	// move the calendar to the new date

	window.location = destination;
}

// get the querystring values from the url and put them in the array
function getQSValues()
{
	var query = window.location.search.substring(1);
	var parms = query.split('&');
	var key;
	var val;

	for (var i=0; i<parms.length; i++)
	{
		var pos = parms[i].indexOf('=');
		if (pos > 0)
		{
			key = parms[i].substring(0,pos);
			val = parms[i].substring(pos+1);
			qsParm[key] = val;
		}
	}
}

var qsParm = new Array();

function initializeQSArray() {

     //initialize array
	qsParm['year'] = null;
	qsParm['month'] = null;
	qsParm['day'] = null;
	qsParm['view'] = null;
	qsParm['curProvider'] = null;
	qsParm['curProviderName'] = null;
	qsParm['displaymode'] = null;
	qsParm['dboperation'] = null;
}

function getMonthNumber(month) {
	// add 1 to the month for the oscar querystring
    return month + 1;
}

function DateAdd(ItemType, DateToWorkOn, ValueToBeAdded) {
    switch (ItemType)
    {
        case 'd': //add days
            DateToWorkOn.setDate(DateToWorkOn.getDate() + ValueToBeAdded);
            break;
        case 'w': //add weeks
			ValueToBeAdded = ValueToBeAdded*7;
            DateToWorkOn.setDate(DateToWorkOn.getDate() + ValueToBeAdded);
            break;
        case 'm': //add months
            DateToWorkOn.setMonth(DateToWorkOn.getMonth() + parseInt(ValueToBeAdded));
            break;
        case 'y': //add years
            DateToWorkOn.setYear(DateToWorkOn.getFullYear() + ValueToBeAdded);
            break;
        //time portion
        case 'h': //add hours
            DateToWorkOn.setHours(DateToWorkOn.getHours() + ValueToBeAdded);
            break;
        case 'n': //add minutes
            DateToWorkOn.setMinutes(DateToWorkOn.getMinutes() + ValueToBeAdded);
            break;
        case 's': //add seconds
            DateToWorkOn.setSeconds(DateToWorkOn.getSeconds() + ValueToBeAdded);
            break;

    }
    return DateToWorkOn;
}

// end calendar shortcuts

function changeGroup(s) {
var newGroupNo = s.options[s.selectedIndex].value;
if(newGroupNo.indexOf("_grp_") != -1) {
  newGroupNo = s.options[s.selectedIndex].value.substring(5);
}else{
  newGroupNo = s.options[s.selectedIndex].value;
}
<%if (org.oscarehr.common.IsPropertiesOn.isCaisiEnable() && org.oscarehr.common.IsPropertiesOn.isTicklerPlusEnable()){%>
	//Disable schedule view associated with the program
	//Made the default program id "0";
	//var programId = document.getElementById("bedprogram_no").value;
	var programId = 0;
	var programId_forCME = document.getElementById("bedprogram_no").value;

	popupPage(10,10, "providercontrol.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&caisiBillingPreferenceNotDelete=<%=caisiBillingPreferenceNotDelete%>&new_tickler_warning_window=<%=newticklerwarningwindow%>&default_pmm=<%=default_pmm%>&color_template=deepblue&dboperation=updatepreference&displaymode=updatepreference&default_servicetype=<%=defaultServiceType%>&prescriptionQrCodes=&erx_enable=<%=erx_enable%>&erx_training_mode=<%=erx_training_mode%>&mygroup_no="+newGroupNo+"&programId_oscarView="+programId+"&case_program_id="+programId_forCME + "<%=eformIds.toString()%><%=ectFormNames.toString()%>");
<%}else {%>
  var programId=0;
  popupPage(10,10, "providercontrol.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&color_template=deepblue&dboperation=updatepreference&displaymode=updatepreference&default_servicetype=<%=defaultServiceType%>&prescriptionQrCodes=&erx_enable=<%=erx_enable%>&erx_training_mode=<%=erx_training_mode%>&mygroup_no="+newGroupNo+"&programId_oscarView="+programId + "<%=eformIds.toString()%><%=ectFormNames.toString()%>");
<%}%>
}

function ts1(s) {
popupPage(790,790,('<%=request.getContextPath()%>/appointment/addappointment.jsp?'+s));
}
function tsr(s) {
popupPage(790,790,('<%=request.getContextPath()%>/appointment/appointmentcontrol.jsp?displaymode=edit&dboperation=search&'+s));
}
function goFilpView(s) {
self.location.href = "<%=request.getContextPath()%>/schedule/scheduleflipview.jsp?originalpage=<%=request.getContextPath()%>/provider/providercontrol.jsp&startDate=<%=year+"-"+month+"-"+day%>" + "&provider_no="+s ;
}
function goWeekView(s) {
self.location.href = "providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=day%>&view=0&displaymode=day&dboperation=searchappointmentday&viewall=1&provider_no="+s;
}
function goZoomView(s, n) {
self.location.href = "providercontrol.jsp?year=<%=strYear%>&month=<%=strMonth%>&day=<%=strDay%>&view=1&curProvider="+s+"&curProviderName="+encodeURIComponent(n)+"&displaymode=day&dboperation=searchappointmentday" ;
}
function findProvider(p,m,d) {
popupPage(400,500, "receptionistfindprovider.jsp?pyear=" +p+ "&pmonth=" +m+ "&pday=" +d+ "&providername="+ document.findprovider.providername.value );
}
function goSearchView(s) {
	popupPage(600,650,"<%=request.getContextPath()%>/appointment/appointmentsearch.jsp?provider_no="+s);
}

function review(key) {
	  if(self.location.href.lastIndexOf("?") > 0) {
	    if(self.location.href.lastIndexOf("&viewall=") > 0 ) a = self.location.href.substring(0,self.location.href.lastIndexOf("&viewall="));
	    else a = self.location.href;
	  } else {
	    a="providercontrol.jsp?year="+document.jumptodate.year.value+"&month="+document.jumptodate.month.value+"&day="+document.jumptodate.day.value+"&view=0&displaymode=day&dboperation=searchappointmentday&site=" + "<%=(selectedSite==null? "none" : selectedSite)%>";
	  }
	  self.location.href = a + "&viewall="+key ;
	}


</script>


<%
	if (OscarProperties.getInstance().getBooleanProperty("indivica_hc_read_enabled", "true")) {
%>
<script src="<%=request.getContextPath()%>/hcHandler/hcHandler.js"></script>
<script src="<%=request.getContextPath()%>/hcHandler/hcHandlerAppointment.js"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/hcHandler/hcHandler.css" type="text/css" />
<%
	}
%>
<% if (!showLargeCalendar) { %>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/calendar/calendar.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/share/calendar/calendar-setup.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/share/calendar/calendar.css" title="win2k-cold-2" />
<% } %>


</head>
<%
	if (org.oscarehr.common.IsPropertiesOn.isCaisiEnable()){
%>
<body  onload="load();" topmargin="0" leftmargin="0" rightmargin="0">
<%
	}else{
%>
<body  onLoad="refreshAllTabAlerts();scrollOnLoad();" topmargin="0" leftmargin="0" rightmargin="0">
<%
	}
%>

<%
	boolean isTeamScheduleOnly = false;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_team_schedule_only" rights="r" reverse="false">
<%
	isTeamScheduleOnly = true;
%>
</security:oscarSec>
<%
	int numProvider=0, numAvailProvider=0;
String [] curProvider_no;
String [] curProviderName;
//initial provider bean for all the application
if(providerBean.isEmpty()) {
	for(Provider p : providerDao.getActiveProviders()) {
		 providerBean.setProperty(p.getProviderNo(),p.getFormattedName());
	}
 }

String viewall = request.getParameter("viewall");
if( viewall == null ) {
    viewall = "0";
}
String _scheduleDate = strYear+"-"+strMonth+"-"+strDay;

List<Map<String,Object>> resultList = null;

if(mygroupno != null && providerBean.get(mygroupno) != null) { //single appointed provider view
     numProvider=1;
     curProvider_no = new String [numProvider];
     curProviderName = new String [numProvider];
     curProvider_no[0]=mygroupno;

     curProviderName[0]=providerDao.getProvider(mygroupno).getFullName();

} else {
	if(view==0) { //multiple views
	   if (selectedSite!=null) {
		   numProvider = siteDao.site_searchmygroupcount(mygroupno, selectedSite).intValue();
	   }
	   else {
		   numProvider = myGroupDao.getGroupByGroupNo(mygroupno).size();
	   }


       String [] param3 = new String [2];
       param3[0] = mygroupno;
       param3[1] = strDate; //strYear +"-"+ strMonth +"-"+ strDay ;
       numAvailProvider = 0;
       if (selectedSite!=null) {
    	    List<String> siteProviders = providerSiteDao.findByProviderNoBySiteName(selectedSite);
    	  	List<ScheduleDate> results = scheduleDateDao.search_numgrpscheduledate(mygroupno, ConversionUtils.fromDateString(strDate));

    	  	for(ScheduleDate result:results) {
    	  		if(siteProviders.contains(result.getProviderNo())) {
    	  			numAvailProvider++;
    	  		}
    	  	}
       }
       else {
    	   	numAvailProvider = scheduleDateDao.search_numgrpscheduledate(mygroupno, ConversionUtils.fromDateString(strDate)).size();

       }

     // _team_schedule_only does not support groups
     // As well, the mobile version only shows the schedule of the login provider.
     if(numProvider==0 || isTeamScheduleOnly || isMobileOptimized) {
       numProvider=1; //the login user
       curProvider_no = new String []{curUser_no};  //[numProvider];
       curProviderName = new String []{(userlastname+", "+userfirstname)}; //[numProvider];
     } else {
       if(request.getParameter("viewall")!=null && request.getParameter("viewall").equals("1") ) {
         if(numProvider >= 6) {lenLimitedL = 6; lenLimitedS = 3; }
       } else {
         if(numAvailProvider >= 7) {lenLimitedL = 6; lenLimitedS = 3; }
         if(numAvailProvider == 6) {lenLimitedL = 10; lenLimitedS = 6; }
         if(numAvailProvider == 5) {lenLimitedL = 15; lenLimitedS = 10; len = 10;}
         if(numAvailProvider == 4) {lenLimitedL = 20; lenLimitedS = 13; len = 20;}
         if(numAvailProvider == 3) {lenLimitedL = 30; lenLimitedS = 20; len = 30;}
         if(numAvailProvider <= 2) {lenLimitedL = 30; lenLimitedS = 30; len = 30;}
       }
      UserProperty uppatientNameLength = userPropertyDao.getProp(curUser_no, UserProperty.PATIENT_NAME_LENGTH);
      int NameLength=0;

      if ( uppatientNameLength != null && uppatientNameLength.getValue() != null) {
          try {
             NameLength=Integer.parseInt(uppatientNameLength.getValue());
          } catch (NumberFormatException e) {
             NameLength=0;
          }

          if(NameLength>0) {
             len=lenLimitedS= lenLimitedL = NameLength;
          }
                   }
     curProvider_no = new String [numProvider];
     curProviderName = new String [numProvider];

     int iTemp = 0;
     if (selectedSite!=null) {
    	 List<String> siteProviders = providerSiteDao.findByProviderNoBySiteName(selectedSite);
    	 List<MyGroup> results = myGroupDao.getGroupByGroupNo(mygroupno);
    	 for(MyGroup result:results) {
    		 if(siteProviders.contains(result.getId().getProviderNo())) {
    			 curProvider_no[iTemp] = String.valueOf(result.getId().getProviderNo());

    			 Provider p = providerDao.getProvider(curProvider_no[iTemp]);
    			 if (p!=null) {
    				 curProviderName[iTemp] = p.getFullName();
    			 }
        	     iTemp++;
    		 }
    	 }
     }
     else {
    	 List<MyGroup> results = myGroupDao.getGroupByGroupNo(mygroupno);
    	 Collections.sort(results,MyGroup.MyGroupNoViewOrderComparator);

    	 for(MyGroup result:results) {
    		 curProvider_no[iTemp] = String.valueOf(result.getId().getProviderNo());

    		 Provider p = providerDao.getProvider(curProvider_no[iTemp]);
    		 if (p!=null) {
        		 curProviderName[iTemp] = p.getFullName();
    		 }
    	     iTemp++;
    	 }
     }


    }
   } else { //single view
     numProvider=1;
     curProvider_no = new String [numProvider];
     curProviderName = new String [numProvider];
     curProvider_no[0]=request.getParameter("curProvider");
     curProviderName[0]=request.getParameter("curProviderName");
   }
}
//set timecode bean
String bgcolordef = "gray" ;
String [] param3 = new String[2];
param3[0] = strDate;
for(nProvider=0;nProvider<numProvider;nProvider++) {
     param3[1] = curProvider_no[nProvider];
     List<Object[]> results = scheduleDateDao.search_appttimecode(ConversionUtils.fromDateString(strDate), curProvider_no[nProvider]);
     for(Object[] result:results) {
    	 ScheduleTemplate st = (ScheduleTemplate)result[0];
    	 ScheduleDate sd = (ScheduleDate)result[1];
    	 dateTimeCodeBean.put(sd.getProviderNo(), st.getTimecode());
     }

}

	for(ScheduleTemplateCode stc : scheduleTemplateCodeDao.findAll()) {

     dateTimeCodeBean.put("description"+stc.getCode(), stc.getDescription());
     dateTimeCodeBean.put("duration"+stc.getCode(), stc.getDuration());
     dateTimeCodeBean.put("color"+stc.getCode(), (stc.getColor()==null || "".equals(stc.getColor()))?bgcolordef:stc.getColor());
     dateTimeCodeBean.put("confirm" + stc.getCode(), stc.getConfirm());
   }

java.util.Locale vLocale =(java.util.Locale)session.getAttribute(org.apache.struts.Globals.LOCALE_KEY);
%>


<table WIDTH="100%" id="firstTable" class="noprint topbar">
<tr>
<td rowspan=2 id="logo" >&nbsp;
<%if("true".equals(OscarProperties.getInstance().getProperty("newui.enabled", "false"))) { %>
	<a href="<%=request.getContextPath()%>/web/" title="OSCAR EMR"><img src="<%=request.getContextPath()%>/images/oscar_logo_small.png" width="30" height="30" border="0"></a>
<% } else { %>
    <a href="#" ONCLICK ="pop1('<%=resourcebaseurl%>');return false;" title="<bean:message key="provider.appointmentProviderAdminDay.viewResources"/>" onmouseover="window.status='<bean:message key="provider.appointmentProviderAdminDay.viewResources"/>';return true" title="<bean:message key="oscarEncounter.Index.clinicalResources"/>">
	<img src="<%=request.getContextPath()%>/images/oscar_logo_small.png" width="30" height="30"  border="0"></a>
<% } %>&nbsp;
</td>
<td id="firstMenu">
<ul id="navlist">&nbsp;
<logic:notEqual name="infirmaryView_isOscar" value="false">
<% if(request.getParameter("viewall")!=null && request.getParameter("viewall").equals("1") && caseload) { %>
         <li>
         <a href=# onClick = "review('0')" title="<bean:message key="provider.appointmentProviderAdminDay.viewProvAval"/>"><bean:message key="provider.appointmentProviderAdminDay.schedView"/></a>
         </li>
 <% } else {
    if (caseload) {
 %>
 <li>
 <a href='providercontrol.jsp?year=<%=curYear%>&month=<%=curMonth%>&day=<%=curDay%>&view=0&displaymode=day&dboperation=searchappointmentday&viewall=1'><bean:message key="provider.appointmentProviderAdminDay.schedView"/></a>
 </li>

<% } } %>
</logic:notEqual>

 <% if (!caseload) { %>
 <li>
 <a href='providercontrol.jsp?year=<%=curYear%>&month=<%=curMonth%>&day=<%=curDay%>&view=0&displaymode=day&dboperation=searchappointmentday&caseload=1&clProv=<%=curUser_no%>'><bean:message key="global.caseload"/></a>
 </li>
<% } %>

<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
 <security:oscarSec roleName="<%=roleName$%>" objectName="_resource" rights="r">

 </security:oscarSec>
</caisi:isModuleLoad>

 <%
 	if (isMobileOptimized) {
 %>
        <!-- Add a menu button for mobile version, which opens menu contents when clicked on -->
        <li id="menu"><a class="leftButton top" onClick="showHideItem('navlistcontents');">
                <bean:message key="global.menu" /></a>
            <ul id="navlistcontents" style="display:none;">
<% } %>


<security:oscarSec roleName="<%=roleName$%>" objectName="_search" rights="r">
 <li id="search">
    <caisi:isModuleLoad moduleName="caisi">
    	<%
    		String caisiSearch = oscarVariables.getProperty("caisi.search.workflow", "true");
    		if("true".equalsIgnoreCase(caisiSearch)) {
    	%>
    	<a HREF="<%=request.getContextPath()%>/PMmodule/ClientSearch2.do" TITLE='<bean:message key="global.searchPatientRecords"/>' OnMouseOver="window.status='<bean:message key="global.searchPatientRecords"/>' ; return true"><bean:message key="provider.appointmentProviderAdminDay.search"/></a>

    	<%
    		} else {
    	%>
       	 <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/demographic/search.jsp','search');return false;"  TITLE='<bean:message key="global.searchPatientRecords"/>' OnMouseOver="window.status='<bean:message key="global.searchPatientRecords"/>' ; return true"><bean:message key="provider.appointmentProviderAdminDay.search"/></a>
   	<% } %>
    </caisi:isModuleLoad>
    <caisi:isModuleLoad moduleName="caisi" reverse="true">
       <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/demographic/search.jsp','search');return false;"  TITLE='<bean:message key="global.searchPatientRecords"/>' OnMouseOver="window.status='<bean:message key="global.searchPatientRecords"/>' ; return true"><bean:message key="provider.appointmentProviderAdminDay.search"/></a>
    </caisi:isModuleLoad>
</li>
</security:oscarSec>

<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
<security:oscarSec roleName="<%=roleName$%>" objectName="_report" rights="r">
<li>
    <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/report/reportindex.jsp','reportPage');return false;"   TITLE='<bean:message key="global.genReport"/>' OnMouseOver="window.status='<bean:message key="global.genReport"/>' ; return true"><bean:message key="global.report"/></a>
</li>
</security:oscarSec>
<oscar:oscarPropertiesCheck property="NOT_FOR_CAISI" value="no" defaultVal="true">

<security:oscarSec roleName="<%=roleName$%>" objectName="_billing" rights="r">
<li>
	<a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/billing/CA/<%=prov%>/billingReportCenter.jsp?displaymode=billreport&providerview=<%=curUser_no%>','BillingReports');return false;" TITLE='<bean:message key="global.genBillReport"/>' onMouseOver="window.status='<bean:message key="global.genBillReport"/>';return true"><bean:message key="global.billing"/></a>
</li>
</security:oscarSec>


<%--
////////////////////
// Tom Le
// 2020-05-12 - Tom Le added this section notify the user that there is new fax
////////////////////
--%>
<%
String dirStr = OscarProperties.getInstance().getProperty("INCOMINGDOCUMENT_DIR");
if (dirStr != null) {
    try {
        File incomingFaxDir = new File( dirStr+"/1/Fax/");

        File[] files = incomingFaxDir.listFiles();
        File[] faxDirFiles = incomingFaxDir.listFiles();

        if ( (files != null) && (files.length > 0) ) {
%>
<oscar:oscarPropertiesCheck property="SHOW_INCOMING_FAXES" value="yes" defaultVal="true">
	<security:oscarSec roleName="<%=roleName$%>" objectName="_eDoc" rights="r">
	<li>
    	<a class="tabalert" HREF="#" ONCLICK ="popupPage(940,1200,'../dms/incomingDocs.jsp','<bean:message key='inboxmanager.document.incomingDocs'/>');return false;" TITLE='<bean:message key="inboxmanager.document.incomingDocs"/>'>
    	<span id="oscar_incomingdocs" class="tabalert"><bean:message key='dms.incomingDocs.fax'/><sup><%=faxDirFiles.length%></sup></a></span>
	</li>
	</security:oscarSec>
</oscar:oscarPropertiesCheck>
<%
}
       } catch (FileNotFoundException e) {
            MiscUtils.getLogger().error("Error", e);
        }

} %>
<%--
////////////////////
--%>


<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment.doctorLink" rights="r">
   <li>
       <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/dms/inboxManage.do?method=prepareForIndexPage&providerNo=<%=curUser_no%>', 'Lab');return false;" TITLE='<bean:message key="provider.appointmentProviderAdminDay.viewLabReports"/>'>
	   <span id="oscar_new_lab"><bean:message key="global.lab"/></span>
       </a>
       <oscar:newUnclaimedLab>
       <a class="tabalert" HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/dms/inboxManage.do?method=prepareForIndexPage&providerNo=0&searchProviderNo=0&status=N&lname=&fname=&hnum=&pageNum=1&startIndex=0', 'Lab');return false;" TITLE='<bean:message key="provider.appointmentProviderAdminDay.viewLabReports"/>'>*</a>
       </oscar:newUnclaimedLab>
   </li>
  </security:oscarSec>

<security:oscarSec roleName="<%=roleName$%>" objectName="_hrm,_admin.hrm,_hrm.administrator" rights="r">
   <li>
       <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/hospitalReportManager/inbox.jsp', 'HRM');return false;" TITLE='HRM'>
	  	HRM
       </a>
   </li>
  </security:oscarSec>

</oscar:oscarPropertiesCheck>

 </caisi:isModuleLoad>

 <caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
 	<security:oscarSec roleName="<%=roleName$%>" objectName="_msg" rights="r">
     <li>
	 <a HREF="#" ONCLICK ="pop4(600,1024,'<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.do?providerNo=<%=curUser_no%>&userName=<%=URLEncoder.encode(userfirstname+" "+userlastname)%>','Messages')" title="<bean:message key="global.messenger"/>">
	 <span id="oscar_new_msg"><bean:message key="global.msg"/></span></a>
     </li>
   	</security:oscarSec>
 </caisi:isModuleLoad>
<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
<security:oscarSec roleName="<%=roleName$%>" objectName="_con" rights="r">
<%


	UserProperty consultsDefaultFilter = propDao.getProp(curUser_no, UserProperty.CONSULTS_DEFAULT_FILTER);
	String consultsDefaultFilterUrl = "../oscarEncounter/IncomingConsultation.do?providerNo="+curUser_no+"&userName="+URLEncoder.encode(userfirstname+" "+userlastname);
	if ( consultsDefaultFilter != null && consultsDefaultFilter.getValue() != null && !consultsDefaultFilter.getValue().trim().equals("")){
		consultsDefaultFilterUrl = "../oscarEncounter/ViewConsultation.do?"+consultsDefaultFilter.getValue();
	}

%>
<li id="con">
 <a HREF="#" ONCLICK ="pop4(625,1224,'<%=consultsDefaultFilterUrl%>','con_req')" title="<bean:message key="provider.appointmentProviderAdminDay.viewConReq"/>">
 <span id="oscar_aged_consults"><bean:message key="global.con"/></span></a>
</li>
</security:oscarSec>
</caisi:isModuleLoad>

<%-- EConsult cannot be logged into without a link, no sense in showing it --%>
 <%
	 boolean hide_eConsult = OscarProperties.getInstance().isPropertyActive("hide_eConsult_link");
	 if("on".equalsIgnoreCase(prov) && !hide_eConsult){
 %>
	 <li id="econ">
		<a href="#" onclick ="pop4(625, 1024, '<%=request.getContextPath()%>/econsult.do?method=frontend&task=physicianSummary','econ')" title="eConsult">
	 	<span>eConsult</span></a>
	</li>
<% 	} %>

<%if(!StringUtils.isEmpty(OscarProperties.getInstance().getProperty("clinicalConnect.CMS.url",""))) { %>
<li id="clinical_connect">
	<a href="#" onclick ="pop4(625, 1024, '<%=request.getContextPath()%>/clinicalConnectEHRViewer.do?method=launchNonPatientContext','clinical_connect')" title="clinical connect EHR viewer">
 	<span>ClinicalConnect</span></a>
</li>
<%}%>

<security:oscarSec roleName="<%=roleName$%>" objectName="_pref" rights="r">
<li>    <!-- remove this and let providerpreference check -->
    <caisi:isModuleLoad moduleName="ticklerplus">
	<a href=# onClick ="pop3(715,680,'providerpreference.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&mygroup_no=<%=mygroupno%>&new_tickler_warning_window=<%=newticklerwarningwindow%>&default_pmm=<%=default_pmm%>&caisiBillingPreferenceNotDelete=<%=caisiBillingPreferenceNotDelete%>&tklerproviderno=<%=tklerProviderNo%>');return false;" TITLE='<bean:message key="provider.appointmentProviderAdminDay.msgSettings"/>' OnMouseOver="window.status='<bean:message key="provider.appointmentProviderAdminDay.msgSettings"/>' ; return true"><bean:message key="global.pref"/></a>
    </caisi:isModuleLoad>
    <caisi:isModuleLoad moduleName="ticklerplus" reverse="true">
	<a href=# onClick ="pop3(715,1005,'providerpreference.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&mygroup_no=<%=mygroupno%>');return false;" TITLE='<bean:message key="provider.appointmentProviderAdminDay.msgSettings"/>' OnMouseOver="window.status='<bean:message key="provider.appointmentProviderAdminDay.msgSettings"/>' ; return true"><bean:message key="global.pref"/></a>
    </caisi:isModuleLoad>
</li>
</security:oscarSec>
 <caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
<security:oscarSec roleName="<%=roleName$%>" objectName="_edoc" rights="r">
<li>
   <a HREF="#" onclick="pop4('700', '1024', '<%=request.getContextPath()%>/dms/documentReport.jsp?function=provider&functionid=<%=curUser_no%>&curUser=<%=curUser_no%>', 'edocView');" TITLE='<bean:message key="provider.appointmentProviderAdminDay.viewEdoc"/>'><bean:message key="global.edoc"/></a>
</li>
</security:oscarSec>
 </caisi:isModuleLoad>
 <security:oscarSec roleName="<%=roleName$%>" objectName="_tickler" rights="r">
<li>
   <caisi:isModuleLoad moduleName="ticklerplus" reverse="true">
    <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/tickler/ticklerMain.jsp','<bean:message key="global.tickler"/>');return false;" TITLE='<bean:message key="global.tickler"/>'>
	<span id="oscar_new_tickler"><bean:message key="global.btntickler"/></span></a>
   </caisi:isModuleLoad>
   <caisi:isModuleLoad moduleName="ticklerplus">
    <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/Tickler.do?filter.assignee=<%=curUser_no%>&filter.demographic_no=&filter.demographic_webName=','<bean:message key="global.tickler"/>');return false;" TITLE='<bean:message key="global.tickler"/>'+'+'>
	<span id="oscar_new_tickler"><bean:message key="global.btntickler"/></span></a>
   </caisi:isModuleLoad>
</li>
</security:oscarSec>
<oscar:oscarPropertiesCheck property="OSCAR_LEARNING" value="yes">
<li>
    <a HREF="#" ONCLICK ="pop2('<%=request.getContextPath()%>/oscarLearning/CourseView.jsp','<bean:message key="global.courseview"/>');return false;" TITLE='<bean:message key="global.courseview"/>'>
	<span id="oscar_courseview"><bean:message key="global.btncourseview"/></span></a>
</li>
</oscar:oscarPropertiesCheck>

<oscar:oscarPropertiesCheck property="referral_menu" value="yes">
<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.misc" rights="r">
<li id="ref">
 <a href="#" onclick="pop4(550,800,'<%=request.getContextPath()%>/oscarEncounter/oscarConsultationRequest/config/EditSpecialists.jsp','bill_ref');return false;"><bean:message key="global.manageReferrals"/></a>
</li>
</security:oscarSec>
</oscar:oscarPropertiesCheck>

<oscar:oscarPropertiesCheck property="WORKFLOW" value="yes">
   <li><a href="javascript: function myFunction() {return false; }" onClick="popup(700,1024,'<%=request.getContextPath()%>/oscarWorkflow/WorkFlowList.jsp','<bean:message key="global.workflow"/>')"><bean:message key="global.btnworkflow"/></a></li>
</oscar:oscarPropertiesCheck>

    <myoscar:indivoRegistered provider="<%=curUser_no%>">
		<%
			MyOscarUtils.attemptMyOscarAutoLoginIfNotAlreadyLoggedInAsynchronously(loggedInInfo1, false);
		%>
	    <li>
			<a HREF="#" ONCLICK ="pop4('600', '1024','<%=request.getContextPath()%>/phr/PhrMessage.do?method=viewMessages','INDIVOMESSENGER2<%=curUser_no%>')" title='<bean:message key="global.phr"/>'>
				<bean:message key="global.btnphr"/>
				<div id="unreadMessagesMenuMarker" style="display:inline-block;vertical-align:top"><!-- place holder for unread message count --></div>
			</a>
			<script type="text/javascript">
				function pollMessageCount()
				{
					jQuery('#unreadMessagesMenuMarker').load('<%=request.getContextPath()%>/phr/msg/unread_message_count.jsp?autoRefresh=true')
				}

				window.setInterval(pollMessageCount, 60000);
				window.setTimeout(pollMessageCount, 2000);
			</script>
	    </li>
	</myoscar:indivoRegistered>
    <phr:phrNotRegistered provider="<%=curUser_no%>">
    		<li>
			<a HREF="#" ONCLICK ="popup('600', '1024','<%=request.getContextPath()%>/phr/PHRSignup.jsp','INDIVOMESSENGER2<%=curUser_no%>')" title='<bean:message key="global.phr"/>'>
				<bean:message key="global.btnphr"/>
			</a>
	    </li>
    </phr:phrNotRegistered>
<%if(appManager.isK2AEnabled()){ %>
<li>
	<a href="javascript:void(0);" id="K2ALink">K2A<span><sup id="k2a_new_notifications"></sup></span></a>
	<script type="text/javascript">
		function getK2AStatus(){
			jQuery.get( "<%=request.getContextPath()%>/ws/rs/resources/notifications/number", function( data ) {
				  if(data === "-"){ //If user is not logged in
					  jQuery("#K2ALink").on( "click", function() {
						var win = window.open('<%=request.getContextPath()%>/apps/oauth1.jsp?id=K2A','appAuth','width=700,height=450,scrollbars=1');
						win.focus();
					  });
				   }else{
					  jQuery("#k2a_new_notifications").text(data);
					  jQuery("#K2ALink").on( "click", function() {
						var win = window.open('<%=request.getContextPath()%>/apps/notifications.jsp','appAuth','width=450,height=700,scrollbars=1');
						win.focus();
					  });
				   }
			});
		}
		getK2AStatus();
	</script>
</li>
<%}%>

<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
	<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.userAdmin,_admin.schedule,_admin.billing,_admin.resource,_admin.reporting,_admin.backup,_admin.messenger,_admin.eform,_admin.encounter,_admin.misc,_admin.fax" rights="r">

<li id="admin2">
 <a href="javascript:void(0)" id="admin-panel" TITLE="<bean:message key="provider.appointmentProviderAdminDay.adminTitle"/>" onclick="pop2('<%=request.getContextPath()%>/administration/','admin')"><bean:message key="provider.appointmentProviderAdminDay.admin"/></a>
</li>

</security:oscarSec>
	</caisi:isModuleLoad>

<security:oscarSec roleName="<%=roleName$%>" objectName="_dashboardDisplay" rights="r">
	<%
		DashboardManager dashboardManager = SpringUtils.getBean(DashboardManager.class);
		List<Dashboard> dashboards = dashboardManager.getActiveDashboards(loggedInInfo1);
		pageContext.setAttribute("dashboards", dashboards);
	%>

	<li id="dashboardList">
		 <div class="dropdown">
			<a href="#" class="dashboardBtn"><bean:message key="provider.appointmentProviderAdminDay.dashboard"/></a>
			<div class="dashboardDropdown">
				<c:forEach items="${ dashboards }" var="dashboard" >
					<a href="javascript:void(0)" onclick="pop2('<%=request.getContextPath()%>/web/dashboard/display/DashboardDisplay.do?method=getDashboard&dashboardId=${ dashboard.id }','dashboard')">
						<c:out value="${ dashboard.name }" />
					</a>
				</c:forEach>
				<security:oscarSec roleName="<%=roleName$%>" objectName="_dashboardCommonLink" rights="r">
					<a href="javascript:void(0)" onclick="pop2('<%=request.getContextPath()%>/web/dashboard/display/sharedOutcomesDashboard.jsp','shared_dashboard')">
						Common Provider Dashboard
					</a>
				</security:oscarSec>
			</div>

		</div>
	</li>

</security:oscarSec>

  <!-- Added logout link for mobile version
  <li id="logoutMobile">
      <a href="<%=request.getContextPath()%>/logout.jsp"><bean:message key="global.btnLogout"/></a>
  </li>
 -->

<!-- plugins menu extension point add -->
<%
	int pluginMenuTagNumber=0;
%>
<plugin:pageContextExtension serviceName="oscarMenuExtension" stemFromPrefix="Oscar"/>
<logic:iterate name="oscarMenuExtension.points" id="pt" scope="page" type="oscar.caisi.OscarMenuExtension">
<%
	if (oscar.util.plugin.IsPropertiesOn.propertiesOn(pt.getName().toLowerCase())) {
	pluginMenuTagNumber++;
%>

       <li><a href='<html:rewrite page="<%=pt.getLink()%>"/>'>
       <%=pt.getName()%></a></li>
<%
	}
%>
</logic:iterate>

<!-- plugin menu extension point add end-->

<%
	int menuTagNumber=0;
%>
<caisi:isModuleLoad moduleName="caisi">
   <li>
     <a href='<html:rewrite page="/PMmodule/ProviderInfo.do"/>'>Program</a>
     <%
     	menuTagNumber++ ;
     %>
   </li>
</caisi:isModuleLoad>

<% if (isMobileOptimized) { %>
    </ul></li> <!-- end menu list for mobile-->
<% } %>

</ul>  <!--- old TABLE -->

</td>


<td align="right" valign="bottom" >
<div class="btn-group">
	<a href="javascript: function myFunction() {return false; }" onClick="popup(700,1024,'<%=request.getContextPath()%>/scratch/index.jsp','scratch')"><i class="icon-pencil" title="<bean:message key="ScratchPad.title"/>"></i></a>&nbsp;
<a href="javascript: function myFunction() {return false; }" onClick="toggleCancelled();"><i class="icon-eye-open" title="<bean:message key="global.btnToggle"/> <bean:message key="oscar.appt.ApptStatusData.msgCanceled"/>"></i></a>&nbsp;
	<%if(resourcehelpHtml==""){ %>
		<a href="javascript:void(0)" onClick ="pop3(600,750,'<%=resourcebaseurl%>')"><i class="icon-question-sign" title="<bean:message key="app.top1"/>"></i></a>


	<%}else{%>
		<a href="javascript:void(0)" onClick ="pop3(750,750,'<%=help_url%>booking-appointment-screen/')"><i class="icon-question-sign" title="<bean:message key="app.top1"/>"></i></a>




	<%}%>
<a href="javascript:void(0)" onclick="window.open('/oscar/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,left=0,top=0')"><i class="icon-info-sign" title="<bean:message key="app.top2"/>"></i></a>

		<%  	if(loggedInInfo1.getOneIdGatewayData() != null){
				int numberOfMinutesUntilRefreshTokenIsInvalid = loggedInInfo1.getOneIdGatewayData().numberOfMinutesUntilRefreshTokenIsInvalid();
				String gtwyColor = "";
				String gtwyMsg = "Token is valid for "+numberOfMinutesUntilRefreshTokenIsInvalid+" minutes";
				if(numberOfMinutesUntilRefreshTokenIsInvalid > 10){
					//use default message;
				}else if(numberOfMinutesUntilRefreshTokenIsInvalid < 10 && numberOfMinutesUntilRefreshTokenIsInvalid > 0){
					gtwyColor = "style='color:yellow;'";
					gtwyMsg = "Token will expire soon, valid for "+numberOfMinutesUntilRefreshTokenIsInvalid+" minutes. Click here to refresh";
				}else if(numberOfMinutesUntilRefreshTokenIsInvalid < 0 && numberOfMinutesUntilRefreshTokenIsInvalid > -10){
					gtwyColor = "style='color:red'";
					gtwyMsg = "Token has expired. Click here to re-authenticate with ONE ID";
				}else{
					gtwyColor = "style='color:grey'";
					gtwyMsg = "Token has expired. Click here to re-authenticate with ONE ID";
				}
				%>
				<a href="<%=request.getContextPath()%>/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=<%=URLEncoder.encode(request.getContextPath()+"/provider/providercontrol.jsp","UTF-8") %>" <%=gtwyColor%> title="<%=gtwyMsg%>">GTWY</a>
				| <a href="uaoSelector.jsp" title="Operating under the authority of: <%=loggedInInfo1.getOneIdGatewayData().getUaoFriendlyName()%>. Click to Change">UAO</a>
				| <a target="_blank" href="<%=request.getContextPath()%>/admin/omdGatewayLog.jsp" title="Current Gateway Log">Log</a>
				| <a href="<%=request.getContextPath()%>/logoutSSO.jsp">Global Logout</a>
			<%
			}else if (request.getSession().getAttribute("oneIdEmail") != null && !request.getSession().getAttribute("oneIdEmail").equals("")) {
				if(loggedInInfo1.getOneIdGatewayData() == null){ %>
					<script>
					window.location = 'uaoSelector.jsp';
					</script>
				<%   /*?ondIdwasnull*/
					return;
				}%>

				| <a href="<%=request.getContextPath()%>/logoutSSO.jsp">Global Logout</a>
 		<% }
		   else { %>
				 &nbsp;&nbsp;&nbsp;<a href="<%=request.getContextPath()%>/logout.jsp"><i class="icon-off icon-large" title="<bean:message key="global.btnLogout"/>"></i>&nbsp;</a>
		<% } %>
</div>
</td>


</tr>



<script>
	<%if(loggedInInfo1.getOneIdGatewayData() != null && loggedInInfo1.getOneIdGatewayData().isDoubleCheckUAO()){
		%>
		if (!confirm('Operating under the authority of: <%=loggedInInfo1.getOneIdGatewayData().getUaoFriendlyName()%> Press Cancel to select another.')){
		 	window.location = 'uaoSelector.jsp';
		}
		<%
		loggedInInfo1.getOneIdGatewayData().setDoubleCheckUAO(false);
	}
	%>
	jQuery(document).ready(function(){
		jQuery.get("<%=request.getContextPath()%>/SystemMessage.do","method=view&autoRefresh=true",function(data,textStatus){
			jQuery("#system_message").html(data);
		});
		jQuery.get("<%=request.getContextPath()%>/FacilityMessage.do","method=view&autoRefresh=true",function(data,textStatus){
			jQuery("#facility_message").html(data);
		});
	});
</script>

<div id="system_message"></div>
<div id="facility_message"></div>
<%
	if (caseload) {
%>
<jsp:include page="caseload.jspf"/>
<%
	} else {
%>

<tr id="ivoryBar" class="topbar noprint">
<td colspan="3">
    <table width="100%">
        <tr class="topbar" >
        <td id="dateAndCalendar" width="43%">
         <a class="redArrow" href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=isWeekView?(day-7):(day-1)%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=day&dboperation=searchappointmentday<%=isWeekView?"&provider_no="+provNum:""%>&viewall=<%=viewall%>">
         &nbsp;&nbsp;<i class="icon-angle-left icon-large" title="<bean:message key="provider.appointmentProviderAdminDay.viewPrevDay"/>"></i></a>



 <span class="dateAppointment" id="theday" ><%
 	if (isWeekView) {
 %><bean:message key="provider.appointmentProviderAdminDay.week"/> <%=week%><%
 	} else {
 %>
    <% if (showLargeCalendar) { %>
    <a id="calendarLink" href=# onClick ="popupPage(425,430,'<%=request.getContextPath()%>/share/CalendarPopup.jsp?urlfrom=<%=request.getContextPath()%>/provider/providercontrol.jsp&year=<%=strYear%>&month=<%=strMonth%>&param=<%=URLEncoder.encode("&view=0&displaymode=day&dboperation=searchappointmentday&viewall="+viewall,"UTF-8")%><%=isWeekView?URLEncoder.encode("&provider_no="+provNum, "UTF-8"):""%>')" title="<bean:message key="tickler.ticklerEdit.calendarLookup"/>" ><%=formatDate%></a>
    <% } else { %>

<%=formatDate%><%
 	}
 %>
<%
 	}
 %></span>
<input type="hidden" id="storeday" onchange="goDate(this.value)";>

 <a class="redArrow" href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=isWeekView?(day+7):(day+1)%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=day&dboperation=searchappointmentday<%=isWeekView?"&provider_no="+provNum:""%>&viewall=<%=viewall%>">
 <i class="icon-angle-right icon-large" title="<bean:message key="provider.appointmentProviderAdminDay.viewNextDay"/>"></i>&nbsp;&nbsp;</a>

<logic:notEqual name="infirmaryView_isOscar" value="false">
 <% if(request.getParameter("viewall")!=null && request.getParameter("viewall").equals("1") ) { %>
 <!-- <span style="color:#333"><bean:message key="provider.appointmentProviderAdminDay.viewAll"/></span> -->
 <a href=# onClick = "review('0')" title="<bean:message key="provider.appointmentProviderAdminDay.viewAllProv"/>"><bean:message key="provider.appointmentProviderAdminDay.schedView"/></a>

<%}else{%>
	<a href=# onClick = "review('1')" title="<bean:message key="provider.appointmentProviderAdminDay.viewAllProv"/>"><bean:message key="provider.appointmentProviderAdminDay.viewAll"/></a>
<%}%>
</logic:notEqual>

<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
<security:oscarSec roleName="<%=roleName$%>" objectName="_day" rights="r">
 | <a class="rightButton top" href="providercontrol.jsp?year=<%=curYear%>&month=<%=curMonth%>&day=<%=curDay%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=day&dboperation=searchappointmentday" TITLE='<bean:message key="provider.appointmentProviderAdminDay.viewDaySched"/>' OnMouseOver="window.status='<bean:message key="provider.appointmentProviderAdminDay.viewDaySched"/>' ; return true"><bean:message key="global.today"/></a>
</security:oscarSec>
<security:oscarSec roleName="<%=roleName$%>" objectName="_month" rights="r">

   | <a href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=1&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=month&dboperation=searchappointmentmonth" TITLE='<bean:message key="provider.appointmentProviderAdminDay.viewMonthSched"/>' OnMouseOver="window.status='<bean:message key="provider.appointmentProviderAdminDay.viewMonthSched"/>' ; return true"><bean:message key="global.month"/></a>

 </security:oscarSec>

</caisi:isModuleLoad>

<%
	boolean anonymousEnabled = false;
	if (loggedInInfo1.getCurrentFacility() != null) {
		anonymousEnabled = loggedInInfo1.getCurrentFacility().isEnableAnonymous();
	}
	if(anonymousEnabled) {
%>
&nbsp;&nbsp;(<a href="#" onclick="popupPage(710, 1024,'<html:rewrite page="/PMmodule/createAnonymousClient.jsp"/>?programId=<%=(String)session.getAttribute(SessionConstants.CURRENT_PROGRAM_ID)%>');return false;">New Anon Client</a>)
<%
	}
%>
<%
	boolean epe = false;
	if (loggedInInfo1.getCurrentFacility() != null) {
		epe = loggedInInfo1.getCurrentFacility().isEnablePhoneEncounter();
	}
	if(epe) {
%>
&nbsp;&nbsp;(<a href="#" onclick="popupPage(710, 1024,'<html:rewrite page="/PMmodule/createPEClient.jsp"/>?programId=<%=(String)session.getAttribute(SessionConstants.CURRENT_PROGRAM_ID)%>');return false;">Phone Encounter</a>)
<%
	}
%>
<% if (showQuickDateMultiplier) { %>
&nbsp;
<input id="monthBackward" type="button" value="<bean:message key="provider.appointmentProviderAdminDay.monthLetter"/>-" class="quick" onclick="getLocation(this.id,document.getElementById('multiplier').value);"/><input id="weekBackward" type="button" value="<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>-" class="quick" onclick="getLocation(this.id,document.getElementById('multiplier').value)"/><input id="multiplier" type="text"  value="1" maxlength="2" class="quick"  style="text-align: center; background-color: Gainsboro; color: black;" /><input id="weekForward" type="button" value="<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>+" class="quick" style="width:22px" onclick="getLocation(this.id,document.getElementById('multiplier').value)"/><input id="monthForward" type="button" value="<bean:message key="provider.appointmentProviderAdminDay.monthLetter"/>+" class="quick" onclick="getLocation(this.id,document.getElementById('multiplier').value)"/>
<% } %>
<% if (showQuickDatePicker && !showQuickDateMultiplier) { %>
<input id="weekForward1" type="button" value="1W" class="quick" onclick="getLocation('weekForward',1) "/>
<% } %>
<% if (showQuickDatePicker) { %>
<input id="weekForward2" type="button" value="2<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>" class="quick"  onclick="getLocation('weekForward',2) "/>
<input id="weekForward3" type="button" value="3<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>" class="quick"  onclick="getLocation('weekForward',3) "/>
<input id="weekForward4" type="button" value="4<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>" class="quick"  onclick="getLocation('weekForward',4) "/>
<input id="weekForward6" type="button" value="6<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>" class="quick"  onclick="getLocation('weekForward',6) "/>
<% } %>
<% if (showQuickDatePicker && !showQuickDateMultiplier) { %>
<input id="monthForward1" type="button" value="1<bean:message key="provider.appointmentProviderAdminDay.monthLetter"/>" class="quick"  onclick="getLocation('weekForward',4) "/>
<% } %>
<% if (showQuickDatePicker) { %>
<input id="monthForward3" type="button" value="3<bean:message key="provider.appointmentProviderAdminDay.monthLetter"/>" class="quick"  onclick="getLocation('weekForward',12) "/>
<input id="monthForward6" type="button" value="6<bean:message key="provider.appointmentProviderAdminDay.monthLetter"/>" class="quick"  onclick="getLocation('weekForward',25) "/>
<input id="monthForward12" type="button" value="1<bean:message key="provider.appointmentProviderAdminDay.yearLetter"/>" class="quick"  onclick="getLocation('weekForward',367/7) "/>
<% } %>

</td>

<td  ALIGN="center"  width="14%">

<%
	if (isWeekView) {
for(int provIndex=0;provIndex<numProvider;provIndex++) {
if (curProvider_no[provIndex].equals(provNum)) {
%>
<bean:message key="provider.appointmentProviderAdminDay.weekView"/>: <%=curProviderName[provIndex]%>
<%
	} } } else { if (view==1) {
%>
<a href='providercontrol.jsp?year=<%=strYear%>&month=<%=strMonth%>&day=<%=strDay%>&view=0&displaymode=day&dboperation=searchappointmentday'><bean:message key="provider.appointmentProviderAdminDay.grpView"/></a>
<% } else { %>
<% if (!isMobileOptimized) { %> <bean:message key="global.hello"/> <% } %>
<% out.println( userfirstname+" "+userlastname); %>
</td>
<% } } %>

<td id="group" ALIGN="RIGHT" >

<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
<form method="post" name="findprovider" onSubmit="findProvider(<%=year%>,<%=month%>,<%=day%>);return false;" target="apptReception" action="receptionistfindprovider.jsp" style="display:inline;margin:0px;padding:0px;padding-right:10px">
<INPUT TYPE="text" NAME="providername" VALUE="" WIDTH="2" HEIGHT="10" border="0" size="13" maxlength="10"
class="noprint" title="Find a Provider" placeholder='<bean:message key="receptionist.receptionistfindprovider.lastname"/>'>
<INPUT TYPE="SUBMIT" NAME="Go" VALUE='<bean:message key="provider.appointmentprovideradminmonth.btnGo"/>' class="noprint btn" onClick="findProvider(<%=year%>,<%=month%>,<%=day%>);return false;">
</form>
</caisi:isModuleLoad>

<form name="appointmentForm" style="display:inline;margin:0px;padding:0px;">
<% if (isWeekView) { %>
<bean:message key="provider.appointmentProviderAdminDay.provider"/>:
<select name="provider_select" onChange="goWeekView(this.options[this.selectedIndex].value)">
<%
	for (nProvider=0;nProvider<numProvider;nProvider++) {
%>
<option value="<%=curProvider_no[nProvider]%>"<%=curProvider_no[nProvider].equals(provNum)?" selected":""%>><%=curProviderName[nProvider]%></option>
<%
	}
%>

</select>

<%
	} else {
%>

<!-- caisi infirmary view extension add ffffffffffff-->
<caisi:isModuleLoad moduleName="caisi">
<table><tr><td align="right">
    <caisi:ProgramExclusiveView providerNo="<%=curUser_no%>" value="appointment">
	<%
		session.setAttribute("infirmaryView_isOscar", "true");
	%>
    </caisi:ProgramExclusiveView>
    <caisi:ProgramExclusiveView providerNo="<%=curUser_no%>" value="case-management">
	<%
		session.setAttribute("infirmaryView_isOscar", "false");
	%>
    </caisi:ProgramExclusiveView>
</caisi:isModuleLoad>

<caisi:isModuleLoad moduleName="TORONTO_RFQ">
	<%
		session.setAttribute("infirmaryView_isOscar", "false");
	%>
</caisi:isModuleLoad>

<caisi:isModuleLoad moduleName="oscarClinic">
	<%
		session.setAttribute("infirmaryView_isOscar", "true");
	%>
</caisi:isModuleLoad>
<!-- caisi infirmary view extension add end ffffffffffffff-->


<logic:notEqual name="infirmaryView_isOscar" value="false">

<%
	//session.setAttribute("case_program_id", null);
%>
	<!--  multi-site , add site dropdown list -->
 <%
 	if (bMultisites) {
 %>
	   <script>
			function changeSite(sel) {
				sel.style.backgroundColor=sel.options[sel.selectedIndex].style.backgroundColor;
				var siteName = sel.options[sel.selectedIndex].value;
				var newGroupNo = "<%=(mygroupno == null ? ".default" : mygroupno)%>";
			        <%if (org.oscarehr.common.IsPropertiesOn.isCaisiEnable() && org.oscarehr.common.IsPropertiesOn.isTicklerPlusEnable()){%>
				  popupPage(10,10, "providercontrol.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&new_tickler_warning_window=<%=newticklerwarningwindow%>&default_pmm=<%=default_pmm%>&color_template=deepblue&dboperation=updatepreference&displaymode=updatepreference&mygroup_no="+newGroupNo+"&site="+siteName);
			        <%}else {%>
			          popupPage(10,10, "providercontrol.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&color_template=deepblue&dboperation=updatepreference&displaymode=updatepreference&mygroup_no="+newGroupNo+"&site="+siteName);
			        <%}%>
			}
      </script>

    	<select id="site" name="site" onchange="changeSite(this)" style="background-color: <%=( selectedSite == null || siteBgColor.get(selectedSite) == null ? "#FFFFFF" : siteBgColor.get(selectedSite))%>" >
    		<option value="none" style="background-color:white">---<bean:message key="provider.appointmentProviderAdminDay.allclinic"/>---</option>
    	<%
    		for (int i=0; i<curUserSites.size(); i++) {
    	%>
    		<option value="<%=curUserSites.get(i).getName()%>" style="background-color:<%=curUserSites.get(i).getBgColor()%>"
    				<%=(curUserSites.get(i).getName().equals(selectedSite)) ? " selected " : ""%> >
    			<%=curUserSites.get(i).getName()%>
    		</option>
    	<%
    		}
    	%>
    	</select>
<%
	}
%>
  <span><i class="icon-group" title="<bean:message key="global.group"/>"></i></span>

<%
	List<MyGroupAccessRestriction> restrictions = myGroupAccessRestrictionDao.findByProviderNo(curUser_no);
%>
  <select id="mygroup_no" name="mygroup_no" onChange="changeGroup(this)">
  <option value=".<bean:message key="global.default"/>">.<bean:message key="global.default"/></option>


<security:oscarSec roleName="<%=roleName$%>" objectName="_team_schedule_only" rights="r" reverse="false">
<%
	String provider_no = curUser_no;
	for(Provider p : providerDao.getActiveProviders()) {
		boolean skip = checkRestriction(restrictions,p.getProviderNo());
		if(!skip) {
%>
<option value="<%=p.getProviderNo()%>" <%=mygroupno.equals(p.getProviderNo())?"selected":""%>>
		<%=p.getFormattedName()%></option>
<%
	} }
%>

</security:oscarSec>
<security:oscarSec roleName="<%=roleName$%>" objectName="_team_schedule_only" rights="r" reverse="true">
<%
	request.getSession().setAttribute("archiveView","false");
	for(MyGroup g : myGroupDao.searchmygroupno()) {

		boolean skip = checkRestriction(restrictions,g.getId().getMyGroupNo());

		if (!skip && (!bMultisites || siteGroups == null || siteGroups.size() == 0 || siteGroups.contains(g.getId().getMyGroupNo()))) {
%>
  <option value="<%="_grp_"+g.getId().getMyGroupNo()%>"
		<%=mygroupno.equals(g.getId().getMyGroupNo())?"selected":""%>><%=g.getId().getMyGroupNo()%></option>
<%
	}
	}

	for(Provider p : providerDao.getActiveProviders()) {
		boolean skip = checkRestriction(restrictions,p.getProviderNo());

		if (!skip && (!bMultisites || siteProviderNos  == null || siteProviderNos.size() == 0 || siteProviderNos.contains(p.getProviderNo()))) {
%>
  <option value="<%=p.getProviderNo()%>" <%=mygroupno.equals(p.getProviderNo())?"selected":""%>>
		<%=p.getFormattedName()%></option>
<%
	}
	}
%>
</security:oscarSec>
</select>

</logic:notEqual>

<logic:equal name="infirmaryView_isOscar" value="false">
&nbsp;&nbsp;&nbsp;&nbsp;
</logic:equal>

<%
	}
%>


<!-- caisi infirmary view extension add fffffffffffff-->
<caisi:isModuleLoad moduleName="caisi">

	<jsp:include page="infirmaryviewprogramlist.jspf"/>

</caisi:isModuleLoad>
<!-- caisi infirmary view extension add end fffffffffffff-->

      </td>
      </tr>
</table>
</td></tr>


      <tr><td colspan="3">
        <table width="100%">
        <tr>
<%
	boolean bShowDocLink = false;
boolean bShowEncounterLink = false;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment.doctorLink" rights="r">
<%
	bShowDocLink = true;
%>
</security:oscarSec>
<security:oscarSec roleName="<%=roleName$%>" objectName="_eChart" rights="r">
<%
	bShowEncounterLink = true;
%>
</security:oscarSec>


<%


SimpleDateFormat formatHour = new SimpleDateFormat("HH");
SimpleDateFormat formatMin = new SimpleDateFormat("mm");
SimpleDateFormat formatAdate = new SimpleDateFormat("yyyyMMdd");
Date curDate = new Date();
String curHour = formatHour.format(curDate);
String curMin = formatMin.format(curDate);
String curDate2 = formatAdate.format(curDate);
boolean isToday = false;
isToday = curDate2.equals(strYear+strMonth+strDay);
int curH = Integer.parseInt(curHour);
int totalM = Integer.parseInt(curMin) + curH*60 -6;  //6min grace offset


int hourCursor=0, minuteCursor=0, depth=everyMin; //depth is the period, e.g. 10,15,30,60min.
String am_pm=null;
boolean bColor=true, bColorHour=true; //to change color

int iCols=0, iRows=0, iS=0,iE=0,iSm=0,iEm=0; //for each S/E starting/Ending hour, how many events
int ih=0, im=0, iSn=0, iEn=0 ; //hour, minute, nthStartTime, nthEndTime, rowspan
boolean bFirstTimeRs=true;
boolean bFirstFirstR=true;
Object[] paramTickler = new Object[2];
String[] param = new String[2];
String strsearchappointmentday=request.getParameter("dboperation");

boolean userAvail = true;
int me = -1;
for(nProvider=0;nProvider<numProvider;nProvider++) {
	if(curUser_no.equals(curProvider_no[nProvider]) ) {
       //userInGroup = true;
		me = nProvider; break;
	}
}

   // set up the iterator appropriately (today - for each doctor; this week - for each day)
   int iterMax;
   if (isWeekView) {
      iterMax=7;
      // find the nProvider value that corresponds to provNum
      if(numProvider == 1) {
    	  nProvider = 0;
      }
      else {
	      for(int provIndex=0;provIndex<numProvider;provIndex++) {
	         if (curProvider_no[provIndex].equals(provNum)) {
	            nProvider=provIndex;
	         }
	      }
      }
   } else {
      iterMax=numProvider;
   }

   StringBuffer hourmin = null;
   String [] param1 = new String[2];

   java.util.ResourceBundle wdProp = ResourceBundle.getBundle("oscarResources", request.getLocale());

   for(int iterNum=0;iterNum<iterMax;iterNum++) {

     if (isWeekView) {
        // get the appropriate datetime objects for the current day in this week
        year = cal.get(Calendar.YEAR);
        month = (cal.get(Calendar.MONTH)+1);
        day = cal.get(Calendar.DAY_OF_MONTH);

        strDate = year + "-" + month + "-" + day;
        monthDay = String.format("%02d", month) + "-" + String.format("%02d", day);

        inform = new SimpleDateFormat ("yyyy-MM-dd", request.getLocale());
        try {
           formatDate = UtilDateUtilities.DateToString(inform.parse(strDate), wdProp.getString("date.EEEyyyyMMdd"),request.getLocale());
        } catch (Exception e) {
           MiscUtils.getLogger().error("Error", e);
           formatDate = UtilDateUtilities.DateToString(inform.parse(strDate), "EEE, yyyy-MM-dd");
        }
        strYear=""+year;
        strMonth=month>9?(""+month):("0"+month);
        strDay=day>9?(""+day):("0"+day);

        // Reset timecode bean for this day
        param3[0] = strDate; //strYear+"-"+strMonth+"-"+strDay;
        param3[1] = curProvider_no[nProvider];
    	dateTimeCodeBean.put(String.valueOf(provNum), "");

    	List<Object[]> results = scheduleDateDao.search_appttimecode(ConversionUtils.fromDateString(strDate), curProvider_no[nProvider]);
    	for(Object[] result : results) {
    		 ScheduleTemplate st = (ScheduleTemplate)result[0];
        	 ScheduleDate sd = (ScheduleDate)result[1];
        	 dateTimeCodeBean.put(sd.getProviderNo(), st.getTimecode());
    	}


     for(ScheduleTemplateCode stc : scheduleTemplateCodeDao.findAll()) {

       dateTimeCodeBean.put("description"+stc.getCode(), stc.getDescription());
       dateTimeCodeBean.put("duration"+stc.getCode(), stc.getDuration());
       dateTimeCodeBean.put("color"+stc.getCode(), (stc.getColor()==null || "".equals(stc.getColor()))?bgcolordef:stc.getColor());
       dateTimeCodeBean.put("confirm" + stc.getCode(), stc.getConfirm());
     }

        // move the calendar forward one day
        cal.add(Calendar.DATE, 1);
     } else {
        nProvider = iterNum;
     }

     userAvail = true;
     int timecodeLength = dateTimeCodeBean.get(curProvider_no[nProvider])!=null?((String) dateTimeCodeBean.get(curProvider_no[nProvider]) ).length() : 4*24;

     if (timecodeLength == 0){
        timecodeLength = 4*24;
     }

     depth = bDispTemplatePeriod ? (24*60 / timecodeLength) : everyMin; // add function to display different time slot
     param1[0] = strDate; //strYear+"-"+strMonth+"-"+strDay;
     param1[1] = curProvider_no[nProvider];

     List<Appointment> appointmentsToCount = appointmentDao.searchappointmentday(curProvider_no[nProvider], ConversionUtils.fromDateString(year + "-" + month + "-" + day), ConversionUtils.fromIntString(programId_oscarView));
     Integer appointmentCount = 0;
     for (Appointment appointment : appointmentsToCount) {
        if (!noCountStatus.contains(appointment.getStatus()) && appointment.getDemographicNo() != 0
            && (!bMultisites || selectedSite == null || "none".equals(selectedSite) || (bMultisites && selectedSite.equals(appointment.getLocation())))
            ) {
                appointmentCount++;
        }
    }



     ScheduleDate sd = scheduleDateDao.findByProviderNoAndDate(curProvider_no[nProvider],ConversionUtils.fromDateString(strDate));

     //viewall function
     if(request.getParameter("viewall")==null || request.getParameter("viewall").equals("0") ) {
         if(sd == null|| "0".equals(String.valueOf(sd.getAvailable())) ) {
             if(nProvider!=me ) continue;
             else userAvail = false;
         }
     }
     bColor=bColor?false:true;

     boolean hideColumn=false;
     if(!showNonScheduled) {
    	 if(sd == null || "0".equals(String.valueOf(sd.getAvailable())) ) {
    		 hideColumn=true;
    	 }
     }

%>
            <td valign="top" width="<%=isWeekView?100/7:100/numProvider%>%" <%=hideColumn?"style=\"display:none\" ":"" %>> <!-- for the first provider's schedule -->

        <table  width="100%" id="providertable"><!-- for the first provider's name -->
          <tr><td class="infirmaryView" NOWRAP ALIGN="center" BGCOLOR="<%=bColor?"silver":"silver"%>">
 <!-- caisi infirmary view extension modify ffffffffffff-->
  <logic:notEqual name="infirmaryView_isOscar" value="false">

      <%
      	if (isWeekView) {
      %>
          <a href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=day%>&view=0&displaymode=day&dboperation=searchappointmentday"><%=formatDate%></a>
      <%
      	} else {
      %>
    <input class="btn noprint s" type='button' value="<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>" name='weekview' onClick=goWeekView('<%=curProvider_no[nProvider]%>') title="<bean:message key="provider.appointmentProviderAdminDay.weekView"/>"  >
	  <input class="btn noprint s" type='button' value="<bean:message key="provider.appointmentProviderAdminDay.searchLetter"/>" name='searchview' onClick=goSearchView('<%=curProvider_no[nProvider]%>') title="<bean:message key="provider.appointmentProviderAdminDay.searchView"/>"  >
          <input type='radio' name='flipview' class="noprint" onClick="goFilpView('<%=curProvider_no[nProvider]%>')" title="Flip view"  >
          <b><a href=#
            onClick="goZoomView('<%=curProvider_no[nProvider]%>','<%=StringEscapeUtils.escapeJavaScript(curProviderName[nProvider])%>')"
            onDblClick="goFilpView('<%=curProvider_no[nProvider]%>')" title="<bean:message key="provider.appointmentProviderAdminDay.zoomView"/>" >
            <c:out value='<%=curProviderName[nProvider]  + " (" + appointmentCount + ") " %>' />
          </a></b>
       	<oscar:oscarPropertiesCheck value="yes" property="TOGGLE_REASON_BY_PROVIDER" defaultVal="true">
				<a id="expandReason" href="#" onclick="return toggleReason('<%=curProvider_no[nProvider]%>');"
					title="<bean:message key="provider.appointmentProviderAdminDay.expandreason"/>">*</a>
					<%-- Default is to hide inline reasons. --%>
				<c:set value="true" var="hideReason" />
		</oscar:oscarPropertiesCheck>

          <input class="btn noprint s ds-btn" type="button" value="<bean:message key="provider.appointmentProviderAdminDay.daysheetLetter"/>" name="daysheet" data-provider_no="<%=curProvider_no[nProvider]%>" title="<bean:message key="report.reportindex.formDaySheet"/>">
      <% } %>

          <%
          	if (!userAvail) {
          %>
          [<bean:message key="provider.appointmentProviderAdminDay.msgNotOnSched"/>]
          <%
          	}
          %>
</logic:notEqual>
<logic:equal name="infirmaryView_isOscar" value="false">
	<%
		String prID="1";
	%>
	<logic:present name="infirmaryView_programId">
	<%
		prID=(String)session.getAttribute(SessionConstants.CURRENT_PROGRAM_ID);
	%>
	</logic:present>
	<logic:iterate id="pb" name="infirmaryView_programBeans" type="org.apache.struts.util.LabelValueBean">
	  	<%
	  		if (pb.getValue().equals(prID)) {
	  	%>
  		<b><%=pb.getLabel()%></label></b>
		<%
			}
		%>
  	</logic:iterate>
</logic:equal>
<!-- caisi infirmary view extension modify end ffffffffffffffff-->
</td></tr>
          <tr><td valign="top">

<!-- caisi infirmary view exteion add -->
<!--  fffffffffffffffffffffffffffffffffffffffffff-->
<caisi:isModuleLoad moduleName="caisi">
<jsp:include page="infirmarydemographiclist.jspf"/>
</caisi:isModuleLoad>
<logic:notEqual name="infirmaryView_isOscar" value="false">
<!-- caisi infirmary view exteion add end ffffffffffffffffff-->
<!-- =============== following block is the original oscar code. -->
        <!-- table for hours of day start -->
        <table id="providerSchedule"  <%=userAvail?"":"style=\"background-color:silver;\""%>  width="100%">
<%
		bFirstTimeRs=true;
        bFirstFirstR=true;

        String useProgramLocation = OscarProperties.getInstance().getProperty("useProgramLocation");
    	String moduleNames = OscarProperties.getInstance().getProperty("ModuleNames");
    	boolean caisiEnabled = moduleNames != null && org.apache.commons.lang.StringUtils.containsIgnoreCase(moduleNames, "Caisi");
    	boolean locationEnabled = caisiEnabled && (useProgramLocation != null && useProgramLocation.equals("true"));

    	int length = locationEnabled ? 4 : 3;

        String [] param0 = new String[length];

        param0[0]=curProvider_no[nProvider];
        param0[1]=year+"-"+month+"-"+day;//e.g."2001-02-02";
		param0[2]=programId_oscarView;
		if (locationEnabled) {


			ProgramManager2 programManager2 = SpringUtils.getBean(ProgramManager2.class);
			ProgramProvider programProvider = programManager2.getCurrentProgramInDomain(loggedInInfo1,loggedInInfo1.getLoggedInProviderNo());
            if(programProvider!=null && programProvider.getProgram() != null) {
            	programProvider.getProgram().getName();
            }
		    param0[3]=request.getParameter("programIdForLocation");
		    strsearchappointmentday = "searchappointmentdaywithlocation";
		}

		List<Appointment> appointments = appointmentDao.searchappointmentday(curProvider_no[nProvider], ConversionUtils.fromDateString(year+"-"+month+"-"+day),ConversionUtils.fromIntString(programId_oscarView));
               	Iterator<Appointment> it = appointments.iterator();

                Appointment appointment = null;
            	String router = "";
            	String record = "";
            	String module = "";
            	String newUxUrl = "";
            	String inContextStyle = "";

            	if(request.getParameter("record")!=null){
            		record=request.getParameter("record");
            	}

            	if(request.getParameter("module")!=null){
            		module=request.getParameter("module");
            	}
        List<Object[]> confirmTimeCode = scheduleDateDao.search_appttimecode(ConversionUtils.fromDateString(strDate), curProvider_no[nProvider]);

	    for(ih=startHour*60; ih<=(endHour*60+(60/depth-1)*depth); ih+=depth) { // use minutes as base
            hourCursor = ih/60;
            minuteCursor = ih%60;
            bColorHour=minuteCursor==0?true:false; //every 00 minute, change color

            //templatecode
            if((dateTimeCodeBean.get(curProvider_no[nProvider]) != null)&&(dateTimeCodeBean.get(curProvider_no[nProvider]) != "") && confirmTimeCode.size()!=0) {
	          int nLen = 24*60 / ((String) dateTimeCodeBean.get(curProvider_no[nProvider]) ).length();
	          int ratio = (hourCursor*60+minuteCursor)/nLen;
              hourmin = new StringBuffer(dateTimeCodeBean.get(curProvider_no[nProvider])!=null?((String) dateTimeCodeBean.get(curProvider_no[nProvider])).substring(ratio,ratio+1):" " );
            } else { hourmin = new StringBuffer(); }

if ( (ih >= totalM)&&(ih < (totalM+depth)) && !isWeekView && isToday && isTimeline ) {%><tr style="font-size:1px;"><td colspan="8"  ><hr color="tomato" style="border:1px dotted" ></td></tr> <%}

%>
          <tr>
            <td align="RIGHT" class="<%=bColorHour?"scheduleTime00":"scheduleTimeNot00"%>" NOWRAP>
             <a href=# onClick="confirmPopupPage(600,842,'<%=request.getContextPath()%>/appointment/addappointment.jsp?provider_no=<%=curProvider_no[nProvider]%>&bFirstDisp=<%=true%>&year=<%=strYear%>&month=<%=strMonth%>&day=<%=strDay%>&start_time=<%=(hourCursor>9?(""+hourCursor):("0"+hourCursor))+":"+ (minuteCursor<10?"0":"") +minuteCursor%>&end_time=<%=(hourCursor>9?(""+hourCursor):("0"+hourCursor))+":"+(minuteCursor+depth-1)%>&duration=<%=dateTimeCodeBean.get("duration"+hourmin.toString())%>','<%=dateTimeCodeBean.get("confirm"+hourmin.toString())%>','<%=allowDay%>','<%=allowWeek%>');return false;"
  title='<%=MyDateFormat.getTimeXX_XXampm(hourCursor +":"+ (minuteCursor<10?"0":"")+minuteCursor)%> - <%=MyDateFormat.getTimeXX_XXampm(hourCursor +":"+((minuteCursor+depth-1)<10?"0":"")+(minuteCursor+depth-1))%>' class="adhour">
             <%=(hourCursor<10?"0":"") +hourCursor+ ":"%><%=(minuteCursor<10?"0":"")+minuteCursor%>&nbsp;</a></td>
            <td class="hourmin" style="text-align:center;" width='1%' <%=dateTimeCodeBean.get("color"+hourmin.toString())!=null?("bgcolor="+dateTimeCodeBean.get("color"+hourmin.toString()) ):""%> title='<%=dateTimeCodeBean.get("description"+hourmin.toString())%>'><font color='<%=(dateTimeCodeBean.get("color"+hourmin.toString())!=null && !dateTimeCodeBean.get("color"+hourmin.toString()).equals(bgcolordef) )?"black":"white"%>'><%=hourmin.toString()%></font></td>
<%
	while (bFirstTimeRs?it.hasNext():true) { //if it's not the first time to parse the standard time, should pass it by
                  appointment = bFirstTimeRs?it.next():appointment;
                  len = bFirstTimeRs&&!bFirstFirstR?lenLimitedS:lenLimitedL;
                  String strStartTime = ConversionUtils.toTimeString(appointment.getStartTime());
                  String strEndTime = ConversionUtils.toTimeString(appointment.getEndTime());

                  iS=Integer.parseInt(String.valueOf(strStartTime).substring(0,2));
                  iSm=Integer.parseInt(String.valueOf(strStartTime).substring(3,5));
                  iE=Integer.parseInt(String.valueOf(strEndTime).substring(0,2));
              	  iEm=Integer.parseInt(String.valueOf(strEndTime).substring(3,5));

          	  if( (ih < iS*60+iSm) && (ih+depth-1)<iS*60+iSm ) { //iS not in this period (both start&end), get to the next period
          	  	//out.println("<td width='10'>&nbsp;</td>"); //should be comment
          	  	bFirstTimeRs=false;
          	  	break;
          	  }
          	  if( (ih > iE*60+iEm) ) { //appt before this time slot (both start&end), get to the next period
          	  	//out.println("<td width='10'>&nbsp;</td>"); //should be comment
          	  	bFirstTimeRs=true;
          	  	continue;
          	  }
         	    iRows=((iE*60+iEm)-ih)/depth+1; //to see if the period across an hour period

                if ( ih >= (totalM -depth) && (ih < totalM) && !isWeekView && isToday && isTimeline) {iRows = iRows+1; }  // to allow for extra row with time indicator

         	    //iRows=(iE-iS)*60/depth+iEm/depth-iSm/depth+1; //to see if the period across an hour period


                    int demographic_no = appointment.getDemographicNo();

                  //Pull the appointment name from the demographic information if the appointment is attached to a specific demographic.
                  //Otherwise get the name associated with the appointment from the appointment information
                  StringBuilder nameSb = new StringBuilder();
                  if ((demographic_no != 0)&& (demographicDao != null)) {
                        Demographic demo = demographicDao.getDemographic(String.valueOf(demographic_no));
                        nameSb.append(demo.getLastName())
                              .append(",");
                        if (replaceNameWithPreferred && StringUtils.isNotEmpty(demo.getAlias())) {
                              nameSb.append(demo.getAlias());
                        } else {
                                nameSb.append(demo.getFirstName());
                                if (StringUtils.isNotEmpty(demo.getAlias())) {
                                    nameSb.append(" (")
                                        .append(demo.getAlias())
                                        .append(")");
                                }
                        }
                  }
                  else {
                        nameSb.append(String.valueOf(appointment.getName()));
                  }
                  String name = WordUtils.capitalizeFully(nameSb.toString(), new char[] {',','-','(','\'',' '});

                  paramTickler[0]=String.valueOf(demographic_no);
                  paramTickler[1]=MyDateFormat.getSysDate(strDate); //year+"-"+month+"-"+day;//e.g."2001-02-02";
                  tickler_no = "";
                  tickler_note="";

                 if(securityInfoManager.hasPrivilege(loggedInInfo1, "_tickler", "r", demographic_no)) {
	                  for(Tickler t: ticklerManager.search_tickler(loggedInInfo1, demographic_no,MyDateFormat.getSysDate(strDate))) {
	                	  tickler_no = t.getId().toString();
	                      tickler_note = t.getMessage()==null?tickler_note:tickler_note + "\n" + t.getMessage();
	                  }
                 }

                  //alerts and notes
                  DemographicCust dCust = demographicCustDao.find(demographic_no);


                  ver = "";
                  roster = "";
                  Demographic demographic = demographicDao.getDemographicById(demographic_no);
                  if(demographic != null) {

                    ver = demographic.getVer();
                    roster = demographic.getRosterStatus();

                    int intMob = 0;
                    int intDob = 0;

                    mob = String.valueOf(demographic.getMonthOfBirth());
                    if(mob.length()>0 && !mob.equals("null"))
                    	intMob = Integer.parseInt(mob);

                    dob = String.valueOf(demographic.getDateOfBirth());
                    if(dob.length()>0 && !dob.equals("null"))
                    	intDob = Integer.parseInt(dob);


                    demBday = mob + "-" + dob;

                    if (roster == null ) {
                        roster = "";
                    }
                  }
                  study_no = new StringBuffer("");
                  study_link = new StringBuffer("");
		  studyDescription = new StringBuffer("");

		  int numStudy = 0;

		  for(DemographicStudy ds:demographicStudyDao.findByDemographicNo(demographic_no)) {
			  Study study = studyDao.find(ds.getId().getStudyNo());
			  if(study != null && study.getCurrent1() == 1) {
				  numStudy++;
				  if(numStudy == 1) {
					  study_no = new StringBuffer(String.valueOf(study.getId()));
	                          study_link = new StringBuffer(String.valueOf(study.getStudyLink()));
	                          studyDescription = new StringBuffer(String.valueOf(study.getDescription()));
				  } else {
					  study_no = new StringBuffer("0");
		                      study_link = new StringBuffer("formstudy.jsp");
				      studyDescription = new StringBuffer("Form Studies");
				  }
			  }
		  }

                  //String reason = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(String.valueOf(appointment.getReason()).trim());
                  //String notes = org.apache.commons.lang.StringEscapeUtils.escapeJavaScript(String.valueOf(appointment.getNotes()).trim());
                  String reason = String.valueOf(appointment.getReason()).trim();
                  String notes = String.valueOf(appointment.getNotes()).trim();
                  String status = String.valueOf(appointment.getStatus()).trim();
          	      String sitename = String.valueOf(appointment.getLocation()).trim();
          	      String type = appointment.getType();
          	      String urgency = appointment.getUrgency();
          	      String reasonCodeName = null;
          	      if(appointment.getReasonCode() != null)    {
          	    	LookupListItem lli  = reasonCodesMap.get(appointment.getReasonCode());
          	    	if(lli != null) {
          	    		reasonCodeName = lli.getLabel();
          	    	}
          	      }
				if ( showTypeReason ) {
					reasonCodeName = ( type + " : " + reasonCodeName );
				}

          	  bFirstTimeRs=true;
	    as.setApptStatus(status);

	 //multi-site. if a site have been selected, only display appointment in that site
	 if (!bMultisites || (selectedSite == null && CurrentSiteMap.get(sitename) != null) || sitename.equals(selectedSite)) {
%>
            <td class="appt <%=as.getTitleString(request.getLocale()).replaceAll("\\s","_")%>" bgcolor='<%=as.getBgColor()%>' rowspan="<%=iRows%>" <%-- =view==0?(len==lenLimitedL?"nowrap":""):"nowrap"--%> nowrap>
			<%
			   if (BookingSource.MYOSCAR_SELF_BOOKING == appointment.getBookingSource())
				{
					%>
						<bean:message key="provider.appointmentProviderAdminDay.SelfBookedMarker"/>
					<%
				}
			%>
			 <!-- multisites : add colour-coded to the "location" value of that appointment. -->
			 <%if (bMultisites) {%>
			 	<span title="<%= sitename %>" style="background-color:<%=siteBgColor.get(sitename)%>;">&nbsp;</span>|
			 <%} %>

            <%
                String nextStatus =null;
            try {nextStatus = as.getNextStatus();} catch(Exception e){}
			    if (nextStatus != null && !nextStatus.equals("")) {
            %>
			<!-- Short letters -->
            <a class="apptStatus" href=# onclick="refreshSameLoc('providercontrol.jsp?appointment_no=<%=appointment.getId()%>&provider_no=<%=curProvider_no[nProvider]%>&status=&statusch=<%=nextStatus%>&year=<%=year%>&month=<%=month%>&day=<%=day%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=addstatus&dboperation=updateapptstatus&viewall=<%=request.getParameter("viewall")==null?"0":(request.getParameter("viewall"))%><%=isWeekView?"&viewWeek=1":""%>');" title="<%=as.getTitleString(request.getLocale())%> " >
            <%
						}
						if (nextStatus != null) {
							if (showShortLetters) {

								String colour = as.getShortLetterColour();
								if(colour == null){
									colour = "#FFFFFF";
								}

					%>
								<span
									class='short_letters'
									style='color:<%= colour%>;border:0;height:10'>
											[<%=UtilMisc.htmlEscape(as.getShortLetters())%>]
									</span>
					<%
							}else{
				    %>

				    			<img src="<%=request.getContextPath()%>/images/<%=as.getImageName()%>" border="0" height="10" title="<%=(as.getTitleString(request.getLocale()).length()>0)?as.getTitleString(request.getLocale()):as.getTitle()%>">

            <%
							}
                } else {
	                out.print("&nbsp;");
                }

			%>
			</a>
			<%
            if(urgency != null && urgency.equals("critical")) {
            %>
            	<img src="<%=request.getContextPath()%>/images/warning-icon.png" border="0" width="14" height="14" title="Critical Appointment"/>
            <% } %>
<%--|--%>
        <%
        			if(demographic_no==0) {
        %>
        	<!--  caisi  -->
        	<security:oscarSec roleName="<%=roleName$%>" objectName="_tickler" rights="r">
	        	<% if (tickler_no.compareTo("") != 0) {%>
		        	<caisi:isModuleLoad moduleName="ticklerplus" reverse="true">
	        			<a href="#" onClick="popupPage(700,1024, '<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview=0');return false;" title="<bean:message key="provider.appointmentProviderAdminDay.ticklerMsg"/>: <%=UtilMisc.htmlEscape(tickler_note)%>"><font color="red">!</font></a>
	    			</caisi:isModuleLoad>
	    			<caisi:isModuleLoad moduleName="ticklerplus">
	    				<a href="<%=request.getContextPath()%>/ticklerPlus/index.jsp" title="<bean:message key="provider.appointmentProviderAdminDay.ticklerMsg"/>: <%=UtilMisc.htmlEscape(tickler_note)%>"><font color="red">!</font></a>
	    			</caisi:isModuleLoad>
	    		<%} %>
    		</security:oscarSec>

    		<!--  alerts -->
    		<% if(showAlerts){ %>
        		<% if(dCust != null && dCust.getAlert() != null && !dCust.getAlert().isEmpty()) { %>
        			<a href="#" onClick="return false;" title="<%=StringEscapeUtils.escapeHtml(dCust.getAlert())%>">A</a>
    		<% }    }%>

    		<!--  notes -->
    		<% if(showNotes){ %>
        		<% if(dCust != null && dCust.getNotes() != null && !SxmlMisc.getXmlContent(dCust.getNotes(), "<unotes>", "</unotes>").isEmpty()) { %>
        			<a href="#" onClick="return false;" title="<%=StringEscapeUtils.escapeHtml(SxmlMisc.getXmlContent(dCust.getNotes(), "<unotes>", "</unotes>"))%>">N</a>
    		<% }    }%>


<a href=# onClick ="popupPage(790,801,'<%=request.getContextPath()%>/appointment/appointmentcontrol.jsp?appointment_no=<%=appointment.getId()%>&provider_no=<%=curProvider_no[nProvider]%>&year=<%=year%>&month=<%=month%>&day=<%=day%>&start_time=<%=iS+":"+iSm%>&demographic_no=0&displaymode=edit&dboperation=search');return false;" title="<%=iS+":"+(iSm>10?"":"0")+iSm%>-<%=iE+":"+iEm%>
<%=name%>
	<%=type != null ? "type: " + type : "" %>
	reason: <%=reasonCodeName!=null?reasonCodeName:""%> <%if(reason!=null && !reason.isEmpty()){%>- <%=UtilMisc.htmlEscape(reason)%>
<%}%>	<bean:message key="provider.appointmentProviderAdminDay.notes"/>: <%=UtilMisc.htmlEscape(notes)%>" >
            .<%=(view==0&&numAvailProvider!=1)?(name.length()>len?name.substring(0,len).toUpperCase():name.toUpperCase()):name.toUpperCase()%>
            </font></a><!--Inline display of reason -->
      <% if (showApptReason) { %>
      <span class="reason reason_<%=curProvider_no[nProvider]%> ${ hideReason ? "hideReason" : "" }"><bean:message key="provider.appointmentProviderAdminDay.Reason"/>:<%=UtilMisc.htmlEscape(reason)%></span>
      <% } %>
        <%
        			} else {
				%>	<% if (tickler_no.compareTo("") != 0) {%>
			        	<caisi:isModuleLoad moduleName="ticklerplus" reverse="true">
                                        <a href="#" onClick="popupPage(700,1024, '<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview=<%=demographic_no%>');return false;" title="<bean:message key="provider.appointmentProviderAdminDay.ticklerMsg"/>: <%=UtilMisc.htmlEscape(tickler_note)%>"><font color="red">!</font></a>
    					</caisi:isModuleLoad>
    					<caisi:isModuleLoad moduleName="ticklerplus">
		    				<!--  <a href="<%=request.getContextPath()%>/Tickler.do?method=filter&filter.client=<%=demographic_no %>" title="<bean:message key="provider.appointmentProviderAdminDay.ticklerMsg"/>: <%=UtilMisc.htmlEscape(tickler_note)%>"><font color="red">!</font></a> -->
    						<a href="#" onClick="popupPage(700,102.4, '<%=request.getContextPath()%>/Tickler.do?method=filter&filter.client=<%=demographic_no %>');return false;" title="<bean:message key="provider.appointmentProviderAdminDay.ticklerMsg"/>: <%=UtilMisc.htmlEscape(tickler_note)%>"><font color="red">!</font></a>
    					</caisi:isModuleLoad>
					<%} %>

					<!--  alerts -->
			<% if(showAlerts){ %>
        		<% if(dCust != null && dCust.getAlert() != null && !dCust.getAlert().isEmpty()) { %>
        			<a href="#" onClick="return false;" title="<%=StringEscapeUtils.escapeHtml(dCust.getAlert())%>">A</a>
    		<%} } %>

    		<!--  notes -->
    		<% if(showNotes){ %>
        		<% if(dCust != null && dCust.getNotes() != null && !SxmlMisc.getXmlContent(dCust.getNotes(), "<unotes>", "</unotes>").isEmpty()) { %>
        			<a href="#" onClick="return false;" title="<%=StringEscapeUtils.escapeHtml(SxmlMisc.getXmlContent(dCust.getNotes(), "<unotes>", "</unotes>"))%>">N</a>
    		<%} }%>

<!-- doctor code block 1 -->
<% if(bShowDocLink) { %>
<!-- security:oscarSec roleName="<%--=roleName$--%>" objectName="_appointment.doctorLink" rights="r" -->
<% if ("".compareTo(study_no.toString()) != 0) {%>	<a href="#" onClick="popupPage(700,1024, '<%=request.getContextPath()%>/form/study/forwardstudyname.jsp?study_link=<%=study_link.toString()%>&demographic_no=<%=demographic_no%>&study_no=<%=study_no%>');return false;" title="<bean:message key="provider.appointmentProviderAdminDay.study"/>: <%=UtilMisc.htmlEscape(studyDescription.toString())%>"><%="<font color='"+studyColor+"'>"+studySymbol+"</font>"%></a><%} %>

<% List<AppointmentDxLink> dxLinkList = appointmentDxLinkManager.getAppointmentDxLinkForDemographic(loggedInInfo1,demographic_no);
   for(AppointmentDxLink dx:dxLinkList){
%>
	<a href="#"
		<%if(dx.getLink() != null){%>
		onClick="popupPage(700,1024,'<%=dx.getLink()%>');return false;"
		<%}%>
		title="<%=dx.getMessage()%>">
		<%="<font color='"+dx.getColour()+"'>"+dx.getSymbol()+"</font>"%></a>
<%}%>
<% if (ver!=null && ver!="" && "##".compareTo(ver.toString()) == 0){%><a href="#" title="<bean:message key="provider.appointmentProviderAdminDay.versionMsg"/> <%=UtilMisc.htmlEscape(ver)%>"> <font color="red">*</font></a><%}%>

<% if (roster!="" && "FS".equalsIgnoreCase(roster)){%> <a href="#" title="<bean:message key="provider.appointmentProviderAdminDay.rosterMsg"/> <%=UtilMisc.htmlEscape(roster)%>"><font color="red">$</font></a><%}%>

<% if ("NR".equalsIgnoreCase(roster) || "PL".equalsIgnoreCase(roster)){%> <a href="#" title="<bean:message key="provider.appointmentProviderAdminDay.rosterMsg"/> <%=UtilMisc.htmlEscape(roster)%>"><font color="red">#</font></a><%}%>
<!-- /security:oscarSec -->
<% } %>
<!-- doctor code block 2 -->
<%

boolean disableStopSigns = PreventionManager.isDisabled();
boolean propertyExists = PreventionManager.isCreated();
if(disableStopSigns!=true){
if( OscarProperties.getInstance().getProperty("SHOW_PREVENTION_STOP_SIGNS","false").equals("true") || propertyExists==true) {

		String warning = prevMgr.getWarnings(loggedInInfo1, String.valueOf(demographic_no));
		warning = PreventionManager.checkNames(warning);

		String htmlWarning = "";

		if( !warning.equals("")) {
			  htmlWarning = "<img src=\"../images/stop_sign.png\" height=\"14\" width=\"14\" title=\"" + warning +"\">&nbsp;";
		}

		out.print(htmlWarning);

}
}

String start_time = "";
if( iS < 10 ) {
	 	start_time = "0";
}
start_time +=  iS + ":";
if( iSm < 10 ) {
	 	start_time += "0";
}

start_time += iSm + ":00";
%>

<a class="apptLink" href=# onClick ="popupPage(790,801,'<%=request.getContextPath()%>/appointment/appointmentcontrol.jsp?appointment_no=<%=appointment.getId()%>&provider_no=<%=curProvider_no[nProvider]%>&year=<%=year%>&month=<%=month%>&day=<%=day%>&start_time=<%=iS+":"+iSm%>&demographic_no=<%=demographic_no%>&displaymode=edit&dboperation=search');return false;"
<oscar:oscarPropertiesCheck property="SHOW_APPT_REASON_TOOLTIP" value="yes" defaultVal="true">
	title="<%=Encode.forHtmlAttribute(name)%>
	type: <%=type != null ? Encode.forHtmlAttribute(type) : "" %>
	reason: <%=reasonCodeName!=null? Encode.forHtml(reasonCodeName):""%> <%if(reason!=null && !reason.isEmpty()){%>- <%=Encode.forHtmlAttribute(reason)%><%}%>
	notes: <%=Encode.forHtmlAttribute(notes)%>"
</oscar:oscarPropertiesCheck> ><%=Encode.forHtml((view==0) ? (name.length()>len?name.substring(0,len) : name) :name)%></a>

<% if(len==lenLimitedL || view!=0 || numAvailProvider==1 ) {%>

<security:oscarSec roleName="<%=roleName$%>" objectName="_eChart" rights="r">
<oscar:oscarPropertiesCheck property="eform_in_appointment" value="yes">
	&#124;<b><a href="#" onclick="popupPage(500,1024,'<%=request.getContextPath()%>/eform/efmformslistadd.jsp?parentAjaxId=eforms&demographic_no=<%=demographic_no%>&appointment=<%=appointment.getId()%>'); return false;"
		  title="eForms">e</a></b>
</oscar:oscarPropertiesCheck>
</security:oscarSec>

<!-- doctor code block 3 -->
<% if(bShowEncounterLink && !isWeekView) { %>
<% if ("true".equals(OscarProperties.getInstance().getProperty("newui.enabled", "false")) && oscar.OscarProperties.getInstance().isPropertyActive("SINGLE_PAGE_CHART")) {

	newUxUrl = "../web/#/record/" + demographic_no + "/";

	if(String.valueOf(demographic_no).equals(record) && !module.equals("summary")){
		newUxUrl =  newUxUrl + module;
		inContextStyle = "style='color: blue;'";
	}else{
		newUxUrl =  newUxUrl + "summary?appointmentNo=" + appointment.getId() + "&encType=face%20to%20face%20encounter%20with%20client";
		inContextStyle = "";
	}
%>
&#124; <a href="<%=newUxUrl%>" <%=inContextStyle %>><bean:message key="provider.appointmentProviderAdminDay.btnE"/>2</a>
<%}%>

<% String  eURL = "../oscarEncounter/IncomingEncounter.do?providerNo="
	+curUser_no+"&appointmentNo="
	+appointment.getId()
	+"&demographicNo="
	+demographic_no
	+"&curProviderNo="
	+curProvider_no[nProvider]
	+"&reason="
	+Encode.forUriComponent(reason)
	+"&encType="
	+URLEncoder.encode("face to face encounter with client","UTF-8")
	+"&userName="
	+URLEncoder.encode( userfirstname+" "+userlastname)
	+"&curDate="+curYear+"-"+curMonth+"-"
	+curDay+"&appointmentDate="+year+"-"
	+month+"-"+day+"&startTime="
	+ start_time + "&status="+status
	+ "&apptProvider_no="
	+ curProvider_no[nProvider]
			+ "&providerview="
	+ curProvider_no[nProvider];%>

<% if (showOldEchartLink) { %>
&#124; <a href=# class="encounterBtn" onClick="pop4WithApptNo(710, 1024,'<%=eURL%>','E',<%=appointment.getId()%>);return false;" title="<bean:message key="global.encounter"/>">
<bean:message key="provider.appointmentProviderAdminDay.btnE"/></a>
<% }} %>

<%= (bShortcutIntakeForm) ? "| <a href='#' onClick='pop3(700, 1024, \"formIntake.jsp?demographic_no="+demographic_no+"\")' title='Intake Form'>In</a>" : "" %>

<!--  eyeform open link -->
<% if (showEyeForm && !isWeekView) { %>
&#124; <a href="#" onClick='pop4(800, 1280, "<%=request.getContextPath()%>/eyeform/eyeform.jsp?demographic_no=<%=demographic_no %>&appointment_no=<%=appointment.getId()%>","EF<%=demographic_no %>");return false;' title="EyeForm">EF</a>
<% } %>

<!-- billing code block -->
<% if (!isWeekView) { %>
	<security:oscarSec roleName="<%=roleName$%>" objectName="_billing" rights="r">
	<%
	if(status.indexOf('B')==-1)
	{
	%>
        <oscar:oscarPropertiesCheck property="BILLING_PREFERENCE_BY_APPT_PROVIDER" value="yes" defaultVal="true">
        &#124; <a href=# onClick='pop4(755,1200, "<%=request.getContextPath()%>/billing.do?billRegion=<%=URLEncoder.encode(prov)%>&billForm=<%=URLEncoder.encode(oscarVariables.getProperty("default_view"))%>&hotclick=<%=URLEncoder.encode("")%>&appointment_no=<%=appointment.getId()%>&demographic_name=<%=URLEncoder.encode(name)%>&status=<%=status%>&demographic_no=<%=demographic_no%>&providerview=<%=curProvider_no[nProvider]%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curProvider_no[nProvider]%>&appointment_date=<%=year+"-"+month+"-"+day%>&start_time=<%=start_time%>&bNewForm=1","B");return false;' title="<bean:message key="global.billingtag"/>"><bean:message key="provider.appointmentProviderAdminDay.btnB"/></a>
        </oscar:oscarPropertiesCheck>
        <oscar:oscarPropertiesCheck property="BILLING_PREFERENCE_BY_APPT_PROVIDER" value="no">
        &#124; <a href=# onClick='popupPage(755,1200, "<%=request.getContextPath()%>/billing.do?billRegion=<%=URLEncoder.encode(prov)%>&billForm=<%=providerDefaultBillForm%>&hotclick=<%=URLEncoder.encode("")%>&appointment_no=<%=appointment.getId()%>&demographic_name=<%=URLEncoder.encode(name)%>&status=<%=status%>&demographic_no=<%=demographic_no%>&providerview=<%=curProvider_no[nProvider]%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curProvider_no[nProvider]%>&appointment_date=<%=year+"-"+month+"-"+day%>&start_time=<%=start_time%>&bNewForm=1");return false;' title="<bean:message key="global.billingtag"/>"><bean:message key="provider.appointmentProviderAdminDay.btnB"/></a>
        </oscar:oscarPropertiesCheck>
	<%
	}
	else
	{
		if(caisiBillingPreferenceNotDelete!=null && caisiBillingPreferenceNotDelete.equals("1"))
		{
	%>
			&#124; <a href=# onClick='pop4(700,720,"<%=request.getContextPath()%>/billing/CA/ON/billingEditWithApptNo.jsp?billRegion=<%=URLEncoder.encode(prov)%>&billForm=<%=URLEncoder.encode(oscarVariables.getProperty("default_view"))%>&hotclick=<%=URLEncoder.encode("")%>&appointment_no=<%=appointment.getId()%>&demographic_name=<%=URLEncoder.encode(name)%>&status=<%=status%>&demographic_no=<%=demographic_no%>&providerview=<%=curProvider_no[nProvider]%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curProvider_no[nProvider]%>&appointment_date=<%=year+"-"+month+"-"+day%>&start_time=<%=iS+":"+iSm%>&bNewForm=1","B");return false;' title="<bean:message key="global.billingtag"/>">=<bean:message key="provider.appointmentProviderAdminDay.btnB"/></a>
	<%
		}
		else
		{
	%>
		&#124; <a href=# onClick='onUnbilled("<%=request.getContextPath()%>/billing/CA/<%=prov%>/billingDeleteWithoutNo.jsp?status=<%=status%>&appointment_no=<%=appointment.getId()%>");return false;' title="<bean:message key="global.billingtag"/>">-<bean:message key="provider.appointmentProviderAdminDay.btnB"/></a>
	<%
		}
	}
	%>

<!--/security:oscarSec-->
	  </security:oscarSec>
<% } %>
<!-- billing code block -->
<security:oscarSec roleName="<%=roleName$%>" objectName="_masterLink" rights="r">

    &#124; <a class="masterBtn" href="javascript: function myFunction() {return false; }" onClick="pop4WithApptNo(700,1024,'<%=request.getContextPath()%>/demographic/demographiccontrol.jsp?demographic_no=<%=demographic_no%>&apptProvider=<%=curProvider_no[nProvider]%>&appointment=<%=appointment.getId()%>&displaymode=edit&dboperation=search_detail','M<%=demographic_no%>',<%=appointment.getId()%>)"
    title="<bean:message key="provider.appointmentProviderAdminDay.msgMasterFile"/>"><bean:message key="provider.appointmentProviderAdminDay.btnM"/></a>

</security:oscarSec>
      <% if (!isWeekView) { %>

<!-- doctor code block 4 -->

<security:oscarSec roleName="<%=roleName$%>" objectName="_appointment.doctorLink" rights="r">
     &#124; <a href=# onClick="pop4WithApptNo(737,1027,'<%=request.getContextPath()%>/oscarRx/choosePatient.do?providerNo=<%=curUser_no%>&demographicNo=<%=demographic_no%>','Rx<%=demographic_no%>',<%=appointment.getId()%>)" title="<bean:message key="global.prescriptions"/>"><bean:message key="global.rx"/>
      </a>
      <%if("true".equals(OscarProperties.getInstance().getProperty("newui.enabled", "false")) && OscarProperties.getInstance().isPropertyActive("RX2")) {
    		// This is temporary for testing the angularRx
    	  %>
	&#124; <a href=# onClick="pop4WithApptNo(737,1027,'<%=request.getContextPath()%>/webp/#!/record/<%=demographic_no%>/rx','rx',<%=appointment.getId()%>)" title="<bean:message key="global.prescriptions"/>"><bean:message key="global.rx"/>2
      </a>
      <%} %>

<!-- doctor color -->
<oscar:oscarPropertiesCheck property="ENABLE_APPT_DOC_COLOR" value="yes">
        <%
                String providerColor = null;
                if(view == 1 && demographicDao != null && userPropertyDao != null) {
                        String providerNo = (demographicDao.getDemographic(String.valueOf(demographic_no))==null?null:demographicDao.getDemographic(String.valueOf(demographic_no)).getProviderNo());
                        UserProperty property = userPropertyDao.getProp(providerNo, UserPropertyDAO.COLOR_PROPERTY);
                        if(property != null) {
                                providerColor = property.getValue();
                        }
                }
        %>
        <%= (providerColor != null ? "<span style=\"background-color:"+providerColor+";width:5px\">&nbsp;</span>" : "") %>
</oscar:oscarPropertiesCheck>

      <%
	  if("bc".equalsIgnoreCase(prov)){
	  if(patientHasOutstandingPrivateBills(String.valueOf(demographic_no))){
	  %>
	  &#124;<b style="color:#FF0000">$</b>
	  <%}}%>
      <oscar:oscarPropertiesCheck property="SHOW_APPT_REASON" value="yes" defaultVal="true">
     		<span class="reason_<%=curProvider_no[nProvider]%> ${ hideReason ? "hideReason" : "" }">
     			<strong>&#124;<%=reasonCodeName==null?"":"&nbsp;" + reasonCodeName + " -"%><%=reason==null?"":"&nbsp;" + reason%></strong>
     		</span>
      </oscar:oscarPropertiesCheck>

	</security:oscarSec>

	  <!-- add one link to caisi Program Management Module -->
	  <caisi:isModuleLoad moduleName="caisi">
                <%-- <a href=# onClick="popupPage(700, 1048,'<%=request.getContextPath()%>/PMmodule/ClientManager.do?id=<%=demographic_no%>')" title="Program Management">|P</a>--%>
	  	<a href='<%=request.getContextPath()%>/PMmodule/ClientManager.do?id=<%=demographic_no%>' title="Program Management">|P</a>
    </caisi:isModuleLoad>
          <%

      if(isBirthday(monthDay,demBday)){%>
       	&#124; <img src="<%=request.getContextPath()%>/images/cake.gif" height="20" alt="Happy Birthday"/>
      <%}%>

      <%String appointment_no=appointment.getId().toString();
      	request.setAttribute("providerPreference", providerPreference);
      	Date appointmentDate = appointmentDateTimeFormat.parse(strYear + "-" + strMonth + "-" + strDay + " " + start_time);
      %>
      <c:set var="demographic_no" value="<%=demographic_no %>" />
      <c:set var="appointment_no" value="<%=appointment_no %>" />
      <c:set var="appointment_date" value="<%=appointmentDate.getTime()%>" />

	  <jsp:include page="appointmentFormsLinks.jspf">
	  	<jsp:param value="${demographic_no}" name="demographic_no"/>
	  	<jsp:param value="${appointment_no}" name="appointment_no"/>
	  	<jsp:param value="${appointment_date}" name="appointment_date"/>
	  </jsp:include>

	<oscar:oscarPropertiesCheck property="appt_pregnancy" value="true" defaultVal="false">

		<c:set var="demographicNo" value="<%=demographic_no %>" />
	   <jsp:include page="appointmentPregnancy.jspf" >
	   	<jsp:param value="${demographicNo}" name="demographicNo"/>
	   </jsp:include>

	</oscar:oscarPropertiesCheck>

<% }} %>
        	</font></td>
        <%
        			}
        		}
        			bFirstFirstR = false;
          	}
            //out.println("<td width='1'>&nbsp;</td></tr>"); give a grid display
            out.println("<td class='noGrid' width='1'></td></tr>"); //no grid display
          }
				%>

          </table> <!-- end table for each provider schedule display -->
<!-- caisi infirmary view extension add fffffffffff-->
</logic:notEqual>
<!-- caisi infirmary view extension add end fffffffffffffff-->

         </td></tr>
          <tr><td class="infirmaryView" ALIGN="center" BGCOLOR="<%=bColor?"silver":"silver"%>">
<!-- caisi infirmary view extension modify fffffffffffffffffff-->
<logic:notEqual name="infirmaryView_isOscar" value="false">

      <% if (isWeekView) { %>
          <b><a href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=day%>&view=0&displaymode=day&dboperation=searchappointmentday"><%=formatDate%></a></b>
      <% } else { %>
          <b><input type='button' value="<bean:message key="provider.appointmentProviderAdminDay.weekLetter"/>" name='weekview' onClick=goWeekView('<%=curProvider_no[nProvider]%>') title="<bean:message key="provider.appointmentProviderAdminDay.weekView"/>"  class="noprint s">
          <input type='button' value="<bean:message key="provider.appointmentProviderAdminDay.searchLetter"/>" name='searchview' onClick=goSearchView('<%=curProvider_no[nProvider]%>') title="<bean:message key="provider.appointmentProviderAdminDay.searchView"/>"  class="noprint s">
          <b><input type='radio' name='flipview' class="noprint" onClick="goFilpView('<%=curProvider_no[nProvider]%>')" title="Flip view"  >
          <a href=# onClick="goZoomView('<%=curProvider_no[nProvider]%>','<%=StringEscapeUtils.escapeJavaScript(curProviderName[nProvider])%>')" onDblClick="goFilpView('<%=curProvider_no[nProvider]%>')" title="<bean:message key="provider.appointmentProviderAdminDay.zoomView"/>" >
          <!--a href="providercontrol.jsp?year=<%=strYear%>&month=<%=strMonth%>&day=<%=strDay%>&view=1&curProvider=<%=curProvider_no[nProvider]%>&curProviderName=<%=curProviderName[nProvider]%>&displaymode=day&dboperation=searchappointmentday" title="<bean:message key="provider.appointmentProviderAdminDay.zoomView"/>"-->
          <%=curProviderName[nProvider]%></a></b>
          <button class="ds-btn" type="button" data-provider_no="<%=curProvider_no[nProvider]%>">DS</button>
      <% } %>

          <% if(!userAvail) { %>
          [<bean:message key="provider.appointmentProviderAdminDay.msgNotOnSched"/>]
          <% } %>
</logic:notEqual>
<logic:equal name="infirmaryView_isOscar" value="false">
	<%String prID="1"; %>
	<logic:present name="infirmaryView_programId">
        <%prID=(String)session.getAttribute(SessionConstants.CURRENT_PROGRAM_ID); %>
	</logic:present>
	<logic:iterate id="pb" name="infirmaryView_programBeans" type="org.apache.struts.util.LabelValueBean">
	  	<%if (pb.getValue().equals(prID)) {%>
  		<b><%=pb.getLabel()%></label></b>
		<%} %>
  	</logic:iterate>
</logic:equal>
<!-- caisi infirmary view extension modify end -->
          </td></tr>

       </table><!-- end table for each provider name -->

            </td>
 <%
   } //end of display team a, etc.

 %>


          </tr>
<% } // end caseload view %>
        </table>        <!-- end table for the whole schedule row display -->




        </td>
      </tr>

      <tr><td colspan="3">
              <table  WIDTH="100%" class="noprint">
                  <tr>
                      <td class="bottombar" width="60%">




                                 <a class="redArrow" href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=isWeekView?(day-7):(day-1)%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=day&dboperation=searchappointmentday<%=isWeekView?"&provider_no="+provNum:""%>&viewall=<%=viewall%>">
         &nbsp;&nbsp;<i class="icon-angle-left icon-large" title="<bean:message key="provider.appointmentProviderAdminDay.viewPrevDay"/>"></i></a>



 <span class="dateAppointment" id="otherDate" ><%
 	if (isWeekView) {
 %><bean:message key="provider.appointmentProviderAdminDay.week"/> <%=week%><%
 	} else {
 %>
    <% if (showLargeCalendar) { %>
    <a id="calendarLink" href=# onClick ="popupPage(425,430,'<%=request.getContextPath()%>/share/CalendarPopup.jsp?urlfrom=<%=request.getContextPath()%>/provider/providercontrol.jsp&year=<%=strYear%>&month=<%=strMonth%>&param=<%=URLEncoder.encode("&view=0&displaymode=day&dboperation=searchappointmentday&viewall="+viewall,"UTF-8")%><%=isWeekView?URLEncoder.encode("&provider_no="+provNum, "UTF-8"):""%>')" title="<bean:message key="tickler.ticklerEdit.calendarLookup"/>" ><%=formatDate%></a>
    <% } else { %>

<%=formatDate%><%
 	}
 %>
<%
 	}
 %></span>

 <a class="redArrow" href="providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=<%=isWeekView?(day+7):(day+1)%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=day&dboperation=searchappointmentday<%=isWeekView?"&provider_no="+provNum:""%>&viewall=<%=viewall%>">
 <i class="icon-angle-right icon-large" title="<bean:message key="provider.appointmentProviderAdminDay.viewNextDay"/>"></i>&nbsp;&nbsp;</a>



</td>
                      <td ALIGN="RIGHT" class="topBar">
                          <a href="<%=request.getContextPath()%>/logout.jsp"><i class="icon-off icon-large" title="<bean:message key="global.btnLogout"/>"></i>&nbsp;</a>
                      </td>
                  </tr>
              </table>
		</td></tr>

	</table>
	</td></tr>
</table>
</body>
<!-- key shortcut hotkey block added by phc -->
<script language="JavaScript">

// popup blocking for the site must be off!
// developed on Windows FF 2, 3 IE 6 Linux FF 1.5
// FF on Mac and Opera on Windows work but will require shift or control with alt and Alpha
// to fire the altKey + Alpha combination - strange

// Modification Notes:
//     event propagation has not been blocked beyond returning false for onkeydown (onkeypress may or may not fire depending)
//     keyevents have not been even remotely standardized so test mods across agents/systems or something will break!
//     use popupOscarRx so that this codeblock can be cut and pasted to appointmentprovideradminmonth.jsp

// Internationalization Notes:
//     underlines should be added to the labels to prompt/remind the user and should correspond to
//     the actual key whose keydown fires, which is also stored in the oscarResources.properties files
//     if you are using the keydown/up event the value stored is the actual key code
//     which, at least with a US keyboard, also is the uppercase utf-8 code, ie A keyCode=65

document.onkeydown=function(e){
	evt = e || window.event;  // window.event is the IE equivalent
	if (evt.altKey) {
		//use (evt.altKey || evt.metaKey) for Mac if you want Apple+A, you will probably want a seperate onkeypress handler in that case to return false to prevent propagation
		switch(evt.keyCode) {
			case <bean:message key="global.adminShortcut"/> : newWindow("<%=request.getContextPath()%>/administration/","admin");  return false;  //run code for 'A'dmin
			case <bean:message key="global.billingShortcut"/> : pop4(600,1024,'<%=request.getContextPath()%>/billing/CA/<%=prov%>/billingReportCenter.jsp?displaymode=billreport&providerview=<%=curUser_no%>','bill');return false;  //code for 'B'illing
			case <bean:message key="global.calendarShortcut"/> : pop3(425,430,'<%=request.getContextPath()%>/share/CalendarPopup.jsp?urlfrom=<%=request.getContextPath()%>/provider/providercontrol.jsp&year=<%=strYear%>&month=<%=strMonth%>&param=<%=URLEncoder.encode("&view=0&displaymode=day&dboperation=searchappointmentday","UTF-8")%>');  return false;  //run code for 'C'alendar
			case <bean:message key="global.edocShortcut"/> : pop4('700', '1024', '<%=request.getContextPath()%>/dms/documentReport.jsp?function=provider&functionid=<%=curUser_no%>&curUser=<%=curUser_no%>', 'edocView');  return false;  //run code for e'D'oc
			case <bean:message key="global.resourcesShortcut"/> : pop3(550,687,'<%=resourcebaseurl%>'); return false; // code for R'e'sources
 			case <bean:message key="global.helpShortcut"/> : pop3(600,750,'<%=resourcebaseurl%>');  return false;  //run code for 'H'elp
			case <bean:message key="global.ticklerShortcut"/> : {
				<caisi:isModuleLoad moduleName="ticklerplus" reverse="true">
					pop3(700,1024,'<%=request.getContextPath()%>/tickler/ticklerMain.jsp','<bean:message key="global.tickler"/>') //run code for t'I'ckler
				</caisi:isModuleLoad>
				<caisi:isModuleLoad moduleName="ticklerplus">
					pop3(700,1024,'<%=request.getContextPath()%>/Tickler.do','<bean:message key="global.tickler"/>'); //run code for t'I'ckler+
				</caisi:isModuleLoad>
				return false;
			}
			case <bean:message key="global.labShortcut"/> : pop4(600,1024,'<%=request.getContextPath()%>/dms/inboxManage.do?method=prepareForIndexPage&providerNo=<%=curUser_no%>', '<bean:message key="global.lab"/>');  return false;  //run code for 'L'ab
			case <bean:message key="global.msgShortcut"/> : pop4(600,1024,'<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.do?providerNo=<%=curUser_no%>&userName=<%=URLEncoder.encode(userfirstname+" "+userlastname)%>','msg'); return false;  //run code for 'M'essage
			case <bean:message key="global.monthShortcut"/> : window.open("providercontrol.jsp?year=<%=year%>&month=<%=month%>&day=1&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=month&dboperation=searchappointmentmonth","_self"); return false ;  //run code for Mo'n'th
			case <bean:message key="global.conShortcut"/> : pop4(625,1024,'<%=request.getContextPath()%>/oscarEncounter/IncomingConsultation.do?providerNo=<%=curUser_no%>&userName=<%=URLEncoder.encode(userfirstname+" "+userlastname)%>','consults');  return false;  //run code for c'O'nsultation
			case <bean:message key="global.reportShortcut"/> : pop4(650,1024,'<%=request.getContextPath()%>/report/reportindex.jsp','reportPage');  return false;  //run code for 'R'eports
			case <bean:message key="global.prefShortcut"/> : {
				    <caisi:isModuleLoad moduleName="ticklerplus">
					pop4(715,680,'providerpreference.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&mygroup_no=<%=mygroupno%>&caisiBillingPreferenceNotDelete=<%=caisiBillingPreferenceNotDelete%>&new_tickler_warning_window=<%=newticklerwarningwindow%>&default_pmm=<%=default_pmm%>','providerPref'); //run code for tickler+ 'P'references
					return false;
				    </caisi:isModuleLoad>
			            <caisi:isModuleLoad moduleName="ticklerplus" reverse="true">
					pop4(715,680,'providerpreference.jsp?provider_no=<%=curUser_no%>&start_hour=<%=startHour%>&end_hour=<%=endHour%>&every_min=<%=everyMin%>&mygroup_no=<%=mygroupno%>','providerPref'); //run code for 'P'references
					return false;
			            </caisi:isModuleLoad>
			}
			case <bean:message key="global.searchShortcut"/> : pop4(550,687,'<%=request.getContextPath()%>/demographic/search.jsp','search');  return false;  //run code for 'S'earch
			case <bean:message key="global.dayShortcut"/> : window.open("providercontrol.jsp?year=<%=curYear%>&month=<%=curMonth%>&day=<%=curDay%>&view=<%=view==0?"0":("1&curProvider="+request.getParameter("curProvider")+"&curProviderName="+URLEncoder.encode(request.getParameter("curProviderName"),"UTF-8") )%>&displaymode=day&dboperation=searchappointmentday","_self") ;  return false;  //run code for 'T'oday
			case <bean:message key="global.viewShortcut"/> : {
				<% if(request.getParameter("viewall")!=null && request.getParameter("viewall").equals("1") ) { %>
				         review('0');  return false; //scheduled providers 'V'iew
				<% } else {  %>
				         review('1');  return false; //all providers 'V'iew
				<% } %>
			}
			case <bean:message key="global.workflowShortcut"/> : pop3(700,1024,'<%=request.getContextPath()%>/oscarWorkflow/WorkFlowList.jsp','<bean:message key="global.workflow"/>'); return false ; //code for 'W'orkflow

			default : return;
               }
	}
	if (evt.ctrlKey) {
               switch(evt.keyCode || evt.charCode) {
			case <bean:message key="global.btnLogoutShortcut"/> : window.open('<%=request.getContextPath()%>/logout.jsp','_self');  return false;  // 'Q'uit/log out
			default : return;
               }

        }
}

</script>
<script>
jQuery(document).ready(function(){
	jQuery('.ds-btn').on( "click", function(){
		//var provider_no = '<%=curUser_no%>';
		var provider_no = jQuery(this).attr('data-provider_no');
		var y = '<%=request.getParameter("year")%>';
		var m = '<%=request.getParameter("month")%>';
		var d = '<%=request.getParameter("day")%>';
		var sTime = 8;
		var eTime = 20;
		var dateStr = y + '-' + m + '-' + d;
		var url = '<%=request.getContextPath()%>/report/reportdaysheet.jsp?dsmode=all&provider_no=' + provider_no
				+ '&sdate=' + dateStr + '&edate=' + dateStr + '&sTime=' + sTime + '&eTime=' + eTime;
		popupPage(600,750, url);
		return false;
	});
});
</script>
<!-- end of keycode block -->

<% if (!showLargeCalendar) { %>
    <script type="text/javascript">
    // setup small calendars with the date from the passed values
    var extdate= "<%=strYear%>"+"-"+"<%=strMonth%>"+"-"+"<%=strDay%>";
	Calendar.setup( { inputField : "storeday", ifFormat : "%Y-%m-%d",  button : "theday"} );
    Calendar.setup( { inputField : "storeday", ifFormat : "%Y-%m-%d",  button : "otherDate"} );
    </script>
<% } %>

<% if (OscarProperties.getInstance().getBooleanProperty("indivica_hc_read_enabled", "true")) { %>
<jsp:include page="/hcHandler/hcHandler.html"/>
<% } %>
</html:html>

<%!public boolean checkRestriction(List<MyGroupAccessRestriction> restrictions, String name) {
                for(MyGroupAccessRestriction restriction:restrictions) {
                        if(restriction.getMyGroupNo().equals(name))
                                return true;
                }
                return false;
        }%>