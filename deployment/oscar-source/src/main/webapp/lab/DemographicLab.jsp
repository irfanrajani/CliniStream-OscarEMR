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
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="oscar.oscarEncounter.pageUtil.EctDisplayLabAction2"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="oscar.oscarLab.ca.all.web.LabDisplayHelper"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="java.util.*"%>
<%@ page import="oscar.oscarLab.ca.on.LabResultData"%>
<%@ page import="oscar.oscarMDS.data.*,oscar.oscarLab.ca.on.*"%>
<%@ page import="oscar.util.DateUtils" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("${ pageContext.request.contextPath }/securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%


    //oscar.oscarMDS.data.MDSResultsData mDSData = new oscar.oscarMDS.data.MDSResultsData();
    CommonLabResultData comLab = new CommonLabResultData();
    //String providerNo = request.getParameter("providerNo");
    String providerNo =  (String) session.getAttribute("user");
    String searchProviderNo = request.getParameter("searchProviderNo");
    String ackStatus = request.getParameter("status");
    String demographicNo = request.getParameter("demographicNo"); // used when searching for labs by patient instead of provider

    if ( ackStatus == null ) { ackStatus = "N"; } // default to only new lab reports
    if ( providerNo == null ) { providerNo = ""; }
    if ( searchProviderNo == null ) { searchProviderNo = providerNo; }

    ArrayList<LabResultData> labs = comLab.populateLabResultsData(LoggedInInfo.getLoggedInInfoFromSession(request), "",demographicNo, "", "","","U");

    LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    if (loggedInInfo.getCurrentFacility().isIntegratorEnabled())
    {
       ArrayList<LabResultData> remoteResults=CommonLabResultData.getRemoteLabs(loggedInInfo,Integer.parseInt(demographicNo));
       labs.addAll(remoteResults);
    }

    Collections.sort(labs);

    int pageNum = 1;
    if ( request.getParameter("pageNum") != null ) {
        pageNum = Integer.parseInt(request.getParameter("pageNum"));
    }

    LabResultData result;

    LinkedHashMap<String,LabResultData> accessionMap = new LinkedHashMap<String,LabResultData>();

	for (int i = 0; i < labs.size(); i++) {
		result = labs.get(i);
		if (result.accessionNumber == null || result.accessionNumber.equals("")) {
			accessionMap.put("noAccessionNum" + i + result.labType, result);
		} else {
			if (!accessionMap.containsKey(result.accessionNumber + result.labType)) accessionMap.put(result.accessionNumber + result.labType, result);
		}
	}
	labs = new ArrayList<LabResultData>(accessionMap.values());


%>
<html:html locale="true">
<head>

<title><bean:message key="oscarMDS.index.title" /> Page <%=pageNum%>
</title>
<html:base />



<script type="text/javascript" language=javascript>

function popupStart(vheight,vwidth,varpage) {
    popupStart(vheight,vwidth,varpage,"helpwindow");
}

function popupStart(vheight,vwidth,varpage,windowname) {
    var page = varpage;
    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
    var popup=window.open(varpage, windowname, windowprops);
}

function reportWindow(page) {
    windowprops="height=800, width=1200, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
    var popup = window.open(page, "labreport", windowprops);
    popup.focus();
}

function checkSelected() {
    aBoxIsChecked = false;
    if (document.reassignForm.flaggedLabs.length == undefined) {
        if (document.reassignForm.flaggedLabs.checked == true) {
            aBoxIsChecked = true;
        }
    } else {
        for (i=0; i < document.reassignForm.flaggedLabs.length; i++) {
            if (document.reassignForm.flaggedLabs[i].checked == true) {
                aBoxIsChecked = true;
            }
        }
    }
    if (aBoxIsChecked) {
        popupStart(300, 400, 'SelectProvider.jsp', 'providerselect');
    } else {
        alert('<bean:message key="oscarMDS.index.msgSelectOneLab"/>');
    }
}

function submitFile(){
   aBoxIsChecked = false;
    if (document.reassignForm.flaggedLabs.length == undefined) {
        if (document.reassignForm.flaggedLabs.checked == true) {
            aBoxIsChecked = true;
        }
    } else {
        for (i=0; i < document.reassignForm.flaggedLabs.length; i++) {
            if (document.reassignForm.flaggedLabs[i].checked == true) {
                aBoxIsChecked = true;
            }
        }
    }
    if (aBoxIsChecked) {
       document.reassignForm.action = '${ pageContext.request.contextPath }/oscarLab/FileLabs.do';
       document.reassignForm.submit();
    }
}

function checkAll(formId){
   var f = document.getElementById(formId);
   var val = f.checkA.checked;
   for (i =0; i < f.flaggedLabs.length; i++){
      f.flaggedLabs[i].checked = val;
   }
}
</script>
    <link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->
    <link href="${ pageContext.request.contextPath }/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
    <link href="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet">

    <link href="${ pageContext.request.contextPath }/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">
    <link href="${ pageContext.request.contextPath }/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">

    <script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="${ pageContext.request.contextPath }/js/global.js"></script>
    <script src="${ pageContext.request.contextPath }/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->

    <script src="${ pageContext.request.contextPath }/library/jquery/jquery-ui-1.12.1.min.js"></script>
    <script src="${ pageContext.request.contextPath }//js/global.js"></script>


    <script>
	    jQuery(document).ready( function () {
	        jQuery('#labTbl').DataTable({
            "order": [],
            "language": {
                        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
            });
	    });
    </script>

<script>
$(function() {
    $( document ).tooltip();
  });
</script>
<style>
.visLink {
	color : white;
}
</style>

</head>
<body>
<form name="reassignForm" method="post" action="ReportReassign.do"
	id="lab_form">
<table class="MainTable" id="scrollNumber1" style="width:100%">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowRightColumn"  style="text-align: left;">
		<table style="width:100%">
			<tr>
				<td style="text-align: left; width:30%"><input
					type="hidden" name="providerNo" value="<%= providerNo %>">
				<input type="hidden" name="searchProviderNo"
					value="<%= searchProviderNo %>"> <%= (request.getParameter("lname") == null ? "" : "<input type=\"hidden\" name=\"lname\" value=\""+request.getParameter("lname")+"\">") %>
				<%= (request.getParameter("fname") == null ? "" : "<input type=\"hidden\" name=\"fname\" value=\""+request.getParameter("fname")+"\">") %>
				<%= (request.getParameter("hnum") == null ? "" : "<input type=\"hidden\" name=\"hnum\" value=\""+request.getParameter("hnum")+"\">") %>
				<input type="hidden" name="status" value="<%= ackStatus %>">
				<input type="hidden" name="selectedProviders"> <% if (demographicNo == null) { %>
				<input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnSearch"/>"
					onClick="window.location='Search.jsp?providerNo=<%= providerNo %>'">
				<% } %> <input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnClose"/>"
					onClick="window.close()">

					 <% if (demographicNo != null) { %>
					<input type="button" class="btn"
					value="Search OLIS"
					onClick="popupStart('1000','1200','<%=request.getContextPath() %>/olis/Search.jsp?demographicNo=<%=demographicNo %>','OLIS_SEARCH')">
					<% } %>

					<% if (demographicNo == null && request.getParameter("fname") != null) { %>
				<input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnDefaultView"/>"
					onClick="window.location='DemographicLab.jsp?providerNo=<%= providerNo %>'">
				<% } %> <% if (demographicNo == null && labs.size() > 0) { %>
				<input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnForward"/>"
					onClick="checkSelected()"> <input type="button"
					class="btn" value="File" onclick="submitFile()" />
					<span title="<bean:message key="global.uploadWarningBody"/>" style="vertical-align:middle;font-family:arial;font-size:20px;font-weight:bold;color:#ABABAB;cursor:pointer"><img border="0" src="${ pageContext.request.contextPath }/images/icon_alertsml.gif"/></span></span>

					 <% } %>
				</td>
				<td style="text-align: center; width:40%" class="Nav">
				&nbsp;&nbsp;&nbsp; <% if (demographicNo == null) { %> <span
					class="white"> <% if (ackStatus.equals("N")) {%> <bean:message
					key="oscarMDS.index.msgNewLabReportsFor" /> <%} else if (ackStatus.equals("A")) {%>
				<bean:message key="oscarMDS.index.msgAcknowledgedLabReportsFor" /> <%} else {%>
				<bean:message key="oscarMDS.index.msgAllLabReportsFor" /> <%}%>&nbsp;
				<% if (searchProviderNo.equals("")) {%> <bean:message
					key="oscarMDS.index.msgAllPhysicians" /> <%} else if (searchProviderNo.equals("0")) {%>
				<bean:message key="oscarMDS.index.msgUnclaimed" /> <%} else {%> <%=ProviderData.getProviderName(searchProviderNo)%>
				<%}%> &nbsp;&nbsp;&nbsp; Page : <%=pageNum%> </span> <% } %>
				</td>
				<td style="text-align:right; width:30%;"><oscar:help keywords="lab demographic" key="app.top1"/> | <a
					href="javascript:popupStart(300,400,'${ pageContext.request.contextPath }/oscarEncounter/About.jsp')"><bean:message
					key="global.about" /></a></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<table  id="labTbl" class="stripe">
<thead>
	<tr>
		<th style="text-align: left;" class="cell"><bean:message
			key="oscarMDS.index.msgDiscipline" /></th>
		<th style="text-align: left;" class="cell"><bean:message
			key="oscarMDS.index.msgDateTest" /></th>
		<th style="text-align: left;" class="cell"><bean:message
			key="oscarMDS.index.msgRequestingClient" /></th>
		<th style="text-align: left;" class="cell"><bean:message
			key="oscarMDS.index.msgResultStatus" /></th>
		<th style="text-align: left;" class="cell"><bean:message
			key="oscarMDS.index.msgReportStatus" /></th>
		<th style="text-align: left;" class="cell"><bean:message
			key="oscarMDS.index.msgLabel" /></th>
	</tr>
</thead>
<tbody>
	<%

            for (int i = 0; i < labs.size(); i++) {


                result =  (LabResultData) labs.get(i);

                String segmentID        = (String) result.segmentID;
                String status           = (String) result.acknowledgedStatus;

                String resultStatus     = (String) result.resultStatus;

                %>

	<tr	class="<%= (result.isAbnormal() ? "AbnormalRes" : "NormalRes" ) %>">
		<td>
		<%
			String remoteFacilityIdQueryString="";
			if (result.getRemoteFacilityId()!=null)
			{
	         	try {
	               remoteFacilityIdQueryString="&remoteFacilityId="+result.getRemoteFacilityId();
	               String remoteLabKey=LabDisplayHelper.makeLabKey(Integer.parseInt(result.getLabPatientId()), result.getSegmentID(), result.labType, result.getDateTime());
	               remoteFacilityIdQueryString=remoteFacilityIdQueryString+"&remoteLabKey="+URLEncoder.encode(remoteLabKey, "UTF-8");
	            } catch (Exception e) {
	            	MiscUtils.getLogger().error("Error", e);
	            }
			}

		   if ( result.isMDS() ){ %> <a
			href="javascript:reportWindow('${ pageContext.request.contextPath }/oscarMDS/SegmentDisplay.jsp?demographicId=<%=demographicNo%>&segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%><%=remoteFacilityIdQueryString%>')"><%= result.getDiscipline()%></a>
		<% } else if (result.isCML()){ %> <a
			href="javascript:reportWindow('${ pageContext.request.contextPath }/lab/CA/ON/CMLDisplay.jsp?demographicId=<%=demographicNo%>&segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%><%=remoteFacilityIdQueryString%>')"><%=(String) result.getDiscipline()%></a>
		<% }else if (result.isHL7TEXT()) {%> <a
			href="javascript:reportWindow('${ pageContext.request.contextPath }/lab/CA/ALL/labDisplay.jsp?demographicId=<%=demographicNo%>&segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%><%=remoteFacilityIdQueryString%>')"><%=(String) result.getDiscipline()%></a>
		<% } else {%> <a
			href="javascript:reportWindow('${ pageContext.request.contextPath }/lab/CA/BC/labDisplay.jsp?demographicId=<%=demographicNo%>&segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%><%=remoteFacilityIdQueryString%>')"><%=(String) result.getDiscipline()%></a>
		<% }%>
		</td>
		<td>
		<%
		    Date d1 = getServiceDate(loggedInInfo,result);
		 	String formattedDate = DateUtils.getDate(d1);

		%>
		<%=formattedDate %>
		</td>
		<td><%= (String) result.getRequestingClient()%></td>
		<td><%= (result.isAbnormal() ? "Abnormal" : "" ) %></td>
		<td><%= ( (String) ( result.isFinal() ? "Final" : "Partial") )%>
		</td>
		<td><%=StringUtils.trimToEmpty(result.getLabel()) %></td>
	</tr>
	<% } %>
</tbody>
</table>
<table style="width:100%;">
	<tr class="MainTableBottomRow">
		<td class="MainTableBottomRowRightColumn"
			 style="text-align:left;">
		<table style="width:100%;">
			<tr>
				<td style="text-align:left; width:30%;">
				<% if (demographicNo == null) { %> <input type="button"
					class="btn"
					value="<bean:message key="oscarMDS.index.btnSearch"/>"
					onClick="window.location='Search.jsp?providerNo=<%= providerNo %>'">
				<% } %> <input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnClose"/>"
					onClick="window.close()"> <% if (request.getParameter("fname") != null) { %>
				<input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnDefaultView"/>"
					onClick="window.location='DemographicLab.jsp?providerNo=<%= providerNo %>'">
				<% } %> <% if (demographicNo == null && labs.size() > 0) { %>
				<input type="button" class="btn"
					value="<bean:message key="oscarMDS.index.btnForward"/>"
					onClick="checkSelected()"> <input type="button"
					class="btn" value="File" onclick="submitFile()" /> <% } %>
				</td>
				<td style="text-align:center; width:40%;">
				<div class="Nav" >

				</div>
				</td>
				<td style="text-align:right; width:30%;">&nbsp;</td>
			</tr>
		</table>
		</td>
	</tr>
</table>
</form>
</body>
</html:html>
<%!
public Date getServiceDate(LoggedInInfo loggedInInfo, LabResultData labData) {
    EctDisplayLabAction2.ServiceDateLoader loader = new EctDisplayLabAction2.ServiceDateLoader(labData);
    Date resultDate = loader.determineResultDate(loggedInInfo);
    if (resultDate != null) {
        return resultDate;
    }
    return labData.getDateObj();
}
%>