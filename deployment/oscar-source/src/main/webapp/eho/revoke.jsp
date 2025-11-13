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


<%
 String tokenUrl = "https://login.pst.oneidfederation.ehealthontario.ca/oidc/access_token";
 String audURL = "https://login.pst.oneidfederation.ehealthontario.ca/sso/oauth2/realms/root/realms/idaaspstoidc/access_token";

//https://login.dev.oneidfederation.ehealthontario.ca:1443/oidc/token/revoke -k
	String revokeUrl = "https://login.pst.oneidfederation.ehealthontario.ca/oidc/token/revoke";
                
	JSONObject tokens = (JSONObject) session.getAttribute("tokens");

	String refreshToken = tokens.getString("refresh_token");

	
	String accessToken = tokens.getString("access_token");

Calendar cal = Calendar.getInstance();
                cal.add(Calendar.MINUTE,10);
                Date expiryDate = cal.getTime();


        Map<String, String> params = new HashMap<>();
        params.put("client_id", "OSCAR_EMR_PST_NODE1");
        params.put("client_assertion_type", "urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer");
	params.put("token",accessToken);

             FileInputStream is  = new FileInputStream("/var/lib/tomcat8/certs/oauth_pst.jks");

            KeyStore keystore = KeyStore.getInstance(KeyStore.getDefaultType());
            keystore.load(is, "changeme".toCharArray());

            String alias = "oscar pst";

            Key key = keystore.getKey(alias, "changeme".toCharArray());

           
            if (key instanceof PrivateKey) {
                Certificate cert = keystore.getCertificate(alias);
                
                JWTCreator.Builder builder = JWT.create().withSubject("OSCAR_EMR_PST_NODE1").withAudience(audURL).withExpiresAt(expiryDate).withIssuer("OSCAR_EMR_PST_NODE1");
                        String jwt = builder.sign(Algorithm.RSA256((RSAPublicKey)cert.getPublicKey(), (RSAPrivateKey) key));

                
                params.put("client_assertion", jwt);
            }


                WebClient wc = WebClient.create(revokeUrl);
                 for (Entry<String, String> entry : params.entrySet()) {
                        wc.query(entry.getKey(), entry.getValue());
                    }

        //      WebClient.getConfig(wc).getHttpConduit().setTlsClientParameters(tlsParams);

                Response response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").post(null);

		String body = response2.readEntity(String.class);

            
%>
