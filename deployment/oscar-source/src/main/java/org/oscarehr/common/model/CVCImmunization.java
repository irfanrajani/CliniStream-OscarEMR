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

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;

@Entity
public class CVCImmunization extends AbstractModel<Integer> {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Integer id;
	private int versionId;

	private String snomedConceptId;
	private Boolean generic;

	@OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "cvcImmunizationId")
	private List<CVCImmunizationName> names = new ArrayList<CVCImmunizationName>();

	/* for tradename ones*/
	Integer prevalence;
	String parentConceptId;
	boolean ispa;

	private String typicalDose;
	private String typicalDoseUofM;
	private String strength;
	private String route;
	private String shelfStatus;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getSnomedConceptId() {
		return snomedConceptId;
	}

	public void setSnomedConceptId(String snomedConceptId) {
		this.snomedConceptId = snomedConceptId;
	}

	public String getDisplayName() {
		for (CVCImmunizationName name : getNames()) { //Changing this from Fully Specified Name to 900000000000003001 because "Fully Specified Name" is the useDisplay column value not code
			if ("en".equals(name.getLanguage()) && "900000000000003001".equals(name.getUseCode())) {
				return name.getValue();
			}
		}
		return null;
	}

	public String getPicklistName() {
		for (CVCImmunizationName name : getNames()) {
			if ("en".equals(name.getLanguage()) && "enClinicianPicklistTerm".equals(name.getUseCode())) {
				return name.getValue();
			}
		}
		return null;
	}

	public int getVersionId() {
		return versionId;
	}

	public void setVersionId(int versionId) {
		this.versionId = versionId;
	}

	public boolean isGeneric() {
		return generic;
	}

	public void setGeneric(boolean generic) {
		this.generic = generic;
	}

	public Integer getPrevalence() {
		return prevalence;
	}

	public void setPrevalence(Integer prevalence) {
		this.prevalence = prevalence;
	}

	public String getParentConceptId() {
		return parentConceptId;
	}

	public void setParentConceptId(String parentConceptId) {
		this.parentConceptId = parentConceptId;
	}

	public boolean isIspa() {
		return ispa;
	}

	public void setIspa(boolean ispa) {
		this.ispa = ispa;
	}

	public Boolean getGeneric() {
		return generic;
	}

	public void setGeneric(Boolean generic) {
		this.generic = generic;
	}

	public List<CVCImmunizationName> getNames() {
		return names;
	}

	public void setNames(List<CVCImmunizationName> names) {
		this.names = names;
	}

	public String getTypicalDose() {
		return typicalDose;
	}

	public void setTypicalDose(String typicalDose) {
		this.typicalDose = typicalDose;
	}

	public String getTypicalDoseUofM() {
		return typicalDoseUofM;
	}

	public void setTypicalDoseUofM(String typicalDoseUofM) {
		this.typicalDoseUofM = typicalDoseUofM;
	}

	public String getStrength() {
		return strength;
	}

	public void setStrength(String strength) {
		this.strength = strength;
	}
	
	public String getRoute() {
		return route;
	}

	public void setRoute(String route) {
		this.route = route;
	}

	public String getShelfStatus() {
		return shelfStatus;
	}

	public void setShelfStatus(String shelfStatus) {
		this.shelfStatus = shelfStatus;
	}

}
