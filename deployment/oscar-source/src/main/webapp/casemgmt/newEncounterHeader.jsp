
<%--


    Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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

    This software was written for
    Centre for Research on Inner City Health, St. Michael's Hospital,
    Toronto, Ontario, Canada

--%>


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="oscar.oscarEncounter.data.*, oscar.oscarProvider.data.*, oscar.util.UtilDateUtilities" %>
<%@ page import="org.oscarehr.util.MiscUtils"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="org.oscarehr.PMmodule.caisi_integrator.CaisiIntegratorManager, org.oscarehr.util.LoggedInInfo, org.oscarehr.common.model.Facility" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@ page import="org.oscarehr.common.model.DemographicExt" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

    oscar.oscarEncounter.pageUtil.EctSessionBean bean = null;
    if((bean=(oscar.oscarEncounter.pageUtil.EctSessionBean)request.getSession().getAttribute("EctSessionBean"))==null) {
        response.sendRedirect("error.jsp");
        return;
    }

    Facility facility = loggedInInfo.getCurrentFacility();

    String demoNo = bean.demographicNo;
    EctPatientData.Patient pd = new EctPatientData().getPatient(loggedInInfo, demoNo);
    String famDocName, famDocSurname, famDocColour, inverseUserColour, userColour;
    String user = (String) session.getAttribute("user");
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    ProviderColourUpdater colourUpdater = new ProviderColourUpdater(user);
    userColour = colourUpdater.getColour();

	String privateConsentEnabledProperty = OscarProperties.getInstance().getProperty("privateConsentEnabled");
    String help_url = (OscarProperties.getInstance().getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/")).trim();
	boolean privateConsentEnabled = privateConsentEnabledProperty != null && privateConsentEnabledProperty.equals("true");
	DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
    DemographicExt infoExt = demographicExtDao.getDemographicExt(Integer.parseInt(demoNo), "informedConsent");
    boolean showPopup = infoExt == null || StringUtils.isBlank(infoExt.getValue());
    Map<String,String> demoExt = demographicExtDao.getAllValuesForDemo(Integer.parseInt(demoNo));
    DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
    Demographic demographic = demographicDao.getDemographic(demoNo);

    //we calculate inverse of provider colour for text
    int base = 16;
    if( userColour == null || userColour.length() == 0 )
        userColour = "#CCCCFF";   //default blue if no preference set

    int num = Integer.parseInt(userColour.substring(1), base);      //strip leading # sign and convert
    int inv = ~num;                                                 //get inverse
    inverseUserColour = Integer.toHexString(inv).substring(2);    //strip 2 leading digits as html colour codes are 24bits

    if(bean.familyDoctorNo == null || bean.familyDoctorNo.equals("")) {
        famDocName = "";
        famDocSurname = "";
        famDocColour = "";
    }
    else {
        EctProviderData.Provider prov = new EctProviderData().getProvider(bean.familyDoctorNo);
        famDocName =  prov == null || prov.getFirstName() == null ? "" : prov.getFirstName();
        famDocSurname = prov == null || prov.getSurname() == null ? "" : prov.getSurname();
        colourUpdater = new ProviderColourUpdater(bean.familyDoctorNo);
        famDocColour = colourUpdater.getColour();
        if( famDocColour.length() == 0 )
            famDocColour = "#CCCCFF";
    }

    String patientAge = pd.getAge();
    String patientSex = pd.getSex();
    String pAge = Integer.toString(UtilDateUtilities.calcAge(bean.yearOfBirth,bean.monthOfBirth,bean.dateOfBirth));

    java.util.Locale vLocale =(java.util.Locale)session.getAttribute(org.apache.struts.Globals.LOCALE_KEY);

    SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
    Map<String, Boolean> echartPreferences = systemPreferencesDao.findByKeysAsMap(SystemPreferences.ECHART_PREFERENCE_KEYS);
    Map<String, Boolean> generalSettingsMap = systemPreferencesDao.findByKeysAsMap(SystemPreferences.GENERAL_SETTINGS_KEYS);

    boolean replaceNameWithPreferred = generalSettingsMap.getOrDefault("replace_demographic_name_with_preferred", false);
    boolean showEmailIndicator = echartPreferences.getOrDefault("echart_email_indicator", true) && StringUtils.isNotEmpty(bean.email);
    boolean showOLIS = echartPreferences.getOrDefault("echart_show_OLIS", false);
    boolean showHIN = echartPreferences.getOrDefault("echart_show_HIN", false);
    boolean showDOB = echartPreferences.getOrDefault("echart_show_DOB", false);
    boolean showCell = echartPreferences.getOrDefault("echart_show_cell", true);

    StringBuilder patientName = new StringBuilder();
    patientName.append(demographic.getLastName())
               .append(", ");
    if (replaceNameWithPreferred && StringUtils.isNotEmpty(demographic.getAlias())) {
        patientName.append(demographic.getPrefName());
    } else {
        patientName.append(demographic.getFirstName());
        if (StringUtils.isNotEmpty(demographic.getAlias())) {
            patientName.append(" (").append(demographic.getAlias()).append(")");
        }
    }
    if (StringUtils.isNotEmpty(demographic.getPronoun())) {
        patientName.append("; ").append(demographic.getPronoun());
    }
    %>
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

<script>
	function copySpanToClipboard(id) {
	    var range = document.createRange();
	    range.selectNode(document.getElementById(id));
	    window.getSelection().removeAllRanges(); // clear current selection
	    window.getSelection().addRange(range); // to select text
	    document.execCommand("copy");
	    window.getSelection().removeAllRanges();// to deselect
	}
</script>

    <c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>

<div style="float:left; width: 99.8%; padding-left:2px; text-align:left; font-size: 12px; color:<%=inverseUserColour%>; background-color:<%=userColour%>" id="encounterHeader">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
    <security:oscarSec roleName="<%=roleName$%>" objectName="_newCasemgmt.doctorName" rights="r">
    <span style="border-bottom: medium solid <%=famDocColour%>"><bean:message key="oscarEncounter.Index.msgMRP"/>&nbsp;&nbsp;
    <%=Encode.forHtml(famDocName.toUpperCase()+" "+famDocSurname.toUpperCase())%>  </span>
	</security:oscarSec>
    <span class="Header" style="color:<%=inverseUserColour%>; background-color:<%=userColour%>">
        <%
            String appointmentNo = request.getParameter("appointmentNo");
            String winName = "Master" + bean.demographicNo;
            String url = "/demographic/demographiccontrol.jsp?demographic_no=" + bean.demographicNo + "&amp;displaymode=edit&amp;dboperation=search_detail&appointment="+appointmentNo;
        %>

        &nbsp;
        <a href="#" onClick="popupPage(913,1386,'<%=winName%>','<c:out value="${ctx}"/><%=url%>'); return false;" title="<bean:message key="provider.appointmentProviderAdminDay.msgMasterFile"/>"><%=Encode.forHtmlContent(patientName.toString()) %></a>

        <%=bean.patientSex%>

        <% if (showDOB) { %>
	        <span id="age" title="<%=bean.patientAge%>" onclick="copySpanToClipboard(this.id)"><%=bean.yearOfBirth%>-<%=bean.monthOfBirth%>-<%=bean.dateOfBirth%></span>
        <% } else { %>
        	<span id="dob" title="<%=bean.yearOfBirth%>-<%=bean.monthOfBirth%>-<%=bean.dateOfBirth%>" onclick="copySpanToClipboard(this.id)"><%=bean.patientAge%></span>
        <% }  %>
        &nbsp;



        <% if (showHIN) { %>
	        <bean:message key="oscarencounter.header.hin"/>&nbsp;<span id="hin" onclick="copySpanToClipboard(this.id)"><%=bean.hin%></span>
	        &nbsp;
        <% } %>
        <oscar:phrverification demographicNo="<%=demoNo%>"><bean:message key="phr.verification.link"/></oscar:phrverification>
        &nbsp;

       <% String STAR="*";
            if ( !StringUtils.endsWith(StringUtils.trimToEmpty(demoExt.get("demo_cell")),STAR) &&  !StringUtils.endsWith(StringUtils.trimToEmpty(bean.phone),STAR) &&  !StringUtils.endsWith(StringUtils.trimToEmpty(demographic.getPhone2()),STAR) ) {
                //no patient preference noted so invoke logic for provider preference
                if ( showCell && !StringUtils.isEmpty(StringUtils.trimToEmpty(demoExt.get("demo_cell"))) ) { %>
                            <i class="icon-mobile-phone" title="<bean:message key="oscarencounter.header.cell"/>"></i>&nbsp;
                            <span id="cell" title="<bean:message key="oscarencounter.header.phone"/>&nbsp;<%=bean.phone%>" onclick="copySpanToClipboard(this.id)"><%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%></span>
                        <% } else { %>
                            <i class="icon-phone" title="<bean:message key="oscarencounter.header.phone"/>"></i>&nbsp;<span id="tel" title="<bean:message key="oscarencounter.header.cell"/>&nbsp;<%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%>" onclick="copySpanToClipboard(this.id)"><%=bean.phone%></span>
                <% }
                } else {
                    if ( StringUtils.endsWith(StringUtils.trimToEmpty(demoExt.get("demo_cell")),STAR) ) { %>
                            <i class="icon-mobile-phone" title="<bean:message key="oscarencounter.header.cell"/>"></i>
                            <span id="cell" title="<bean:message key="oscarencounter.header.phone"/>&nbsp;<%=bean.phone%>" onclick="copySpanToClipboard(this.id)"><%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%></span>
                 <% }
                    if ( StringUtils.endsWith(StringUtils.trimToEmpty(bean.phone),STAR)) { %>
                            <i class="icon-phone" title="<bean:message key="oscarencounter.header.phone"/>"></i>&nbsp;<span id="tel" title="<bean:message key="oscarencounter.header.cell"/>&nbsp;<%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%>" onclick="copySpanToClipboard(this.id)"><%=bean.phone%></span>
                    <% }
                    if ( StringUtils.endsWith(StringUtils.trimToEmpty(demographic.getPhone2()),STAR)) { %>
                            <i class="icon-briefcase" title="<bean:message key="demographic.demographicaddrecordhtm.formPhoneWork"/>"></i>&nbsp;<span id="tel" title="<bean:message key="oscarencounter.header.cell"/>&nbsp;<%=StringUtils.trimToEmpty(demoExt.get("demo_cell"))%>" onclick="copySpanToClipboard(this.id)"><%=demographic.getPhone2()%></span>
                    <% }
                }
        %>
        &nbsp;
        <% if (showEmailIndicator) { %>
        	<% if (demographic.getConsentToUseEmailForCare() != null && demographic.getConsentToUseEmailForCare()){ %>
	        	<a href="mailto:<%=bean.email%>?subject=Message from your Doctors Office" target="_blank" rel="noopener noreferrer" ><%=bean.email%></a>
        	<% } else { %>
        		<span id="email" onclick="copySpanToClipboard(this.id)"><%=bean.email%></span>
        	<% }  %>
            &nbsp;
        <% }  %>

		<span id="encounterHeaderExt"></span>
		<security:oscarSec roleName="<%=roleName$%>" objectName="_newCasemgmt.apptHistory" rights="r">
		<a href="javascript:popupPage(555,1000,'ApptHist','<c:out value="${ctx}"/>/demographic/demographiccontrol.jsp?demographic_no=<%=bean.demographicNo%>&amp;last_name=<%=bean.patientLastName.replaceAll("'", "\\\\'")%>&amp;first_name=<%=bean.patientFirstName.replaceAll("'", "\\\\'")%>&amp;orderby=appointment_date&amp;displaymode=appt_history&amp;dboperation=appt_history&amp;limit1=0&amp;limit2=25')" style="font-size: 11px;text-decoration:none;" title="<bean:message key="oscarEncounter.Header.nextApptMsg"/>"><span style="margin-left:20px;"><bean:message key="oscarEncounter.Header.nextAppt"/>: <oscar:nextAppt demographicNo="<%=bean.demographicNo%>"/></span></a>
		</security:oscarSec>
        &nbsp;
		<% if(oscar.OscarProperties.getInstance().hasProperty("ONTARIO_MD_INCOMINGREQUESTOR")){%>
           <a href="javascript:void(0)" onClick="popupPage(600,175,'Calculators','<c:out value="${ctx}"/>/common/omdDiseaseList.jsp?sex=<%=bean.patientSex%>&age=<%=pAge%>'); return false;" ><bean:message key="oscarEncounter.Header.OntMD"/></a>
           &nbsp;
        <%}
		if (oscar.OscarProperties.getInstance().hasProperty("kaiemr_lab_queue_url")) {%>
            <a href="javascript:void(0)" id="work_lab_button" title='Lab Queue' onclick="popupPage(700, 1215,'work_queue', '<%=OscarProperties.getInstance().getProperty("kaiemr_lab_queue_url")%>?demographicNo=<%=bean.demographicNo%>')">Lab Queue</a>
            &nbsp;
		<%}%>

        <%=getEChartLinks() %>
        &nbsp;
        <% if (showOLIS) { %>
			<a href="javascript:popupPage(800,1000, 'olis_search', '<%=request.getContextPath()%>/olis/Search.jsp?demographicNo=<%=demoNo%>')">OLIS Search</a>
        	&nbsp;        <% } %>

        <% if (OscarProperties.getInstance().isPropertyActive("moh_file_management_enabled")) { %>
        <a href="javascript:popupPage(900,1100, 'outside_use_report', '<%=request.getContextPath()%>/billing/CA/ON/outsideUse.jsp?demographic_no=<%=demoNo%>')">OU</a>
        &nbsp;
        <% } %>

		<%
		if (facility.isIntegratorEnabled()){
			int secondsTillConsideredStale = -1;
			try{
				secondsTillConsideredStale = Integer.parseInt(oscar.OscarProperties.getInstance().getProperty("seconds_till_considered_stale"));
			}catch(Exception e){
				MiscUtils.getLogger().error("OSCAR Property: seconds_till_considered_stale did not parse to an int",e);
				secondsTillConsideredStale = -1;
			}

			boolean allSynced = true;

			try{
				allSynced  = CaisiIntegratorManager.haveAllRemoteFacilitiesSyncedIn(loggedInInfo, loggedInInfo.getCurrentFacility(), secondsTillConsideredStale,false);
				CaisiIntegratorManager.setIntegratorOffline(session, false);
			}catch(Exception remoteFacilityException){
				MiscUtils.getLogger().error("Error checking Remote Facilities Sync status",remoteFacilityException);
				CaisiIntegratorManager.checkForConnectionError(session, remoteFacilityException);
			}
			if(secondsTillConsideredStale == -1){
				allSynced = true;
			}
		%>
			<%if (CaisiIntegratorManager.isIntegratorOffline(session)) {%>
    			<div style="background: none repeat scroll 0% 0% red; color: white; font-weight: bold; padding-left: 10px; margin-bottom: 2px;"><bean:message key="oscarEncounter.integrator.NA"/></div>
    		<%}else if(!allSynced) {%>
    			<div style="background: none repeat scroll 0% 0% orange; color: white; font-weight: bold; padding-left: 10px; margin-bottom: 2px;"><bean:message key="oscarEncounter.integrator.outOfSync"/>
    			&nbsp;&nbsp;
				<a href="javascript:void(0)" onClick="popupPage(233,600,'ViewICommun','<c:out value="${ctx}"/>/admin/viewIntegratedCommunity.jsp'); return false;" >Integrator</a>
    			</div>
	    	<%}else{%>
	    		<a href="javascript:void(0)" onClick="popupPage(233,600,'ViewICommun','<c:out value="${ctx}"/>/admin/viewIntegratedCommunity.jsp'); return false;" >I</a>
	    	<%}%>
	  <%}%>
   </span>
</td>
<td align=right>
	<span class="HelpAboutLogout">
	<a style="font-size:10px;font-style:normal;" href="<%=help_url%>echart/" target="_blank"><bean:message key="global.help" /></a>&nbsp;|
	<a style="font-size:10px;font-style:normal;" href="javascript:void(0)" onclick="window.open('<%=request.getContextPath()%>/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,top=0')"><bean:message key="global.about" /></a>
	</span>
</td>
</tr>
</table>
</div>

<%!

String getEChartLinks(){
	String str = oscar.OscarProperties.getInstance().getProperty("ECHART_LINK");
		if (str == null){
			return "";
		}
		try{
			String[] httpLink = str.split("\\|");
 			return "<a target=\"_blank\" href=\""+httpLink[1]+"\">"+httpLink[0]+"</a>";
		}catch(Exception e){
			MiscUtils.getLogger().error("ECHART_LINK is not in the correct format. title|url :"+str, e);
		}
		return "";
}
%>