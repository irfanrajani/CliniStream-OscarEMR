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
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>

<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.*"%>
<%@ page import="oscar.oscarLab.ca.on.*"%>
<%@ page import="org.oscarehr.util.DbConnectionFilter"%>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.common.dao.ViewDao" %>
<%@ page import="org.oscarehr.common.model.View,org.oscarehr.util.LocaleUtils" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.oscarehr.common.model.TicklerLink" %>
<%@ page import="org.oscarehr.common.dao.TicklerLinkDao" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="oscar.MyDateFormat" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.oscarehr.common.model.Site" %>
<%@ page import="org.oscarehr.common.dao.SiteDao" %>
<%@ page import="org.oscarehr.common.model.Tickler" %>
<%@ page import="org.oscarehr.common.model.TicklerComment" %>
<%@ page import="org.oscarehr.common.model.TicklerUpdate" %>
<%@ page import="org.oscarehr.common.model.CustomFilter" %>
<%@ page import="org.oscarehr.managers.TicklerManager" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.net.URLEncoder" %>

<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_tickler" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_tickler");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%
	TicklerManager ticklerManager = SpringUtils.getBean(TicklerManager.class);

	String labReqVer = oscar.OscarProperties.getInstance().getProperty("onare_labreqver","07");
	String help_url = oscar.OscarProperties.getInstance().getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/");
	if(labReqVer.equals("")) {labReqVer="07";}

	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

	String user_no;
     user_no = (String) session.getAttribute("user");

     TicklerLinkDao ticklerLinkDao = (TicklerLinkDao) SpringUtils.getBean("ticklerLinkDao");

     String createReport = request.getParameter("Submit");
     boolean doCreateReport = createReport != null && createReport.equals("Create Report");

     ViewDao viewDao = (ViewDao) SpringUtils.getBean("viewDao");
     String userRole = (String) session.getAttribute("userrole");
     Map<String, View> ticklerView = viewDao.getView("tickler", userRole, user_no);

     String providerview = "all";
     View providerView = ticklerView.get("providerview");

     if( providerView != null  && !doCreateReport)
     {
         providerview = providerView.getValue();
     }
     else if (request.getParameter("providerview") != null)
     {
         providerview = request.getParameter("providerview");
     }

     String assignedTo = "all";
     View assignedToView = ticklerView.get("assignedTo");

     if( assignedToView != null && !doCreateReport)
     {
         assignedTo = assignedToView.getValue();
     }
     else if (request.getParameter("assignedTo") != null)
     {
         assignedTo = request.getParameter("assignedTo");
     }

     String mrpview = "all";
     View mrpView = ticklerView.get("mrpview");

     if( mrpView != null && !doCreateReport)
     {
   	  mrpview = mrpView.getValue();
     }
     else if (request.getParameter("mrpview") != null)
     {
         mrpview = request.getParameter("mrpview");
     }

    String ticklerview = "A";
    View statusView = ticklerView.get("ticklerview");

    if( statusView != null && !doCreateReport)
    {
       ticklerview = statusView.getValue();
    }
     else if (request.getParameter("ticklerview") != null)
     {
         ticklerview = request.getParameter("ticklerview");
     }

    Calendar prior=Calendar.getInstance();
    prior.add(Calendar.MONTH, -3);
    int priorYear = prior.get(Calendar.YEAR);
    int priorMonth = (prior.get(Calendar.MONTH)+1);
    int priorDay = prior.get(Calendar.DAY_OF_MONTH);

    String xml_vdate = MyDateFormat.getMysqlStandardDate(priorYear, priorMonth, priorDay);

    View beginDateView = ticklerView.get("dateBegin");

    if( beginDateView != null && !doCreateReport)
    {
        xml_vdate = beginDateView.getValue();

//xml_vdate = MyDateFormat.getMysqlStandardDate(priorYear, priorMonth, priorDay);
    }
    else if (request.getParameter("xml_vdate") != null)
    {
         xml_vdate = request.getParameter("xml_vdate");
    }

    Calendar now=Calendar.getInstance();
    now.add(Calendar.MONTH, 1);
    int curYear = now.get(Calendar.YEAR);
    int curMonth = (now.get(Calendar.MONTH)+1);
    int curDay = now.get(Calendar.DAY_OF_MONTH);

    String xml_appointment_date = MyDateFormat.getMysqlStandardDate(curYear, curMonth, curDay);

    View endDateView = ticklerView.get("dateEnd");


    if( endDateView != null && !doCreateReport)
    {

        xml_appointment_date = endDateView.getValue();
        //xml_appointment_date = MyDateFormat.getMysqlStandardDate(curYear, curMonth, curDay);
    }
    else if (request.getParameter("xml_appointment_date") != null)
    {
        xml_appointment_date = request.getParameter("xml_appointment_date");
    }
%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />

<html:html locale="true">
<head>
<title><bean:message key="tickler.ticklerMain.title"/></title>

<link href="<c:out value="${ctx}"/>/css/print.css" rel="stylesheet" type="text/css" media="print" >
<link href="${pageContext.request.contextPath}/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->
<link href="${pageContext.request.contextPath}/css/font-awesome.min.css" rel="stylesheet">

<script src="${pageContext.request.contextPath}/library/jquery/jquery-3.6.4.min.js"></script>
<!-- <script src="${pageContext.request.contextPath}/library/jquery/jquery-migrate-3.4.0.js"></script> -->
<script src="${pageContext.request.contextPath}/library/jquery/jquery-ui-1.12.1.min.js"></script>
<script src="${pageContext.request.contextPath}/js/global.js"></script>



<script>
jQuery.noConflict();
</script>
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
	//alert('not yet implemented');
	jQuery.ajax({url:'../CaseManagementEntry.do',
		data: { method: "ticklerSaveNote", noteId: jQuery("#tickler_note_noteId").val(), value: jQuery('#tickler_note').val(), demographicNo: jQuery('#tickler_note_demographicNo').val(), ticklerNo: jQuery('#tickler_note_ticklerNo').val()  },
		async:false,
		success:function(data) {
		 // alert('ok');
		},
		error: function(jqXHR, textStatus, errorThrown ) {
			alert(errorThrown);
		}
		});

	jQuery( "#note-form" ).dialog( "close" );
}



</script>
<script language="JavaScript">
function popupPage(vheight,vwidth,varpage) { //open a new popup window
  var page = "" + varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
  var popup=window.open(page, "attachment", windowprops);
  if (popup != null) {
    if (popup.opener == null) {
      popup.opener = self;
    }
  }
}
function selectprovider(s) {
  if(self.location.href.lastIndexOf("&providerview=") > 0 ) a = self.location.href.substring(0,self.location.href.lastIndexOf("&providerview="));
  else a = self.location.href;
	self.location.href = a + "&providerview=" +s.options[s.selectedIndex].value ;
}
function openBrWindow(theURL,winName,features) {
  window.open(theURL,winName,features);
}
function setfocus() {
  this.focus();
}
function refresh() {
  var u = self.location.href;
  if(u.lastIndexOf("view=1") > 0) {
    self.location.href = u.substring(0,u.lastIndexOf("view=1")) + "view=0" + u.substring(eval(u.lastIndexOf("view=1")+6));
  } else {
    history.go(0);
  }
}



function allYear()
{
var newD = "2200-12-31";
var beginD = "1900-01-01"
	document.serviceform.xml_appointment_date.value = newD;
		document.serviceform.xml_vdate.value = beginD;
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

    function reportWindow(page) {
    windowprops="height=660, width=960, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
    var popup = window.open(page, "labreport", windowprops);
    popup.focus();
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
	    nn = window.prompt("<bean:message key="tickler.ticklerMain.msgFolderName"/>","");
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

    function saveView() {

        var url = "<c:out value="${ctx}"/>/saveWorkView.do";
        var role = "<%=(String)session.getAttribute("userrole")%>";
        var provider_no = "<%=(String) session.getAttribute("user")%>";
        var params = "method=save&view_name=tickler&userrole=" + role + "&providerno=" + provider_no + "&name=ticklerview&value=" + jQuery("#ticklerview").val() + "&name=dateBegin&value=" + jQuery("#xml_vdate").val() + "&name=dateEnd&value=" + jQuery("#xml_appointment_date").val() + "&name=providerview&value=" + encodeURI(jQuery("#providerview").val()) + "&name=assignedTo&value=" + encodeURI(jQuery("#assignedTo").val())  + "&name=mrpview&value=" + encodeURI(jQuery("#mrpview").val());
        var sortables = document.getElementsByClassName('tableSortArrow');

        var attrib = null;
        var columnId = -1;
        for( var idx = 0; idx < sortables.length; ++idx ) {
            attrib = sortables[idx].readAttribute("sortOrder");
            if( attrib != null ) {
                columnId = sortables[idx].previous().readAttribute("columnId");
                break;
            }
        }

        if( columnId != -1 ) {
            params += "&name=columnId&value=" + columnId + "&name=sortOrder&value=" + attrib;
        }

        fetch(url+"?"+params);

    }

    function generateRenalLabReq(demographicNo) {
		var url = '<%=request.getContextPath()%>/form/formlabreq<%=labReqVer%>.jsp?demographic_no='+demographicNo+'&formId=0&provNo=<%=session.getAttribute("user")%>&fromSession=true';
		jQuery.ajax({url:'<%=request.getContextPath()%>/renal/Renal.do?method=createLabReq&demographicNo='+demographicNo,async:false, success:function(data) {
			popupPage(900,850,url);
		}});
	}

</script>

<oscar:customInterface section="ticklerMain"/>
</head>
<body>

<table style="width:100%">
  <tr class="noprint">
    <td style="width:80%; text-align:left">
      <h4>&nbsp;<i class="icon-lightbulb" title='<bean:message key="tickler.ticklerMain.msgTickler"/>'></i>&nbsp;<bean:message key="tickler.ticklerMain.msgTickler"/>
      </h4>
    </td>
	<td style="text-align:right" >
            <i class="icon-question-sign"></i>
            <a href="<%=help_url%>tickler/" target="_blank"><bean:message key="app.top1"/></a>
            <i class=" icon-info-sign" style="margin-left:10px;"></i>
            <a href="javascript:void(0)"  onClick="window.open('<%=request.getContextPath()%>/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,left=0,top=0')" ><bean:message key="global.about" /></a>
    </td>
  </tr>
</table>

<form name="serviceform" method="get" action="ticklerMain.jsp" class="form-horizontal">
<div class="container-fluid well well-small">

        <div class="span4">
          <label for="xml_vdate"><bean:message key="tickler.ticklerMain.formDateRange"/></label>
            <div class="input-append" title="<bean:message key="tickler.ticklerMain.btnBegin"/>" onClick="popupPage(405,430,'../share/CalendarPopup.jsp?urlfrom=../tickler/ticklerMain.jsp&year=<%=priorYear%>&month=<%=priorMonth%>&param=<%=URLEncoder.encode("&formdatebox=document.getElementsByName('xml_vdate')[0].value")%>')">
                <input type="text" class="input-small" id="xml_vdate" name="xml_vdate" value="<%=xml_vdate%>">
                <span class="add-on"><i class="icon-calendar"></i></span>
            </div>
            <div class="input-append" title="<bean:message key="tickler.ticklerMain.btnEnd"/>" onClick="popupPage(405,430,'../share/CalendarPopup.jsp?urlfrom=../tickler/ticklerMain.jsp&year=<%=curYear%>&month=<%=curMonth%>&param=<%=URLEncoder.encode("&formdatebox=document.getElementsByName('xml_appointment_date')[0].value")%>')">

        <input type="text" class="input-small" id="xml_appointment_date" name="xml_appointment_date" value="<%=xml_appointment_date%>">
                <span class="add-on"><i class="icon-calendar"></i></span>
            </div>
        <br><br><a href="#" onClick="allYear()"><bean:message key="tickler.ticklerMain.btnViewAll"/></a>
        </div>

        <div class="span6">
            <div class="control-group">
                <label for="ticklerview"  class="control-label"><bean:message key="tickler.ticklerMain.formMoveTo"/></label>
                    <div class="controls">
                        <select id="ticklerview" name="ticklerview" style="width:240px">
                            <option value="A" <%=ticklerview.equals("A")?"selected":""%>><bean:message key="tickler.ticklerMain.formActive"/></option>
                            <option value="C" <%=ticklerview.equals("C")?"selected":""%>><bean:message key="tickler.ticklerMain.formCompleted"/></option>
                            <option value="D" <%=ticklerview.equals("D")?"selected":""%>><bean:message key="tickler.ticklerMain.formDeleted"/></option>
                        </select>
                    </div>
            </div>
            <div class="control-group">
                <label for="mrpview" class="control-label"> <bean:message key="tickler.ticklerMain.MRP"/></label>
                    <div class="controls">
                        <select id="mrpview" name="mrpview" style="width:240px">
                            <option value="all" <%=mrpview.equals("all")?"selected":""%>><bean:message key="tickler.ticklerMain.formAllProviders"/></option>
                            <%
                            	ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
                                                    List<Provider> providers = providerDao.getActiveProviders();
                                                    for (Provider p : providers) {
                            %>
                            <option value="<%=p.getProviderNo()%>" <%=mrpview.equals(p.getProviderNo())?"selected":""%>><%=p.getLastName()%>,<%=p.getFirstName()%></option>
                            <%
                            	}
                            %>
                         </select>

                    </div>
            </div>
        </div>

        <div class="span6">
            <div class="control-group">
                <label for="providerview" class="control-label"><bean:message key="tickler.ticklerMain.msgCreator"/></label>
                    <div class="controls">
                        <select id="providerview" name="providerview" style="width:240px">
                        <option value="all" <%=providerview.equals("all")?"selected":""%>><bean:message key="tickler.ticklerMain.formAllProviders"/></option>
                    <%
                    	for (Provider p : providers) {
                    %>
                        <option value="<%=p.getProviderNo()%>" <%=providerview.equals(p.getProviderNo())?"selected":""%>><%=p.getLastName()%>,<%=p.getFirstName()%></option>
                    <%
                    	}
                    %>
                        </select>
                </div>
            </div>
            <div class="control-group">
                <label for="assignedTo" class="control-label"><bean:message key="tickler.ticklerMain.msgAssignedTo"/></label>
                    <div class="controls">
<%
	if (org.oscarehr.common.IsPropertiesOn.isMultisitesEnable())
{ // multisite start ==========================================
        	SiteDao siteDao = (SiteDao)SpringUtils.getBean("siteDao");
          	List<Site> sites = siteDao.getActiveSitesByProviderNo(user_no);
%>
      <script>
        var _providers = [];
        <%for (int i=0; i<sites.size(); i++) {%>
	        _providers["<%=sites.get(i).getSiteId()%>"]="<%Iterator<Provider> iter = sites.get(i).getProviders().iterator();
	        while (iter.hasNext()) {
		        Provider p=iter.next();
		        if ("1".equals(p.getStatus())) {%><option value='<%=p.getProviderNo()%>'><%=p.getLastName()%>, <%=p.getFirstName()%></option><%}}%>";
        <%}%>
        function changeSite(sel) {
	        sel.form.assignedTo.innerHTML=sel.value=="none"?"":_providers[sel.value];
        }
      </script>
                      	<select id="site" name="site" onchange="changeSite(this)" style="width:240px">
                      		<option value="none">---select clinic---</option>
                      	<%
                      		for (int i=0; i<sites.size(); i++) {
                      	%>
                      		<option value="<%=sites.get(i).getSiteId()%>" <%=sites.get(i).getSiteId().toString().equals(request.getParameter("site"))?"selected":""%>><%=sites.get(i).getName()%></option>
                      	<%
                      		}
                      	%>
                      	</select>

      	<select id="assignedTo" name="assignedTo" style="width:240px"></select>
<%
	if (request.getParameter("assignedTo")!=null) {
%>
      	<script>
     	changeSite(document.getElementById("site"));
      	document.getElementById("assignedTo").value='<%=request.getParameter("assignedTo")%>';
      	</script>
<%
	} // multisite end ==========================================
} else {
%>
        <select id="assignedTo" name="assignedTo" style="width:240px">
        <%
        // Check for property to default assigned provider and if present - default to user logged in
        	boolean ticklerDefaultAssignedProvier = OscarProperties.getInstance().isPropertyActive("tickler_default_assigned_provider");
        	if (ticklerDefaultAssignedProvier) {
        		if("all".equals(assignedTo)) {
        			assignedTo = user_no;
        		}
        	}
        %>
        	<option value="all" <%=assignedTo.equals("all")?"selected":""%>><bean:message key="tickler.ticklerMain.formAllProviders"/></option>
        <%
        	List<Provider> providersActive = providerDao.getActiveProviders();
                                    for (Provider p : providersActive) {
        %>
        <option value="<%=p.getProviderNo()%>" <%=assignedTo.equals(p.getProviderNo())?"selected":""%>><%=p.getLastName()%>, <%=p.getFirstName()%></option>
        <%
        	}
        %>
        </select>
<%
	}
%>
                </div>
            </div>
        </div><!-- class="span6" -->
    <div >
        <span class="pull-right">
        <input type="hidden" name="Submit" value="">
        <input type="button" class="btn btn-primary noprint" value="<bean:message key="tickler.ticklerMain.btnCreateReport"/>"  onclick="document.forms['serviceform'].Submit.value='Create Report'; document.forms['serviceform'].submit();">

        &nbsp;
        <input type="button" class="btn" value="<bean:message key="tickler.ticklerMain.msgSaveView"/>" onclick="saveView();">
        </span>
</div>
</div> <!-- well -->
</form>

<form name="ticklerform" method="post" action="dbTicklerMain.jsp">

<%
        Locale locale = request.getLocale();
        String sortImage = "uparrow_inv.gif";
        String sortDirection = LocaleUtils.getMessage(locale, "tickler.ticklerMain.sortUp");
        String sortOrderStr = request.getParameter("sort_order");
        boolean isSortAscending = true;

        if(sortOrderStr == null) {
        	sortOrderStr = OscarProperties.getInstance().getProperty("tickler.default_sort_order","asc");
        }
        if (sortOrderStr == null || sortOrderStr.equals("asc")) {
            isSortAscending = false;
            sortOrderStr = TicklerManager.SORT_DESC;
            sortImage = "downarrow_inv.gif";
            sortDirection = LocaleUtils.getMessage(locale, "tickler.ticklerMain.sortDown");
        } else {
            sortOrderStr = TicklerManager.SORT_ASC;
        }

        String sortColumn = request.getParameter("sort_column");
        if (sortColumn == null) {
            sortColumn = TicklerManager.SERVICE_DATE;
        }
%>

	<input type="hidden" name="sort_order" id="sort_order" value="<%=sortOrderStr%>"/>
        <input type="hidden" name="sort_column" id="sort_column" value=""/>

        <c:set var="imgTag" scope="request"><img src="<c:out value="${ctx}"/>/images/<%=sortImage%>" alt="Sort Arrow <%=sortDirection%>"/></c:set>
        <c:set var="sortColumn" scope="request"><%=sortColumn%></c:set>
        <c:set var="sortByDemoName" scope="request"><%=TicklerManager.DEMOGRAPHIC_NAME%></c:set>
        <c:set var="sortByCreator" scope="request"><%=TicklerManager.CREATOR%></c:set>
        <c:set var="sortByServiceDate" scope="request"><%=TicklerManager.SERVICE_DATE%></c:set>
        <c:set var="sortByCreationDate" scope="request"><%=TicklerManager.CREATION_DATE%></c:set>
        <c:set var="sortByPriority" scope="request"><%=TicklerManager.PRIORITY%></c:set>
        <c:set var="sortByTAT" scope="request"><%=TicklerManager.TASK_ASSIGNED_TO%></c:set>

<table class="table table-striped table-compact" id="ticklersTbl" style="width:100%">
    <thead>
        <TR>
            <th  style="width:1%">&nbsp;</th>
<%
            boolean ticklerEditEnabled = Boolean.parseBoolean(OscarProperties.getInstance().getProperty("tickler_edit_enabled"));
            if (ticklerEditEnabled) {
%>
            <th style="width:1%">&nbsp;</th>
<%
            }
%>
            <th style="width:12%">
                <a href="#" onClick="document.forms['ticklerform'].sort_order.value='<%=sortOrderStr%>';document.forms['ticklerform'].sort_column.value='<c:out value="${sortByDemoName}"/>'; document.forms['ticklerform'].submit();"><bean:message key="tickler.ticklerMain.msgDemographicName"/></a>
                <c:if test="${sortColumn == sortByDemoName}">
                    <c:out value="${imgTag}" escapeXml="false"/>
                </c:if>
            </th>
            <th style="width:10%">
                <a href="#" onClick="document.forms['ticklerform'].sort_order.value='<%=sortOrderStr%>';document.forms['ticklerform'].sort_column.value='<c:out value="${sortByCreator}"/>'; document.forms['ticklerform'].submit();"><bean:message key="tickler.ticklerMain.msgCreator"/></a>
                <c:if test="${sortColumn == sortByCreator}">
                    <c:out value="${imgTag}" escapeXml="false"/>
                </c:if>
            </th>
            <th style="width:7%">
                <a href="#" onClick="document.forms['ticklerform'].sort_order.value='<%=sortOrderStr%>';document.forms['ticklerform'].sort_column.value='<c:out value="${sortByServiceDate}"/>'; document.forms['ticklerform'].submit();"><bean:message key="tickler.ticklerMain.msgDate"/></a>
                 <c:if test="${sortColumn == sortByServiceDate}">
                    <c:out value="${imgTag}" escapeXml="false"/>
                </c:if>
            </th>
            <th style="width:7%">
                <a href="#" onClick="document.forms['ticklerform'].sort_order.value='<%=sortOrderStr%>';document.forms['ticklerform'].sort_column.value='<c:out value="${sortByCreationDate}"/>'; document.forms['ticklerform'].submit();"><bean:message key="tickler.ticklerMain.msgCreationDate"/></a>
                <c:if test="${sortColumn == sortByCreationDate}">
                    <c:out value="${imgTag}" escapeXml="false"/>
                </c:if>
            </th>

            <th style="width:4%">
                <a href="#" onClick="document.forms['ticklerform'].sort_order.value='<%=sortOrderStr%>';document.forms['ticklerform'].sort_column.value='<c:out value="${sortByPriority}"/>'; document.forms['ticklerform'].submit();"><bean:message key="tickler.ticklerMain.Priority"/></a>
                <c:if test="${sortColumn == sortByPriority}">
                    <c:out value="${imgTag}" escapeXml="false"/>
                </c:if>
            </th>

            <th style="width:10%">
                <a href="#" onClick="document.forms['ticklerform'].sort_order.value='<%=sortOrderStr%>';document.forms['ticklerform'].sort_column.value='<c:out value="${sortByTAT}"/>'; document.forms['ticklerform'].submit();"><bean:message key="tickler.ticklerMain.taskAssignedTo"/></a>
                <c:if test="${sortColumn == sortByTAT}">
                    <c:out value="${imgTag}" escapeXml="false"/>
                </c:if>
            </th>

            <th style="width:4%"><bean:message key="tickler.ticklerMain.msgStatus"/></th>
            <th style="width:40%"><bean:message key="tickler.ticklerMain.msgMessage"/></th>
            <th style="width:4%">&nbsp;</th>
        </TR>
    </thead>

                        <tbody>

                            <%
                            	String dateBegin = xml_vdate;
								  String dateEnd = xml_appointment_date;

								  String vGrantdate = "1980-01-07 00:00:00.0";
								  DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:ss:mm.SSS", locale);

								  if (dateEnd.compareTo("") == 0) dateEnd = MyDateFormat.getMysqlStandardDate(curYear, curMonth, curDay);
								  if (dateBegin.compareTo("") == 0) dateBegin="1950-01-01"; // any early start date should suffice for selecting since the beginning

								  CustomFilter filter = new CustomFilter();
								  filter.setPriority(null);

								  filter.setStatus(ticklerview);

								  filter.setStartDateWeb(dateBegin);
								  filter.setEndDateWeb(dateEnd);
								  filter.setPriority(null);

								  if( !mrpview.isEmpty() && !mrpview.equals("all")) {
								  	filter.setMrp(mrpview);
								  }

								  if (!providerview.isEmpty() && !providerview.equals("all")) {
								      filter.setProvider(providerview);
								  }

								  if (!assignedTo.isEmpty() && !assignedTo.equals("all")) {
								      filter.setAssignee(assignedTo);
								  }

                                                                  filter.setSort_order("desc");

								  List<Tickler> ticklers = ticklerManager.getTicklers(loggedInInfo, filter); //, 0, 100);

                                                                  if (sortColumn != null) {
                                                                       ticklers = ticklerManager.sortTicklerList(isSortAscending,sortColumn, ticklers);
                                                                  }
								  String rowColour = "lilac";
                                    DateFormat dateFormat2 = new SimpleDateFormat("yyyy-MM-dd");

								  for (Tickler t : ticklers) {

								      Demographic demo = t.getDemographic();

								      vGrantdate = t.getServiceDate() + " 00:00:00.0";
								      java.util.Date grantdate = dateFormat.parse(vGrantdate);
								      java.util.Date toDate = new java.util.Date();
								      long millisDifference = toDate.getTime() - grantdate.getTime();

								      long ONE_DAY_IN_MS = (1000 * 60 * 60 * 24);
								      long daysDifference = millisDifference / (ONE_DAY_IN_MS);

								      String numDaysUntilWarn = OscarProperties.getInstance().getProperty("tickler_warn_period");
								      long ticklerWarnDays = Long.parseLong(numDaysUntilWarn);
								      boolean ignoreWarning = (ticklerWarnDays < 0);
								      boolean warning = false;

								      //Set the colour of the table cell
								      String warnColour = "";
								      if (!ignoreWarning && (daysDifference >= ticklerWarnDays)){
								          warnColour = "Red";
                                          warning = true;
								      }

								      if (rowColour.equals("lilac")){
								          rowColour = "white";
								      }else {
								          rowColour = "lilac";
								      }

								      String cellColour = rowColour + warnColour;
                            %>

                                <tr <%=warning?"class='error'":""%>>
                                    <TD class="<%=cellColour%>"><input type="checkbox" name="checkbox" value="<%=t.getId()%>" class="noprint"></TD>
                                    <%
                                    	if (ticklerEditEnabled) {
                                    %>
                                    <td class="<%=cellColour%>"><a href=# title="<bean:message key="tickler.ticklerMain.editTickler"/>" onClick="window.open('../tickler/ticklerEdit.jsp?tickler_no=<%=t.getId()%>')"><i class="icon-pencil"></i></a></td>
                                    <%
                                    	}
                                    %>
                                    <TD class="<%=cellColour%>"><a href=# onClick="window.open('../demographic/demographiccontrol.jsp?demographic_no=<%=demo.getDemographicNo()%>&displaymode=edit&dboperation=search_detail')"><%=demo.getLastName()%>,<%=demo.getFirstName()%></a></TD>
                                    <TD class="<%=cellColour%>"><%=t.getProvider() == null ? "N/A" : t.getProvider().getFormattedName()%></TD>
                                    <TD class="<%=cellColour%>"><%=dateFormat2.format(t.getServiceDate())%></TD>
                                    <TD class="<%=cellColour%>"><%=dateFormat2.format(t.getUpdateDate())%></TD>
                                    <TD class="<%=cellColour%>"><%=t.getPriority()%></TD>
                                    <TD class="<%=cellColour%>"><%=t.getAssignee() != null ? t.getAssignee().getLastName() + ", " + t.getAssignee().getFirstName() : "N/A"%></TD>
                                    <TD class="<%=cellColour%>"><%=t.getStatusDesc(locale)%></TD>
                                    <TD class="<%=cellColour%>"><%=t.getMessage()%>

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
                                                <a href="javascript:reportWindow('../lab/CA/ON/CMLDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isHL7TEXT(type)){
                                                %>
                                                <a href="javascript:reportWindow('../lab/CA/ALL/labDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isDocument(type)){
                                                %>
                                                <a href="javascript:reportWindow('../dms/ManageDocument.do?method=display&doc_no=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}else if (LabResultData.isHRM(type)){
                                                %>
                                                <a href="javascript:reportWindow('../hospitalReportManager/Display.do?id=<%=tl.getTableId()%>')">ATT</a>
                                                <%
                                                	}else {
                                                %>
                                                <a href="javascript:reportWindow('../lab/CA/BC/labDisplay.jsp?segmentID=<%=tl.getTableId()%>&providerNo=<%=user_no%>&searchProviderNo=<%=user_no%>&status=')">ATT</a>
                                                <%
                                                	}
                                                %>
                                        <%
                                        	}
                                                                                }
                                        %>

                                    </TD>
                                    <td class="<%=cellColour%> noprint">
                                    	<a href="#" onClick="return openNoteDialog('<%=demo.getDemographicNo() %>','<%=t.getId() %>');return false;" title="note">
                                    		<i class="icon-comment"></i>
                                    	</a>
                                    </td>
                                </tr>
                                <%
                                	Set<TicklerComment> tcomments = t.getComments();
                                                                    if (ticklerEditEnabled && !tcomments.isEmpty()) {
                                                                        for(TicklerComment tc : tcomments) {
                                %>
                                    <tr>
                                        <td class="<%=cellColour%>"></td>
                                        <td class="<%=cellColour%>"></td>
                                        <td class="<%=cellColour%>"></td>
                                        <td class="<%=cellColour%>"><%=tc.getProvider().getLastName()%>,<%=tc.getProvider().getFirstName()%></td>
                                        <td class="<%=cellColour%>"></td>
                                        <% if (tc.isUpdateDateToday()) { %>
                                        <td class="<%=cellColour%>"><%=tc.getUpdateTime(locale)%></td>
                                        <% } else { %>
                                        <td class="<%=cellColour%>"><%=tc.getUpdateDate(locale)%></td>
                                        <% } %>
                                        <td class="<%=cellColour%>"></td>
                                        <td class="<%=cellColour%>"></td>
                                        <td class="<%=cellColour%>"></td>
                                        <td class="<%=cellColour%>"><%=tc.getMessage()%></td>
                                        <td class="<%=cellColour%>">&nbsp;</td>
                                    </tr>
                                <%      }
                                    }
                            }

                            Integer footerColSpan = 10;
                            if (ticklerEditEnabled) {
                                footerColSpan = 11;
                            }

                            if (ticklers.isEmpty()) {
                            %>
                            <tr><td colspan="<%=footerColSpan%>" class="white"><bean:message key="tickler.ticklerMain.msgNoMessages"/></td></tr>
                            <%}%>
                        </tbody>
    <tfoot>

                                <tr class="noprint"><td colspan="<%=footerColSpan%>" class="white"><a id="checkAllLink" name="checkAllLink" href="javascript:CheckAll();"><bean:message key="tickler.ticklerMain.btnCheckAll"/></a> - <a href="javascript:ClearAll();"><bean:message key="tickler.ticklerMain.btnClearAll"/></a> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                                    <input type="button" class="btn" name="button" value="<bean:message key="tickler.ticklerMain.btnAddTickler"/>" onClick="window.open('ticklerAdd.jsp')" >
                                    <input type="hidden" name="submit_form" value="">
                                    <%
                                    	if (ticklerview.compareTo("D") == 0){
                                    %>
                                    <input type="button" class="btn" value="<bean:message key="tickler.ticklerMain.btnEraseCompletely"/>"  onclick="document.forms['ticklerform'].submit_form.value='Erase Completely'; document.forms['ticklerform'].submit();">
                                    <%
                                    	} else{
                                    %>
                                    <input type="button" class="btn" value="<bean:message key="tickler.ticklerMain.btnComplete"/>"  onclick="document.forms['ticklerform'].submit_form.value='Complete'; document.forms['ticklerform'].submit();">
                                    <input type="button" class="btn btn-danger" value="<bean:message key="tickler.ticklerMain.btnDelete"/>" onclick="document.forms['ticklerform'].submit_form.value='Delete'; document.forms['ticklerform'].submit();">
                                    <%
                                    	}
                                    %>
                            <input type="button" name="button" class="btn" value="<bean:message key="global.btnCancel"/>" onClick="window.close()" > </td></tr>
                        </tfoot>

</table></form>




<p class="yesprint">
	<%=OscarProperties.getConfidentialityStatement()%>
</p>




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


</body>
</html:html>