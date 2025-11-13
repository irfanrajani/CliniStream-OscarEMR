package org.oscarehr.integration.dhdr;
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
import java.io.FileInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.Key;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Map.Entry;

import javax.net.ssl.SSLContext;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.Response;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.cxf.configuration.jsse.TLSClientParameters;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.http.conn.ssl.SSLContexts;
import org.apache.logging.log4j.Logger;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.OperationOutcome;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
//import org.oscarehr.common.dao.DHIRTransactionLogDao;
import org.oscarehr.common.dao.OMDGatewayTransactionLogDao;
//import org.oscarehr.common.model.DHIRTransactionLog;
import org.oscarehr.common.model.OMDGatewayTransactionLog;
import org.oscarehr.integration.OneIDTokenUtils;
import org.oscarehr.integration.OneIdGatewayData;
import org.oscarehr.integration.TokenExpiredException;
import org.oscarehr.integration.fhircast.Event;
import org.oscarehr.integration.ohcms.CMSManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.PKCEUtils;
import org.oscarehr.util.SpringUtils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTCreator;
import com.auth0.jwt.algorithms.Algorithm;

import net.sf.json.JSONObject;
import oscar.OscarProperties;

public class OmdGateway {
	
	private static Logger logger = MiscUtils.getLogger();
	
	public final static String Immunization = "Immunization";
	public final static String MedicationDispense = "MedicationDispense";
	
	protected OMDGatewayTransactionLogDao transactionLogDao = SpringUtils.getBean(OMDGatewayTransactionLogDao.class);
	
	
	protected String getValidToken(HttpSession session) throws TokenExpiredException {
		
		//	String tokenAttr = (String) session.getAttribute("oneid_token");
		//	JSONObject tokens = JSONObject.fromObject(tokenAttr);

		//	String accessToken = tokens.getString("access_token");
			
			//logger.info("CURRENT WORKING TOKEN=" + tokenAttr);
			
		   String  accessToken = OneIDTokenUtils.getValidAccessToken(session);

			return accessToken;
		}
	
	protected List<OperationOutcome> hasOperationOutcome(Bundle bundle)  {
		List<OperationOutcome> result = new ArrayList<OperationOutcome>();
		
		for(BundleEntryComponent comp : bundle.getEntry()) {
			Resource resource = comp.getResource();
			if(resource.getResourceType() == ResourceType.OperationOutcome) {
				OperationOutcome oo = (OperationOutcome)resource;
				result.add(oo);
			}
		}
		return result;
	}
	
	public boolean hasGatewayPropertiesSet(LoggedInInfo loggedInInfo) throws Exception{
		String clientId = OscarProperties.getInstance().getProperty("oneid.consumerKey");
		String clientSecret = OscarProperties.getInstance().getProperty("oneid.consumerSecret");
		String publicKeyStore = OscarProperties.getInstance().getProperty("oneid.gateway.keystore");
		String keystorePassword = OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password");
		String endPoint = OscarProperties.getInstance().getProperty("oneid.gateway.url");
		
		StringBuilder sb = new StringBuilder();
		
		logger.debug("clientId"+ clientId+" clientSecret "+ clientSecret+" publicKeyStore "+publicKeyStore+" keystorePassword "+keystorePassword+" endPoint "+endPoint);
		
		if(clientId == null || clientId.trim().isEmpty()) {
			sb.append("Client Id has not been configured. Use OSCAR property 'oneid.consumerKey' to configure.\n");
		}
		
		if(clientSecret == null || clientSecret.trim().isEmpty()) {
			sb.append("Client Secret has not been configured. Use OSCAR property 'oneid.consumerSecret' to configure.\n");
		}
		
		if(publicKeyStore == null || publicKeyStore.trim().isEmpty()) {
			sb.append("Public Keystore has not been configured. Use OSCAR property 'oneid.gateway.keystore' to configure.\n");
		}
		try {
			Path path = Paths.get(publicKeyStore);
			if(Files.notExists(path)) {
				sb.append("Public Keystore can not be found at: "+publicKeyStore+"\n");
			}
		}catch(Exception e) {
			sb.append("Public Keystore can not be found at: "+publicKeyStore+"\n");
		}
		
		if(keystorePassword == null || keystorePassword.trim().isEmpty()) {
			sb.append("Keystore password has not been configured. Use OSCAR property 'oneid.gateway.keystore.password' to configure.\n");
		}
		
		if(endPoint == null || endPoint.trim().isEmpty()) {
			sb.append("Gateway endPoint has not been configured. Use OSCAR property 'oneid.gateway.url' to configure.\n");
		}
		
		
		if(sb.length() > 0) {
			OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, null, "GATEWAY" , "Configuration Error");
			//omdGatewayTransactionLog.setOscarSessionId(loggedInInfo.getSession().getId());
			omdGatewayTransactionLog.setStarted(new Date());
			omdGatewayTransactionLog.setError(sb.toString());
			transactionLogDao.persist(omdGatewayTransactionLog);
			throw(new Exception("Gateway Configuration Error"));
		}
		logger.info("has props out "+sb.toString());
		return true;
	}
	
	public void logError(LoggedInInfo loggedInInfo,String externalSystem, String transactionType,String error) {
		OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, null, externalSystem, transactionType);
		omdGatewayTransactionLog.setStarted(new Date());
		omdGatewayTransactionLog.setSuccess(Boolean.FALSE);
		omdGatewayTransactionLog.setError(error);
		transactionLogDao.persist(omdGatewayTransactionLog);
	}
	
	public void logDataReceived(LoggedInInfo loggedInInfo,String externalSystem, String transactionType,String dataReceived,Integer demographicNo) {
		logDataReceived( loggedInInfo, externalSystem,  transactionType, dataReceived, demographicNo,null) ;
	}
	
	public void logDataReceived(LoggedInInfo loggedInInfo,String externalSystem, String transactionType,String dataReceived,Integer demographicNo,String uniqueToken) {
		OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, null, externalSystem, transactionType);
		omdGatewayTransactionLog.setStarted(new Date());
		omdGatewayTransactionLog.setSuccess(Boolean.TRUE);
		if(demographicNo != null) {
			omdGatewayTransactionLog.setDemographicNo(demographicNo);
		}
		omdGatewayTransactionLog.setDataRecieved(dataReceived);
		if(uniqueToken != null) {
			omdGatewayTransactionLog.setxCorrelationId(uniqueToken);
		}
		transactionLogDao.persist(omdGatewayTransactionLog);
	}
	
	public WebClient getWebClientWholeURL(LoggedInInfo loggedInInfo,String url) throws Exception {
		hasGatewayPropertiesSet(loggedInInfo);
		String gatewayUrl = getEndpointURL();
		WebClient wc = WebClient.create(url);
		WebClient.getConfig(wc).getHttpConduit().setTlsClientParameters(getTLSClientParameters(loggedInInfo));
		return wc;
	}
	
	public WebClient getWebClient(LoggedInInfo loggedInInfo,String resource) throws Exception {
			hasGatewayPropertiesSet(loggedInInfo);
			String gatewayUrl = getEndpointURL();
			String fullURL = gatewayUrl+resource;
			
			WebClient wc = WebClient.create(fullURL);
			WebClient.getConfig(wc).getHttpConduit().setTlsClientParameters(getTLSClientParameters(loggedInInfo));
			WebClient.getConfig(wc).getHttpConduit().getClient().setConnectionTimeout((Long.parseLong(OscarProperties.getInstance().getProperty("oneid.gateway.timeout"))*1000));
			WebClient.getConfig(wc).getHttpConduit().getClient().setReceiveTimeout((Long.parseLong(OscarProperties.getInstance().getProperty("oneid.gateway.timeout"))*1000));

			return wc;
		}
		
	protected TLSClientParameters getTLSClientParameters(LoggedInInfo loggedInInfo) throws Exception {
			hasGatewayPropertiesSet(loggedInInfo);
			KeyStore ks = KeyStore.getInstance("JKS");
			ks.load(new FileInputStream(OscarProperties.getInstance().getProperty("oneid.gateway.keystore")), 
					OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password").toCharArray());
			
			SSLContext sslcontext = SSLContexts.custom().loadKeyMaterial(ks, OscarProperties.getInstance().getProperty("oneid.gateway.keystore.password").toCharArray()).build();
			sslcontext.getDefaultSSLParameters().setNeedClientAuth(true);
			sslcontext.getDefaultSSLParameters().setWantClientAuth(true);

			TLSClientParameters tlsParams = new TLSClientParameters();
			tlsParams.setSSLSocketFactory(sslcontext.getSocketFactory());
			tlsParams.setDisableCNCheck(true);
			
			return tlsParams;
		}
		
	/*public Response doGet(WebClient wc, HttpServletRequest request) throws TokenExpiredException {
			String consumerKey = OscarProperties.getInstance().getProperty("oneid.consumerKey");
			String consumerSecret = OscarProperties.getInstance().getProperty("oneid.consumerSecret");
			String accessToken = getValidToken(request.getSession());
			
			Response response2 = wc.header("Authorization", "Bearer " + accessToken).header("X-Gtwy-Client-Id", consumerKey).header("X-Gtwy-Client-Secret", consumerSecret).get();
			
			return response2;
		}
*/
	
	public Response doGet(LoggedInInfo loggedInInfo, WebClient wc) throws TokenExpiredException {
		return doGet(loggedInInfo,wc,null);
	}
	
	
	protected String getConsumerKey() {
		return OscarProperties.getInstance().getProperty("oneid.consumerKey");
	}
	
	protected String getEndpointURL() {
		return OscarProperties.getInstance().getProperty("oneid.gateway.url");
	}
	
	public Response doGet(LoggedInInfo loggedInInfo, WebClient wc,AuditInfo auditInfo) throws TokenExpiredException {
		String consumerKey = getConsumerKey();
		String consumerSecret = OscarProperties.getInstance().getProperty("oneid.consumerSecret");
		if(loggedInInfo.getOneIdGatewayData().isAccessTokenExpired()) {
			throw new TokenExpiredException();
		}
		String accessToken = loggedInInfo.getOneIdGatewayData().getAccessToken();
		
		Integer demographicNo = null;
		String externalSystem = null;
		String transactionType = null;
		if(auditInfo != null) {
			demographicNo = auditInfo.getDemographicNo();
			externalSystem = auditInfo.getExternalSystem();
			transactionType = auditInfo.getTransactionType();
		}
		
		OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, demographicNo, externalSystem, transactionType);
		omdGatewayTransactionLog.setDataSent(wc.getCurrentURI().toASCIIString());
		omdGatewayTransactionLog.setxGtwyClientId(consumerKey);
		transactionLogDao.persist(omdGatewayTransactionLog);
		
		Response response2 = null;
		try {
			response2 = wc.header("Authorization", "Bearer " + accessToken).header("X-Gtwy-Client-Id", consumerKey).header("X-Gtwy-Client-Secret", consumerSecret).get();
			completeLog(omdGatewayTransactionLog,response2);
			transactionLogDao.merge(omdGatewayTransactionLog);
		}catch(Exception e) {
			logger.error("ERROR OMD Gateway GET",e);
			omdGatewayTransactionLog.setError(e.getLocalizedMessage());
			transactionLogDao.merge(omdGatewayTransactionLog);
			throw(e);
		}
		return response2;
	}
	
	
	public String getConsentViewletURL(LoggedInInfo loggedInInfo, int demographicNo, String target,String uniqueToken) throws Exception {
		CMSManager.consentTargetChange(loggedInInfo, demographicNo,target);
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		String url = oneIdGatewayData.getPCOIUrl()+"?launch="+oneIdGatewayData.getHubTopic()+"&iss="+oneIdGatewayData.getFHIRiss()+"&inheritanceID="+oneIdGatewayData.getAuthzid();
		OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, demographicNo, "PCOI", "consentViewletLaunch");
		omdGatewayTransactionLog.setDataSent(url);
		omdGatewayTransactionLog.setxCorrelationId(uniqueToken);
		transactionLogDao.persist(omdGatewayTransactionLog);
		return url;
	}
	
	public Response doPost(LoggedInInfo loggedInInfo, WebClient wc,Event fhirCastEvent) throws TokenExpiredException {
		String consumerKey = OscarProperties.getInstance().getProperty("oneid.consumerKey");
		String consumerSecret = OscarProperties.getInstance().getProperty("oneid.consumerSecret");
		if(loggedInInfo.getOneIdGatewayData().isAccessTokenExpired()) {
			throw new TokenExpiredException();
		}
		String accessToken = loggedInInfo.getOneIdGatewayData().getAccessToken();
		Integer demographicNo = null;
		String externalSystem = null;
		String transactionType = null;
		if(fhirCastEvent != null) {
			externalSystem = "CMS";
			transactionType = fhirCastEvent.getHubEvent();
		}
		OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, demographicNo, externalSystem, transactionType);
		omdGatewayTransactionLog.setDataSent(fhirCastEvent.getFhirCastEvent());
		omdGatewayTransactionLog.setxGtwyClientId(consumerKey);
		transactionLogDao.persist(omdGatewayTransactionLog);
		Response response2 = null;
		try {
			response2 = wc.header("Authorization", "Bearer " + accessToken).header("X-Gtwy-Client-Id", consumerKey)
				.header("X-Gtwy-Client-Secret", consumerSecret).header("X-Request-Id", fhirCastEvent.getId())
				.header("X-Correlation-Id", fhirCastEvent.getId()).header("X-LobTxId", fhirCastEvent.getId())
				.header("Content-Type", "application/json").post(fhirCastEvent.getFhirCastEvent());
		completeLog(omdGatewayTransactionLog,response2);
		transactionLogDao.merge(omdGatewayTransactionLog);
		}catch(Exception e) {
			e.getMessage();
			omdGatewayTransactionLog.setError(e.getLocalizedMessage());
			transactionLogDao.merge(omdGatewayTransactionLog);
			throw(e);
		}
		return response2;
	}
	
	public Response getTokens(LoggedInInfo loggedInInfo,String code,String clientId, String codeVerifier,String jwt)  {
		String externalSystem = "OIDC";
		String transactionType = "TOKENS";
		String tokenUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.tokenUrl");
		String callbackUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.callbackUrl");
		
		OMDGatewayTransactionLog omdGatewayTransactionLog = getOMDGatewayTransactionLog(loggedInInfo, null, externalSystem, transactionType);
		omdGatewayTransactionLog.setDataSent(null);
		transactionLogDao.persist(omdGatewayTransactionLog);
		Response response2 = null;
		try {
			WebClient wc = WebClient.create(tokenUrl); 
			wc.query("grant_type", "authorization_code");
			//TODO: Not sure that _profile should be hard coded
			//params.put("_profile", "http://ehealthontario.ca/StructureDefinition/ca-on-dhir-profile-Immunization");
			wc.query("client_assertion_type", "urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer");

			wc.query("code", code);
			wc.query("redirect_uri", callbackUrl);
			wc.query("client_id", clientId);

			wc.query("code_verifier",codeVerifier);
			wc.query("client_assertion", jwt);
			

			response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").post(null);
			
			
		completeLog(omdGatewayTransactionLog,response2);
		transactionLogDao.merge(omdGatewayTransactionLog);
		}catch(Exception e) {
			e.getMessage();
			omdGatewayTransactionLog.setError(e.getLocalizedMessage());
			transactionLogDao.merge(omdGatewayTransactionLog);
			throw(e);
		}
		return response2;
	}
	
	public static OMDGatewayTransactionLog getOMDGatewayTransactionLog(LoggedInInfo loggedInInfo,Integer demographicNo,String externalSystem,String transactionType) {
		OMDGatewayTransactionLog omdGatewayTransactionLog = new OMDGatewayTransactionLog();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		if(oneIdGatewayData != null) {
			logger.error("oneIdGatewayData.howLongUntilAccessTokenIsExpired() "+oneIdGatewayData.howLongUntilAccessTokenIsExpired());
			omdGatewayTransactionLog.setSecondsLeft(oneIdGatewayData.howLongUntilAccessTokenIsExpired());
			omdGatewayTransactionLog.setUao(oneIdGatewayData.getUao());
			omdGatewayTransactionLog.setContextSessionId(oneIdGatewayData.getCtxSessionId());
			omdGatewayTransactionLog.setUniqueSessionId(oneIdGatewayData.getUniqueSessionId());
		}
		
		omdGatewayTransactionLog.setDemographicNo(demographicNo);
		omdGatewayTransactionLog.setExternalSystem(externalSystem);
		omdGatewayTransactionLog.setInitiatingProviderNo(loggedInInfo.getLoggedInProviderNo());
		omdGatewayTransactionLog.setOscarSessionId(loggedInInfo.getSession().getId());
		omdGatewayTransactionLog.setStarted(new Date());
		omdGatewayTransactionLog.setTransactionType(transactionType);
		
		return omdGatewayTransactionLog;
	}
	private static void completeError(OMDGatewayTransactionLog log, Response response2) {
		
	}
	
	protected static void completeLog(OMDGatewayTransactionLog log, Response response2) {
		log.setResultCode(response2.getStatus());
		log.setSuccess(true);
	
		log.setEnded(new Date());
		
		String xRequestId = response2.getHeaderString("X-Request-Id");
		if(xRequestId != null) {
			log.setxRequestId(xRequestId);
		}
		String xLobTxId = response2.getHeaderString("X-LobTxId");
		if(xLobTxId != null) {
			log.setxLobTxId(xLobTxId);
		}
		String xCorrelationId = response2.getHeaderString("X-Correlation-Id");
		if(xCorrelationId != null) {
			log.setxCorrelationId(xCorrelationId);
		}
		if(response2.getStatus() >= 300) {
			log.setError(response2.readEntity(String.class));
			log.setSuccess(false);
		}else {
			logger.info("DATA RECIEVED "+response2.readEntity(String.class));
			log.setDataRecieved(response2.readEntity(String.class));
		}
		logger.error("DATA RECIEVED set to "+log.getDataRecieved());
		StringBuilder headers = new StringBuilder();
		for(String headerName : response2.getHeaders().keySet()) {
			headers.append(headerName + ":" + response2.getHeaderString(headerName) + "\n");
		}		
		log.setHeaders(headers.toString());
	}
	
	public String generateVerifier() {
		//create verifier and challenge
	    byte[] array = new byte[50];
	    new Random().nextBytes(array);
	    String generatedString = RandomStringUtils.randomAlphabetic(50);
	    
	    String verifier = PKCEUtils.encodeBase64NoPadding(generatedString);
	    logger.debug("verifier = "+verifier);
	    return verifier;
	}
	
	public Response callAuthorize(LoggedInInfo loggedInInfo,OneIdGatewayData oneIdGatewayData,String state,String verifier) {
		
		logger.info("OAUTH2 Login started oneIdGatewayData null ?"+ (oneIdGatewayData == null)+ " loggedInInfo "+(loggedInInfo.getOneIdGatewayData() == null));
		
		if(oneIdGatewayData == null ){
			
			oneIdGatewayData = new OneIdGatewayData();
		}


	    

	    String challenge = null;
	    try {
	    	challenge = PKCEUtils.generateChallengeS256(verifier);
	    } catch(Exception e) {
	    	logger.error("Error",e);
			//need to forward back to login page with error
	    }    
	    logger.debug("challenge = "+challenge);
	    
	    
		String authorizeUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.authorizeUrl");
		String callbackUrl = OscarProperties.getInstance().getProperty("oneid.oauth2.callbackUrl");
		String clientId = OscarProperties.getInstance().getProperty("oneid.oauth2.clientId");
		
		String aud = OscarProperties.getInstance().getProperty("oneid.oauth2.aud");
		
		WebClient wc = WebClient.create(authorizeUrl); 

		wc.query("response_type", "code");
		
		wc.query("scope", OneIDTokenUtils.urlEncode(oneIdGatewayData.getScope()));
		
		if(oneIdGatewayData.get_profile() != null && oneIdGatewayData.get_profile().length() != 0) {
			wc.query("_profile",OneIDTokenUtils.urlEncode(oneIdGatewayData.get_profile()));
		}
		
		wc.query("code_challenge_method", "S256");
		
		wc.query("code_challenge", challenge);
		wc.query("redirect_uri", callbackUrl);
		wc.query("client_id", clientId);
		wc.query("state", state);
		if(aud != null){
			wc.query("aud",aud);
		}
		if(oneIdGatewayData.getUao() != null) {
			wc.query("uao",oneIdGatewayData.getUao());
		}
		 
		OMDGatewayTransactionLog omdGatewayTransactionLog = OmdGateway.getOMDGatewayTransactionLog(loggedInInfo, null, "Auth", "AUTHORIZE");
		transactionLogDao.persist(omdGatewayTransactionLog);
		Response response2 = null;
		try {
			response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").get();
			completeLog(omdGatewayTransactionLog,response2);
			transactionLogDao.merge(omdGatewayTransactionLog);
			logger.info("Response Status from /Authorize =" + response2.getStatus());
		}catch(Exception e) {
			logger.error("Error calling Authorize "+omdGatewayTransactionLog,e);			
			omdGatewayTransactionLog.setError(ExceptionUtils.getStackTrace(e));
			omdGatewayTransactionLog.setSuccess(false);
			transactionLogDao.merge(omdGatewayTransactionLog);
		}
		return response2;
	}
	
	public void refreshToken(LoggedInInfo loggedInInfo,OneIdGatewayData oneIdGatewayData) {
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
		params.put("refresh_token", oneIdGatewayData.getRefreshTokenString());

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
			OMDGatewayTransactionLog omdGatewayTransactionLog = OmdGateway.getOMDGatewayTransactionLog(loggedInInfo, null, "Auth", "REFRESH");
			transactionLogDao.persist(omdGatewayTransactionLog);
			Response response2 = wc.header("Content-Type", "application/x-www-form-urlencoded").post(null);
			completeLog(omdGatewayTransactionLog,response2);
			transactionLogDao.merge(omdGatewayTransactionLog);

			if(response2.getStatus() == 200) {
				String body = response2.readEntity(String.class);
				logger.debug("BODY FROM REFRESH "+body);
				JSONObject respObj = JSONObject.fromObject(body);
				String accessToken = respObj.getString("access_token");
				oneIdGatewayData.processAccessToken(accessToken);
				
			}
			
		}catch(Exception e) {
			logger.error("Error",e);
		}
	}

}
