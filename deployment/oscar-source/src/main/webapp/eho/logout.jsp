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
<%@page import="net.sf.json.JSONObject"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="javax.ws.rs.core.Response"%>
<%@page import="org.apache.cxf.jaxrs.client.WebClient"%>

<%@page import="java.security.interfaces.RSAPrivateKey"%>
<%@page import="java.security.interfaces.RSAPublicKey"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Date"%>
<%@page import="com.auth0.jwt.JWT"%>
<%@page import="java.security.cert.Certificate"%>
<%@page import="java.security.PrivateKey"%>
<%@page import="java.security.Key"%>
<%@page import="java.security.KeyStore"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.auth0.jwt.algorithms.Algorithm"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.auth0.jwt.JWTCreator"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.oscarehr.util.LoggedInInfo" %>
<%@page import="org.oscarehr.integration.ohcms.CMSManager" %>


<%
	LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
    	CMSManager.userLogout(loggedInInfo);
	String logoutUrl = "https://login.pst.oneidfederation.ehealthontario.ca/oidc/logout/";

	WebClient wc = WebClient.create(logoutUrl);
	Response response2 = wc.get();

	String body = response2.readEntity(String.class);

	if (response2.getStatus() == 302) {
		response.sendRedirect(response2.getHeaderString("Location"));
	}
%>
