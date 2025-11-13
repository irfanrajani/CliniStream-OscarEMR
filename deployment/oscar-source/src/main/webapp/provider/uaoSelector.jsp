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
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo,org.oscarehr.util.LoggedInUserFilter" %>
<%@page import="org.oscarehr.common.dao.UAODao"%>
<%@page import="org.oscarehr.common.dao.SecurityDao"%>
<%@page import="org.oscarehr.common.model.UAO"%>
<%@page import="org.oscarehr.common.model.Security"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.oscarehr.integration.OneIdGatewayData"%>
<%@page import="java.util.List,org.oscarehr.util.SessionConstants,org.oscarehr.integration.ohcms.CMSManager"%><%
UAODao uaoDao = SpringUtils.getBean(UAODao.class);
LoggedInInfo loggedInInfo =LoggedInInfo.getLoggedInInfoFromSession(request);

int port = request.getServerPort();
StringBuilder appointmentScreenLink = new StringBuilder();
appointmentScreenLink.append(request.getScheme()).append("://").append(request.getServerName());
if((request.getScheme().equals("http") && port != 80) || (request.getScheme().equals("https") && port != 443)){
	appointmentScreenLink.append(':').append(port);
}

appointmentScreenLink.append(request.getContextPath()+"/provider/providercontrol.jsp");

if(request.getParameter("id") != null){
	String id = 	request.getParameter("id");
	UAO uao = uaoDao.find(Integer.parseInt(id));
	if(uao.getProviderNo().equals(loggedInInfo.getLoggedInProviderNo())){ //double check that this uao is available for this provider
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		if(oneIdGatewayData != null){	
			oneIdGatewayData.setUao(uao.getName());
			oneIdGatewayData.setUaoFriendlyName(uao.getFriendlyName());
			oneIdGatewayData.setUpdateUAOInCMS(true);
			uaoDao.setAsDefault(uao,loggedInInfo.getLoggedInProviderNo());
			
		}else{
			MiscUtils.getLogger().error("OneIdGatewayData was null!");
			oneIdGatewayData = new OneIdGatewayData();
    			session.setAttribute(SessionConstants.OH_GATEWAY_DATA,oneIdGatewayData);
    			loggedInInfo = LoggedInUserFilter.generateLoggedInInfoFromSession(request);
    			oneIdGatewayData.setUao(uao.getName());
    			oneIdGatewayData.setUaoFriendlyName(uao.getFriendlyName());
		}
		response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(request.getContextPath()+"/provider/providercontrol.jsp","UTF-8")  );
		return;
	}
}else if(request.getParameter("disassociate") != null && "true".equalsIgnoreCase(request.getParameter("disassociate"))){
	SecurityDao securityDao = (SecurityDao) SpringUtils.getBean(SecurityDao.class);
	Security securityRecord = securityDao.getByProviderNo(loggedInInfo.getLoggedInProviderNo());
	
	if (securityRecord != null) {
		securityRecord.setOneIdKey(null);
		securityRecord.setOneIdEmail(null);
		securityDao.updateOneIdKey(securityRecord);
		response.sendRedirect(request.getContextPath() + "/logoutSSO.jsp" );
		return;
	}
}else if(request.getParameter("oneidlogout") != null && "true".equalsIgnoreCase(request.getParameter("oneidlogout"))){
	try{
		CMSManager.userLogout(loggedInInfo);
	}catch(Exception e){
		org.oscarehr.util.MiscUtils.getLogger().error("Error logging out of CMS",e);
	}
	loggedInInfo.getOneIdGatewayData().clearGatewayData();
	MiscUtils.getLogger().error("Sending return url to "+appointmentScreenLink.toString());
	response.sendRedirect(oscar.OscarProperties.getInstance().getProperty("oneid.oauth2.logoutUrl") +  "/?returnurl=" + URLEncoder.encode(appointmentScreenLink.toString(),"UTF-8"));
	return;
}






List<UAO> uaolist = uaoDao.findByProvider(loggedInInfo.getLoggedInProviderNo());

String currentUAOName = "N/A";
if(loggedInInfo.getOneIdGatewayData() != null){
	currentUAOName = loggedInInfo.getOneIdGatewayData().getUaoFriendlyName();
}


%>
<html>
	<head>		
		<link href="../library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
		<style>
			
		</style>
		<script>
			function disassociate(){
				return confirm('Are you sure you want to Disassociate this ONE ID account with this OSCAR Account?');
			}
		</script>
	</head>
	<body>
	
		<div class="container">
		<div class="row">
			<div class="jumbotron" style="margin-top:100px" >
				<h2>Current UAO: <%=currentUAOName%></h2>
				<p class="lead">Change to:</p> 
				<% for(UAO uao : uaolist){ %>
					<a class="btn btn-primary btn-lg btn-block"  href="uaoSelector.jsp?id=<%=uao.getId()%>"><%=uao.getFriendlyName() %></a>
				<% }%>
				
				<hr><hr><hr>
				<a class="btn btn-danger btn-lg btn-block" onclick="return disassociate();" href="uaoSelector.jsp?disassociate=true">Disassociate One ID login with this OSCAR account</a>
				<a class="btn btn-danger btn-lg btn-block" href="uaoSelector.jsp?oneidlogout=true">Logout of ONE ID</a>
			</div>
		</div>
		</div>
	</body>
</html>