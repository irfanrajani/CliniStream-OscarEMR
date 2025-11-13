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

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "erefer_attachment")
public class EReferAttachment extends AbstractModel<Integer> {
	@Id
	@GeneratedValue
	@Column(name = "id")
	private Integer id;
	@Column(name = "demographic_no")
	private Integer demographicNo;
	@Column(name = "created")
	private Date created;
	@Column(name = "archived")
	private boolean archived = false;

	@OneToMany(cascade = CascadeType.PERSIST)
	@JoinColumn(name = "erefer_attachment_id", referencedColumnName = "id")
	private List<EReferAttachmentData> attachments;


	public EReferAttachment() {
	}

	public EReferAttachment(Integer demographicNo) {
		this.demographicNo = demographicNo;
		this.created = new Date();
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getDemographicNo() {
		return demographicNo;
	}
	public void setDemographicNo(Integer demographicNo) {
		this.demographicNo = demographicNo;
	}

	public Date getCreated() {
		return created;
	}
	public void setCreated(Date created) {
		this.created = created;
	}

	public boolean isArchived() {
		return archived;
	}
	public void setArchived(boolean archived) {
		this.archived = archived;
	}

	public List<EReferAttachmentData> getAttachments() {
		return attachments;
	}
	public void setAttachments(List<EReferAttachmentData> attachments) {
		this.attachments = attachments;
	}
}
