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
package org.oscarehr.research.eaaps;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.DxresearchDAO;

import org.oscarehr.common.dao.OscarAppointmentDao;
import org.oscarehr.common.dao.ScheduleDateDao;
import org.oscarehr.common.jobs.OscarRunnable;
import org.oscarehr.common.model.Appointment;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.Security;
import org.oscarehr.managers.SecurityInfoManager;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;


public class EAMSFindAsthmaAppts implements OscarRunnable {
	private static Logger logger = MiscUtils.getLogger();
	private Provider provider = null;
	 
	
	
	/*
	 -Find appointments for the next 7 days.
	 -Filter out appts for patients the are not >15 and that do not have asthma in the dx Reg
	 -Filter out appts for providers without the specified role.
	 
	 */
	@Override
	public void run() {
		MiscUtils.getLogger().info("Starting EAMSFindAsthmaAppts Job");
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		Calendar now = Calendar.getInstance();
		Calendar sevenDays = Calendar.getInstance();	
		MiscUtils.getLogger().info("DATE " + sevenDays.getTime());
		sevenDays.add(Calendar.DATE, 8);	
		sevenDays.set(Calendar.HOUR_OF_DAY, 0);
		sevenDays.set(Calendar.MINUTE, 0);
		sevenDays.set(Calendar.SECOND, 0);
		sevenDays.set(Calendar.MILLISECOND, 0);
		logger.info("DATE Now: " +dateFormat.format(now.getTime())+" seven days: " + dateFormat.format(sevenDays.getTime()));
		
		DemographicDao demographicDao = SpringUtils.getBean(DemographicDao.class);	
		OscarAppointmentDao appointmentDao = SpringUtils.getBean(OscarAppointmentDao.class);
			ScheduleDateDao scheduleDateDao = SpringUtils.getBean(ScheduleDateDao.class);
			DxresearchDAO dxresearchDAO = SpringUtils.getBean(DxresearchDAO.class);
			SecurityInfoManager securityInfoManager = SpringUtils.getBean(SecurityInfoManager.class);
			
		List<Appointment> results = appointmentDao.findByDateRange(now.getTime(), sevenDays.getTime());
		logger.info("FOUND " + results.size() + " appointments");			
		
		
		JSONArray jsonArray = new JSONArray();
		
		for( Appointment appointment  : results ) {
			logger.debug("appoint"+appointment.getId()+" demo "+appointment.getDemographicNo());
			if( appointment.getStatus().matches(".*C.*") || appointment.getDemographicNo() ==0 ) {
				logger.info("Skipping appointment as it is canceled");
			}else {
				//Does this patient have asthma and over 16?
						
						Demographic demographic = demographicDao.getDemographicById(appointment.getDemographicNo());
						if(demographic.getAgeInYears() > 15 && dxresearchDAO.activeEntryExists(demographic.getDemographicNo(), "icd9", "493") && demographic.getHin() != null && !demographic.getHin().trim().isEmpty()) {
							////////
							LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoAsCurrentClassAndMethod();
							Provider provider = new Provider();
					        provider.setProviderNo(appointment.getProviderNo());
					        loggedInInfo.setLoggedInProvider(provider);
							if(securityInfoManager.hasPrivilege(loggedInInfo, "_newCasemgmt.eaaps", "r", demographic.getDemographicNo())){
								EaapsHash hash = new EaapsHash(demographic);
								JSONObject jsonObject = new JSONObject();
								jsonObject.element("hash", hash.getHash());
								jsonObject.element("apptDate", dateFormat.format(appointment.getAppointmentDate()));
								
								jsonArray.add(jsonObject);
							}
						}
						logger.debug("demo "+demographic);
			}
		}
		JSONObject jsonObject = new JSONObject();
		jsonObject.element("dateCollected", dateFormat.format(now.getTime()));
		jsonObject.element("appointments", jsonArray);
		
		EaapsServiceClient eaapsServiceClient = new EaapsServiceClient(); 
		try {
			eaapsServiceClient.postHash(jsonObject);
		}catch(Exception e) {
			logger.error("error posting hashes",e);
		}
			
	}
		
	@Override
	public void setLoggedInProvider(Provider provider) {
		this.provider = provider;

	}

	@Override
	public void setLoggedInSecurity(Security security) {
		// TODO Auto-generated method stub

	}
	
	@Override
	public void setConfig(String string) {
	}

}
