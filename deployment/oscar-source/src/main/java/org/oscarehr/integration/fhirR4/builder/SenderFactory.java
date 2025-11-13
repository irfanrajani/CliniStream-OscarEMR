package org.oscarehr.integration.fhirR4.builder;
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

import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.integration.fhirR4.manager.OscarFhirConfigurationManager;
import org.oscarehr.integration.fhirR4.model.Sender;
import org.oscarehr.integration.fhirR4.resources.Settings;
// import org.oscarehr.util.SpringUtils;
import org.oscarehr.util.SpringUtils;

import oscar.OscarProperties;


public final class SenderFactory {

	private static String buildName = OscarProperties.getInstance().getProperty("buildtag", "UNKNOWN");
	private static String senderEndpoint = OscarProperties.getInstance().getProperty("ws_endpoint_url_base", "UNKNOWN");
	private static ClinicDAO clinicDao = SpringUtils.getBean( ClinicDAO.class );
	private static String vendorName = "Oscar EMR";
	private static String softwareName = "OSCAR";

	
	public static final Sender getSender() {
		return init(null,null);
	}
	
	public static final Sender getSender( Settings settings ) {
		return init(settings,null);
	}
	
	public static final Sender getSender( Settings settings, OscarFhirConfigurationManager configurationManager ) {
		return init(settings, configurationManager);
	}
	
	private static Sender init( Settings settings, OscarFhirConfigurationManager configurationManager ) {
		Sender sender = null; 
		
		if( settings != null && ! settings.isIncludeSenderEndpoint() ) {
			sender = new Sender( vendorName, softwareName, buildName );			
		} else {
			sender = new Sender( vendorName, softwareName, buildName, senderEndpoint );
		}
		
		if( clinicDao != null ) {
			org.oscarehr.common.model.Clinic clinic = clinicDao.getClinic();
			sender.setClinic( clinic, configurationManager );
		}
		
		return sender;
	}
}
