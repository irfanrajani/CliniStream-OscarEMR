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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@page import="org.oscarehr.common.model.UserProperty"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.dao.UserPropertyDAO"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
	if(!authed) return;

	String url = "";
	String action = request.getParameter("action");
	String message = null;
	
	UserPropertyDAO upDao = SpringUtils.getBean(UserPropertyDAO.class);
	UserProperty up =  upDao.getProp("cvc.url");
	
	if(up != null) {
		url = up.getValue();
	}
	
	if(!StringUtils.isEmpty(action) && "submit".equals(action)) {
		url = request.getParameter("url");
		if(up == null) {
			up = new UserProperty();
			up.setName("cvc.url");
		}
		up.setValue(url);
		upDao.merge(up);
		message = "URL Updated!";
	} 

	String lastUpdated = "";
	UserProperty up2 = upDao.getProp("cvc.updated");
	if(up2 != null) {
		lastUpdated = up2.getValue();
	}
%>

<%@ page import="java.util.*"%>

<html:html locale="true">
<head>
	<title>Canadian Vaccine Catalogue</title>
	<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
	<script>
		function update() {
			$("#update_div").html("<img src='<%=request.getContextPath()%>/images/loader.gif'/> Updating...");
			$.ajax({
	             type: "POST",
	             url: "<%=request.getContextPath()%>/cvc.do",
	             data: { method : "updateCVC"},
	            // dataType: 'json',
	             success: function(data,textStatus) {
	            	 $("#update_div").html("<font style='color:blue'>Updated</font>");
	             },
	             error: function(data,textStatus) {
	            	 console.log("cvc error",data,textStatus);
	            	 $("#update_div").html("<font style='color:red'>An Error has occurred</font>");
	             }
			});
		}
	</script>
</head>

<body vlink="#0000FF" class="BodyStyle">
<%
	if(!StringUtils.isEmpty(message)) {
%>
<div class="alert alert-success" role="alert">
  <%=message %>
</div>
<% } %>
<h4>Canadian Vaccine Catalogue</h4>
<h3><b>Last Updated:</b><%=lastUpdated %> </h3>
	<form method="post" action="cvc.jsp">
	<input type="hidden" name="action" value="submit"/>
	<fieldset>
		<div class="control-group">
			<label class="control-label">CVC URL</label>
			<div class="controls">
				<input name="url" type="text" value="<%=url%>"/><br/>
			</div>
		</div>
		<div class="control-group">
			<input type="submit" class="btn btn-primary" value="Save"/>
		</div>
	</fieldset>
	</form>
	
	<br/>
	<button onClick="update()">Update Now</button>
	<div id="update_div">
	
	</div>
</html:html>
