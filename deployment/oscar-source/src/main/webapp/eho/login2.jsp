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
<%@page import="oscar.OscarProperties"%>
<%@page import="org.oscarehr.util.PKCEUtils"%>
<%@page import="org.apache.logging.log4j.Logger" %>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="org.apache.cxf.jaxrs.ext.form.Form"%>
<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.nio.charset.Charset"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.util.Random"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="javax.ws.rs.core.Response"%>
<%@page import="org.apache.cxf.configuration.jsse.TLSClientParameters"%>
<%@page import="org.apache.cxf.jaxrs.client.Client"%>
<%@page import="org.apache.cxf.jaxrs.client.WebClient"%>
<%@page import="org.apache.http.conn.ssl.SSLConnectionSocketFactory"%>
<%@page import="org.apache.http.conn.ssl.SSLContexts"%>
<%@page import="javax.net.ssl.SSLContext"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.security.KeyStore"%>
<%@page import="java.net.URI"%>
<%@page import="org.apache.cxf.rs.security.oauth2.client.OAuthClientUtils"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="org.oscarehr.integration.OneIDTokenUtils" %>
<%@page import="org.oscarehr.integration.OneIdGatewayData"%>
<%@page import="org.oscarehr.util.SessionConstants"%>
<%@page import="org.oscarehr.integration.dhdr.OmdGateway"%>
<%@page import="org.oscarehr.util.LoggedInInfo,org.oscarehr.util.LoggedInUserFilter" %>
<%@page import="org.oscarehr.common.dao.UAODao"%>
<%@page import="org.oscarehr.common.model.UAO"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="java.util.List"%>

<%
	Logger logger = MiscUtils.getLogger();
	logger.info("OAUTH2 Login started");
    	LoggedInInfo loggedInInfo =LoggedInInfo.getLoggedInInfoFromSession(request);

    	OneIdGatewayData oneIdGatewayData = (OneIdGatewayData) session.getAttribute(SessionConstants.OH_GATEWAY_DATA);
    	if(oneIdGatewayData == null){
    		oneIdGatewayData = new OneIdGatewayData();
    		session.setAttribute(SessionConstants.OH_GATEWAY_DATA,oneIdGatewayData);
    		loggedInInfo = LoggedInUserFilter.generateLoggedInInfoFromSession(request);// this will set the oneIdGatewayData to be in the loggedInInfo
    	}
    	//If everyone in a clinic is using one UAO it would seem easy to set they UAO for all requests to elminate the extra trip to the IDP to set the UAO BUT 
    	//The EMR needs to validate that this is known valid user to the EMR before it lets the EMR user operate under it's authority.
    //IE. If it was set for every request, and patient with a ONE ID credential had access to the front page of OSCAR they could 
    //login to ONE ID and create a valid session token with ONE ID with the UAO of the clinic. They wouldn't gain access to OSCAR but they might be able to do something with the OMD gateway
    
    	
    	OmdGateway omdGateway = new OmdGateway();
    	String state = RandomStringUtils.randomAlphanumeric(20);
    	
    	String verifier = omdGateway.generateVerifier();
    	logger.error("oneIdGatewayData in login2.jsp "+oneIdGatewayData.getUniqueSessionId());
    	
    
		
	if(request.getParameter("alreadyLoggedIn") != null && "true".equals(request.getParameter("alreadyLoggedIn"))) {
		
		if(oneIdGatewayData.getUao() == null){
			logger.info("UAO was null");
			UAODao uaoDao = SpringUtils.getBean(UAODao.class);
			List<UAO> uaolist = uaoDao.findByProvider(loggedInInfo.getLoggedInProviderNo());
			if(uaolist.size() > 0) {
				logger.info("UAO was has more than none");
				oneIdGatewayData.setUao(uaolist.get(0).getName());
				oneIdGatewayData.setUaoFriendlyName(uaolist.get(0).getFriendlyName());
				
			}
		}
		logger.info("UAO was :"+oneIdGatewayData.getUao());
		session.setAttribute("eho_verifier-" + state + ".alreadyLoggedIn",true);
		session.setAttribute("eho_verifier-" + state + ".forwardURL",request.getParameter("forwardURL"));
			logger.info("alreadyLoggedIn Set! + "+request.getParameter("forwardURL"));
	}
    	
	Response response2 =	omdGateway.callAuthorize(loggedInInfo,oneIdGatewayData,state,verifier);
	
	session.setAttribute("eho_verifier-" + state,verifier);
	if(response2 == null){
		%>Unexpected Error, more info available in the logs <%
	}else if(response2.getStatus() == 302) {
		logger.info("Redirecting to " + response2.getHeaderString("Location") );
		response.sendRedirect( response2.getHeaderString("Location"));
	} else {
		//unexpected
		logger.info("Received unexpected " + response2.getStatus());
		response.sendRedirect(request.getContextPath() + "/index.jsp?errorMessage=" + URLEncoder.encode("Received unexpected error from eHealth", "UTF-8" ));
	}
	
	
%>
