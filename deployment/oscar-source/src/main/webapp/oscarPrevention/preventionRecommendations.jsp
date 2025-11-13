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


<%@page import="oscar.oscarPrevention.*"%>
<%@page import="org.oscarehr.managers.SecurityInfoManager"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.managers.PreventionManager"%>

<%@page import="java.util.ArrayList"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_prevention"
	rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_prevention");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>
<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
	String demographic_no = request.getParameter("demographic_no");
	Prevention p = PreventionData.getPrevention(loggedInInfo, Integer.valueOf(demographic_no));
	PreventionDS pf = SpringUtils.getBean(PreventionDS.class);
  
	boolean dsProblems = false;
	try{
     pf.getMessages(p);
	}catch(Exception dsException){
	  MiscUtils.getLogger().error("Error running prevention rules",dsException);
      dsProblems = true;
	}

	ArrayList warnings = p.getWarnings();
	ArrayList recomendations = p.getReminder();
	
	if (warnings.size() > 0 || recomendations.size() > 0  || dsProblems) { 
%>

						<ul>
							<% for (int i = 0 ;i < warnings.size(); i++){
                       String warn = (String) warnings.get(i);%>
							<li style="color: red;"><%=warn%></li>
							<%}%>
							<% for (int i = 0 ;i < recomendations.size(); i++){
                       String warn = (String) recomendations.get(i);%>
							<li style="color: black;"><%=warn%></li>
							<%}%>
							<!--li style="color: red;">6 month TD overdue</li>
							<li>12 month MMR due in 2 months</li-->
							<% if (dsProblems){ %>
							<li style="color: red;">Decision Support Had Errors Running.</li>
							<% } %>
						</ul>
					 
<% } %>