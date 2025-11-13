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

/*
Drug Information
a) Dispense date [MedicationDispense.whenPrepared]
b) Generic name of the dispensed drug [Medication.code.coding[2].display]
c) Brand name of the dispensed drug [Medication.code.coding[1].display]
d) Dispensed drug strength [Medication.extension[1].valueString]
e) Drug dosage form (e.g., tablet, capsule, injection) [Medication.form.text]
f) Dispensed quantity [MedicationDispense.quantity.value] [MedicationDispense.quantity.unit]
g) Estimated days’ supply [MedicationDispense.daysSupply.value]
Prescriber Information
h) Prescriber first and last name [Practitioner.name.given] [Practitioner.name.family]
i) Prescriber phone number [Practitioner.telecom[1].value]
Pharmacy Information
j) Dispensing Pharmacy [Organization.name]
k) Dispensing Pharmacy Fax Number [Organization.telecom[2].value]
The information MUST be displayed exactly as it is received from the DHDR EHR Service.
Note: Dispense Date maps to the FHIR element “whenPrepared”, NOT to “whenHandedOver” (this element indicates the pickup date, rather than the dispense date).
Note: It is possible that the EMR may receive a coded value for Dosage Form. 
 */
public class MedicationDispenseTo1 {

	private Date dispenseDate; // [MedicationDispense.whenPrepared]
	private String genericName; //[Medication.code.coding[2].display]
	private String brandName;//[Medication.code.coding[1].display]
	private String dispensedDrugStrength;// [Medication.extension[1].valueString]
	private String drugDosageForm;// (e.g., tablet, capsule, injection) [Medication.form.text]
	private String dispensedQuantity;// [MedicationDispense.quantity.value] [MedicationDispense.quantity.unit]
	private String estimatedDaysSupply;// [MedicationDispense.daysSupply.value]
	//Prescriber Information
	private String prescriberFirstname;//[Practitioner.name.given] 
	private String prescriberLastname;// [Practitioner.name.family]
	private String prescriberPhoneNumber;// [Practitioner.telecom[1].value]
	//Pharmacy Information
	private String dispensingPharmacy;// [Organization.name]
	private String dispensingPharmacyFaxNumber;// [Organization.telecom[2].value]
	public Date getDispenseDate() {
		return dispenseDate;
	}
	public void setDispenseDate(Date dispenseDate) {
		this.dispenseDate = dispenseDate;
	}
	public String getGenericName() {
		return genericName;
	}
	public void setGenericName(String genericName) {
		this.genericName = genericName;
	}
	public String getBrandName() {
		return brandName;
	}
	public void setBrandName(String brandName) {
		this.brandName = brandName;
	}
	public String getDispensedDrugStrength() {
		return dispensedDrugStrength;
	}
	public void setDispensedDrugStrength(String dispensedDrugStrength) {
		this.dispensedDrugStrength = dispensedDrugStrength;
	}
	public String getDrugDosageForm() {
		return drugDosageForm;
	}
	public void setDrugDosageForm(String drugDosageForm) {
		this.drugDosageForm = drugDosageForm;
	}
	public String getDispensedQuantity() {
		return dispensedQuantity;
	}
	public void setDispensedQuantity(String dispensedQuantity) {
		this.dispensedQuantity = dispensedQuantity;
	}
	public String getEstimatedDaysSupply() {
		return estimatedDaysSupply;
	}
	public void setEstimatedDaysSupply(String estimatedDaysSupply) {
		this.estimatedDaysSupply = estimatedDaysSupply;
	}
	public String getPrescriberFirstname() {
		return prescriberFirstname;
	}
	public void setPrescriberFirstname(String prescriberFirstname) {
		this.prescriberFirstname = prescriberFirstname;
	}
	public String getPrescriberLastname() {
		return prescriberLastname;
	}
	public void setPrescriberLastname(String prescriberLastname) {
		this.prescriberLastname = prescriberLastname;
	}
	public String getPrescriberPhoneNumber() {
		return prescriberPhoneNumber;
	}
	public void setPrescriberPhoneNumber(String prescriberPhoneNumber) {
		this.prescriberPhoneNumber = prescriberPhoneNumber;
	}
	public String getDispensingPharmacy() {
		return dispensingPharmacy;
	}
	public void setDispensingPharmacy(String dispensingPharmacy) {
		this.dispensingPharmacy = dispensingPharmacy;
	}
	public String getDispensingPharmacyFaxNumber() {
		return dispensingPharmacyFaxNumber;
	}
	public void setDispensingPharmacyFaxNumber(String dispensingPharmacyFaxNumber) {
		this.dispensingPharmacyFaxNumber = dispensingPharmacyFaxNumber;
	}
	
	
	
	
	
}
