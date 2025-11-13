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
<security:oscarSec roleName="<%=roleName$%>" objectName="_tickler" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_tickler");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	String user_no = (String) session.getAttribute("user");
  int  nItems=0;
     String strLimit1="0";
    String strLimit2="5";
    if(request.getParameter("limit1")!=null) strLimit1 = request.getParameter("limit1");
  if(request.getParameter("limit2")!=null) strLimit2 = request.getParameter("limit2");
  String demoview = request.getParameter("demoview")==null?"all":request.getParameter("demoview") ;

//Retrieve encounter id for updating encounter navbar if info this page changes anything
String parentAjaxId;
if( request.getParameter("parentAjaxId") != null )
    parentAjaxId = request.getParameter("parentAjaxId");
else if( request.getAttribute("parentAjaxId") != null )
    parentAjaxId = (String)request.getAttribute("parentAjaxId");
else
    parentAjaxId = "";

String updateParent;
if( request.getParameter("updateParent") != null )
    updateParent = request.getParameter("updateParent");
else
    updateParent = "false";

	LogAction.addLog(loggedInInfo, LogConst.READ, "Tickler", demoview, "all".equals(demoview)?null:demoview, (String)null);
%>
<%@ page import="java.util.*,java.text.*, oscar.*"%>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Appointment" %>
<%@page import="org.oscarehr.common.dao.OscarAppointmentDao" %>
<%@page import="org.oscarehr.common.model.Provider" %>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@page import="oscar.util.ConversionUtils" %>
<%@page import="org.oscarehr.common.model.Demographic" %>
<%@page import="org.oscarehr.common.dao.DemographicDao" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.common.model.Tickler" %>
<%@ page import="org.oscarehr.common.model.TicklerComment" %>
<%@ page import="org.oscarehr.common.model.TicklerUpdate" %>
<%@ page import="org.oscarehr.managers.TicklerManager" %>
<%@ page import="org.oscarehr.common.model.TicklerLink" %>
<%@ page import="org.oscarehr.common.dao.TicklerLinkDao" %>
<%@ page import="oscar.oscarLab.ca.on.*"%>
<%@ page import="oscar.log.LogAction" %>
<%@ page import="oscar.log.LogConst" %>
<%
	TicklerManager ticklerManager = SpringUtils.getBean(TicklerManager.class);
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
	DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);

	TicklerLinkDao ticklerLinkDao = (TicklerLinkDao) SpringUtils.getBean("ticklerLinkDao");
%>


<%
	String labReqVer = oscar.OscarProperties.getInstance().getProperty("onare_labreqver","07");
if(labReqVer.equals("")) {labReqVer="07";}
%>

<%
	GregorianCalendar now=new GregorianCalendar();
  int curYear = now.get(Calendar.YEAR);
  int curMonth = (now.get(Calendar.MONTH)+1);
  int curDay = now.get(Calendar.DAY_OF_MONTH);
%>
<%
	//String providerview=request.getParameter("provider")==null?"":request.getParameter("provider");
  String ticklerview=request.getParameter("ticklerview")==null?"A":request.getParameter("ticklerview");
   String xml_vdate=request.getParameter("xml_vdate") == null?"2000-01-01":request.getParameter("xml_vdate");
   String xml_appointment_date = request.getParameter("xml_appointment_date")==null?"3000-12-31":request.getParameter("xml_appointment_date");
%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<html:html locale="true">

<head>
<title><bean:message key="tickler.ticklerDemoMain.title" /></title>
 <script src="<%=request.getContextPath()%>/js/global.js"></script>
 <script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>

 <script src="<%=request.getContextPath() %>/library/jquery/jquery-ui-1.12.1.min.js"></script>

 <script>
    jQuery.noConflict();
 </script>


 <link rel="stylesheet" href="<%=request.getContextPath()%>/library/jquery/jquery-ui.theme-1.12.1.min.css">
 <link rel="stylesheet" href="<%=request.getContextPath()%>/library/jquery/jquery-ui.structure-1.12.1.min.css">
 <style>
	td.lilac, td.white      {
        color: #000000;
        padding-top: 4px;
        padding-bottom: 4px;
    }
	td.lilacRed, td.whiteRed {
        color: red;
        padding-top: 4px;
        padding-bottom: 4px;
    }
	td.lilacRed A:link, td.whiteRed a:link  {
        font-weight: normal;
        color: red;
    }
	td.lilacRed A:visited, td.whiteRed a:visited  {
        font-weight: normal;
        color: red;
    }
	td.lilacRed A:hover, td.whiteRed a:hover {
        font-weight: normal;
        color: red;
        background-color: #CDCFFF  ;
    }
    td.lilacRed A:focus, td.whiteRed a:focus    {
        font-weight: bold;
        color: white;
        background-color: #666699  ;
    }
	td.whiteRed, td.lilacRed {
        font-weight: normal;
        color: red;
        background-color: #FFFFFF;
        padding-top: 4px;
        padding-bottom: 4px;
    }
    .message {
        font-style: italic;
        font-size: 90%;
     }

 </style>

 <link rel="stylesheet" type="text/css" media="all" href="../css/print.css"  />
 <link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

<script>
jQuery(document).ready(function() {
	jQuery( "#note-form" ).dialog({
		autoOpen: false,
		height: 340,
		width: 450,
		modal: true,

		close: function() {

		}
	});

});

function openNoteDialog(demographicNo, ticklerNo) {
	jQuery("#tickler_note_demographicNo").val(demographicNo);
	jQuery("#tickler_note_ticklerNo").val(ticklerNo);

    	//is there an existing note?
	jQuery.ajax({url:'../CaseManagementEntry.do',
		data: { method: "ticklerGetNote", ticklerNo: jQuery('#tickler_note_ticklerNo').val()  },
		success:function(data) {
            //console.log(data);
            try {
                note = JSON.parse(data);
			    jQuery("#tickler_note_noteId").val(note.noteId);
			    jQuery("#tickler_note").val(note.note);
			    jQuery("#tickler_note_revision").html(note.revision);
			    jQuery("#tickler_note_revision_url").attr('onclick','window.open(\'../CaseManagementEntry.do?method=notehistory&noteId='+note.noteId+'\');return false;');
			    jQuery("#tickler_note_editor").html(note.editor);
			    jQuery("#tickler_note_obsDate").html(note.obsDate);
            } catch(e) {
                console.log("No data");

            }

		}

		});
		jQuery( "#note-form" ).dialog( "open" );

}
function closeNoteDialog() {
	jQuery( "#note-form" ).dialog( "close" );
}
function saveNoteDialog() {

	jQuery.ajax({url:'../CaseManagementEntry.do',
		data: { method: "ticklerSaveNote", noteId: jQuery("#tickler_note_noteId").val(), value: jQuery('#tickler_note').val(), demographicNo: jQuery('#tickler_note_demographicNo').val(), ticklerNo: jQuery('#tickler_note_ticklerNo').val()  },
		async:false,
		success:function(data) {
		//  alert('ok');
		},
		error: function(jqXHR, textStatus, errorThrown ) {
			alert(errorThrown);
		}
		});

	jQuery( "#note-form" ).dialog( "close" );
}



</script>



<script>

    function Check(e)
    {
	e.checked = true;
	//Highlight(e);
    }

    function Clear(e)
    {
	e.checked = false;
	//Unhighlight(e);
    }

    function CheckAll()
    {
	var ml = document.ticklerform;
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
	    var e = ml.elements[i];
	    if (e.name == "checkbox") {
		Check(e);
	    }
	}
	//ml.toggleAll.checked = true;
    }

    function ClearAll()
    {
	var ml = document.ticklerform;
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
	    var e = ml.elements[i];
	    if (e.name == "checkbox") {
		Clear(e);
	    }
	}
	//ml.toggleAll.checked = false;
    }

    function Highlight(e)
    {
	var r = null;
	if (e.parentNode && e.parentNode.parentNode) {
	    r = e.parentNode.parentNode;
	}
	else if (e.parentElement && e.parentElement.parentElement) {
	    r = e.parentElement.parentElement;
	}
	if (r) {
	    if (r.className == "msgnew") {
		r.className = "msgnews";
	    }
	    else if (r.className == "msgold") {
		r.className = "msgolds";
	    }
	}
    }

    function Unhighlight(e)
    {
	var r = null;
	if (e.parentNode && e.parentNode.parentNode) {
	    r = e.parentNode.parentNode;
	}
	else if (e.parentElement && e.parentElement.parentElement) {
	    r = e.parentElement.parentElement;
	}
	if (r) {
	    if (r.className == "msgnews") {
		r.className = "msgnew";
	    }
	    else if (r.className == "msgolds") {
		r.className = "msgold";
	    }
	}
    }

    function AllChecked()
    {
	ml = document.messageList;
	len = ml.elements.length;
	for(var i = 0 ; i < len ; i++) {
	    if (ml.elements[i].name == "Mid" && !ml.elements[i].checked) {
		return false;
	    }
	}
	return true;
    }

    function Delete()
    {
	var ml=document.messageList;
	ml.DEL.value = "1";
	ml.submit();
    }

    function SynchMoves(which) {
	var ml=document.messageList;
	if(which==1) {
	    ml.destBox2.selectedIndex=ml.destBox.selectedIndex;
	}
	else {
	    ml.destBox.selectedIndex=ml.destBox2.selectedIndex;
	}
    }

    function SynchFlags(which)
    {
	var ml=document.messageList;
	if (which == 1) {
	    ml.flags2.selectedIndex = ml.flags.selectedIndex;
	}
	else {
	    ml.flags.selectedIndex = ml.flags2.selectedIndex;
	}
    }

    function SetFlags()
    {
	var ml = document.messageList;
	ml.FLG.value = "1";
	ml.submit();
    }

    function Move() {
	var ml = document.messageList;
	var dbox = ml.destBox;
	if(dbox.options[dbox.selectedIndex].value == "@NEW") {
	    nn = window.prompt("<bean:message key="tickler.ticklerDemoMain.msgFolderName"/>","");
	    if(nn == null || nn == "null" || nn == "") {
		dbox.selectedIndex = 0;
		ml.destBox2.selectedIndex = 0;
	    }
	    else {
		ml.NewFol.value = nn;
		ml.MOV.value = "1";
		ml.submit();
	    }
	}
	else {
	    ml.MOV.value = "1";
	    ml.submit();
	}
    }

    function allYear()
    {
    var newD = "3000-12-31";
    var beginD = "2000-01-01"
    	document.serviceform.xml_appointment_date.value = newD;
    		document.serviceform.xml_vdate.value = beginD;
}

function setup() {

    var parentId = "<%=parentAjaxId%>";
    var Url = window.opener.URLs;
    var update = "<%=updateParent%>";

    if( update == "true" && parentId != "" && !window.opener.closed ) {
        window.opener.document.forms['encForm'].elements['reloadDiv'].value=parentId;
        window.opener.updateNeeded = true;
    }
    else if( update == "true" && parentId == "" && !window.opener.closed )
        window.opener.location.reload();
  }


function generateRenalLabReq(demographicNo) {
	var url = '<%=request.getContextPath()%>/form/formlabreq<%=labReqVer%>.jsp?demographic_no='+demographicNo+'&formId=0&provNo=<%=session.getAttribute("user")%>&fromSession=true';
	jQuery.ajax({url:'<%=request.getContextPath()%>/renal/Renal.do?method=createLabReq&demographicNo='+demographicNo,async:false, success:function(data) {
		popupPage(900,850,url);
	}});
}

function reportWindow(page) {
    windowprops="height=660, width=960, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
    var popup = window.open(page, "labreport", windowprops);
    popup.focus();
}
</script>


<!--<oscar:customInterface section="ticklerMain"/>-->
</head>
<body onload="setup();" >


<table style="width:100%" >
	<tr>
		<td style="width:10%" class="noprint"><input type='button' name='print' class="btn sbttn"
			value="<bean:message key="global.btnPrint"/>"
			onClick='window.print()'></td>
		<td style="width:90%;text-align:left; font-weight: 900; height:40px;font-size:large;font-family:arial,sans-serif;color:black"><bean:message
			key="tickler.ticklerDemoMain.msgTitle" />
		</td>
	</tr>
</table>
<div class="container-fluid well" >
<form name="serviceform" method="get" action="ticklerDemoMain.jsp">
<table style="width:100%;">
	<tr class="noprint">
		<td style="width:20%;">
		<div><b><bean:message
			key="tickler.ticklerDemoMain.formMoveTo" /> </b> <select
			name="ticklerview">
			<option value="A" <%=ticklerview.equals("A")?"selected":""%>><bean:message
				key="tickler.ticklerDemoMain.formActive" /></option>
			<option value="C" <%=ticklerview.equals("C")?"selected":""%>><bean:message
				key="tickler.ticklerDemoMain.formCompleted" /></option>
			<option value="D" <%=ticklerview.equals("D")?"selected":""%>><bean:message
				key="tickler.ticklerDemoMain.formDeleted" /></option>
		</select></div>
		</td>
		<td style="width:30%;">
		<div style="text-align: center;" ><bean:message
			key="tickler.ticklerDemoMain.btnBegin" />:<input type="date" style="height:26px;" name="xml_vdate"
			value="<%=xml_vdate%>">  </div>
		</td>
		<td style="width:30%;"><bean:message
			key="tickler.ticklerDemoMain.btnEnd" />:
            <input type="date" style="height:26px;" name="xml_appointment_date"
			value="<%=xml_appointment_date%>"> </td>
		<td style="width:20%;">
		<div style="text-align: right;"><input type="hidden" name="demoview"
			value="<%=demoview%>"> <input type="hidden" name="Submit"
			value=""> <input type="hidden" name="parentAjaxId"
			value="<%=parentAjaxId%>"> <input type="submit"
			value="<bean:message key="tickler.ticklerDemoMain.btnCreateReport"/>"
			class="btn btn-primary"
			onclick="document.forms['serviceform'].Submit.value='Create Report'; document.forms['serviceform'].submit();">
		</div>
		</td>
	</tr>
</table>
	</form>

	<form name="ticklerform" method="post" action="dbTicklerDemoMain.jsp">
        <input type="hidden" name="demoview" value="<%=demoview%>">
		<input type="hidden" name="parentAjaxId" value="<%=parentAjaxId%>">
		<input type="hidden" name="updateParent" value="true">
<table style="width:100%;">

	<tr>
		<td>


		<table id="ticklerTable" class="table table-striped table-condensed">
            <thead>
			<tr>
				<th style="width:3%;" class="noprint">&nbsp;</th>
				<th style="width:3%;" class="noprint">&nbsp;</th>
				<th style="width:12%;"><bean:message
					key="tickler.ticklerMain.msgDemographicName" /></th>
				<th style="width:12%;"><bean:message
					key="tickler.ticklerMain.MRP" /></th>
				<th style="width:9%;"><bean:message
					key="tickler.ticklerMain.msgDate" /></th>
				<th style="width:9%;"><bean:message
					key="tickler.ticklerMain.msgCreationDate" /></th>
				<th style="width:6%;"><bean:message
					key="tickler.ticklerMain.Priority" /></th>
				<th style="width:12%;"><bean:message
					key="tickler.ticklerMain.taskAssignedTo" /></th>
				<th style="width:6%;"><bean:message
					key="tickler.ticklerMain.msgStatus" /></th>
				<th style="width:29%;"><bean:message
					key="tickler.ticklerMain.msgMessage" /></th>
				<th style="width:3%;" class="noprint">&nbsp;&nbsp;&nbsp;</th>
			</tr>
            </thead>
            <tbody>
			<%
				String vGrantdate = "1980-01-07 00:00:00.0";
				DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:ss:mm.SSS", request.getLocale());


				String dateBegin = xml_vdate;
				String dateEnd = xml_appointment_date;
				String provider = "";
				String taskAssignedTo = "";

				if (dateEnd.compareTo("") == 0) dateEnd = "3000-12-31";
				if (dateBegin.compareTo("") == 0) dateBegin="2000-01-01";

				List<Tickler> ticklers = ticklerManager.search_tickler_bydemo(loggedInInfo, request.getParameter("demoview")==null?null: Integer.parseInt(request.getParameter("demoview")),ticklerview,ConversionUtils.fromDateString(dateBegin),ConversionUtils.fromDateString(dateEnd));
				String rowColour = "lilac";
				for (Tickler t:ticklers) {

				    Demographic d = demographicDao.getDemographicById(t.getDemographicNo());
				    Provider p = null;
				    Provider assignedP = null;
					String providerNumber = d.getProviderNo();

				    if(d != null && providerNumber != null && ! providerNumber.isEmpty()) {
				            p = providerDao.getProvider(providerNumber);
				    }
				    if(t.getTaskAssignedTo().length()>0) {
				            assignedP = providerDao.getProvider(t.getTaskAssignedTo());
				    }

				    nItems = nItems +1;

				    if (p == null){
				      provider = "";
				    } else {
				      provider = p.getFormattedName();
				    }

				    if (assignedP == null){
				      taskAssignedTo = "";
				    }
				    else{
				      taskAssignedTo = assignedP.getFormattedName();
				    }

				    vGrantdate = t.getServiceDate() + " 00:00:00.0";
				    java.util.Date grantdate = dateFormat.parse(vGrantdate);
				    java.util.Date toDate = new java.util.Date();
				    long millisDifference = toDate.getTime() - grantdate.getTime();

				    long ONE_DAY_IN_MS = (1000 * 60 * 60 * 24);
				    long daysDifference = millisDifference / (ONE_DAY_IN_MS);

				    String numDaysUntilWarn = OscarProperties.getInstance().getProperty("tickler_warn_period");
				    long ticklerWarnDays = Long.parseLong(numDaysUntilWarn);
				    boolean ignoreWarning = (ticklerWarnDays < 0);


				    //Set the colour of the table cell
				    String warnColour = "";
				    if (!ignoreWarning && (daysDifference >= ticklerWarnDays)){
				       warnColour = "Red";
				    }

				    if (rowColour.equals("lilac")){
				       rowColour = "white";
				    }else {
				       rowColour = "lilac";
				    }

				    String cellColour = rowColour + warnColour;
			%>

			<tr>
				<td class="<%=cellColour%> noprint"><input
					type="checkbox" name="checkbox"
					value="<%=t.getId()%>"></td>
					<td class="<%=cellColour%> noprint">
					<%if(Boolean.parseBoolean(OscarProperties.getInstance().getProperty("tickler_edit_enabled"))) {%>
					<a href=#  onClick="popupPage(600,800, '<%=request.getContextPath() %>/tickler/ticklerEdit.jsp?tickler_no=<%=t.getId()%>')"><bean:message key="tickler.ticklerMain.editTickler"/></a>
					<% } %>
					</td>
				<TD class="<%=cellColour%>"><a
					href=#
					onClick="window.open('<%=request.getContextPath() %>/demographic/demographiccontrol.jsp?demographic_no=<%=t.getDemographicNo()%>&displaymode=edit&dboperation=search_detail')"><%=d.getLastName()%>,<%=d.getFirstName()%></a></td>
				<td class="<%=cellColour%>"><%=provider%></td>
				<td class="<%=cellColour%>">
				<%
					java.util.Date service_date = t.getServiceDate();
						SimpleDateFormat dateFormat2 = new SimpleDateFormat("yyyy-MM-dd");
						String service_date_str = dateFormat2.format(service_date);
						out.print(service_date_str);
				%>
				</td>
				<td class="<%=cellColour%>">
				<%
					service_date = t.getUpdateDate();
						dateFormat2 = new SimpleDateFormat("yyyy-MM-dd");
						service_date_str = dateFormat2.format(service_date);
						out.print(service_date_str);

				%>
				</td>
				<td class="<%=cellColour%>"><%=t.getPriority().toString().equals("High")? "<span style=\"font-weight:bold;\"><i class=\"icon-flag\"></i> High</span>": t.getPriority() %></td>
				<td class="<%=cellColour%>"><%=taskAssignedTo%></td>
				<td class="<%=cellColour%>"><%=String.valueOf(t.getStatus()).equals("A")?"Active":String.valueOf(t.getStatus()).equals("C")?"Completed":String.valueOf(t.getStatus()).equals("D")?"Deleted":String.valueOf(t.getStatus())%></td>
				<td class="<%=cellColour%>"><%=t.getMessage()%>

<%
                                             	List<TicklerLink> linkList = ticklerLinkDao.getLinkByTickler(t.getId().intValue());
                                                if (linkList != null){
                                                    for(TicklerLink tl : linkList){
                                                        String type = tl.getTableName();
%>

                                                <%
                                                	if ( LabResultData.isMDS(type) ){
                                                %>
                                                <a href="javascript:reportWindow('SegmentDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isCML(type)){
                                                %>
                                                <a href="javascript:reportWindow('<%=request.getContextPath() %>/lab/CA/ON/CMLDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isHL7TEXT(type)){
                                                %>
                                                <a href="javascript:reportWindow('<%=request.getContextPath() %>/lab/CA/ALL/labDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isDocument(type)){
                                                %>
                                                <a href="javascript:reportWindow('<%=request.getContextPath() %>/dms/ManageDocument.do?method=display&doc_no=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isHRM(type)){
                                                %>
                                                <a href="javascript:reportWindow('<%=request.getContextPath() %>/hospitalReportManager/Display.do?id=<%=tl.getTableId()%>')">ATT</a>
                                                <%
                                                	}else {
                                                %>
                                                <a href="javascript:reportWindow('<%=request.getContextPath() %>/lab/CA/BC/labDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}
                                                %>
                                        <%
                                        	}
                                                                                }
                                        %>




				</td>
				  <td class="<%=cellColour%> noprint">
                	<a href="javascript:void(0)" onClick="openNoteDialog('<%=t.getDemographicNo() %>','<%=t.getId() %>');return false;">
                		<img title="<bean:message key="Appointment.formNotes"/>" src="<%=request.getContextPath()%>/images/notepad.gif"/>
                	</a>
                </td>
			</tr>
        <%
        	boolean ticklerEditEnabled = Boolean.parseBoolean(OscarProperties.getInstance().getProperty("tickler_edit_enabled"));
                        Set<TicklerComment> tcomments = t.getComments();
                        if (ticklerEditEnabled && !tcomments.isEmpty()) {
                            for (TicklerComment tc : tcomments) {
        %>
                        <tr>
                            <td class="<%=cellColour%> message"></td>
                            <td class="<%=cellColour%> message"></td>
                            <td class="<%=cellColour%> message"><%=tc.getProvider().getLastName()%>,<%=tc.getProvider().getFirstName()%></td>
                            <td class="<%=cellColour%> message"></td>
                            <% if (tc.isUpdateDateToday()) { %>
                            <td class="<%=cellColour%> message"><%=tc.getUpdateTime(request.getLocale())%></td>
                            <% } else { %>
                            <td class="<%=cellColour%> message"><%=tc.getUpdateDate(request.getLocale())%></td>
                            <% } %>
                            <td class="<%=cellColour%> message"></td>
                            <td class="<%=cellColour%> message" colspan="5"><%=tc.getMessage()%></td>

                        </tr>
       <%           }
                }
}

if (nItems == 0) {
%>
			<tr>
				<td colspan="8" class="white"><bean:message
					key="tickler.ticklerDemoMain.msgNoMessages" /></td>
			</tr>
			<%}
			Demographic d = demographicDao.getDemographicById(request.getParameter("demoview")==null?null: Integer.parseInt(request.getParameter("demoview")));
			%>
</tbody>
</table>
<table style="width:100%;">
			<tr class="noprint">
				<td class="white"><a id="checkAllLink" href="javascript:CheckAll();"><bean:message
					key="tickler.ticklerDemoMain.btnCheckAll" /></a> - <a
					href="javascript:ClearAll();"><bean:message
					key="tickler.ticklerDemoMain.btnClearAll" /></a> &nbsp; &nbsp; &nbsp;
				&nbsp; &nbsp; <input type="button" name="button" class="btn btn-primary"
					value="<bean:message key="tickler.ticklerDemoMain.btnAddTickler"/>"
					onClick="popupPage('450','650', 'ticklerAdd.jsp?updateParent=true&parentAjaxId=<%=parentAjaxId%>&bFirstDisp=false&messageID=null&demographic_no=<%=d.getDemographicNo()%>&chart_no=<%=d.getChartNo()%>&name=<%=d.getDisplayName()%>')"
					> <input type="hidden" name="submit_form"
					value=""> <% if (ticklerview.compareTo("D") == 0){%> <input
					type="button"
					value="<bean:message key="tickler.ticklerDemoMain.btnErase"/>"
					class="btn"
					onclick="document.forms['ticklerform'].submit_form.value='Erase Completely'; document.forms['ticklerform'].submit();">
				<%} else{%> <input type="button"
					value="<bean:message key="tickler.ticklerDemoMain.btnComplete"/>"
					class="btn"
					onclick="document.forms['ticklerform'].submit_form.value='Complete'; document.forms['ticklerform'].submit();">
				<input type="button"
					value="<bean:message key="tickler.ticklerDemoMain.btnDelete"/>"
					class="btn"
					onclick="document.forms['ticklerform'].submit_form.value='Delete'; document.forms['ticklerform'].submit();">
				<%}%> <input type="button" name="button"
					value="<bean:message key="global.btnCancel"/>"
					onClick="window.close()" class="btn"></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
	</form>

<div id="note-form" title="<bean:message key="tickler.ticklerDemoMain.title"/>">
	<form>
        <input type="hidden" name="tickler_note_demographicNo" id="tickler_note_demographicNo" value="">
		<input type="hidden" name="tickler_note_ticklerNo" id="tickler_note_ticklerNo" value="">
		<input type="hidden" name="tickler_note_noteId" id="tickler_note_noteId" value="">

		<fieldset>
			<div class="control-group">
				<label class="control-label" for="tickler_note"><bean:message key="Appointment.formNotes"/>:</label>
				<div class="controls">
					<textarea class="input-block-level" rows="5" id="tickler_note" name="tickler_note"></textarea>
				</div>
			</div>
		</fieldset>
        <input type="button" name="button"
					value="<bean:message key="global.btnSave"/>"
					onclick="saveNoteDialog(); return false;" class="btn btn-primary">
        <input type="button" name="button"
					value="<bean:message key="global.btnCancel"/>"
					onclick="closeNoteDialog(); return false;" class="btn"><br>
        <div style="text-align:right; font-size: 80%;">
            <bean:message key="tickler.ticklerDemoMain.msgDate"/>: <span id="tickler_note_obsDate"></span> <bean:message key="oscarEncounter.noteRev.title"/> <a id="tickler_note_revision_url" href="javascript:void(0)" onClick=""><span id="tickler_note_revision"></span></a><br/>
			<bean:message key="oscarEncounter.editors.title"/>: <span id="tickler_note_editor"></span>
        </div>
	</form>
</div>



<p class="noprint">
<%@ include file="../demographic/zfooterbackclose.jsp"%>

</div>
</body>
</html:html>