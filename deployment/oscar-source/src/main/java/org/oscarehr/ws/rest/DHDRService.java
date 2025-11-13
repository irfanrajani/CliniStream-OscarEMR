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
package org.oscarehr.ws.rest;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.StreamingOutput;
import javax.ws.rs.core.Response.Status;

import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.Logger;
import org.hl7.fhir.r4.model.MedicationDispense;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.Extension;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Medication;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.OMDGatewayTransactionLogDao;
import org.oscarehr.common.dao.UAODao;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.OMDGatewayTransactionLog;
import org.oscarehr.common.model.UAO;
import org.oscarehr.integration.dhdr.DHDRManager;
import org.oscarehr.integration.dhdr.DHDRPrint;
import org.oscarehr.integration.dhdr.OmdGateway;
import org.oscarehr.integration.ohcms.CMSException;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.ws.rest.to.DHDRSearchConfig;
import org.oscarehr.ws.rest.to.model.MedicationDispenseTo1;
import org.oscarehr.ws.rest.to.model.NotificationTo1;
import org.oscarehr.ws.rest.to.model.TokenExpireTo;
import org.oscarehr.ws.rest.to.model.UAOTo1;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import net.sf.json.JSONObject;
import oscar.log.LogAction;

@Path("/dhdr")
@Component("dhdrService")
public class DHDRService extends AbstractServiceImpl {
	Logger logger = MiscUtils.getLogger();

	@Autowired
	DemographicDao demographicDao;
	
	@Autowired
	OMDGatewayTransactionLogDao omdGatewayTransactionLogDao; 
	
	@Autowired
	UAODao uaoDao;

	
	@POST
	@Path("/searchByDemographicNo2")
	@Produces("application/json")
	@Consumes("application/json")
	public Response searchByDemographicNo2(@QueryParam("demographicNo") int demographicNo, @QueryParam("offset") int offset, @QueryParam("limit") int limit,DHDRSearchConfig searchConfig ) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		DHDRManager dhdrManager = new DHDRManager();
		Date startDate = null;
		Date endDate = null;
		String searchId = null;
		Integer pageId = null;
		if(searchConfig != null) {
			startDate = searchConfig.getStartDate();
			endDate = searchConfig.getEndDate();
			searchId = searchConfig.getSearchId();
			try{
				pageId = Integer.parseInt(searchConfig.getPageId());
			}catch(Exception e){
				//not a number 
			}
			
			
		}
		Demographic demographic = demographicDao.getDemographicById(demographicNo);
		String bundle = dhdrManager.search2(loggedInInfo, demographic, startDate, endDate,searchId,pageId);
				
		
		return Response.ok().entity(bundle).build();
	}
	
	
	
	public MedicationDispenseTo1 translate(MedicationDispense medicationDispense) {
		MedicationDispenseTo1 medicationDispenseTo1 = new MedicationDispenseTo1();
		List<Resource> listRes =medicationDispense.getContained();
		
		medicationDispenseTo1.setDispenseDate(medicationDispense.getWhenPrepared()); //
		medicationDispenseTo1.setDispensedQuantity(medicationDispense.getQuantity().getValue().toPlainString());
		medicationDispenseTo1.setEstimatedDaysSupply(medicationDispense.getDaysSupply().getValue().toPlainString());// display right?
		
		
		
		
		for(Resource resource :listRes) {
			
			if(resource.getResourceType()  == ResourceType.Medication) {
				Medication medication = (Medication) resource;
				if(medication != null && medication.getCode() != null) {
					medicationDispenseTo1.setDrugDosageForm(medication.getForm().getText());
					Extension ext = medication.getExtensionByUrl("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-medications-ext-medication-strength");
					if(ext != null) {
						medicationDispenseTo1.setDispensedDrugStrength(ext.getValue().primitiveValue());
					}
					List<Coding> codings = medication.getCode().getCoding();
					for(Coding coding : codings) {
						//{"system": "http://hl7.org/fhir/NamingSystem/ca-hc-din","code": "01916580","display": "Hycodan"
						if("http://hl7.org/fhir/NamingSystem/ca-hc-din".equals(coding.getSystem())) {
							medicationDispenseTo1.setBrandName(coding.getDisplay());
						}
						if("http://ehealthontario.ca/fhir/NamingSystem/ca-drug-gen-name".equals(coding.getSystem())) {
							medicationDispenseTo1.setGenericName(coding.getDisplay());
						}
			            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-drug-gen-name","display": "HYDROCODONE BITARTRATE"
			          
			            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-class-ahfs","code": "480000000","display": "COUGH PREPARATIONS"
			            //"system": "http://ehealthontario.ca/fhir/NamingSystem/ca-on-drug-subclass-ahfs","code": "480400000","display": "ANTITUSSIVES"
			         
					}
				}else {
					logger.error("was null "+medication);
				}
			
			}else if(resource.getResourceType()  == ResourceType.Organization) {
				Organization organization = (Organization) resource;
				medicationDispenseTo1.setDispensingPharmacy(organization.getName());
				medicationDispenseTo1.setDispensingPharmacyFaxNumber(organization.getTelecom().get(1).getValue());
			}else if(resource.getResourceType()  == ResourceType.Practitioner) {
				Practitioner practitioner = (Practitioner) resource;
				for(Identifier identifier:practitioner.getIdentifier()) {
					if("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician".equals(identifier.getSystem())) {
						for(HumanName humanName :practitioner.getName()) {
							medicationDispenseTo1.setPrescriberLastname(humanName.getFamily());
							medicationDispenseTo1.setPrescriberFirstname(humanName.getGivenAsSingleString());
						}
						
						
						medicationDispenseTo1.setPrescriberPhoneNumber(practitioner.getTelecom().get(0).getValue());
					}
						
				}
			}else {
				logger.error("resource.getResourceType() "+resource.getResourceType());
			}
		}
		
		
		return medicationDispenseTo1;
	}
	
	
	@GET
	@Path("/getConsentOveride")
	@Produces("application/json")
	public Response getConsentOveride(@QueryParam("demographicNo") int demographicNo) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		try {
			//CMSManager.consentTargetChange(loggedInInfo, demographicNo,"http://ehealthontario.ca/fhir/StructureDefinition/ca-on-medications-profile-MedicationDispense");
			//OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
			//String url = oneIdGatewayData.getPCOIUrl()+"?launch="+oneIdGatewayData.getHubTopic()+"&iss="+oneIdGatewayData.getFHIRiss()+"&InheritanceID="+UUID.randomUUID().toString();
			OmdGateway omdGateway = new OmdGateway();
			String uuid = UUID.randomUUID().toString();
			String uniqueToken = Base64.getUrlEncoder().encodeToString(uuid.getBytes());			
			String url = omdGateway.getConsentViewletURL(loggedInInfo, demographicNo, "http://ehealthontario.ca/fhir/StructureDefinition/ca-on-medications-profile-MedicationDispense",uniqueToken);
			NotificationTo1 notif = new NotificationTo1();
			notif.setReferenceURL(url);
			notif.setUuid(uniqueToken);
			
			return Response.ok().entity(notif).build();
		}catch(CMSException e) {
			NotificationTo1 notif = new NotificationTo1(); 
			notif.setSummary(e.getMessage());
			return Response.status(268).entity(notif).build();
		}
	}
	
	@POST
	@Path("/logConsentOveride/{demographicNo}/{uniqueToken}")
	@Produces("application/json")
	@Consumes("application/json")
	public Response logConsentOveride(@PathParam("demographicNo") Integer demographicNo,@PathParam("uniqueToken") String uniqueToken,JSONObject message) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		
		OmdGateway omdGateway = new OmdGateway();
		omdGateway.logDataReceived(loggedInInfo, "PCOI", "CALLBACK MESSAGE", message.toString(),demographicNo,uniqueToken);
		
		return Response.ok(true).build();
	}
	
	
	@POST
	@Path("/logConsentOverrideCancelRefuse/{demographicNo}")
	@Produces("application/json")
	@Consumes("application/json")
	public Response logConsentOverrideCancelRefuse(@PathParam("demographicNo") Integer demographicNo,JSONObject message) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();

		String type   = message.optString("type");
		String reason = message.optString("reason");
		
		if("CANCEL".equalsIgnoreCase(type)) {
			LogAction.addLog(loggedInInfo, "CANCEL", "DHDR-PCOI", null, ""+demographicNo,reason);//String contentId, String demographicNo, String data)
			return Response.ok(true).build();
		}else if("REFUSED".equalsIgnoreCase(type)) {
			LogAction.addLog(loggedInInfo, "REFUSED", "DHDR-PCOI", null, ""+demographicNo,reason);//String contentId, String demographicNo, String data)
			return Response.ok(true).build();
		}

		return Response.ok(false).build();
	}
	
	
	@GET
	@Path("/muteDisclaimer/{disclaimerType}")
	@Produces("application/json")
	public Response muteDisclaimer(@PathParam("disclaimerType") String disclaimerType) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		if("DHDR".equals(disclaimerType )) {
			loggedInInfo.getSession().setAttribute("MUTE.gateway.DHDR", Boolean.TRUE);
			LogAction.addLog(loggedInInfo, "HIDE", "DHDR Disclaimer", null, null,null);//String contentId, String demographicNo, String data)
			return Response.ok("{\"DHDR\":\"false\"}").build();
		}
		return Response.noContent().build();
	}
	
	@GET
	@Path("/showDisclaimer/{disclaimerType}")
	@Produces("application/json")
	public Response showDisclaimer(@PathParam("disclaimerType") String disclaimerType) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		if("DHDR".equals(disclaimerType )) {
			if( loggedInInfo.getSession().getAttribute("MUTE.gateway.DHDR") != null) {
				return Response.status(268).entity("{\"DHDR\":\"true\"}").build();
			}
		}
		return Response.ok("{\"DHDR\":\"false\"}").build();
	}
	
	
	@GET
	@Path("/openClinicalConnect/{demographicNo}")
	public Response openClinicalConnect(@Context HttpServletRequest request,@Context HttpServletResponse response,@PathParam("demographicNo") Integer demographicNo) throws IOException{
		
		
		String redirectUrl = request.getContextPath()+"/common/ClinicalConnectCMS11Redirect.jsp?demographicNo="+demographicNo;
		response.sendRedirect(request.getContextPath() + "/eho/login2.jsp?alreadyLoggedIn=true&forwardURL=" + URLEncoder.encode(redirectUrl,"UTF-8") );
		return Response.status(Status.ACCEPTED).build();
	}
	
	@GET
	@Path("/getTokenExpireTime")
	@Produces("application/json")
	public Response getTokenExpireTime(@Context HttpServletRequest request) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		if(loggedInInfo.getOneIdGatewayData() != null) {
			
			List<TokenExpireTo> list = new ArrayList<TokenExpireTo>();
			list.add(new TokenExpireTo("ACCESS",loggedInInfo.getOneIdGatewayData().getAccessTokenExpireDate()));
			list.add(new TokenExpireTo("REFRESH",loggedInInfo.getOneIdGatewayData().getRefreshTokenExpireDate()));
			
			return Response.ok().entity(list).build();
		}
		return Response.noContent().build();
	}
	
	@GET
	@Path("/getGatewayLogs")
	@Produces("application/json")
	public Response getGatewayLogs(@Context HttpServletRequest request) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		if(loggedInInfo.getOneIdGatewayData() != null) {
			List<OMDGatewayTransactionLog> list = omdGatewayTransactionLogDao.findByUniqueSessionId(loggedInInfo.getOneIdGatewayData().getUniqueSessionId());
			
			for(OMDGatewayTransactionLog item: list) {
				if(item.getDataRecieved() != null) {
					try {
						JSONObject json =  JSONObject.fromObject(item.getDataRecieved());
						
						logger.debug("getGAtelogs :"+item.getDataRecieved()+" >> "+json.toString());
						item.setDataRecieved(json.toString());
						//item.setDataRecieved(item.getDataRecieved().replace("\"", """"));
					}catch(Exception e) {
						// no problem just not a json object 
					}
					
					
				}
			}
			
			
			
			return Response.ok().entity(list).build();
		}
		return Response.noContent().build();
	}
	
	@GET
	@Path("/getPreviousGatewayLogs")
	@Produces("application/json")
	public Response getGatewayLogsByProvider(@Context HttpServletRequest request) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		
		List<OMDGatewayTransactionLog> list = omdGatewayTransactionLogDao.findByProviderNo(loggedInInfo.getLoggedInProviderNo());
		return Response.ok().entity(list).build();
	}
	
	
	@GET
	@Path("/getGatewayLogs/{providerNo}")
	@Produces("application/json")
	public Response getGatewayLogsByProvider(@Context HttpServletRequest request,@PathParam("providerNo") String providerNo) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		//NEED TO CHECK CREDS WHO CAN DO THIS?
		List<OMDGatewayTransactionLog> list = omdGatewayTransactionLogDao.findByProviderNo(providerNo);
		
		for(OMDGatewayTransactionLog item: list) {
			if(item.getDataRecieved() != null) {
				logger.debug("getGAtelogs :"+item.getDataRecieved()+" >> "+item.getDataRecieved().replace("\n", ""));
				item.setDataRecieved(item.getDataRecieved().replace("\n", ""));
			}
		}
		
		return Response.ok().entity(list).build();
	}
	
	@GET
	@Path("/getGatewayLogsByExternalSystem/{systemType}")
	@Produces("application/json")
	public Response getGatewayLogsByExternalSystem(@Context HttpServletRequest request,@PathParam("systemType") String systemType) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		//NEED TO CHECK CREDS WHO CAN DO THIS?
		List<OMDGatewayTransactionLog> list = omdGatewayTransactionLogDao.findByExternalSystem(systemType);
		
		for(OMDGatewayTransactionLog item: list) {
			if(item.getDataRecieved() != null) {
				logger.debug("getGAtelogs :"+item.getDataRecieved()+" >> "+item.getDataRecieved().replace("\n", ""));
				item.setDataRecieved(item.getDataRecieved().replace("\n", ""));
			}
		}
		
		return Response.ok().entity(list).build();
	}
	
	
	@GET
	@Path("/getAllGatewayLogs")
	@Produces("application/json")
	public Response getAllGatewayLogs(@Context HttpServletRequest request) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		//NEED TO CHECK CREDS WHO CAN DO THIS?
		List<OMDGatewayTransactionLog> list = omdGatewayTransactionLogDao.getAll();
		return Response.ok().entity(list).build();
	}
	
	
	@POST
	@Path("/createUAO/{providerNo}")
	@Produces("application/json")
	@Consumes("application/json")
	public Response createUAO(@PathParam("providerNo") String providerNo,JSONObject uaoJson) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		
		String friendlyName = uaoJson.optString("uaoFriendlyName");
		String uoaName = uaoJson.optString("uaoName");
		
		//Validate input;
		
		UAO uao = new UAO();
		uao.setActive(true);
		uao.setAddedBy(loggedInInfo.getLoggedInProviderNo());
		uao.setDefaultUAO(false);//?
		uao.setFriendlyName(friendlyName);
		uao.setName(uoaName);
		uao.setProviderNo(providerNo);
		uaoDao.persist(uao);
		
		LogAction.addLog(loggedInInfo, "add", "uao", ""+uao.getId(), null, "{\"uao\":\""+uao.getName()+"\",\"friendlyName\":\""+uao.getFriendlyName()+"\",\"providerNo\":\""+uao.getProviderNo()+"\"}");
		
		return Response.ok(true).build();
	//}
	//return Response.ok(false).build();
	}
	
	//need method to return list of uao
	@GET
	@Path("/UAO/list/{providerNo}")
	@Produces("application/json")
	@Consumes("application/json")
	public Response listUAO(@PathParam("providerNo") String providerNo ) throws Exception{
		List<UAO> list = uaoDao.findByProvider(providerNo);
		
		List<UAOTo1> returnList = new ArrayList<UAOTo1>();
		
		for(UAO uao :list) {
			UAOTo1 UAOTo = new UAOTo1();
			UAOTo.setAddedBy(uao.getAddedBy());
			UAOTo.setDefaultUAO(uao.getDefaultUAO());
			UAOTo.setFriendlyName(uao.getFriendlyName());
			UAOTo.setId(uao.getId());
			UAOTo.setName(uao.getName());
			UAOTo.setProviderNo(uao.getProviderNo());
			returnList.add(UAOTo);
		}
			
		return Response.ok(returnList).build();
	}
			
	
	@POST
	@Path("/archiveUAO/{providerNo}/{id}")
	@Produces("application/json")
	@Consumes("application/json")
	public Response archiveUAO(@PathParam("providerNo") String providerNo,@PathParam("id") Integer id,JSONObject uaoJson) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		
		UAO uao = uaoDao.find(id);
		if(uao != null && uao.getProviderNo().equals(providerNo)) {
			uao.setActive(false);
			uao.setDateUpdated(new Date());
			uaoDao.merge(uao);
			LogAction.addLog(loggedInInfo, "archive", "uao", ""+uao.getId(), null, "{\"uao\":\""+uao.getName()+"\",\"friendlyName\":\""+uao.getFriendlyName()+"\",\"providerNo\":\""+uao.getProviderNo()+"\"}");
			return Response.ok(true).build();
		}
		return Response.ok(false).build();
	}
	
	
	@POST
	@Path("/{demographicNo}/print/{view}")
	@Produces("application/pdf")
    @Consumes(MediaType.APPLICATION_JSON)
	public StreamingOutput print(@PathParam("demographicNo") Integer demographicNo,@PathParam("view") String view,JSONObject jsonOb){
    	
		final Integer demo = demographicNo;
		final LoggedInInfo loggedInInfo = getLoggedInInfo();
		final JSONObject jsonObject = jsonOb;
		final String printViewType = view;
		
		logger.debug("debug "+jsonOb);
		
		return new StreamingOutput() {
			@Override
			public void write(java.io.OutputStream os) throws IOException, WebApplicationException {
				try {
					DHDRPrint dhdrPrint = new DHDRPrint();
					if("summary".equals(printViewType)) {
						dhdrPrint.printSummary(loggedInInfo, demo, os,jsonObject);
					}else if("detail".equals(printViewType)) {
						dhdrPrint.printDetail(loggedInInfo, demo, os,jsonObject);
					}else if("comparative".equals(printViewType)) {
						dhdrPrint.printComparative(loggedInInfo, demo, os,jsonObject);
					}
				}catch(Exception e){
	        			logger.error("error streaming",e);
				}finally{
					IOUtils.closeQuietly(os);
				}
				
			}
		};
	}
	
	
	
	
	//need method to chnage defualt uao
	/*@POST
	@Path("/setDefaultUAO/{providerNo}/{id}")
	@Produces("application/json")
	@Consumes("application/json")
	public Response setDefaultUAO(@PathParam("providerNo") String providerNo,@PathParam("id") Integer id,JSONObject uaoJson) throws Exception{
		LoggedInInfo loggedInInfo = getLoggedInInfo();
		
		UAO uao = uaoDao.find(id);
		if(uao != null && uao.getProviderNo().equals(providerNo)) {
			uao.setDefault(false);
			uao.setDateUpdated(new Date());
			uaoDao.merge(uao);
			return Response.ok(true).build();
		}
		return Response.ok(false).build();
	}
	*/
	

	
}
