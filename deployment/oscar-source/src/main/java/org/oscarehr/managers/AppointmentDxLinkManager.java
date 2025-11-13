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

package org.oscarehr.managers;

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.dao.AppointmentDxLinkDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.dao.DxresearchDAO;
import org.oscarehr.common.model.AppDefinition;
import org.oscarehr.common.model.AppointmentDxLink;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import oscar.log.LogAction;

@Service
public class AppointmentDxLinkManager {
	protected Logger logger = MiscUtils.getLogger();
	 
		@Autowired
		AppointmentDxLinkDao appointmentDxLinkDao;
		
		@Autowired
		DxresearchDAO dxresearchDAO; 
		
		@Autowired
		private SecurityInfoManager securityInfoManager;
		
		@Autowired
		private DemographicDao demographicDao;
		
		public List<AppointmentDxLink> getAppointmentDxLinkForDemographic(LoggedInInfo loggedInInfo,int demographicNo) {
			Demographic demographic = demographicDao.getDemographicById(demographicNo);
			List<AppointmentDxLink> list = appointmentDxLinkDao.getActiveDxLink(demographic) ;
			List<AppointmentDxLink> returnList = new ArrayList<AppointmentDxLink>();
			if(list.size() > 0) {
				for(AppointmentDxLink appointmentDxLink : list) {
					if(dxresearchDAO.activeEntryExists(demographicNo, appointmentDxLink.getCodeType(), appointmentDxLink.getCode())) {
						returnList.add(appointmentDxLink);
					}
				}
			}
			return returnList;
		}
	
		public AppointmentDxLink disableAppointmentDxLink(LoggedInInfo loggedInInfo,Integer id) {
			if (!securityInfoManager.hasPrivilege(loggedInInfo, "_admin", "w", null)) {
				throw new RuntimeException("Access Denied");
			}
			AppointmentDxLink appointmentDxLink = appointmentDxLinkDao.find(id);
			appointmentDxLink.setActive(false);
			appointmentDxLinkDao.merge(appointmentDxLink);
			LogAction.addLogSynchronous(loggedInInfo, "AppointmentDxLink.disableAppointmentDxLink", "disabled id =" + id);
			return appointmentDxLink;
		}
	
		public AppointmentDxLink addAppointmentDxLink(LoggedInInfo loggedInInfo, AppointmentDxLink appointmentDxLink) {
			if (!securityInfoManager.hasPrivilege(loggedInInfo, "_admin", "w", null)) {
				throw new RuntimeException("Access Denied");
			}
			appointmentDxLinkDao.persist(appointmentDxLink);
			if (appointmentDxLink!=null) {
				LogAction.addLogSynchronous(loggedInInfo, "AppointmentDxLink.addAppointmentDxLink", "id=" + appointmentDxLink.getId());
			}
			return appointmentDxLink;
		}

		public List<AppointmentDxLink> getAllAppointmentDxLinks(LoggedInInfo loggedInInfo) {
			List<AppointmentDxLink> list = appointmentDxLinkDao.findAll(0, 200);
			String resultIds = "none";
			if(list != null && !list.isEmpty()) {
				resultIds=AppDefinition.getIdsAsStringList(list);
			}
			LogAction.addLogSynchronous(loggedInInfo, "AppointmentDxLink.getAllAppointmentDxLinks", "id=" + resultIds);
			return list;
		}

	
}
