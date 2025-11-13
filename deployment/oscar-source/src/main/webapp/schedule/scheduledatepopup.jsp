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
<%!  boolean bMultisites=org.oscarehr.common.IsPropertiesOn.isMultisitesEnable(); %>
<%!  String [] bgColors; %>

<%@ page import="java.util.*, java.sql.*, oscar.*, java.text.*, java.lang.*" errorPage="../appointment/errorpage.jsp"%>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.dao.ScheduleTemplateDao" %>
<%@page import="org.oscarehr.common.model.ScheduleTemplate" %>
<%@page import="org.oscarehr.common.dao.SiteDao"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="org.oscarehr.common.model.Site"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%
	ScheduleTemplateDao scheduleTemplateDao = SpringUtils.getBean(ScheduleTemplateDao.class);
%>

<jsp:useBean id="scheduleDateBean" class="java.util.Hashtable" scope="session" />
<%
  String year = request.getParameter("year");
  String month = MyDateFormat.getDigitalXX(Integer.parseInt(request.getParameter("month")));
  String day = MyDateFormat.getDigitalXX(Integer.parseInt(request.getParameter("day")));

  String available = "checked", strHour = "", strReason = "value=''", strCreator="Me";
  HScheduleDate aHScheduleDate= (HScheduleDate) scheduleDateBean.get(year+"-"+month+"-"+day);
  if (aHScheduleDate!=null) {
    available = aHScheduleDate.available.compareTo("1")==0?"checked":""  ;
    strHour = aHScheduleDate.hour;
    strReason = aHScheduleDate.reason ;
    strCreator= aHScheduleDate.creator;
  }

%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message key="schedule.scheduledatepopup.title" /></title>
<link href="${pageContext.request.contextPath}/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->

<script language="JavaScript">
<!--
function setfocus() {
  this.focus();
  document.schedule.hour.focus();
  //document.schedule.hour.select();
}
function upCaseCtrl(ctrl) {
	ctrl.value = ctrl.value.toUpperCase();
}
//-->
</script>
</head>
<body onLoad="setfocus()">

<h4>&nbsp;<bean:message key="schedule.scheduledatepopup.title" /></h4>
<div class="well">
    <div style="background-color:#CCFFCC; text-align:center">
        <bean:message key="schedule.scheduledatepopup.formDate" />: <%=year%>-<%=month%>-<%=day%>
    </div>
    <form method="post" name="schedule" action="scheduledatesave.jsp" class="form-horizontal">
        <input type="hidden" name="date" value="<%=year%>-<%=month%>-<%=day%>">
        <div class="control-group">
            <label class="control-label" for="available"><bean:message
					key="schedule.scheduledatepopup.formAvailable" />:</label>
        <div class="controls">
            <input type="radio" name="available" value="1"
					<%=available.equals("checked")?"checked":""%>> <bean:message
					key="schedule.scheduledatepopup.formAvailableYes" /> <input
					type="radio" name="available" value="0"
					<%=available.equals("checked")?"":"checked"%>> <bean:message
					key="schedule.scheduledatepopup.formAvailableNo" />
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for="hour"><bean:message
					key="schedule.scheduledatepopup.formTemplate" />:</label>
        <div class="controls">
             <select name="hour" id="hour">
					<%

					for(ScheduleTemplate st: scheduleTemplateDao.findByProviderNo("Public")) {

	%>
					<option value="<%=st.getId().getName()%>"
						<%=strHour.equals(st.getId().getName())?"selected":""%>><%=st.getId().getName()+" |"+st.getSummary()%></option>
					<% }
					for(ScheduleTemplate st: scheduleTemplateDao.findByProviderNo( request.getParameter("provider_no"))) {

	%>
					<option value="<%=st.getId().getName()%>"
						<%=st.getId().getName().equals(strHour)?"selected":""%>><%=st.getId().getName()+" |"+st.getSummary()%></option>
					<% }	%>
				</select>
        </div>
      </div>
			<%
          OscarProperties props = OscarProperties.getInstance();
          boolean bMoreAddr = bMultisites
						? true
						: props.getProperty("scheduleSiteID", "").equals("") ? false : true;
          String [] siteList;
          if (bMultisites) {
        		//multisite starts =====================
        		  SiteDao siteDao = (SiteDao)WebApplicationContextUtils.getWebApplicationContext(application).getBean("siteDao");
        	      List<Site> sites = siteDao.getActiveSitesByProviderNo(request.getParameter("provider_no"));
        	      siteList = new String[sites.size()+1];
        		  bgColors = new String[sites.size()+1];
        	      for (int i=0; i<sites.size(); i++) {
        	    	  siteList[i]=sites.get(i).getName();
        			  bgColors[i]=sites.get(i).getBgColor();
        	      }
        	      siteList[sites.size()]="NONE";
        		  bgColors[sites.size()]="white";
        		//multisite ends =====================
          } else {
          	siteList = props.getProperty("scheduleSiteID", "").split("\\|");
          }

          if (bMoreAddr) {
          %>
      <div class="control-group">
        <label class="control-label" for="reason"><bean:message key="Appointment.formLocation" />:</label>
        <div class="controls">
             <select id="reason" name="reason" onchange='this.style.backgroundColor=this.options[this.selectedIndex].style.backgroundColor'>
					<% for(int i=0; i<siteList.length; i++) { %>
					<option value="<%=siteList[i]%>" <%=(bMultisites? " style='background-color:"+bgColors[i]+"'" : "")%>
						<%=strReason.equals(siteList[i])?"selected":""%>><b><%=siteList[i]%></b></option>
					<% } %>
				</select>
		<% } %>
        </div>
      </div>
      <div class="control-group">
        <label class="control-label" for=""><bean:message
					key="schedule.scheduledatepopup.formCreator" />:</label>
          <div class="controls">
            <%=strCreator%>
        </div>
      </div>
        <div style="text-align:right">
                <input type="hidden" name="Submit" value="">
				<input type="hidden" name="provider_no"
					value="<%=request.getParameter("provider_no")%>"> <input
					type="button" class="btn"
					value='<bean:message key="schedule.scheduledatepopup.btnSave"/>'
					onclick="document.forms['schedule'].Submit.value=' Save '; document.forms['schedule'].submit();">
                <input type="button" class="btn"
					value='<bean:message key="schedule.scheduledatepopup.btnDelete"/>'
					onclick="document.forms['schedule'].Submit.value=' Delete '; document.forms['schedule'].submit();">
				<input type="button" name="Button" class="btn btn-link"
					value='<bean:message key="schedule.scheduledatepopup.btnCancel"/>'
					onClick="window.close()">
        </div>
    </form>
<% 		if (bMultisites)
			out.println("<script>var _r=document.getElementById('reason'); _r.style.backgroundColor=_r.options[_r.selectedIndex].style.backgroundColor;</script>");
%>
</div>

</form>
</body>
</html:html>