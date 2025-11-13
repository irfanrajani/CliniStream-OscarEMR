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

import java.io.Reader;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.logging.log4j.Logger;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.oscarehr.util.MiscUtils;
import org.hl7.fhir.r4.model.Immunization;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.ResourceType;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.parser.DataFormatException;

public class SearchResultsHandler {
	
	FhirContext ctx = FhirContext.forR4();
	
	private static Logger logger = MiscUtils.getLogger();
	
	Bundle bundle = null;
	
	Map<String, Resource> allResources = new HashMap<String, Resource>();
	Map<String, Immunization> immunizationResources = new HashMap<String, Immunization>();
	
	public Date getTimestamp() {
		return bundle.getTimestamp();
	}
	
	public String getId() {
		return bundle.getId();
	}
	
	public String getResourceAsString(Resource resource) {
		return ctx.newJsonParser().setPrettyPrint(true).encodeResourceToString( resource );
	}
	
	public SearchResultsHandler(Reader reader) throws DataFormatException  {
		bundle = ctx.newJsonParser().parseResource(Bundle.class, reader);
		 
		for(BundleEntryComponent comp : bundle.getEntry()) {
			Resource resource = comp.getResource();
			logger.debug("bundle resource: "+resource.getResourceType());
			
			if(resource.getResourceType() == ResourceType.Immunization) {
				immunizationResources.put(resource.getId(),(Immunization)resource);
			}
			allResources.put(resource.getIdElement().getIdPart(),resource);
		}
	}
	
	public SearchResultsHandler(Bundle bundle) throws DataFormatException  {
		this.bundle = bundle;
		 
		for(BundleEntryComponent comp : bundle.getEntry()) {
			Resource resource = comp.getResource();
			logger.debug("bundle resource: "+resource.getResourceType());
			if(resource.getResourceType() == ResourceType.Immunization) {
				immunizationResources.put(resource.getId(),(Immunization)resource);
			}
			allResources.put(resource.getIdElement().getIdPart(),resource);
		}
	}
	
	public List<Immunization> getImmunizationResources() {
		List<Immunization> imms = new ArrayList<Immunization>();
		for(Immunization resource : immunizationResources.values()) {
			imms.add(resource);
		}
		
		return imms;
	}
	
	public Map<String,Resource> getAllResources() {
		return allResources;
	}
}
