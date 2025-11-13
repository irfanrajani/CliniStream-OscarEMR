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

import org.oscarehr.common.model.Measurement;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.ws.rest.to.model.MeasurementTo1;

public class MeasurementConverter extends AbstractConverter<Measurement, MeasurementTo1> {

    @Override
    public Measurement getAsDomainObject(LoggedInInfo loggedInInfo, MeasurementTo1 t) throws ConversionException {
        Measurement d = new Measurement();
        //Sets the properties
        d.setId(t.getId());
        d.setType(t.getType());
        d.setDemographicId(t.getDemographicId());
        d.setProviderNo(t.getProviderNo());
        d.setDataField(t.getDataField());
        d.setMeasuringInstruction(t.getMeasuringInstruction());
        d.setComments(t.getComments());
        d.setDateObserved(t.getDateObserved());
        d.setAppointmentNo(t.getAppointmentNo());
        d.setCreateDate(t.getCreateDate());
        return d;
    }

    @Override
    public MeasurementTo1 getAsTransferObject(LoggedInInfo loggedInInfo, Measurement d) throws ConversionException {
        MeasurementTo1 t = new MeasurementTo1();

        t.setId(d.getId());
        t.setType(d.getType());
        t.setDemographicId(d.getDemographicId());
        t.setProviderNo(d.getProviderNo());
        t.setDataField(d.getDataField());
        t.setMeasuringInstruction(d.getMeasuringInstruction());
        t.setComments(d.getComments());
        t.setDateObserved(d.getDateObserved());
        t.setAppointmentNo(d.getAppointmentNo());
        t.setCreateDate(d.getCreateDate());

        return t;
    }
}