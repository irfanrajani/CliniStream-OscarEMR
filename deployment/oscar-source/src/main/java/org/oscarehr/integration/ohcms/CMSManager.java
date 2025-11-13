package org.oscarehr.integration.ohcms;
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
import java.util.UUID;

import javax.ws.rs.core.Response;

import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.logging.log4j.Logger;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import net.sf.json.JSONObject;

import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.Demographic;

import org.oscarehr.integration.OneIdGatewayData;
import org.oscarehr.integration.dhdr.OmdGateway;
import org.oscarehr.integration.fhircast.Event;
import org.oscarehr.integration.fhircast.UserLogin;

public class CMSManager {
	static Logger logger = MiscUtils.getLogger();
	
	
	static public String createHubTopic(LoggedInInfo loggedInInfo) throws Exception{
		
		OmdGateway omdGateway = new OmdGateway();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl()+"/createHubTopic");
		
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,new Event(UUID.randomUUID().toString(),  "hubTopic", "createHubTopic"));
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		
		JSONObject responseB = JSONObject.fromObject(hubTopicResponseBody);
		logger.error("hubTopicResponse: "+hubTopicResponseBody);
		oneIdGatewayData.setHubTopic(responseB.getString("hub.topic"));
		
		return null;
	}
	
	//userLogin
	static public String userLogin(LoggedInInfo loggedInInfo) throws Exception{

		ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
		
		FhirResources fhirResources = new FhirResources();
		
		OmdGateway omdGateway = new OmdGateway();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		
		if(oneIdGatewayData.getHubTopic() == null) {
			createHubTopic(loggedInInfo);
		}
		
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
		String uuid = UUID.randomUUID().toString();
		UserLogin userLogin = new UserLogin(uuid,oneIdGatewayData.getHubTopic());
		Clinic clinic = clinicDao.getClinic();
		try {
		userLogin.addContext("organization",fhirResources.getString(fhirResources.getOrganization(loggedInInfo)));
		
		userLogin.addContext("practitioner",fhirResources.getString(fhirResources.getPractitioner(loggedInInfo)));
		
		String language = loggedInInfo.getLocale().getLanguage(); 
		if("en".equals(language) || "fr".equals(language)) {
			logger.debug("Language selected was "+language);//all good
		}else {
			logger.info("unknown Language selected: "+language+" changing to en");//all good
			language = "en";
		}
		
		userLogin.addContext("parameters",fhirResources.getString(fhirResources.getLanguageParameter(loggedInInfo, UUID.randomUUID().toString(), "en")));
		
		}catch( CMSException cme) {
			omdGateway.logError(loggedInInfo, "CMS", "userLogin configuration error",cme.getLocalizedMessage());
			throw(cme);
		}
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,userLogin);
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		logger.error("userLoginResponse: "+hubTopicResponseBody);
		if(hubTopicResponse.getStatus() >= 200 && hubTopicResponse.getStatus() < 300) {
			oneIdGatewayData.setCmsLoggedIn(hubTopicResponseBody);
		}else if(hubTopicResponse.getStatus() >= 400 && hubTopicResponseBody != null) {
			throw new CMSException(hubTopicResponseBody);
		}else {
			throw new CMSException();
		}
		
		return null;
	}
	
	//setLanguage
	
	//organizationChange

	static public String organizationChange(LoggedInInfo loggedInInfo)  throws Exception{
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		if(oneIdGatewayData.getCmsLoggedIn() == null) {
			//Do nothing if not logged in.
			return null;
		}
		FhirResources fhirResources = new FhirResources();
		OmdGateway omdGateway = new OmdGateway();
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
		String uuid = UUID.randomUUID().toString();
		Event event = new Event(uuid,oneIdGatewayData.getHubTopic(),"OH.Organization-change");
		event.addContext("organization",fhirResources.getString(fhirResources.getOrganization(loggedInInfo)));
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,event);
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		logger.error("OH.Organization-change: "+hubTopicResponseBody);
		
		if(hubTopicResponse.getStatus() >= 200 && hubTopicResponse.getStatus() < 300) {
			oneIdGatewayData.setUpdateUAOInCMS(false);
		}else if(hubTopicResponse.getStatus() >= 400 && hubTopicResponseBody != null) {
			throw new CMSException(hubTopicResponseBody);
		}else {
			throw new CMSException();
		}
		return null;
	}
	
	//patientOpen
	static public String patientOpen(LoggedInInfo loggedInInfo,int demographicNo) throws Exception{		

		DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
		Demographic demographic = demographicDao.getDemographicById(demographicNo);
		FhirResources fhirResources = new FhirResources();
		OmdGateway omdGateway = new OmdGateway();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		
		if(oneIdGatewayData.getCmsLoggedIn() == null) {
			userLogin(loggedInInfo);
		}
		
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
		String uuid = UUID.randomUUID().toString();
		Event event = new Event(uuid,oneIdGatewayData.getHubTopic(),"Patient-open");
		try {
			event.addContext("patient",fhirResources.getString(fhirResources.getPatient(loggedInInfo,demographic)));
		}catch( CMSException cme) {
			omdGateway.logError(loggedInInfo, "CMS", "Patient-open error",cme.getLocalizedMessage());
			throw(cme);
		}
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,event);
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		logger.error("patientOpen: "+hubTopicResponseBody);
		
		if(hubTopicResponse.getStatus() >= 200 && hubTopicResponse.getStatus() < 300) {
			oneIdGatewayData.setCmsPatientInContext(""+demographicNo);
		}else if(hubTopicResponse.getStatus() >= 400 && hubTopicResponseBody != null) {
			throw new CMSException(hubTopicResponseBody);
		}else {
			throw new CMSException();
		}
		
		
		
		//NEED to set the patient that is open in the cms
		return null;
	}
	
	//patientClose
	static public String patientClose(LoggedInInfo loggedInInfo,int demographicNo) throws Exception{

		DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);
		Demographic demographic = demographicDao.getDemographicById(demographicNo);
		FhirResources fhirResources = new FhirResources();
		OmdGateway omdGateway = new OmdGateway();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		
		if(oneIdGatewayData.getHubTopic() == null) {
			createHubTopic(loggedInInfo);
		}
		
		
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
		String uuid = UUID.randomUUID().toString();
		Event event = new Event(uuid,oneIdGatewayData.getHubTopic(),"Patient-close");
		
		event.addContext("patient",fhirResources.getString(fhirResources.getPatient(loggedInInfo,demographic)));
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,event);
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		logger.error("patientOpen: "+hubTopicResponseBody);
		if(hubTopicResponse.getStatus() >= 200 && hubTopicResponse.getStatus() < 300) {
			oneIdGatewayData.setCmsPatientInContext(null);
		}else if(hubTopicResponse.getStatus() >= 400 && hubTopicResponseBody != null) {
			throw new CMSException(hubTopicResponseBody);
		}else {
			throw new CMSException();
		}
		return null;
	}
	
	
	//consentTargetChange
	static public String consentTargetChange(LoggedInInfo loggedInInfo,int demographicNo,String param) throws Exception{
		
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		String patientInContext = oneIdGatewayData.getCmsPatientInContext();
		
		if(patientInContext == null) { //demographicNo is patient in context? If not, call patientOpen
			patientOpen(loggedInInfo,demographicNo);
		}else if(Integer.parseInt(patientInContext) != demographicNo) { //If a different patient Is Open -- Close that patient and open this patient
			patientClose(loggedInInfo,Integer.parseInt(patientInContext));
			patientOpen(loggedInInfo,demographicNo);
		}
		patientInContext = oneIdGatewayData.getCmsPatientInContext();
		OmdGateway omdGateway = new OmdGateway();
		FhirResources fhirResources = new FhirResources();
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
		String uuid = UUID.randomUUID().toString();
		Event event = new Event(uuid,oneIdGatewayData.getHubTopic(),"OH.consentTargetChange");
		
		event.addContext("parameters",fhirResources.getString(fhirResources.getConsentTargetParameter(loggedInInfo,UUID.randomUUID().toString(),param)));
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,event);
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		logger.error("userLoginResponse: "+hubTopicResponseBody);
		
		//Now call consentTargetChange.
		/*
		{
			  "timestamp": "2019-01-08T01:37:05.14",
			  "id": "q9v3jubddqt63n3",
			  "event": {
			    "hub.topic": "7jaa86kgdudewiaq0wta",
			    "hub.event": "OH.consentTargetChange",
			    "context": [
			      {
			        "key": "parameters",
			        "resource": {
			          "resourceType": "Parameters",
			          "id": "0c678a3d-3b71-446e-91b3-41541e1360af",
			          "meta": {
			          "profile": "http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0"
			          },
			          "parameter": [
			            {
			              "name": "consentTarget",
			              "valueString": "HomeMedicine,Immunization"
			            }
			          ]
			        }
			      }
			    ]
			  }
			}
			*/
		return null;
	}
	
	//legacyLaunch
	static public String legacyLaunch(LoggedInInfo loggedInInfo,int demographicNo,String param) throws Exception{
		
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		String patientInContext = oneIdGatewayData.getCmsPatientInContext();
		logger.debug("is legacy for same patient ? current patientInContext "+patientInContext+" request demogrpahic "+demographicNo);
		if(patientInContext == null) { //demographicNo is patient in context? If not, call patientOpen
			patientOpen(loggedInInfo,demographicNo);
		}else if(Integer.parseInt(patientInContext) != demographicNo) { //If a different patient Is Open -- Close that patient and open this patient
			patientClose(loggedInInfo,Integer.parseInt(patientInContext));
			patientOpen(loggedInInfo,demographicNo);
		}
		patientInContext = oneIdGatewayData.getCmsPatientInContext();
		OmdGateway omdGateway = new OmdGateway();
		FhirResources fhirResources = new FhirResources();
		WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
		String uuid = UUID.randomUUID().toString();
		Event event = new Event(uuid,oneIdGatewayData.getHubTopic(),"OH.legacyLaunch");
		
		event.addContext("parameters",fhirResources.getString(fhirResources.getContextSessionIdParameter(loggedInInfo,UUID.randomUUID().toString(),param)));
		Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,event);
		String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
		logger.error("legacyLaunch: "+hubTopicResponseBody);
		
		//Now call consentTargetChange.
		/*
		{
		  "timestamp": "2019-01-08T01:37:05.14",
		  "id": "q9v3jubddqt63n3",
		  "event": {
		    "hub.topic": "7jaa86kgdudewiaq0wta",
		    "hub.event": "OH.legacyLaunch",
		    "context": [
		      {
		        "key": "parameters",
		        "resource": {
		          "resourceType": "Parameters",
		          "id": "0c678a3d-3b71-446e-91b3-41541e1360af",
		          "meta": {
		          "profile": "http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0"
		           },
		          "parameter": [
		            {
		              "name": "contextSessionId",
		              "valueId": "7we9hfgt45jslsl0322dhyf"
		            }
		          ]
		        }
		      }
		    ]
		  }
		}
			*/
		return null;
	}
	
	
	//userLogout
	//Should check to see if the user is logged in. Also check to see if a patient is still in context
	static public String userLogout(LoggedInInfo loggedInInfo) throws Exception{
		if(loggedInInfo != null) {
			OmdGateway omdGateway = new OmdGateway();
			OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
			if(oneIdGatewayData != null && oneIdGatewayData.getHubTopic() != null) {
				//TODO:Need to check if a patient is still in context
				
				WebClient createHubTopic = omdGateway.getWebClientWholeURL(loggedInInfo,oneIdGatewayData.getCMSUrl());
				
				Response hubTopicResponse = omdGateway.doPost(loggedInInfo,createHubTopic,new Event(UUID.randomUUID().toString(),  oneIdGatewayData.getHubTopic(), "userLogout"));
				String hubTopicResponseBody = hubTopicResponse.readEntity(String.class);
				
				JSONObject responseB = JSONObject.fromObject(hubTopicResponseBody);
				logger.error("hubTopicResponse: "+hubTopicResponseBody);
			}
			//oneIdGatewayData.setHubTopic(responseB.getString("hub.topic"));}\
		}
		return null;
	}
	
	
	

}
