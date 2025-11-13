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

<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Tickler" %>
<%@ page import="org.oscarehr.common.model.TicklerLink" %>
<%@ page import="org.oscarehr.common.dao.TicklerLinkDao" %>
<%@ page import="oscar.util.UtilDateUtilities" %>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.managers.TicklerManager" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="org.oscarehr.casemgmt.util.WriteToEncounterUtil" %>

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
	TicklerManager ticklerManager = SpringUtils.getBean(TicklerManager.class);
   	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
%>

<%
	String module="", module_id="", doctype="", docdesc="", docxml="", doccreator="", docdate="", docfilename="", docpriority="", docassigned="";
module_id = request.getParameter("demographic_no");
doccreator = request.getParameter("user_no");
docdate = request.getParameter("xml_appointment_date");
docfilename =request.getParameter("textarea");
docpriority =request.getParameter("priority");
docassigned =request.getParameter("task_assigned_to");
String programAssignedTo = request.getParameter("program_assigned_to");

String docType =request.getParameter("docType");
String docId = request.getParameter("docId");
String writeToEncounter = request.getParameter("writeToEncounter");
GregorianCalendar now=new GregorianCalendar();
int curYear = now.get(Calendar.YEAR);
int curMonth = (now.get(Calendar.MONTH)+1);
String monthStr = now.getDisplayName(Calendar.MONTH, Calendar.SHORT, Locale.CANADA);
int curDay = now.get(Calendar.DAY_OF_MONTH);
String dateString = curDay+"-"+monthStr+"-"+curYear;

Tickler tickler = new Tickler();
    tickler.setDemographicNo(Integer.parseInt(module_id));
    tickler.setUpdateDate(new java.util.Date());
    if(docpriority != null && docpriority.equalsIgnoreCase("High")) {
   	 tickler.setPriority(Tickler.PRIORITY.High);
    }
    if(docpriority != null && docpriority.equalsIgnoreCase("Low")) {
      	 tickler.setPriority(Tickler.PRIORITY.Low);
    }
    tickler.setTaskAssignedTo(docassigned);
    if (programAssignedTo != null) {
        tickler.setProgramId(Integer.valueOf(programAssignedTo));
    }
    tickler.setCreator(doccreator);
    tickler.setMessage(docfilename);
    Date serviceDate = UtilDateUtilities.StringToDate(docdate);
    if (serviceDate == null) {
        serviceDate = new Date();
    }
    tickler.setServiceDate(serviceDate);


   ticklerManager.addTickler(loggedInInfo,tickler);

   int ticklerNo = tickler.getId();
   if (docType != null && docId != null && !docType.trim().equals("") && !docId.trim().equals("") && !docId.equalsIgnoreCase("null") ){
      if (ticklerNo > 0){
          try{
             TicklerLink tLink = new TicklerLink();
             tLink.setTableId(Long.parseLong(docId));
             tLink.setTableName(docType);
             tLink.setTicklerNo(new Long(ticklerNo).intValue());
             TicklerLinkDao ticklerLinkDao = (TicklerLinkDao) SpringUtils.getBean("ticklerLinkDao");
             ticklerLinkDao.save(tLink);
             }catch(Exception e){
            	 MiscUtils.getLogger().error("No link with this tickler", e);
             }
      }
   }

    if (writeToEncounter!=null && writeToEncounter.equals("true") && ticklerNo > 0){
		WriteToEncounterUtil.addToCurrentNote(loggedInInfo, session, module_id, docfilename, "tickler");
%>
<script>
    var windowFeatures = "height=700,width=960";
    // Open encounter window
    window.open('../oscarEncounter/IncomingEncounter.do?demographicNo=<%=module_id%>&providerNo=<%=loggedInInfo.getLoggedInProviderNo()%>&curDate=<%=curYear%>-<%=curMonth%>-<%=curDay%>&encType=&status=', 'encounter', windowFeatures)
</script>
<%
    }

   boolean rowsAffected = true;

String parentAjaxId = request.getParameter("parentAjaxId");
String updateParent = request.getParameter("updateParent");
if (rowsAffected ){
%>
<script LANGUAGE="JavaScript">

      var parentId = "<%=parentAjaxId%>";
      var updateParent = <%=updateParent%>;
      var demo = "<%=module_id%>";
      var Url = window.opener.URLs;

      /*because the url for demomaintickler is truncated by the delete action, we need
        to reconstruct it if necessary
      */
      if( parentId != "" && updateParent == true && !window.opener.closed ) {
          var ref = window.opener.location.href;
          let useAmp = ref.includes('?');
          if(!ref.includes('demoview')) {
              ref += (useAmp?'&':'?') + 'demoview=' + demo + '&parentAjaxId=' + parentId + '&updateParent=true';
              useAmp = true;
          }
          if (!ref.includes('updateParent')) {
              ref += (useAmp?'&':'?') + 'updateParent=true';
              useAmp = true;
          }
          window.opener.location = ref;
      }
      else if( parentId != "" && !window.opener.closed ) {
        if (window.opener.document.forms['encForm']) { window.opener.document.forms['encForm'].elements['reloadDiv'].value=parentId; }
        window.opener.updateNeeded = true;
      }
      else if( updateParent == true && !window.opener.closed )
        window.opener.location.reload();

      self.close();
</script>
<%}%>
