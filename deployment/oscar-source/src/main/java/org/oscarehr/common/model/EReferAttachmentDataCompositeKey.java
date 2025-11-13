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
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import java.io.Serializable;
import java.util.Objects;

public class EReferAttachmentDataCompositeKey implements Serializable {
	@ManyToOne
	@JoinColumn(name = "erefer_attachment_id", referencedColumnName = "id")
	private EReferAttachment eReferAttachment;
	@Column(name = "lab_id")
	private Integer labId;
	@Column(name = "lab_type")
	private String labType;

	public EReferAttachmentDataCompositeKey() {
	}

	public EReferAttachmentDataCompositeKey(EReferAttachment eReferAttachment, Integer labId, String labType) {
		this.eReferAttachment = eReferAttachment;
		this.labId = labId;
		this.labType = labType;
	}

	public EReferAttachment getEReferAttachment() {
		return eReferAttachment;
	}
	public void setEReferAttachment(EReferAttachment eReferAttachment) {
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

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		EReferAttachmentDataCompositeKey that = (EReferAttachmentDataCompositeKey) o;
		return eReferAttachment.equals(that.eReferAttachment) &&
				labId.equals(that.labId) &&
				labType.equals(that.labType);		
	}

	@Override
	public int hashCode() {
		return Objects.hash(eReferAttachment, labId, labType);
	}
}
