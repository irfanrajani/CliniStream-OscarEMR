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
package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@IdClass(EReferAttachmentDataCompositeKey.class)
@Table(name = "erefer_attachment_data")
public class EReferAttachmentData extends AbstractModel<EReferAttachmentDataCompositeKey>{
	
	@Id
	@ManyToOne
	@JoinColumn(name = "erefer_attachment_id", referencedColumnName = "id")
	private EReferAttachment eReferAttachment;
	
	@Id
	@Column(name = "lab_id")
	private Integer labId;
	
	@Id
	@Column(name = "lab_type")
	private String labType;

	public EReferAttachmentData() {
	}

	public EReferAttachmentData(EReferAttachment eReferAttachment, Integer labId, String labType) {
		this.eReferAttachment = eReferAttachment;
		this.labId = labId;
		this.labType = labType;
	}

	public EReferAttachmentDataCompositeKey getId() {
		return new EReferAttachmentDataCompositeKey(eReferAttachment, labId, labType);
	}
	
	public EReferAttachment geteReferAttachment() {
		return eReferAttachment;
	}
	public void seteReferAttachment(EReferAttachment eReferAttachment) {
		this.eReferAttachment = eReferAttachment;
	}

	public Integer getLabId() {
		return labId;
	}
	public void setLabId(Integer labId) {
		this.labId = labId;
	}

	public String getLabType() {
		return labType;
	}
	public void setLabType(String labType) {
		this.labType = labType;
	}
}
