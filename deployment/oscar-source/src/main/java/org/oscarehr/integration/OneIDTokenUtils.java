/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.integration;

import java.io.FileInputStream;
import java.security.Key;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.time.Instant;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.Response;

import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.logging.log4j.Logger;
import org.oscarehr.integration.dhdr.OmdGateway;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTCreator;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.Claim;
import com.auth0.jwt.interfaces.DecodedJWT;

import net.sf.json.JSONObject;
import oscar.OscarProperties;

public class OneIDTokenUtils {

	static Logger logger = MiscUtils.getLogger();
	
	
	public static String urlEncode(String toEncode) {
	    if (toEncode == null) {
	        return "";
	    }
	    String encoded = toEncode.replace("%", "%25");
	    encoded = encoded.replace(" ", "%20");
	    encoded = encoded.replace("!", "%21");
	    encoded = encoded.replace("#", "%23");
	    encoded = encoded.replace("$", "%24");
	    encoded = encoded.replace("&", "%26");
	    encoded = encoded.replace("'", "%27");
	    encoded = encoded.replace("(", "%28");
	    encoded = encoded.replace(")", "%29");
	    encoded = encoded.replace("*", "%2A");
	    encoded = encoded.replace("+", "%2B");
	    encoded = encoded.replace(",", "%2C");
	    encoded = encoded.replace("/", "%2F");
	    encoded = encoded.replace(":", "%3A");
	    encoded = encoded.replace(";", "%3B");
	    encoded = encoded.replace("=", "%3D");
	    encoded = encoded.replace("?", "%3F");
	    encoded = encoded.replace("@", "%40");
	    encoded = encoded.replace("[", "%5B");
	    encoded = encoded.replace("]", "%5D");
	    return encoded;
	}
	
	public static String debugTokens(HttpSession session) {
		String tokenAttr = (String) session.getAttribute("oneid_token");

		if (tokenAttr == null) {
			logger.warn("tokenAttr is null");
			return "ERROR no token";
		}
		StringBuilder sb = new StringBuilder("===============================\nDEBUG ONEID TOKEN\n=======================\n");
		try {
			JSONObject tokens = JSONObject.fromObject(tokenAttr);
			sb.append("\n"+tokens.toString(3)); 
			
			String accessToken = tokens.getString("access_token");
	
			if (accessToken == null) {
				logger.warn("accessToken is null");
				return "ERROR no access token";
			}
			sb.append("\n\nACCESS TOKEN\n");
			DecodedJWT decodedJWT = JWT.decode(accessToken);
			for (Entry<String,Claim> entry : decodedJWT.getClaims().entrySet()) {
				sb.append("\t entry:"+entry.getKey()+"  "+entry.getValue().asString()+"\n");
			}
			
			decodedJWT = JWT.decode(tokens.getString("refresh_token"));
			sb.append("\n\nRefresh TOKEN\n");
			for (Entry<String,Claim> entry : decodedJWT.getClaims().entrySet()) {
				sb.append("\t entry:"+entry.getKey()+"  "+entry.getValue().asString()+"\n");
				
			}
			
			
			decodedJWT = JWT.decode(tokens.getString("id_token"));
			sb.append("\n\nID TOKEN\n");
			for (Entry<String,Claim> entry : decodedJWT.getClaims().entrySet()) {
				sb.append("\t entry:"+entry.getKey()+"  "+entry.getValue().asString()+"\n");
			}
		}catch(Exception e) {
			sb.append("Error parsing Token "+tokenAttr);
		}
		sb.append("\n=================================\n");
		
		return sb.toString();
	}

	public static String getValidAccessToken(HttpSession session) throws TokenExpiredException {
		String tokenAttr = (String) session.getAttribute("oneid_token");

		if (tokenAttr == null) {
			logger.warn("tokenAttr is null");
			return null;
		}
		
		logger.debug(tokenAttr);
		
		JSONObject tokens = JSONObject.fromObject(tokenAttr);

		if (tokens == null) {
			logger.warn("tokens is null");
			return null;
		}

		String accessToken = tokens.getString("access_token");

		if (accessToken == null) {
			logger.warn("accessToken is null");
			return null;
		}

		DecodedJWT decodedJWT = JWT.decode(accessToken);

		if (decodedJWT == null) {
			logger.warn("decodedJWT is null");
			return null;
		}

		long iat = decodedJWT.getClaim("iat").asLong();
		int expiresIn = decodedJWT.getClaim("expires_in").asInt();

		logger.debug("iat=" + iat);
		logger.debug("expires_in=" + expiresIn);
		Date date = Date.from(Instant.ofEpochSecond(iat));
		logger.debug("date="+date);
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.SECOND, expiresIn);

		Date expires = cal.getTime();

		Calendar cal2 = Calendar.getInstance();
		cal2.add(Calendar.SECOND, 15);

		Date inTheFuture = cal2.getTime();

		logger.debug("IAT=" + date);
		logger.debug("expires=" + expires);
		logger.debug("inTheFuture=" + inTheFuture);
	
		if (expires.after(inTheFuture)) {
			logger.info("access token is not expired");
			return accessToken;
		} else {
			logger.info("access token expired; using referesh token");
			return refreshToken(session);
		}
		
	}
	
	
	public static void verifyAccessTokenIsValid(LoggedInInfo loggedInInfo,OneIdGatewayData oneIdGatewayData) throws TokenExpiredException {
		if(oneIdGatewayData.isAccessTokenExpired()) {
			refreshToken(loggedInInfo,oneIdGatewayData);
		}
		
	}


	private static void refreshToken(LoggedInInfo loggedInInfo,OneIdGatewayData oneIdGatewayData) throws TokenExpiredException{
				
		if(oneIdGatewayData.isRefreshTokenExpired()) {
			logger.info("Token was expired"+oneIdGatewayData);
			throw new TokenExpiredException();
		}
		OmdGateway omdGateway = new OmdGateway();
		omdGateway.refreshToken(loggedInInfo,oneIdGatewayData);	
	}

	public static String refreshToken(HttpSession session) throws TokenExpiredException {
		String tokenAttr = (String) session.getAttribute("oneid_token");

		if (tokenAttr == null) {
			logger.warn("tokenAttr is null");
			return null;
		}
		JSONObject tokens = JSONObject.fromObject(tokenAttr);

		if (tokens == null) {
			logger.warn("tokens is null");
			return null;
		}

		String refreshToken = tokens.getString("refresh_token");

		if (refreshToken == null) {
			logger.warn("refresh token is null");
			return null;
		}
		
		//TODO: check that the refresh token is not expired
		if(isRefreshTokenExpired(refreshToken)) {
			throw new TokenExpiredException();
		}
		

		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.MINUTE, 10);
		Date expiryDate = cal.getTime();
		
		String tokenUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.tokenUrl");
		String audURL = OscarProperties.getInstance().getProperty("oneid.oauth2.audUrl");
		
		String clientId = OscarProperties.getInstance().getProperty("oneid.oauth2.clientId");
		String alias = OscarProperties.getInstance().getProperty("oneid.oauth2.keystore.alias");
		String keystoreLocation = OscarProperties.getInstance().getProperty("oneid.oauth2.keystore");
		String keystorePassword= OscarProperties.getInstance().getProperty("oneid.oauth2.keystore.password");
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("grant_type", "refresh_token");
		params.put("client_id", clientId);
		params.put("client_assertion_type", "urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer");
		params.put("refresh_token", refreshToken);

		try {
			FileInputStream is = new FileInputStream(keystoreLocation);
	
			KeyStore keystore = KeyStore.getInstance(KeyStore.getDefaultType());
			keystore.load(is, keystorePassword.toCharArray());
	

			Key key = keystore.getKey(alias, keystorePassword.toCharArray());
	
			if (key instanceof PrivateKey) {
				Certificate cert = keystore.getCertificate(alias);
	
				JWTCreator.Builder builder = JWT.create().withSubject(clientId).withAudience(audURL).withExpiresAt(expiryDate).withIssuer(clientId);
				String jwt = builder.sign(Algorithm.RSA256((RSAPublicKey) cert.getPublicKey(), (RSAPrivateKey) key));
				params.put("client_assertion", jwt);
			}
	
			WebClient wc = WebClient.create(tokenUrl);
			for (Entry<String, String> entry : params.entrySet()) {
				wc.query(entry.getKey(), entry.getValue());
			}
	
			Response response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").post(null);

			if(response2.getStatus() == 200) {
				String body = response2.readEntity(String.class);
				JSONObject respObj = JSONObject.fromObject(body);
				String accessToken = respObj.getString("access_token");
				tokens.put("access_token", accessToken);
				session.setAttribute("oneid_token",tokens.toString());
				
				return accessToken;
			}
			
		}catch(Exception e) {
			logger.error("Error",e);
		}
	
		return null;
	}
	
	public static boolean isRefreshTokenExpired(String refreshToken) {
		DecodedJWT decodedJWT = JWT.decode(refreshToken);
		long iat = decodedJWT.getClaim("iat").asLong();
		int expiresIn = decodedJWT.getClaim("expires_in").asInt();
		
		Date date = Date.from(Instant.ofEpochSecond(iat));
		
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.SECOND, expiresIn);

		Date expires = cal.getTime();

		if(expires.before(new Date())) {
			return true;
		}
		
		return false;
	}
	
	public static String getCompleteURL(HttpServletRequest request) {
		StringBuffer requestURL = request.getRequestURL();
		if (request.getQueryString() != null) {
		    requestURL.append("?").append(request.getQueryString());
		}
		String completeURL = requestURL.toString();
		
		return completeURL;
	}

	
}
