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
<security:oscarSec roleName="<%=roleName$%>" objectName="_con" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../securityError.jsp?type=_con");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="org.oscarehr.common.dao.ConsultationRequestDao"%>
<%@ page import="oscar.oscarEncounter.pageUtil.*,java.text.*,java.util.*"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO, org.oscarehr.common.model.UserProperty, org.springframework.web.context.support.WebApplicationContextUtils" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>

<%@ page import="org.oscarehr.common.model.Site"%>
<%@ page import="org.oscarehr.common.dao.SiteDao"%>

<%@ page import="org.oscarehr.common.model.ProviderData"%>
<%@ page import="org.oscarehr.common.dao.ProviderDataDao"%>

<%@ page import="org.oscarehr.common.dao.ConsultationServiceDao" %>
<%@ page import="org.oscarehr.common.model.ConsultationServices" %>
<%@ page import="oscar.OscarProperties"%>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<%
    String curProvider_no = (String) session.getAttribute("user");
    
    boolean isSiteAccessPrivacy=false;
    boolean isTeamAccessPrivacy=false; 
    boolean bMultisites=org.oscarehr.common.IsPropertiesOn.isMultisitesEnable();
    List<String> mgrSite = new ArrayList<String>();
    
	ProviderDataDao providerDataDao = SpringUtils.getBean(ProviderDataDao.class);
	
	String strLimit =  request.getParameter("limit");
	String strOffset = request.getParameter("offset");
	
	Integer limit = ConsultationRequestDao.DEFAULT_CONSULT_REQUEST_RESULTS_LIMIT;
	Integer offset = 0;
	
	try {
		offset = Integer.parseInt(strOffset);
	} catch(NumberFormatException e) {
		offset = 0;
	}
	
	try {
		limit = Integer.parseInt(strLimit);
	} catch(NumberFormatException e) {
		limit = 100;
	}
	
	
	

%>
<security:oscarSec objectName="_site_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false"> <%isSiteAccessPrivacy=true; %></security:oscarSec>
<security:oscarSec objectName="_team_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false"> <%isTeamAccessPrivacy=true; %></security:oscarSec>

<% 
List<ProviderData> pdList = null;
HashMap<String,String> providerMap = new HashMap<String,String>();

//multisites function
if (isSiteAccessPrivacy || isTeamAccessPrivacy) {

	if (isSiteAccessPrivacy) 
		pdList = providerDataDao.findByProviderSite(curProvider_no);
	
	if (isTeamAccessPrivacy) 
		pdList = providerDataDao.findByProviderTeam(curProvider_no);

	for(ProviderData providerData : pdList) {
		providerMap.put(providerData.getId(), "true");
	}
}
%>

<%
//multi-site office , save all bgcolor to Hashmap
HashMap<String,String> siteBgColor = new HashMap<String,String>();
HashMap<String,String> siteShortName = new HashMap<String,String>();
if (bMultisites) {
   	SiteDao siteDao = (SiteDao)WebApplicationContextUtils.getWebApplicationContext(application).getBean("siteDao");
   	
   	List<Site> sites = siteDao.getAllSites();
   	for (Site st : sites) {
   		siteBgColor.put(st.getName(),st.getBgColor());
   		siteShortName.put(st.getName(),st.getShortName());
   	}
   	List<Site> providerSites = siteDao.getActiveSitesByProviderNo(curProvider_no);
   	for (Site st : providerSites) {
   		mgrSite.add(st.getName());
   	}
}
%>

<html:html locale="true">

<%

  String team = (String) request.getAttribute("teamVar");
  if (team == null){
    team = new String();
  }

  Boolean includeBool = (Boolean) request.getAttribute("includeCompleted");  
  boolean includeCompleted = false;  
  if(includeBool != null){
     includeCompleted  = includeBool.booleanValue();    
  }
  
  Date startDate = (Date) request.getAttribute("startDate");               
  Date endDate = (Date) request.getAttribute("endDate");    
  String orderby = (String) request.getAttribute("orderby");
  String desc = (String) request.getAttribute("desc");
  String searchDate = (String) request.getAttribute("searchDate");

UserPropertyDAO pref = (UserPropertyDAO) WebApplicationContextUtils.getWebApplicationContext(pageContext.getServletContext()).getBean("UserPropertyDAO");
String user = (String)session.getAttribute("user");

UserProperty default_filter = pref.getProp(user, UserProperty.CONSULTS_DEFAULT_FILTER);
String defaultFilterValue = null;


  String mrpNo = (String) request.getAttribute("mrpNo");
  String patientId = (String) request.getAttribute("patientId");
  String urgencyFilter = (String) request.getAttribute("urgencyFilter");
  String serviceFilter = (String) request.getAttribute("serviceFilter");
  String consultantFilter = (String) request.getAttribute("consultantFilter");


if ( default_filter != null && default_filter.getValue() != null && !default_filter.getValue().trim().equals("")){
	defaultFilterValue = default_filter.getValue();
}

  oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctConsultationFormRequestUtil consultUtil;
  consultUtil = new  oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctConsultationFormRequestUtil();
  
  if (isTeamAccessPrivacy) {
	  consultUtil.estTeamsByTeam(curProvider_no);
  }
  else if (isSiteAccessPrivacy) {
	  consultUtil.estTeamsBySite(curProvider_no);
  }
  else {
  	consultUtil.estTeams();
  }
  

ArrayList tickerList = new ArrayList();
%>


<head>
<title>
<bean:message key="ectViewConsultationRequests.title"/>
</title>


<html:base/>

<link rel="stylesheet" type="text/css" media="all" href="../../share/calendar/calendar.css" title="win2k-cold-1" /> 
<script type="text/javascript" src="../../share/calendar/calendar.js"></script>
<script type="text/javascript" src="../../share/calendar/lang/<bean:message key="global.javascript.calendar"/>"></script>                                                            
<script type="text/javascript" src="../../share/calendar/calendar-setup.js"></script>
<!--META HTTP-EQUIV="Refresh" CONTENT="20;"-->



<%="<script>\nvar provider_no=\""+curProvider_no+"\";\nvar default_filter=\""+defaultFilterValue+"\";\n</script>"%>

<script language="javascript">
function BackToOscar()
{
       window.close();
}
///
function popupOscarRx(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgConsReq"/>", windowprops);
  if (popup != null) {
    if (popup.opener == null) {
      popup.opener = self;
    }
  }
//setTimeout("window.location.reload();",5000);
}

///
function popupOscarConsultationConfig(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgConsConfig"/>", windowprops);
  if (popup != null) {
    if (popup.opener == null) {
      popup.opener = self;
    }
  }
}


//

function setOrder(val){
  if ( document.forms[0].orderby.value == val){
  //alert( document.forms[0].desc.value);
    if ( document.forms[0].desc.value == '1'){
       document.forms[0].desc.value = '0';
    }else{
       document.forms[0].desc.value = '1';
    }    
  }else{
    document.forms[0].orderby.value = val;
    document.forms[0].desc.value = '0';
  }    
  document.forms[0].submit();
}

function gotoPage(next) {
	var frm = document.forms[0];
	
	frm.limit.value = <%=limit%>;
	if (next) frm.offset.value = <%=offset+limit%>;
	else frm.offset.value = <%=offset-limit%>;
	
	frm.submit();
}
</script>



<!-- <link rel="stylesheet" type="text/css" href="../encounterStyles.css"> -->
<style>
.searchDate{width:90px}

.custom-dropdown{
list-style: none; margin:0px;padding:0px
}

.custom-dropdown li{
font-size:12px;
padding:2px;
}

.custom-dropdown li:hover{
background-color: #ccc;
cursor: pointer;
cursor: hand;
}
</style>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

</head>
<body class="BodyStyle" vlink="#0000FF" >
<!--  -->

                <table class="TopStatusBar" width="100%">
                    <tr>
                        <td class="Header" NOWRAP >
                            <h4>&nbsp;<i class="icon-external-link"></i>&nbsp;<bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msfConsReqForTeam"/> = 
                            <%
                               if (team.equals("-1")){
                            %>
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formTeamNotApplicable"/>
                            <% } else if (team.isEmpty()) { %>
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formViewAll"/>
                            <% } else { %>
                            <%= team %>
                            <% } %></h4>             
                        </td>
                        <td align="right">
		                    <i class=" icon-question-sign"></i> 
	                        <a href="javascript:void(0)" onClick ="popupOscarConsultationConfig(700,960,'<%=(OscarProperties.getInstance()).getProperty("HELP_SEARCH_URL")%>'+'Consultation+Tab')"><bean:message key="app.top1"/></a>
	                        <i class=" icon-info-sign" style="margin-left:10px;"></i> 
                            <a href="javascript:void(0)"  onClick="window.open('<%=request.getContextPath()%>/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,left=0,top=0')" ><bean:message key="global.about" /></a>
                        </td>                      
                    </tr>
                </table>

        
                <table width="100%" class="table table-striped table-hover">
                <tr>
                    <td style="margin: 0; padding: 0;">
                        <html:form action="/oscarEncounter/ViewConsultation"  method="get">  

                        <a href="javascript:popupOscarConsultationConfig(700,960,'<%=request.getContextPath()%>/oscarEncounter/oscarConsultationRequest/config/ShowAllServices.jsp')" class="btn">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgEditSpecialists"/>
                        </a>
                    <div class="form-inline control-group">
                        <label class="control-label" for="sendTo">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formSelectTeam"/>:
                        </label>                        
                            <select name="sendTo" class="input-medium">                                
				                <option value=""><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formViewAll"/></option>
                                                            
                                <%                                
                                   if (team.equals("-1")) { %>
                                <option value="-1" selected ><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formTeamNotApplicable"/></option>
                                <% }
                                    else {
                                 %>
                                 <option value="-1"><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formTeamNotApplicable"/></option>
                                <%    }
                                   for (int i =0; i < consultUtil.teamVec.size();i++){
                                     String te = (String) consultUtil.teamVec.elementAt(i);                                                                        
                                     if (te.equals(team)){
                                %>
                                    <option value="<%=te%>" selected><%=te%></option>
                                <%}else{%>
                                    <option value="<%=te%>"><%=te%></option>
                                <%}}%>
                            </select> 
                        
                        <label class="control-label" for="startDate">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgStart"/>:
                        </label> 
                            <html:text property="startDate" styleClass="input-small" styleId="startDate" /><a id="SCal"><img title="Calendar" src="../../images/cal.gif" alt="Calendar" border="0" /></a>
                        <label class="control-label" for="endDate">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgEnd"/>:
                        </label> 
                            <html:text property="endDate" styleClass="searchDate"   styleId="endDate"/><a id="ECal"><img title="Calendar" src="../../images/cal.gif" alt="Calendar" border="0" /></a>
                        <label class="radio">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgSearchon"/><html:radio property="searchDate" value="0" titleKey="Search on Referal Date"/> </label>
                        <label class="radio">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgApptDate"/><html:radio property="searchDate" value="1" titleKey="Search on Appt. Date"/></label>
                            <html:hidden property="currentTeam"/>
                            <html:hidden property="orderby"/>
                            <html:hidden property="desc"/>
                            <html:hidden property="offset"/>
                            <html:hidden property="limit"/>
                        <label class="checkbox">
                            <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgIncludeCompleted"/>:<html:checkbox property="includeCompleted" value="include" /></label>


			    <div style="width:100%"> 
                        <label class="control-label" for="mrpName">
				            MRP 
                        </label>
                    <input type="text" class="form-control input-medium" id="mrpName" size="14" onKeyup="mrpSearch(this.value)" placeholder="lastname, firstname" autocomplete="off" onFocus="toggleTempBin(1, 'mrpName')" onBlur="toggleTempBin(0, 'mrpName')">
				    <html:hidden property="mrpNo" styleId="mrpNo" value="<%=mrpNo%>" /> 
                        <label class="control-label" for="patientName">
				           Patient  
                        </label>
                    <input type="text" class="form-control input-medium" id="patientName" onKeyup="patientSearch(this.value)" placeholder="lastname, firstname" autocomplete="off" onFocus="toggleTempBin(1, 'patientName')" onBlur="toggleTempBin(0, 'patientName')">
				<html:hidden property="patientId" styleId="patientId" />
                        <label class="control-label" for="tz">
				            Service 
                        </label>
                    <select name="serviceFilter" data-new="2" id="tz" class="input-medium">
				    <option value="">select</option>
				<%
				ConsultationServiceDao consultationServiceDao = SpringUtils.getBean(ConsultationServiceDao.class);

				List<ConsultationServices> services = consultationServiceDao.findActive();

				for(ConsultationServices cs:services) {
				out.print("<option value=\""+String.valueOf(cs.getServiceId())+"\">"+Encode.forHtml(cs.getServiceDesc())+"</option>\n");
				}
				%></select>

                        <label class="control-label" for="consultantName">
				            Consultant
                        </label>
                        <input type="text" class="form-control input-medium" id="consultantName" onKeyup="consultantSearch(this.value)" placeholder="lastname, firstname" autocomplete="off" onFocus="toggleTempBin(1, 'consultantName')" onBlur="toggleTempBin(0, 'consultantName')">
				        <html:hidden property="consultantFilter" styleId="consultantFilter" />

                        <label class="control-label" for="urg">
				            Urgency </label>
                        <select name="urgencyFilter" id="urg" class="input-small">
					  <option value="">select</option> 
					  <option value="1">Urgent</option> 
					  <option value="2">Non-Urgent</option> 
					  <option value="3">Return</option>
					</select>
                    </div><!-- control-group -->

				<div id="tempBin" onmouseover="tempBinHover(true)" onmouseout="tempBinHover(false)" style="display:none;position:absolute;padding:4px; background-color:white;border:thin solid #cccccc">You must enter at least 2 characters of the name!</div>
			    </div>
		
<input class="btn btn-primary" type="submit" value="Apply Filter"/> <!-- <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.btnConsReq"/> -->
<input type="reset" class="btn" value="Clear Filter"/>
<input type="reset" class="btn" value="Reload" onclick="reloadConsults();"/>
                            <!--/div-->
                        </html:form>
                    </td>
                </tr>
                <tr>
                    <td>                    
                        <table border="0" width="100%" cellspacing="1" style="border: thin solid #C0C0C0;">
                            <tr>
                                <th align="left" class="VCRheads" width="20">
                                   <a href=# onclick="setOrder('1'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgStatus"/>
                                   </a>
                                </th>
 				<th align="left" class="VCRheads" width="60">
					<bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgUrgency"/>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('2'); return false;">
                                       <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgTeam"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads" width="75">
                                   <a href=# onclick="setOrder('3'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgPatient"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('4'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgProvider"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('5'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgService"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('6'); return false;">
                                       <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgConsultant"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('7'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgRefDate"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('8'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgAppointmentDate"/>
                                   </a>
                                </th>
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('9'); return false;">
                                       <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgFollowUpDate"/>
                                   </a>
                                </th>
 			    <% if (bMultisites) { %>                                
                                <th align="left" class="VCRheads">
                                   <a href=# onclick="setOrder('10'); return false;">
                                   <bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgSiteName"/>
                                   </a>
                                </th>            
                            <%} %>                                   
                            </tr>
                        <%                                                        
	Integer intMrpNo = null;
	Integer intPatientId = null;
	Integer intUrgencyFilter = null; 
	Integer intServiceFilter = null;
	Integer intConsultantFilter = null;

	if(mrpNo!=null && !mrpNo.isEmpty())
	intMrpNo = Integer.parseInt(mrpNo.trim());

	if(patientId!=null && !patientId.isEmpty())
	intPatientId = Integer.parseInt(patientId.trim());

	if(urgencyFilter!=null && !urgencyFilter.isEmpty())
	intUrgencyFilter = Integer.parseInt(urgencyFilter.trim());

	if(serviceFilter!=null && !serviceFilter.isEmpty())
	intServiceFilter = Integer.parseInt(serviceFilter.trim());

	if(consultantFilter!=null && !consultantFilter.isEmpty())
	intConsultantFilter = Integer.parseInt(consultantFilter.trim());


                            oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctViewConsultationRequestsUtil theRequests;                            
                            theRequests = new  oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctViewConsultationRequestsUtil();                            
                            theRequests.estConsultationVecByTeam(LoggedInInfo.getLoggedInInfoFromSession(request), team,includeCompleted,startDate,endDate,orderby,desc,searchDate,offset,limit, intMrpNo, intPatientId, intUrgencyFilter, intServiceFilter, intConsultantFilter);                                                        
                            boolean overdue;                            
                            
                            UserProperty up = pref.getProp(user, UserProperty.CONSULTATION_TIME_PERIOD_WARNING);
                            String timeperiod = null;
                            int countback;

                            if ( up != null && up.getValue() != null && !up.getValue().trim().equals("")){
                                timeperiod = up.getValue();
                            }

                            for (int i = 0; i < theRequests.ids.size(); i++){
                             //multisites. skip record if not belong to same site/team
                             if (isSiteAccessPrivacy || isTeamAccessPrivacy) {
                             	if(providerMap.get(theRequests.providerNo.elementAt(i))== null)  continue;
                             }	
                            	
                            String id      =  theRequests.ids.elementAt(i);
                            String status  =  theRequests.status.elementAt(i);
                            String patient =  Encode.forHtml(theRequests.patient.elementAt(i));
                            String provide =  Encode.forHtml(theRequests.provider.elementAt(i));
                            String service =  Encode.forHtml(theRequests.service.elementAt(i));
                            String date    =  theRequests.date.elementAt(i);
                            String demo    =  theRequests.demographicNo.elementAt(i);
                            String appt    =  theRequests.apptDate.elementAt(i);
                            String patBook =  theRequests.patientWillBook.elementAt(i);
                            String urgency =  theRequests.urgency.elementAt(i);
                            String sendTo  =  theRequests.teams.elementAt(i);
                            if (sendTo==null) sendTo = "-1";
                            String specialist = Encode.forHtml(theRequests.vSpecialist.elementAt(i));
                            String followUpDate = theRequests.followUpDate.elementAt(i);
                            String siteName = ""; 
                            if (bMultisites) {
                            	siteName =  Encode.forHtml(theRequests.siteName.elementAt(i));
                            }
                            if(status.equals("1") && dateGreaterThan(date, Calendar.WEEK_OF_YEAR, -1)){
                                tickerList.add(demo);
                            }
                            
                            //multisites. skip record if not belong to same site
                            if (isSiteAccessPrivacy || isTeamAccessPrivacy) {
                             	if(!mgrSite.contains(siteName))  continue;
                             }	
                            overdue = false;
                                                                                                                
                            if (timeperiod != null){ 
                               countback = Integer.parseInt(timeperiod);
                               countback = countback * -1;
                            
                           
                                if( (status.equals("1") || status.equals("2") || status.equals("3")) && dateGreaterThan(date, Calendar.MONTH, countback) ) {
                                    overdue = true;
                                }
                            }
                            else {
                                countback = -7;  //7 days
                                if( (status.equals("1") || status.equals("3")) && dateGreaterThan(date, Calendar.DAY_OF_YEAR, countback) ) {
                                    overdue = true;
                                }

                                countback = -30;  //30 days
                                if( status.equals("2") && dateGreaterThan(date, Calendar.DAY_OF_YEAR, countback) ) {
                                    overdue = true;
                                }
                            }


                        %>
                        <tr <%=overdue?"class='error'":""%> onclick="popupOscarRx(700,960,'<%=request.getContextPath()%>/oscarEncounter/ViewRequest.do?requestId=<%=id%>')">
                            <td class="stat<%=status%>">
                            <% if (status.equals("1")){ %>
                                <a href="javascript:popupOscarRx(700,960,'<%=request.getContextPath()%>/oscarEncounter/ViewRequest.do?requestId=<%=id%>')"
                                title="Nothing"><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgND"/></a>  
                            <% }else if(status.equals("2")) { %>
                                <a href="javascript:popupOscarRx(700,960,'<%=request.getContextPath()%>/oscarEncounter/ViewRequest.do?requestId=<%=id%>')"
                                title="Pending Specialist Callback"><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgSR"/></a>
                            <% }else if(status.equals("3")) { %>
                                <a href="javascript:popupOscarRx(700,960,'<%=request.getContextPath()%>/oscarEncounter/ViewRequest.do?requestId=<%=id%>')"
                                title="Pending Patient Callback"><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgPR"/></a>    
                            <% }else if(status.equals("4")) { %>
                                <a href="javascript:popupOscarRx(700,960,'<%=request.getContextPath()%>/oscarEncounter/ViewRequest.do?requestId=<%=id%>')"
                                title="Completed"><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.msgDONE"/></a>
                                    <% } %>
								</td>
                                <td class="stat<%=status%>">
			            <% if (urgency.equals("1")){ %>
								<div style="color:red;"> Urgent </div>
                                    <% }else if(urgency.equals("2")) { %>
										Non-Urgent
                                    <% }else if(urgency.equals("3")) { %>
										Return
                                    <% } %>


                                </td>
                                <td class="stat<%=status%>">
                                    
                                    <%=sendTo.equals("-1")?"N/A":sendTo%>
                                    
                                </td>
                                <td class="stat<%=status%>">
      
                                    <%=patient%>
                                   
                                </td>
                                <td>
                                    <%=provide%>
                                </td>
                                <td >
                                    
                                    <%=service%>
                                    

                                </td>
                                <td class="stat<%=status%>">
                                   
                                        <%=specialist%>
                                   

                                </td>
                                <td class="stat<%=status%>">
                                    <%=date%>
                                </td>
                                <td class="stat<%=status%>">
                                   <% if ( patBook != null && patBook.trim().equals("1") ){%>
                                    Patient will book
                                   <%}else{%> 
                                   <%=appt%> 
                                   <%}%>
                                </td>
                                <td class="stat<%=status%>">
                                    
                                        <%=followUpDate%>
                                  

                                </td>
                                <% if (bMultisites) { %>   
                                <td bgcolor="<%=(siteBgColor.get(siteName)==null || siteBgColor.get(siteName).length()== 0 ? "#FFFFFF" : siteBgColor.get(siteName))%>">
                                    <%=siteShortName.get(siteName)%>
                                </td>                      
                                <%} %>          
                            </tr>
                        <%}%>
                        </table>
                    
                    </td>
                </tr>
                </table>
                
          
                	<%
                	if(offset > 0) {
//                		String queryString = getNewQueryString(request.getQueryString(),offset-limit,limit);
                		%><input type="button" class="btn" value="Prev" onClick="gotoPage(false);"/><%
                	}
                	if(theRequests.ids.size() == limit) {
//                		String queryString = getNewQueryString(request.getQueryString(),offset+limit,limit);
	               		%><input type="button" class="btn" value="Next" onClick="gotoPage(true);"/><%
                	}
                	%>
               
            
            <% if ( tickerList.size() > 0 ) { 
                  String queryStr = "";
                  for (int i = 0; i < tickerList.size(); i++){
                     String demo = (String) tickerList.get(i);
                     if (i == 0){
                        queryStr += "demo="+demo;
                     }else{
                        queryStr += "&demo="+demo;  
                     }
                   }%>                        
             <a target="_blank" href="../../tickler/AddTickler.do?<%=queryStr%>&message=<%=java.net.URLEncoder.encode("Patient has Consultation Letter with a status of 'Nothing Done' for over one week","UTF-8")%>">Add Tickler</a> for Consults with ND for more than one week
            <%}%>

    <script language='javascript'>
       Calendar.setup({inputField:"startDate",ifFormat:"%Y-%m-%d",showsTime:false,button:"SCal",singleClick:true,step:1});          
       Calendar.setup({inputField:"endDate",ifFormat:"%Y-%m-%d",showsTime:false,button:"ECal",singleClick:true,step:1});    


var searchDropDownFlag = false;

function patientSearch(term) {

if(term.length<2){
document.getElementById('tempBin').innerHTML = "You must enter at least 2 characters of a patients name!";
return false;
}

tmpBin = document.getElementById('tempBin');
loaderImg(tmpBin);

oscar_url = window.location.href;     
static_path = '/ws/rs/demographics/quickSearch?query=';
url_chucks = oscar_url.split( '/' );
oscar_name = url_chucks[3];
search_url = origin + '/' + oscar_name + static_path + term;

var request = new XMLHttpRequest();

request.open('GET', search_url, true);
request.onload = function() {

  var data = JSON.parse(this.response);
  var results_html = "";
  if (request.status >= 200 && request.status < 400) {

    if(data.content.length>0){
      results_html += "<ul class=\"custom-dropdown\">";
	    for(i=0;i<=data.content.length-1;i++){
	      results_html += "<li><a onclick=\"populateInputField(this, 'patient')\" data-id=\""+data.content[i].demographicNo+" \">"+ data.content[i].lastName + ", " + data.content[i].firstName + "</a></li>";
	    }
      results_html += "</ul>";
    }else{
	results_html = "No results found matching <b>"+term+"</b>.";
    }
   document.getElementById('tempBin').innerHTML = results_html;
  } else {
    console.log('error')
  }

}// end onload

request.send();
}     


function xmrpSearch(term) {

if(term.length<2){
document.getElementById('tempBin').innerHTML = "You must enter at least 2 characters of a patients name!";
return false;
}

tmpBin = document.getElementById('tempBin');
loaderImg(tmpBin);

oscar_url = window.location.href;     
static_path = '/ws/rs/providerService/providers?searchTerm=';
url_chucks = oscar_url.split( '/' );
oscar_name = url_chucks[3];
search_url = origin + '/' + oscar_name + static_path + term;

var request = new XMLHttpRequest();

request.open('GET', search_url, true);
request.setRequestHeader("Content-Type", "application/json");
request.onload = function() {

  var data = this.response;
  var results_html = "";
  if (request.status >= 200 && request.status < 400) {

 	//xmlDoc = data;
        //var lastName = xmlDoc.getElementsByTagName("lastName"); 

	console.log(data);
  } else {
    console.log('error')
  }

}// end onload

request.send();
} 


function mrpSearch(term){

if(term.length<2){
document.getElementById('tempBin').innerHTML = "You must enter at least 2 characters of a patients name!";
return false;
}

tmpBin = document.getElementById('tempBin');
loaderImg(tmpBin);

var search = {searchTerm:term, active:true};
var xhr = new XMLHttpRequest();
xhr.open("POST", '../../ws/rs/providerService/providers/search', true);

//Send the proper header information along with the request
xhr.setRequestHeader("Content-Type", "application/json");

xhr.onreadystatechange = function() { // Call a function when the state changes.
    if (this.readyState === XMLHttpRequest.DONE && this.status === 200) {
        // Request finished. Do processing here.
	var data = JSON.parse(this.response);
        var results_html = "";
	    if(data.content.length>0){
	      results_html += "<ul class=\"custom-dropdown\">";
		    for(i=0;i<=data.content.length-1;i++){
		      results_html += "<li><a onclick=\"populateInputField(this, 'mrp')\" data-id=\""+data.content[i].providerNo+" \">"+ data.content[i].lastName + ", " + data.content[i].firstName + "</a></li>";
		    }
	      results_html += "</ul>";
	    }else{
		results_html = "No results found matching <b>"+term+"</b>.";
	    }
	   document.getElementById('tempBin').innerHTML = results_html;
    }
}

xhr.send(JSON.stringify(search));
}


function consultantSearch(term){
if(term.length<2){
document.getElementById('tempBin').innerHTML = "You must enter at least 2 characters of a patients name!";
return false;
}

tmpBin = document.getElementById('tempBin');
loaderImg(tmpBin);

var request = new XMLHttpRequest();

request.open('GET', 'searchProfessionalSpecialist.json?keyword='+term, true);
request.setRequestHeader("Content-Type", "application/json");
request.onload = function() {

  var data = this.response;
  var results_html = "";
  if (request.status >= 200 && request.status < 400) {

        // Request finished. Do processing here.
	var data = JSON.parse(this.response);
        var results_html = "";
	    if(data.length>0){
	      results_html += "<ul class=\"custom-dropdown\">";
		    for(i=0;i<=data.length-1;i++){
		      results_html += "<li><a onclick=\"populateInputField(this, 'consultant')\" data-id=\""+data[i].id+" \">"+ data[i].lastName + ", " + data[i].firstName + "</a></li>";
		    }
	      results_html += "</ul>";
	    }else{
		results_html = "No results found matching <b>"+term+"</b>.";
	    }
	   document.getElementById('tempBin').innerHTML = results_html;



  } else {
    console.log('error')
  }

}// end onload

request.send();
}


function populateInputField(el, type){ 
  
document.getElementById(type+"Name").value=el.firstChild.data;

if(type=="mrp")
document.getElementById("mrpNo").value=el.getAttribute("data-id");

if(type=="patient")
document.getElementById("patientId").value=el.getAttribute("data-id");

if(type=="consultant")
document.getElementById("consultantFilter").value=el.getAttribute("data-id").trim();

searchDropDownFlag = false;
toggleTempBin(0, null);
}

function reloadConsults(){
url="../../oscarEncounter/IncomingConsultation.do?providerNo="+provider_no;
if(default_filter!=="null"){
url="../../oscarEncounter/ViewConsultation.do?"+default_filter;
}

window.location.href = url;
}

function toggleTempBin(a, parentElement){
if(a===1){

position = getOffset( document.getElementById(parentElement) );

new_top = position.top + document.getElementById(parentElement).offsetHeight

document.getElementById("tempBin").style.top=new_top+"px";
document.getElementById("tempBin").style.left=position.left+"px";
document.getElementById("tempBin").style.width=document.getElementById(parentElement).offsetWidth+"px";
document.getElementById("tempBin").style.display='block';

}else if(a===0 && searchDropDownFlag===false){
document.getElementById("tempBin").style.display='none';
document.getElementById("tempBin").innerHTML="You must enter at least 2 characters of a patients name!";
}
}

function getOffset( el ) {
    var _x = 0;
    var _y = 0;
    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
        _x += el.offsetLeft - el.scrollLeft;
        _y += el.offsetTop - el.scrollTop;
        el = el.offsetParent;
    }
    return { top: _y, left: _x};
}


function loaderImg(bin){
    bin.innerHTML="";
    var img = document.createElement('img');      
    img.src = '../../images/loader.gif';
    img.style.marginLeft = "40%";
    bin.appendChild(img);
}


function tempBinHover(h){

if(h){
//console.log("true");
searchDropDownFlag = true;
}else{
searchDropDownFlag = false;
//console.log("false");
}
}
   </script>
</body>

</html:html>
<%!
/*
String getNewQueryString(String queryString,Integer offset, Integer limit) {
	
	String result = "";
	List<String> resultParts = new ArrayList<String>();
	
	String[] parts = queryString.split("&");
	for(String part:parts) {
		
		if(!part.startsWith("offset=") && !part.startsWith("limit=")) {
			resultParts.add(part);
		}
	}
	
	resultParts.add("offset=" + (offset!=null?offset:0));
	resultParts.add("limit=" + (limit != null?limit:ConsultationRequestDao.DEFAULT_CONSULT_REQUEST_RESULTS_LIMIT));
	for(int x=0;x<resultParts.size();x++) {
		if(x>0)
			result += "&";
		result += resultParts.get(x);
	}
	
	return result;
}
*/

boolean dateGreaterThan(String dateStr, int unit, int period){
    DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");    
    Date prevDate = null;
    try{
       prevDate = formatter.parse(dateStr);
    }catch (Exception e){ 
    return false;
    }         
         
    Calendar bonusEl = Calendar.getInstance();                     
    bonusEl.add(unit,period);
    Date bonusStartDate = bonusEl.getTime();                                          
    
    return bonusStartDate.after(prevDate);
}

%>