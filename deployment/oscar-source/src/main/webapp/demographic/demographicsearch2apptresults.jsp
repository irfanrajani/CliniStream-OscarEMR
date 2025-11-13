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
<security:oscarSec roleName="<%=roleName$%>" objectName="_search" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_search");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="org.oscarehr.caisi_integrator.ws.CachedProvider"%>
<%@page import="org.oscarehr.caisi_integrator.ws.FacilityIdStringCompositePk"%>
<%@page import="org.oscarehr.PMmodule.caisi_integrator.CaisiIntegratorManager"%>
<%@page import="org.apache.commons.lang.time.DateFormatUtils"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="oscar.util.DateUtils"%>
<%@page import="org.oscarehr.caisi_integrator.ws.DemographicTransfer"%>
<%@page import="org.oscarehr.caisi_integrator.ws.MatchingDemographicTransferScore"%>
<%@page import="org.oscarehr.casemgmt.service.CaseManagementManager"%>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="java.util.*, java.sql.*,java.net.*, oscar.*"%>

<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="oscar.oscarDemographic.data.DemographicMerged" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="net.sf.json.JSONObject" %>
<%@ page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@page import="org.oscarehr.common.dao.OscarLogDao"%>

<jsp:useBean id="providerBean" class="java.util.Properties" scope="session" />

<% 
	Boolean isMobileOptimized = session.getAttribute("mobileOptimized") != null;
	
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	
	String curProvider_no = request.getParameter("provider_no");
	    
	String keyword = request.getParameter("keyword");
	String searchMode = request.getParameter("search_mode");
	
	String strLimit1="0";
	String strLimit2="10";
	if(request.getParameter("limit1")!=null) strLimit1 = request.getParameter("limit1");
	if(request.getParameter("limit2")!=null) strLimit2 = request.getParameter("limit2");
	
	int offset = Integer.parseInt(strLimit1);
	int limit = Integer.parseInt(strLimit2);
	boolean caisi = Boolean.valueOf(request.getParameter("caisi")).booleanValue();

	OscarProperties props = OscarProperties.getInstance();

	List<Demographic> demoList = null;  
	DemographicDao demographicDao = (DemographicDao)SpringUtils.getBean("demographicDao");
	DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
	OscarLogDao oscarLogDao = (OscarLogDao)SpringUtils.getBean("oscarLogDao");

	String providerNo = loggedInInfo.getLoggedInProviderNo();
	boolean outOfDomain = true;
	if(OscarProperties.getInstance().getProperty("ModuleNames","").indexOf("Caisi") != -1) {
		if(!"true".equals(OscarProperties.getInstance().getProperty("pmm.client.search.outside.of.domain.enabled","true"))) {
			outOfDomain=false;
		}
		if(request.getParameter("outofdomain")!=null && request.getParameter("outofdomain").equals("true")) {
			outOfDomain=true;
		}
	}
	
%>

<html>
<head>

<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
<link rel="stylesheet" href="../css/helpdetails.css" type="text/css">
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message key="demographic.demographicsearch2apptresults.title" />(demographicsearch2apptresults)</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>

<% 
	if (isMobileOptimized) { 
%>
   <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width" />
   <link rel="stylesheet" type="text/css" href="../mobile/searchdemographicstyle.css">
<% 
	} else { 
%>
   <!-- <link rel="stylesheet" type="text/css" href="../share/css/searchBox.css" />
   <link rel="stylesheet" type="text/css" media="all" href="../demographic/searchdemographicstyle.css"  />  -->
<% 
	} 
%>
<script language="javascript" type="text/javascript" src="../share/javascript/Oscar.js"></script>
<script language="JavaScript">
function setfocus() {
  this.focus();
  document.titlesearch.keyword.focus();
  document.titlesearch.keyword.select();
}
function showHideItem(id){
    if(document.getElementById(id).style.display == 'inline')
        document.getElementById(id).style.display = 'none';
    else
        document.getElementById(id).style.display = 'inline';
}
function checkTypeIn() {
    // type can be swipe, HIN, name, DOB  and others

    var keyObj = document.titlesearch.keyword;
    var keyVal = keyObj.value;
    console.log(keyVal);

    //swipe pattern
    if (keyVal.indexOf('%b610054') == 0 && keyVal.length > 18){                  
         keyObj.value = keyVal.substring(8,18);
         document.titlesearch.search_mode[4].checked = true;
         document.getElementById("search_mode").value="search_hin";                  
    }

    // DOB either 
    const reDOB=/^(19|20)\d\d([\/.-])(0[1-9]|1[012])[\/.-](0[1-9]|[12]\d|3[01])$/;
    // DOB with delimiters of / or . or -
    if (reDOB.exec(keyVal)) {
        const yyyy = Number(keyVal.substring(0,4));
        const mm =(keyVal.substring(5,7));
        const dd = (keyVal.substring(8));
        const dob = yyyy+"-"+mm+"-"+dd;
        keyObj.value = dob;
        document.titlesearch.search_mode[2].checked = true; 
        document.getElementById("search_mode").value="search_dob";
    }  

  // if DOB is a 8 digit number AND DOB search is identified add the -
  if(document.titlesearch.search_mode[2].checked) {
    if(keyVal.length==8) {
      keyVal = keyVal.substring(0, 4)+"-"+keyVal.value.substring(4, 6)+"-"+keyVal.substring(6, 8);
    }
    if(keyVal.length != 10) {
      alert("<bean:message key="demographic.demographicsearch2apptresults.msgWrongDOB"/>");
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}

function searchInactive() {
    document.titlesearch.ptstatus.value="inactive"
    if (checkTypeIn()) document.forms[0].submit()
}

function searchAll() {
    document.titlesearch.ptstatus.value=""
    if (checkTypeIn()) document.forms[0].submit()
}


</script>
</head>
<body bgcolor="white" onLoad="setfocus();" topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<div id="demographicSearch" class="searchBox">
	<form class="form-horizontal" method="post" name="titlesearch" action="../demographic/demographiccontrol.jsp" onSubmit="return checkTypeIn()">
	<%--@ include file="zdemographictitlesearch.htm"--%>
    <div >
        <H4><bean:message key="demographic.demographicsearch2apptresults.title" /></H4> 
    </div>
    
           
            
            <select class="wideInput" name="search_mode" id="search_mode">
                <option value="search_name" <%=request.getParameter("search_mode").equals("search_name")?"selected":""%>>
					<bean:message key="demographic.demographicsearch2apptresults.optName" />
				</option>
				<option value="search_phone" <%=request.getParameter("search_mode").equals("search_phone")?"selected":""%>>
                    <bean:message key="demographic.demographicsearch2apptresults.optPhone" />
                </option>
				<option value="search_dob" <%=request.getParameter("search_mode").equals("search_dob")?"selected":""%>>
                    <bean:message key="demographic.demographicsearch2apptresults.optDOB" />
                </option>
                <option value="search_address" <%=request.getParameter("search_mode").equals("search_address")?"selected":""%>>
                    <bean:message key="demographic.demographicsearch2apptresults.optAddress" />
                </option>
				<option value="search_hin" <%=request.getParameter("search_mode").equals("search_hin")?"selected":""%>>
                    <bean:message key="demographic.demographicsearch2apptresults.optHIN" />
                </option>
                <option value="search_chart_no" <%=request.getParameter("search_mode").equals("search_chart_no")?"selected":""%>>
                    <bean:message key="demographic.demographicsearch2apptresults.optChart"/>
                </option>
            </select>
      
          <input type="text" class="wideInput" NAME="keyword" VALUE="<%=Encode.forHtmlAttribute(request.getParameter("keyword"))%>" SIZE="17" MAXLENGTH="100"/>
        
	<INPUT TYPE="hidden" NAME="orderby" VALUE="last_name, first_name">
        <INPUT TYPE="hidden" NAME="dboperation" VALUE="search_titlename">
        <INPUT TYPE="hidden" NAME="limit1" VALUE="0">
        <INPUT TYPE="hidden" NAME="limit2" VALUE="5">
        <input type="hidden" name="displaymode" value="Search ">
        <INPUT TYPE="hidden" NAME="ptstatus" VALUE="active">
        
        <input type="hidden" name="fromAppt" value="<%=Encode.forHtmlAttribute(request.getParameter("fromAppt"))%>">
		<input type="hidden" name="originalPage" value="<%=Encode.forHtmlAttribute(request.getParameter("originalPage"))%>">
		<input type="hidden" name="bFirstDisp" value="<%=Encode.forHtmlAttribute(request.getParameter("bFirstDisp"))%>">
		<input type="hidden" name="provider_no" value="<%=Encode.forHtmlAttribute(request.getParameter("provider_no"))%>">
		<input type="hidden" name="start_time" value="<%=Encode.forHtmlAttribute(request.getParameter("start_time"))%>">
		<input type="hidden" name="end_time" value="<%=Encode.forHtmlAttribute(request.getParameter("end_time"))%>">
		<input type="hidden" name="year" value="<%=Encode.forHtmlAttribute(request.getParameter("year"))%>">
		<input type="hidden" name="month" value="<%=Encode.forHtmlAttribute(request.getParameter("month"))%>">
		<input type="hidden" name="day" value="<%=Encode.forHtmlAttribute(request.getParameter("day"))%>">
		<input type="hidden" name="appointment_date" value="<%=Encode.forHtmlAttribute(request.getParameter("appointment_date"))%>">
		<input type="hidden" name="notes" value="<%=Encode.forHtmlAttribute(request.getParameter("notes"))%>">
		<input type="hidden" name="reasonCode" value="<%=Encode.forHtmlAttribute(request.getParameter("reasonCode"))%>">
		<input type="hidden" name="reason" value="<%=Encode.forHtmlAttribute(request.getParameter("reason"))%>">
		<input type="hidden" name="location" value="<%=Encode.forHtmlAttribute(request.getParameter("location"))%>">
		<input type="hidden" name="resources" value="<%=Encode.forHtmlAttribute(request.getParameter("resources"))%>">
		<input type="hidden" name="type" value="<%=Encode.forHtmlAttribute(request.getParameter("type"))%>">
		<input type="hidden" name="style" value="<%=Encode.forHtmlAttribute(request.getParameter("style"))%>">
		<input type="hidden" name="billing" value="<%=Encode.forHtmlAttribute(request.getParameter("billing"))%>">
		<input type="hidden" name="status" value="<%=Encode.forHtmlAttribute(request.getParameter("status"))%>">
		<input type="hidden" name="createdatetime" value="<%=Encode.forHtmlAttribute(request.getParameter("createdatetime"))%>">
		<input type="hidden" name="creator" value="<%=Encode.forHtmlAttribute(request.getParameter("creator"))%>">
		<input type="hidden" name="remarks" value="<%=Encode.forHtmlAttribute(request.getParameter("remarks"))%>">
		        
<%
	String temp=null;
	for (Enumeration e = request.getParameterNames() ; e.hasMoreElements() ;) {
		temp=e.nextElement().toString();
		if(temp.equals("keyword") || temp.equals("dboperation") ||temp.equals("displaymode") ||temp.equals("search_mode") ||temp.equals("chart_no")  ||temp.equals("ptstatus") ||temp.equals("submit") || temp.equals("includeIntegratedResults")) continue; %>
		<input type="hidden" name="<%=Encode.forHtmlAttribute(temp)%>" value="<%=Encode.forHtmlAttribute(request.getParameter(temp))%>">
 <% }
%>
       
       <input type="SUBMIT" class="btn btn-primary top" name="displaymode"
           value='<bean:message key="global.search"/>' size="17"
           title='<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchActive"/>'>&nbsp;&nbsp;
       <INPUT TYPE="button" id="inactiveButton" class="btn"
           onclick="searchInactive();"
           TITLE="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchInactive"/>"
           VALUE="<bean:message key="demographic.search.Inactive"/>">
       <INPUT TYPE="button" id="allButton" class="btn"
           onclick="searchAll();"
           TITLE="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchAll"/>"
           VALUE="<bean:message key="demographic.search.All"/>">
        <INPUT TYPE="button" id="cancelButton" class="btn btn-link"
           onclick="document.addform.action='<%=request.getParameter("originalpage")%>?'; document.addform.submit();"
           TITLE="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchAll"/>"
           VALUE="<bean:message key="global.btnCancel"/>">
<!-- <a href="#" onclick="showHideItem('demographicSearch');" id="xcancelButton" class="btn btn-link"><bean:message key="global.btnCancel" /></a>-->
<%
	if (loggedInInfo.getCurrentFacility().isIntegratorEnabled()){
%>
    	<input type="checkbox" name="includeIntegratedResults" value="true"   <%="true".equals(request.getParameter("includeIntegratedResults"))?"checked":""%>/> <span style="font-size:small"><bean:message key="demographic.search.msgInclIntegratedResults"/></span>
<%	} %>
   
<% if (loggedInInfo.getCurrentFacility().isIntegratorEnabled()){%>
        
        	<jsp:include page="../admin/IntegratorStatus.jspf"></jsp:include>
        
<%	} %>
    
	</form>
</div>



<div id="searchResults">
    <div class="header deep">
        <div class="title"><bean:message key="demographic.demographicsearch2apptresults.patientsRecord" />
        </div>
    </div>
<table width="95%" border="0">
	<tr>
		<td align="left">
            <%if(request.getParameter("keyword")!=null && request.getParameter("keyword").length()==0) { %>
                    <bean:message key="demographic.demographicsearch2apptresults.msgMostRecentPatients"/>
            <% } else { %>
                    <bean:message key="demographic.demographicsearch2apptresults.msgKeywords" /> 
                    <%=Encode.forHtml(request.getParameter("keyword"))%>
            <%}%>
        </td>
	</tr>
</table>

<script language="JavaScript">
    var contactResults = [];
var fullname="";
<%-- RJ 07/10/2006 Need to pass doctor of patient back to referrer --%>
function addName(demographic_no, lastname, firstname, chartno, messageID, doctorNo, remoteFacilityId) {  
  fullname=lastname+","+firstname;

   if (remoteFacilityId == '')
   {
	   document.addform.action="<%=request.getParameter("originalpage")%>?";
   }
   else
   {
	   document.addform.action="<%=request.getContextPath()%>/appointment/copyRemoteDemographic.jsp?originalPage=<%=URLEncoder.encode(request.getParameter("originalpage") != null ? request.getParameter("originalpage") : "")%>&";
   }	  
  
  document.addform.action=document.addform.action+"demographic_no="+demographic_no+"&name="+fullname+"&chart_no="+chartno+"&bFirstDisp=false"+"&messageID="+messageID+"&doctor_no="+doctorNo+"&remoteFacilityId="+remoteFacilityId; 
  
  document.addform.submit();
  return true;
}

function selectContactJson(index) {
    var contact = contactResults[index];

    if (contact) {
        opener.document.contactForm.elements['contact_contactName'].value = contact.name;
        opener.document.contactForm.elements['contact_contactId'].value = contact.contactId;
        opener.document.contactForm.elements['contact_phone'].value = contact.phone ? contact.phone : 'Not Set';
        opener.document.contactForm.elements['contact_cell'].value = contact.cell ? contact.cell : 'Not Set';
        opener.document.contactForm.elements['contact_work'].value = contact.work ? contact.work : 'Not Set';
        opener.document.contactForm.elements['contact_work_extension'].value = contact.workExt ? contact.workExt : 'Not Set';
        opener.document.contactForm.elements['contact_email'].value = contact.email ? contact.email : 'Not Set';

        opener.document.contactForm.elements['contact_contactName'].onchange();
        self.close();
    }

}

<%if(caisi) {%>
function addNameCaisi(demographic_no,lastname,firstname,chartno,messageID) {
  	fullname=lastname+","+firstname;
  	if(opener.document.<%=request.getParameter("formName")%>!=null){
      if(opener.document.<%=request.getParameter("formName")%>.elements['<%=request.getParameter("elementName")%>']!=null)
    	 opener.document.<%=request.getParameter("formName")%>.elements['<%=request.getParameter("elementName")%>'].value=fullname;
	  if(opener.document.<%=request.getParameter("formName")%>.elements['<%=request.getParameter("elementId")%>']!=null)
  	     opener.document.<%=request.getParameter("formName")%>.elements['<%=request.getParameter("elementId")%>'].value=demographic_no;
	}
	self.close();
}
<%}%>
</script>




	<form method="post" name="addform" action="../appointment/addappointment.jsp">
	
        
<table class="table table-striped table-hover table-condensed">
        <tr>
        

		<th>
		<bean:message key="demographic.demographicsearch2apptresults.demographicId" />
       </th>

		<th>
		<bean:message key="demographic.demographicsearch2apptresults.lastName" />
                </th>
		<th>
		<bean:message key="demographic.demographicsearch2apptresults.firstName" />
                </th>
		<th>
		<bean:message key="demographic.demographicsearch2apptresults.age" />
                </th>
		<th>
		<bean:message key="demographic.demographicsearch2apptresults.rosterStatus" />
                </th>
		<th>
		<bean:message key="demographic.demographicsearch2apptresults.sex" />
                </th>
        <th>
        <bean:message key="demographic.demographicsearch2apptresults.DOB" />
                </th>
		<th>
		<bean:message key="demographic.demographicsearch2apptresults.doctor" />
                </th>
	</tr>


<%
	JSONObject contactJson = new JSONObject();
	String ptstatus = request.getParameter("ptstatus") == null ? "active" : request.getParameter("ptstatus");
	MiscUtils.getLogger().debug("PSTATUS " + ptstatus);

	int rowCounter=0;
	String bgColor = rowCounter%2==0?"#EEEEFF":"white";

	String pstatus = props.getProperty("inactive_statuses", "IN, DE, IC, ID, MO, FI");
	pstatus = pstatus.replaceAll("'","").replaceAll("\\s", "");
	List<String>stati = Arrays.asList(pstatus.split(","));

    if(request.getParameter("keyword")!=null && request.getParameter("keyword").length()==0) {
        int mostRecentPatientListSize=Integer.parseInt(OscarProperties.getInstance().getProperty("MOST_RECENT_PATIENT_LIST_SIZE","3"));
        List<Integer> results = oscarLogDao.getRecentDemographicsAccessedByProvider(providerNo,  0, mostRecentPatientListSize);
        demoList = new ArrayList<Demographic>();
        for(Integer r:results) {
            demoList.add(demographicDao.getDemographicById(r));
        }
    } else {
	    if( "".equals(ptstatus) ) {
		    if(searchMode.equals("search_name")) {
			    demoList = demographicDao.searchDemographicByName(keyword, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_phone")) {
			    demoList = demographicDao.searchDemographicByPhone(keyword, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_dob")) {
			    demoList = demographicDao.searchDemographicByDOB(keyword, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_address")) {
			    demoList = demographicDao.searchDemographicByAddress(keyword, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_hin")) {
			    demoList = demographicDao.searchDemographicByHIN(keyword, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_chart_no")) {
			    demoList = demographicDao.findDemographicByChartNo(keyword, limit, offset,providerNo,outOfDomain);
		    }
	    }
	    else if( "active".equals(ptstatus) ) {
	        if(searchMode.equals("search_name")) {
			    demoList = demographicDao.searchDemographicByNameAndNotStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
	        else if(searchMode.equals("search_phone")) {
			    demoList = demographicDao.searchDemographicByPhoneAndNotStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_dob")) {
			    demoList = demographicDao.searchDemographicByDOBAndNotStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_address")) {
			    demoList = demographicDao.searchDemographicByAddressAndNotStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_hin")) {
			    demoList = demographicDao.searchDemographicByHINAndNotStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_chart_no")) {
			    demoList = demographicDao.findDemographicByChartNoAndNotStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
	    }
	    else if( "inactive".equals(ptstatus) ) {
	        if(searchMode.equals("search_name")) {
			    demoList = demographicDao.searchDemographicByNameAndStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
	        else if(searchMode.equals("search_phone")) {
			    demoList = demographicDao.searchDemographicByPhoneAndStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_dob")) {
			    demoList = demographicDao.searchDemographicByDOBAndStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_address")) {
			    demoList = demographicDao.searchDemographicByAddressAndStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_hin")) {
			    demoList = demographicDao.searchDemographicByHINAndStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
		    else if(searchMode.equals("search_chart_no")) {
			    demoList = demographicDao.findDemographicByChartNoAndStatus(keyword, stati, limit, offset,providerNo,outOfDomain);
		    }
	    }
    }
	
	if(demoList == null) {
	    //out.println("failed!!!");
	}

	else {
		Collections.sort(demoList, Demographic.LastNameComparator);
		
		DemographicMerged dmDAO = new DemographicMerged();
	
		for(Demographic demo : demoList) {

			String dem_no = demo.getDemographicNo().toString();
			String head = dmDAO.getHead(dem_no);
			contactJson = new JSONObject();
			contactJson.put("name", Encode.forJavaScript(demo.getFormattedName()));
			contactJson.put("contactId", demo.getDemographicNo());
			contactJson.put("cell", demographicExtDao.getValueForDemoKey(demo.getDemographicNo(), "demo_cell"));
			contactJson.put("phone", demo.getPhone());
			contactJson.put("work", demo.getPhone2());
			contactJson.put("workExt", demographicExtDao.getValueForDemoKey(demo.getDemographicNo(), "wPhoneExt"));
			contactJson.put("email", demo.getEmail()); %>
	<script type="text/javascript">
		contactResults.push(<%=contactJson%>)
	</script>
<%			if (head != null && !head.equals(dem_no)) {
				//skip non head records
				continue;
			}
			
			rowCounter++;
			bgColor = rowCounter%2==0?"#EEEEFF":"white";

%>
<tr 
		onClick="document.forms[0].demographic_no.value=<%=demo.getDemographicNo()%>;
			<% if(caisi){ %>
				addNameCaisi('<%=demo.getDemographicNo()%>','<%=URLEncoder.encode(demo.getLastName())%>','<%=URLEncoder.encode(demo.getFirstName())%>','<%=URLEncoder.encode(demo.getChartNo() == null ? "" : demo.getChartNo())%>','<%=request.getParameter("messageId")%>','<%=demo.getProviderNo()%>','')">
			<% } else if (!caisi && OscarProperties.getInstance().isPropertyActive("NEW_CONTACTS_UI") && "contactForm".equals(request.getParameter("formName"))) { %>
				selectContactJson('<%=demoList.indexOf(demo)%>')">
			<% } else { %>
				addName('<%=demo.getDemographicNo()%>','<%=URLEncoder.encode(demo.getLastName())%>','<%=URLEncoder.encode(demo.getFirstName())%>','<%=URLEncoder.encode(demo.getChartNo() == null ? "" : demo.getChartNo())%>','<%=request.getParameter("messageId")%>','<%=demo.getProviderNo()%>','')">
			<% } %>
		<td class="demoId"><input type="submit" class="btn btn-link" name="demographic_no" value="<%=demo.getDemographicNo()%>"
			onClick="<% if(caisi){ %>
					addNameCaisi('<%=demo.getDemographicNo()%>','<%=URLEncoder.encode(demo.getLastName())%>','<%=URLEncoder.encode(demo.getFirstName())%>','<%=URLEncoder.encode(demo.getChartNo() == null ? "" : demo.getChartNo())%>','<%=request.getParameter("messageId")%>','<%=demo.getProviderNo()%>','')">
					<% } else if (!caisi && OscarProperties.getInstance().isPropertyActive("NEW_CONTACTS_UI") && "contactForm".equals(request.getParameter("formName"))) { %>
					selectContactJson('<%=demoList.indexOf(demo)%>')">
					<% } else { %>
					addName('<%=demo.getDemographicNo()%>','<%=URLEncoder.encode(demo.getLastName())%>','<%=URLEncoder.encode(demo.getFirstName())%>','<%=URLEncoder.encode(demo.getChartNo() == null ? "" : demo.getChartNo())%>','<%=request.getParameter("messageId")%>','<%=demo.getProviderNo()%>','')">
					<% } %>
        </td>
		<td class="lastName"><%=Encode.forHtml(Misc.toUpperLowerCase(demo.getLastName()))%></td>
		<td class="firstName"><%=Encode.forHtml(Misc.toUpperLowerCase(demo.getFirstName()))%></td>
		<td class="age"><%=demo.getAge()%></td>
		<td class="rosterStatus"><%=demo.getRosterStatus()==null||demo.getRosterStatus().equals("")?"&nbsp;":demo.getRosterStatus()%></td>
		<td class="sex"><%=demo.getSex()%></td>
		<td class="dob"><%=demo.getYearOfBirth() + "-" + demo.getMonthOfBirth() + "-" + demo.getDateOfBirth()%></td>
        <td class="doctor"><%=providerBean.getProperty(demo.getProviderNo()==null?"":demo.getProviderNo())==null?"":Encode.forHtml(providerBean.getProperty(demo.getProviderNo()))%></td>
        </tr>

<%
    }
  }

  @SuppressWarnings("unchecked")
  List<MatchingDemographicTransferScore> integratorSearchResults=(List<MatchingDemographicTransferScore>)request.getAttribute("integratorSearchResults");
  if (integratorSearchResults!=null) {
	  for (MatchingDemographicTransferScore matchingDemographicTransferScore : integratorSearchResults) {
	      if( isLocal(matchingDemographicTransferScore, demoList)) {
		  	continue;
	      }
		  rowCounter++;
		  bgColor = rowCounter%2==0?"#EEEEFF":"white";
		  DemographicTransfer demographicTransfer=matchingDemographicTransferScore.getDemographicTransfer();
%>
		   <tr style="background-color: <%=bgColor%>" onMouseOver="this.style.cursor='hand';this.style.backgroundColor='pink';" onMouseout="this.style.backgroundColor='<%=bgColor%>';"
			   onClick="document.forms[0].demographic_no.value=<%=demographicTransfer.getCaisiDemographicId()%>;addName('<%=demographicTransfer.getCaisiDemographicId()%>','<%=URLEncoder.encode(demographicTransfer.getLastName())%>','<%=URLEncoder.encode(demographicTransfer.getFirstName())%>','','<%=request.getParameter("messageId")%>','<%=demographicTransfer.getCaisiProviderId()%>','<%=demographicTransfer.getIntegratorFacilityId()%>')">
			<td class="demoId" colspan="8">
				<input type="submit" class="mbttn" name="demographic_no" value="Integrator <%=CaisiIntegratorManager.getRemoteFacility(loggedInInfo, loggedInInfo.getCurrentFacility(), demographicTransfer.getIntegratorFacilityId()).getName()%>:<%=demographicTransfer.getCaisiDemographicId()%>" />
            </td>
			<td class="lastName"><%=Misc.toUpperLowerCase(demographicTransfer.getLastName())%></td>
			<td class="firstName"><%=Misc.toUpperLowerCase(demographicTransfer.getFirstName())%></td>
<%
		String ageString="";
		String bdayString="";
	
		if (demographicTransfer.getBirthDate()!=null) {
			Integer ageX=DateUtils.getAge(demographicTransfer.getBirthDate(), new GregorianCalendar());
			ageString=ageX.toString();
			
			bdayString=DateFormatUtils.ISO_DATE_FORMAT.format(demographicTransfer.getBirthDate());
		}
%>
			<td class="age"><%=ageString%></td>
			<td class="rosterStatus"></td>
			<td class="sex"><%=demographicTransfer.getGender()%></td>
			<td class="dob"><%=bdayString%></td>
	        <td class="doctor">
<% 
   		FacilityIdStringCompositePk providerPk=new FacilityIdStringCompositePk();
   		providerPk.setIntegratorFacilityId(demographicTransfer.getIntegratorFacilityId());
   		providerPk.setCaisiItemId(demographicTransfer.getCaisiProviderId());
   		CachedProvider cachedProvider=CaisiIntegratorManager.getProvider(loggedInInfo, loggedInInfo.getCurrentFacility(), providerPk);
   		MiscUtils.getLogger().debug("Cached provider, pk="+providerPk.getIntegratorFacilityId()+","+providerPk.getCaisiItemId()+", cachedProvider="+cachedProvider);
   		
   		String providerName="";
   		
   		if (cachedProvider!=null)
   		{
   			providerName=cachedProvider.getLastName()+", "+cachedProvider.getFirstName();
   		}
%>
        	<%=Encode.forHtml(providerName)%>
			</td>
		</tr>
<%	  
		}
 	}
	for (Enumeration e = request.getParameterNames() ; e.hasMoreElements() ;) {
		temp=e.nextElement().toString();
		if(temp.equals("keyword") || temp.equals("dboperation") ||temp.equals("displaymode")||temp.equals("submit") ||temp.equals("chart_no")) continue; %>
  	  	<input type="hidden" name="<%=Encode.forHtmlAttribute(temp)%>" value="<%=Encode.forHtmlAttribute(request.getParameter(temp))%>">
  <% }
  
%>
	
</table>
</form>
<%
	int nLastPage=0,nNextPage=0;
	nNextPage=Integer.parseInt(strLimit2)+Integer.parseInt(strLimit1);
	nLastPage=Integer.parseInt(strLimit1)-Integer.parseInt(strLimit2);
%>
 
<%
	if(rowCounter==0 && nLastPage<=0) {	 
	  	     
      	HashMap<String, String> params = new HashMap<String, String>();
      	params.put("originalPage", request.getParameter("originalPage"));
      	params.put("provider_no", request.getParameter("provider_no"));
		params.put("bFirstDisp", request.getParameter("bFirstDisp"));
      	params.put("year", request.getParameter("year"));
  		params.put("month", request.getParameter("month"));
  		params.put("day", request.getParameter("day"));  		
  		params.put("start_time", request.getParameter("start_time"));
  		params.put("end_time", request.getParameter("end_time"));
  		params.put("duration", request.getParameter("duration"));
  		params.put("appointment_date", request.getParameter("appointment_date"));  		
  		params.put("notes", request.getParameter("notes"));
		params.put("reasonCode", request.getParameter("reasonCode"));
  		params.put("reason", request.getParameter("reason"));
  		params.put("location", request.getParameter("location"));
  		params.put("resources", request.getParameter("resources"));
  		params.put("apptType", request.getParameter("type"));
  		params.put("style", request.getParameter("style"));
  		params.put("billing", request.getParameter("billing"));
  		params.put("status", request.getParameter("status"));
  		params.put("createdatetime", request.getParameter("createdatetime"));
  		params.put("creator", request.getParameter("creator"));
  		params.put("remarks", request.getParameter("remarks"));
  		
  		pageContext.setAttribute("apptParamsName", params);
  		
  		if(OscarProperties.getInstance().getProperty("ModuleNames","").indexOf("Caisi") != -1 &&
                OscarProperties.getInstance().getProperty("caisi.search.workflow","false").equals("true")) {

%>
                <html:link action="/PMmodule/GenericIntake/Edit.do?method=create&type=quick&fromAppt=1" name="apptParamsName">
                <bean:message key="demographic.search.btnCreateNew" /></html:link>
 <%
        } else {
%>
	<div><br><bean:message key="demographic.search.noResultsWereFound" /></div>
  <div class="createNew">
		<a href="../demographic/demographicaddarecordhtm.jsp?fromAppt=1&originalPage=<%=request.getParameter("originalPage")%>&search_mode=<%=Encode.forUriComponent(request.getParameter("search_mode"))%>&keyword=<%=Encode.forUriComponent(request.getParameter("keyword"))%>&notes=<%=Encode.forUriComponent(request.getParameter("notes"))%>&appointment_date=<%=request.getParameter("appointment_date")%>&year=<%=request.getParameter("year")%>&month=<%=request.getParameter("month")%>&day=<%=request.getParameter("day")%>&start_time=<%=request.getParameter("start_time")%>&end_time=<%=request.getParameter("end_time")%>&duration=<%=request.getParameter("duration")%>&bFirstDisp=false&provider_no=<%=request.getParameter("provider_no")%>&notes=<%=Encode.forUriComponent(request.getParameter("notes"))%>&reasonCode=<%=Encode.forUriComponent(request.getParameter("reasonCode"))%>&reason=<%=Encode.forUriComponent(request.getParameter("reason"))%>&location=<%=Encode.forUriComponent(request.getParameter("location"))%>&resources=<%=request.getParameter("resources")%>&type=<%=request.getParameter("type")%>&style=<%=request.getParameter("style")%>&billing=<%=request.getParameter("billing")%>&status=<%=Encode.forUriComponent(request.getParameter("status"))%>&createdatetime=<%=request.getParameter("createdatetime")%>&creator=<%=Encode.forUriComponent(request.getParameter("creator"))%>&remarks=<%=request.getParameter("remarks")%>">
		<bean:message key="demographic.search.btnCreateNew" /></a>
    </div>    
<%
        }
%>	


<%
	}
%> 
<script language="JavaScript">
	<!--
	function last() {
	  document.nextform.action="../demographic/demographiccontrol.jsp?keyword=<%=request.getParameter("keyword")%>&search_mode=<%=request.getParameter("search_mode")%>&displaymode=<%=request.getParameter("displaymode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=<%=request.getParameter("orderby")%>&limit1=<%=nLastPage%>&limit2=<%=strLimit2%>" ;
	  //document.nextform.submit();  
	}
	function next() {
	  document.nextform.action="../demographic/demographiccontrol.jsp?keyword=<%=request.getParameter("keyword")%>&search_mode=<%=request.getParameter("search_mode")%>&displaymode=<%=request.getParameter("displaymode")%>&dboperation=<%=request.getParameter("dboperation")%>&orderby=<%=request.getParameter("orderby")%>&limit1=<%=nNextPage%>&limit2=<%=strLimit2%>" ;
	  //document.nextform.submit();  
	}
	//-->
	</script>
	<!-- <a href="#" onclick="showHideItem('demographicSearch');" id="searchPopUpButton" class="btn btn-link">Search</a> -->
	<div class="bottomBar">
	<form method="post" name="nextform" action="../demographic/demographiccontrol.jsp">
<%
	if(nLastPage>=0) {
%> 
	<input type="submit" id="prevPageButton" name="submit" class="btn"
	value="<bean:message key="demographic.demographicsearch2apptresults.btnPrevPage"/>"
	onClick="last()"> 
<%
	}

	if((demoList.size()==limit)) {
%> 
	<input type="submit" id="nextPageButton" name="submit" class="btn" value="<bean:message key="demographic.demographicsearch2apptresults.btnNextPage"/>" onClick="next()"> 
<%
	}
	for (Enumeration e = request.getParameterNames() ; e.hasMoreElements() ;) {
		temp=e.nextElement().toString();
		if(temp.equals("dboperation") ||temp.equals("displaymode") ||temp.equals("submit")  ||temp.equals("chart_no")) continue; %>
  		<input type='hidden' name="<%=Encode.forHtmlAttribute(temp)%>" value="<%=Encode.forHtmlAttribute(request.getParameter(temp))%>">
	<% }
%>
	<% if (demoList.size() == 1) {
		Demographic demo = demoList.get(0);
	
			if(caisi) {
	%>
			<script language="JavaScript">
				addNameCaisi('<%=demo.getDemographicNo()%>','<%=URLEncoder.encode(demo.getLastName())%>','<%=URLEncoder.encode(demo.getFirstName())%>','<%=URLEncoder.encode(demo.getChartNo() == null ? "" : demo.getChartNo())%>','<%=request.getParameter("messageId")%>','<%=demo.getProviderNo()%>','');
			</script>
	<%		} else if (OscarProperties.getInstance().isPropertyActive("NEW_CONTACTS_UI") && "contactForm".equals(request.getParameter("formName"))) { %>
        <script type="text/javascript">
            document.forms[0].demographic_no.value = <%=demo.getDemographicNo()%>;
            selectContactJson('<%=demoList.indexOf(demo)%>');
        </script>
		<% } else {%>
				<script language="JavaScript">
					document.forms[0].demographic_no.value = <%=demo.getDemographicNo()%>;
					addName('<%=demo.getDemographicNo()%>','<%=URLEncoder.encode(demo.getLastName())%>','<%=URLEncoder.encode(demo.getFirstName())%>','<%=URLEncoder.encode(demo.getChartNo() == null ? "" : demo.getChartNo())%>','<%=request.getParameter("messageId")%>','<%=demo.getProviderNo()%>','');
				</script>
	<%		}
	 } %>
</form>
</div>
</div>
</body>
</html>
<%!

Boolean isLocal(MatchingDemographicTransferScore matchingDemographicTransferScore, List<Demographic> demoList) {
    String hin = matchingDemographicTransferScore.getDemographicTransfer().getHin(); 
    for( Demographic demo : demoList ) {
		
		if( hin != null && hin.equals(demo.getHin()) ) {
		    return true;
		}
    }
    
    return false;
    
}

%>
