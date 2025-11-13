package org.oscarehr.ws.rest.to.model;
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
import java.util.Date;

import org.oscarehr.common.model.AppointmentDxLink;


public class AppointmentDxLinkTo1 {

	private Integer id;
	private String providerNo;
	private String code;
	private String codeType;
	private String ageRange;
	private String colour = "000";
	private String message;
	private String symbol;
	private String link;
	private Date createDate;
	private Date updateDate;
	private boolean active;
	
	
	public void fill(AppointmentDxLink appointmentDxLink ) {
		id = appointmentDxLink.getId();
		providerNo = appointmentDxLink.getProviderNo();
		code = appointmentDxLink.getCode();
		setCodeType(appointmentDxLink.getCodeType());
		setAgeRange(appointmentDxLink.getAgeRange());
		colour = appointmentDxLink.getColour();
		message = appointmentDxLink.getMessage();
		symbol = appointmentDxLink.getSymbol();
		link = appointmentDxLink.getLink();
		createDate = appointmentDxLink.getCreateDate();
		updateDate = appointmentDxLink.getUpdateDate();
		active = appointmentDxLink.isActive();
				
	}
	
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getProviderNo() {
		return providerNo;
	}
	public void setProviderNo(String providerNo) {
		this.providerNo = providerNo;
	}

	
	
	
	public Date getCreateDate() {
		return createDate;
	}
	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}
	public Date getUpdateDate() {
		return updateDate;
	}
	public void setUpdateDate(Date updateDate) {
		this.updateDate = updateDate;
	}
	public boolean isActive() {
		return active;
	}
	public void setActive(boolean active) {
		this.active = active;
	}
	public String getLink() {
		return link;
	}
	public void setLink(String link) {
		this.link = link;
	}
	public String getSymbol() {
		return symbol;
	}
	public void setSymbol(String symbol) {
		this.symbol = symbol;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public String getColour() {
		return colour;
	}
	public void setColour(String colour) {
		this.colour = colour;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}


	public String getCodeType() {
		return codeType;
	}


	public void setCodeType(String codeType) {
		this.codeType = codeType;
	}


	public String getAgeRange() {
		return ageRange;
	}


	public void setAgeRange(String ageRange) {
		this.ageRange = ageRange;
	}
	
}
