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
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.ws.rs.core.Response;

import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.logging.log4j.Logger;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.OperationOutcome;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;

import ca.uhn.fhir.context.FhirContext;
import oscar.OscarProperties;

public class DHDRManager extends OmdGateway {
	
	Logger logger = MiscUtils.getLogger();
	static FhirContext ctx = FhirContext.forR4();
	
	//This only used if the endpoint is different for the dhdr than the rest of the gateway applications
	@Override
	protected String getConsumerKey() {
		if(OscarProperties.getInstance().hasProperty("oneid.consumerKey.dhdr")) {
			return OscarProperties.getInstance().getProperty("oneid.consumerKey.dhdr");
		}
		return OscarProperties.getInstance().getProperty("oneid.consumerKey");
	}
	
	@Override
	protected String getEndpointURL() {
		if(OscarProperties.getInstance().hasProperty("oneid.gateway.url.dhdr")) {
			return OscarProperties.getInstance().getProperty("oneid.gateway.url.dhdr");
		}
		return OscarProperties.getInstance().getProperty("oneid.gateway.url");
	}

	public String search2(LoggedInInfo loggedInInfo, Demographic demographic, Date startDate, Date endDate,String searchId,Integer pageId) throws Exception {
		
		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
		WebClient wc = getWebClient(loggedInInfo,OmdGateway.MedicationDispense);
		
		wc.query("patient.identifier", "https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn|" + demographic.getHin());//"5365837912");
		
		wc.query("patient.birthdate", demographic.getBirthDayAsString());
		
		//Map to fhir types “male”, “female”, “other”, “unknown”
		
		if("M".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "male");//"5365837912");
		}else if("F".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "female");//"5365837912");
		}else if("T".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "other");//"5365837912");
		}else if("O".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "other");//"5365837912");
		}else if("U".equalsIgnoreCase(demographic.getSex())){
			wc.query("patient.gender", "unknown");//"5365837912");
		}else{
			wc.query("patient.gender", "unknown");//"5365837912");
		}
	
		
		wc.query("_count", "1000");
		
		if (endDate == null) {
			wc.query("whenprepared", "lt"+fmt.format(endDate));
		}else {
			wc.query("whenprepared", "lt"+fmt.format(new Date()));
		}
		if (startDate != null) {
			wc.query("whenprepared", "gt"+fmt.format(startDate));
		}
		wc.query("_format", "application/fhir+json");
		
		if(searchId != null){
			wc.query("search-id",searchId);
		}
		
		if(pageId != null){
			wc.query("page",pageId);
		}
		
		AuditInfo auditInfo = new AuditInfo(AuditInfo.DHDR,AuditInfo.SEARCH,demographic.getDemographicNo());
		Response response2 = doGet(loggedInInfo, wc,auditInfo);			
		String body = response2.readEntity(String.class);
	
		logger.debug("body:"+ body);
		
		if(response2.getStatus() >= 200 && response2.getStatus() < 300) {	
			Bundle bundle = (Bundle) ctx.newJsonParser().parseResource(body);
			
			return body;
		} else if(response2.getStatus() >= 400 && response2.getStatus() < 600 && body != null) {
			OperationOutcome outcome = ctx.newJsonParser().parseResource(OperationOutcome.class, body);
			if(outcome != null) {
				logger.debug("would add outcome here "+outcome);
				return body;
			} 
		} else {
			logger.error(response2.getStatus()); 
			logger.error(body);
		}
		 
		return null;

	}
	
	List<String> getMoreBundles(LoggedInInfo loggedInInfo,List<String> bundles,Bundle bundle,AuditInfo auditInfo) throws Exception{
		logger.debug("bundle.hasLink()" +bundle.hasLink()+" bundle.getLink(\"next\") " +bundle.getLink("next"));
		if(bundle.hasLink() && bundle.getLink("next") != null) {
			String url = bundle.getLink("next").getUrl();
			WebClient wc = getWebClientWholeURL(loggedInInfo, url); 
			Response response2 = doGet(loggedInInfo, wc,auditInfo);			
			String body = response2.readEntity(String.class);
			Bundle bundle2 = (Bundle) ctx.newJsonParser().parseResource(body);
			bundles.add(body);
			getMoreBundles(loggedInInfo,bundles,bundle2,auditInfo);
		}
		return bundles;
	}
	
}
