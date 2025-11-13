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


package org.oscarehr.common.model;

import java.util.Comparator;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.PrePersist;
import javax.persistence.PreRemove;
import javax.persistence.PreUpdate;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;

@Entity
public class DemographicContact extends AbstractModel<Integer> {

	//link to the provider table
	public static final int TYPE_PROVIDER = 0;
	//link to the demographic table
	public static final int TYPE_DEMOGRAPHIC = 1;
	//link to the contact table
	public static final int TYPE_CONTACT = 2;
	//link to the professional specialists table
	public static final int TYPE_PROFESSIONALSPECIALIST = 3;

	public static final String CATEGORY_PERSONAL = "personal";
	public static final String CATEGORY_PROFESSIONAL = "professional";

	public static final String ROLE_GUARDIAN = "Guardian";
	
    public static final String CONTACT_CELL = "cell";
    public static final String CONTACT_EMAIL = "email";
    public static final String CONTACT_PHONE = "phone";
    public static final String CONTACT_WORK = "work";

	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Integer id;
	@Temporal(TemporalType.TIMESTAMP)
	private Date created;
	@Temporal(TemporalType.TIMESTAMP)
	private Date updateDate;
	private boolean deleted = false;
	private int demographicNo;
	private String contactId;
	private String role;
	private int type;
	private String category;
	private String sdm;
	private String ec;
	private String note;

	private int facilityId;
	private String creator;

	private Boolean consentToContact = true;

    @Column(name = "best_contact")
    private String bestContact = "";

	@Column(name = "health_care_team")
	private Boolean healthCareTeam = false;
	
	private Boolean active = true;

	@Transient
	private String contactName;
	@Transient
	private Contact details;

	public DemographicContact() {
	}

	public DemographicContact(int demographicNo, String contactId, String role, int type, String category, String sdm, String ec, String note, int facilityId, String creator, Boolean consentToContact, String bestContact, Boolean healthCareTeam, Boolean active) {
		this.demographicNo = demographicNo;
		this.contactId = contactId;
		this.role = role;
		this.type = type;
		this.category = category;
		this.sdm = sdm;
		this.ec = ec;
		this.note = note;
		this.facilityId = facilityId;
		this.creator = creator;
		this.consentToContact = consentToContact;
		this.bestContact = bestContact;
		this.healthCareTeam = healthCareTeam;
		this.active = active;
	}

	@Override
	public Integer getId() {
		return this.id;
	}

	public Date getCreated() {
		return created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	public boolean isDeleted() {
		return deleted;
	}

	public void setDeleted(boolean deleted) {
		this.deleted = deleted;
	}

	public int getDemographicNo() {
		return demographicNo;
	}

	public void setDemographicNo(int demographicNo) {
		this.demographicNo = demographicNo;
	}

	public String getContactId() {
		return contactId;
	}

	public void setContactId(String contactId) {
		this.contactId = contactId;
	}


	public Date getUpdateDate() {
		return updateDate;
	}

	public void setUpdateDate(Date updateDate) {
		this.updateDate = updateDate;
	}


	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getCategory() {
    	return category;
    }

	public void setCategory(String category) {
    	this.category = category;
    }

	public String getContactName() {
    	return contactName;
    }

	public void setContactName(String contactName) {
    	this.contactName = contactName;
    }

	public String getSdm() {
    	return sdm;
    }

	public void setSdm(String sdm) {
    	this.sdm = sdm;
    }

	public String getEc() {
    	return ec;
    }

	public void setEc(String ec) {
    	this.ec = ec;
    }

	public String getNote() {
    	return note;
    }

	public void setNote(String note) {
    	this.note = note;
    }



	public int getFacilityId() {
    	return facilityId;
    }

	public void setFacilityId(int facilityId) {
    	this.facilityId = facilityId;
    }

	public String getCreator() {
    	return creator;
    }

	public void setCreator(String creator) {
    	this.creator = creator;
    }

	@PreRemove
	protected void jpa_preventDelete() {
		throw (new UnsupportedOperationException("Remove is not allowed for this type of item."));
	}

	@PrePersist
	@PreUpdate
	protected void jpa_updateTimestamp() {
		this.setUpdateDate(new Date());
	}

	public boolean isConsentToContact() {
		return consentToContact;
	}

	public void setConsentToContact(boolean consentToContact) {
		this.consentToContact = consentToContact;
	}

	public String getBestContact() {
		return bestContact;
	}

	public void setBestContact(String bestContact) {
		this.bestContact = bestContact;
	}

	public Boolean getHealthCareTeam() {
		return healthCareTeam;
	}
	public void setHealthCareTeam(Boolean healthCareTeam) {
		this.healthCareTeam = healthCareTeam;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

	public Contact getDetails() {
	    return details;
    }

	public void setDetails(Contact details) {
	    this.details = details;
    }

	public static final Comparator<DemographicContact> CategoryComparator = new Comparator<DemographicContact>() {
		@Override
		public int compare(DemographicContact dc1, DemographicContact dc2) {
			String category = dc1.getCategory() != null ? dc1.getCategory() : "";
			String category2 = dc2.getCategory() != null ? dc2.getCategory() : "";
			return category.compareToIgnoreCase(category2);
		}
	};

	public static final Comparator<DemographicContact> NameComparator = new Comparator<DemographicContact>() {
		@Override
		public int compare(DemographicContact dc1, DemographicContact dc2) {
			String name = dc1.getContactName() != null ? dc1.getContactName() : "";
			String name2 = dc2.getContactName() != null ? dc2.getContactName() : "";
			return name.compareToIgnoreCase(name2);
		}
	};

	public static final Comparator<DemographicContact> RoleComparator = new Comparator<DemographicContact>() {
		@Override
		public int compare(DemographicContact dc1, DemographicContact dc2) {
			String role = dc1.getRole() != null ? dc1.getRole() : "";
			String role2 = dc2.getRole() != null ? dc2.getRole() : "";
			return role.compareToIgnoreCase(role2);
		}
	};
}
