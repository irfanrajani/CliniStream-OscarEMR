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
package org.oscarehr.integration.dhir;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.ImmunizationRecommendation;
import org.hl7.fhir.r4.model.ImmunizationRecommendation.ImmunizationRecommendationRecommendationComponent;
import org.hl7.fhir.r4.model.ImmunizationRecommendation.ImmunizationRecommendationRecommendationDateCriterionComponent;

public class ImmunizationRecommendationsHandler {
	
	private List<org.oscarehr.integration.dhir.ImmunizationRecommendation> recs = new ArrayList<org.oscarehr.integration.dhir.ImmunizationRecommendation>();
	private Date date;
	
	
	public List<org.oscarehr.integration.dhir.ImmunizationRecommendation> getDueRecommendations() {
		List<org.oscarehr.integration.dhir.ImmunizationRecommendation> result = new ArrayList<org.oscarehr.integration.dhir.ImmunizationRecommendation>();
		for(org.oscarehr.integration.dhir.ImmunizationRecommendation rec : recs) {
			if("due".equals(rec.getForecastStatus().getCode())) {
				result.add(rec);
			}
		}
		return result;
	}
	
	public List<org.oscarehr.integration.dhir.ImmunizationRecommendation> getOverdueRecommendations() {
		List<org.oscarehr.integration.dhir.ImmunizationRecommendation> result = new ArrayList<org.oscarehr.integration.dhir.ImmunizationRecommendation>();
		for(org.oscarehr.integration.dhir.ImmunizationRecommendation rec : recs) {
			if("overdue".equals(rec.getForecastStatus().getCode())) {
				result.add(rec);
			}
		}
		return result;
	}

	public ImmunizationRecommendationsHandler(ImmunizationRecommendation immunizationRecomendation) {
		
		date = immunizationRecomendation.getDate();
		for(ImmunizationRecommendationRecommendationComponent comp : immunizationRecomendation.getRecommendation()) {
			
			org.oscarehr.integration.dhir.ImmunizationRecommendation rec = new org.oscarehr.integration.dhir.ImmunizationRecommendation();
			
			if(comp.getVaccineCode() != null) {
				for(CodeableConcept cc : comp.getVaccineCode()) {
					for(Coding coding : cc.getCoding()) {
					//	VaccineCode vc = new VaccineCode(coding.getSystem(), coding.getCode(), coding.getDisplay());
						rec.getCodes().add(new org.oscarehr.integration.dhir.Coding(coding.getSystem(), coding.getCode(), coding.getDisplay()));
					}
					
				}
			}
			
			if(comp.getTargetDisease() != null) {
				CodeableConcept cc = comp.getTargetDisease();
				if(cc.getCodingFirstRep() != null) {
					rec.setTargetDisease(cc.getCodingFirstRep().getDisplay());
				}
			}
			
			if(comp.getForecastStatus() != null) {
				CodeableConcept cc  = comp.getForecastStatus();
				if(cc.getCodingFirstRep() != null) {
					for(Coding coding:cc.getCoding()) {
						String code = coding.getCode();
						rec.setForecastStatus(new org.oscarehr.integration.dhir.Coding(coding.getSystem(),coding.getCode(),coding.getDisplay()));

					}
				}
			}
			
			if(comp.getDateCriterionFirstRep() != null) {
				for(ImmunizationRecommendationRecommendationDateCriterionComponent cc : comp.getDateCriterion()) {
					CodeableConcept concept = cc.getCode();
					for(Coding coding : concept.getCoding()) {
						String code = coding.getCode();
						String display = coding.getDisplay();
					}
					Date date = cc.getValue();
					rec.setDate(date);
				}
			}
			recs.add(rec);
		} //end of for loop
	} //end of method

	public List<org.oscarehr.integration.dhir.ImmunizationRecommendation> getRecs() {
		return recs;
	}

	public void setRecs(List<org.oscarehr.integration.dhir.ImmunizationRecommendation> recs) {
		this.recs = recs;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}
	
	
	
}
