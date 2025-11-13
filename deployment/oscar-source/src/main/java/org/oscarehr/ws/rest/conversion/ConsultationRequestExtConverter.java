/**
 * Copyright (c) 2014-2015. KAI Innovations Inc. All Rights Reserved.
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
package org.oscarehr.ws.rest.conversion;

import org.oscarehr.common.model.ConsultationRequestExt;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.ws.rest.to.model.ConsultationRequestExtTo1;

public class ConsultationRequestExtConverter extends AbstractConverter<ConsultationRequestExt, ConsultationRequestExtTo1> {
	@Override
	public ConsultationRequestExt getAsDomainObject(LoggedInInfo loggedInInfo, ConsultationRequestExtTo1 t) throws ConversionException {
		ConsultationRequestExt d = new ConsultationRequestExt();
		
		d.setId(t.getId());
		if (t.getRequestId() != null) {
			d.setRequestId(t.getRequestId());
		}
		d.setKey(t.getKey());
		d.setValue(t.getValue());
		d.setDateCreated(t.getDateCreated());
		
		return d;
	}

	@Override
	public ConsultationRequestExtTo1 getAsTransferObject(LoggedInInfo loggedInInfo, ConsultationRequestExt d) throws ConversionException {
		ConsultationRequestExtTo1 t = new ConsultationRequestExtTo1();
		
		t.setId(d.getId());
		t.setRequestId(d.getRequestId());
		t.setKey(d.getKey());
		t.setValue(d.getValue());
		t.setDateCreated(d.getDateCreated());

		return t;
	}
}
