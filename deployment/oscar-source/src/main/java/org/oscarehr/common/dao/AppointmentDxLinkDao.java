package org.oscarehr.common.dao;
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

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Query;

import org.apache.logging.log4j.Logger;
import org.oscarehr.common.model.AppointmentDxLink;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.MiscUtils;
import org.springframework.stereotype.Repository;


@Repository
public class AppointmentDxLinkDao extends AbstractDao<AppointmentDxLink> {
	protected Logger logger = MiscUtils.getLogger();
	
	public AppointmentDxLinkDao() {
		super(AppointmentDxLink.class);
	}
	
	public List<AppointmentDxLink> getActiveDxLink() {
			
		Query query = entityManager.createQuery("select b from AppointmentDxLink b where b.active = true");
				
		@SuppressWarnings("unchecked")
		List<AppointmentDxLink> list = query.getResultList();
		return list;
	}
	
	
	public List<AppointmentDxLink> filterDxLinkListByDemographic(Demographic demographic,List<AppointmentDxLink> list){
		List<AppointmentDxLink> retList = new ArrayList<AppointmentDxLink>();
		for(AppointmentDxLink apptDxLink : list) {
			if(apptDxLink.getAgeRange() != null && !apptDxLink.getAgeRange().trim().equals("")) {
				boolean demographicIsInRange = false;
				String ageRangeStr = apptDxLink.getAgeRange();
				try {
					if (ageRangeStr.indexOf("-") != -1 && ageRangeStr.indexOf("-") != 0 ){ //between style
			            String[] betweenVals = ageRangeStr.split("-");
			            if (betweenVals.length == 2 ){
			            			
			            		if(demographic.getAgeInYears() >= Integer.parseInt(betweenVals[0]) && demographic.getAgeInYears() <= Integer.parseInt(betweenVals[1])) {
			            			demographicIsInRange = true;
			            		}
			            }
					}else if (ageRangeStr.indexOf("&gt;") != -1 ||  ageRangeStr.indexOf(">") != -1 ){ // greater than style
						ageRangeStr = ageRangeStr.replaceFirst("&gt;","");
						ageRangeStr = ageRangeStr.replaceFirst(">","");
						
						if(demographic.getAgeInYears() > Integer.parseInt(ageRangeStr)) {
							demographicIsInRange = true;
						}
						
			        }else if (ageRangeStr.indexOf("&lt;") != -1  ||  ageRangeStr.indexOf("<") != -1 ){ // less than style
			        		ageRangeStr = ageRangeStr.replaceFirst("&lt;","");
			        		ageRangeStr = ageRangeStr.replaceFirst("<","");
	
			        		if(demographic.getAgeInYears() < Integer.parseInt(ageRangeStr)) {
								demographicIsInRange = true;
						}
			        }
				}catch(Exception e) {
					logger.error("Error calculating dxLink Age",e);
				}     
		        if(demographicIsInRange) {
		        		retList.add(apptDxLink);
		        }
			}else{//if
				//If not ageRange add it for everyone
				retList.add(apptDxLink);
			}
		}//for
		return retList;
	}
	
	public List<AppointmentDxLink> getActiveDxLink(Demographic demographic) {
		
		Query query = entityManager.createQuery("select b from AppointmentDxLink b where b.active = true");
				
		@SuppressWarnings("unchecked")
		List<AppointmentDxLink> list = query.getResultList();
		List<AppointmentDxLink> retList = filterDxLinkListByDemographic(demographic,list);
		
		return retList;
	}
	
}
 