package org.oscarehr.integration.ohcms;
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
import org.hl7.fhir.r4.model.Identifier;
import org.hl7.fhir.r4.model.Organization;
import org.hl7.fhir.r4.model.Parameters;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.Practitioner;
import org.hl7.fhir.r4.model.StringType;
import org.hl7.fhir.r4.model.Address.AddressType;
import org.hl7.fhir.r4.model.Address.AddressUse;

import java.sql.Date;

import org.hl7.fhir.r4.model.BaseResource;
import org.hl7.fhir.r4.model.CodeableConcept;
import org.hl7.fhir.r4.model.Coding;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.IdType;
import org.hl7.fhir.r4.model.ContactPoint.ContactPointSystem;
import org.hl7.fhir.r4.model.ContactPoint.ContactPointUse;
import org.hl7.fhir.r4.model.HumanName.NameUse;
import org.oscarehr.common.Gender;
import org.oscarehr.common.dao.ClinicDAO;
import org.oscarehr.common.model.Clinic;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.integration.OneIdGatewayData;
import org.oscarehr.integration.fhirR4.utils.EnumMappingUtil;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.SpringUtils;

import ca.uhn.fhir.context.FhirContext;

public class FhirResources {
	
	ClinicDAO clinicDao = SpringUtils.getBean(ClinicDAO.class);
	private static FhirContext fhirContext = FhirContext.forR4();
	
	public Organization getOrganization(LoggedInInfo loggedInInfo) throws CMSException{
		Organization organization = new Organization();
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		organization.setId(oneIdGatewayData.getProviderUPI());
		organization.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Organization|1.0.0");
		Identifier identifier = new Identifier();
		CodeableConcept codeableConcept = new CodeableConcept();
		codeableConcept.addCoding().setSystem("http://hl7.org/fhir/v2/0203").setCode("RRI");
		identifier.setType(codeableConcept);
		identifier.setSystem("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-provider-upi").setValue( oneIdGatewayData.getProviderUPI()); 
		organization.addIdentifier(identifier);
		//not sure what code is for this organization.addType().addCoding().setSystem("http://terminology.hl7.org/CodeSystem/organization-type");
		Clinic clinic = clinicDao.getClinic();
		
		if(clinic.getOrganizationName()  == null || clinic.getOrganizationName().trim().isEmpty()) {
			throw new CMSException("Organization name can not be blank. Edit Clinic details in the administration section.");
		}
		
		organization.setName(clinic.getOrganizationName());
		
		
		if(clinic.getAddress2() != null && clinic.getCity() != null && clinic.getProvince() != null && clinic.getPostal() != null ) {
			organization.addAddress()
			.setUse(AddressUse.WORK)
			.addLine( clinic.getAddress2() )
			.setCity( clinic.getCity() )
			.setState( clinic.getProvince())
			.setPostalCode( clinic.getPostal() )
			.setType(AddressType.PHYSICAL);
		}
		//May want to log that address was not included 
		
		if(clinic.getWorkPhone() != null && clinic.getWorkPhone().trim().length() > 4) { // checking for 4 characters because a lot of numbers area code defaulted 905-.
			organization.addTelecom().setSystem( ContactPointSystem.PHONE ).setValue( clinic.getWorkPhone() );
		}
		if(clinic.getFax() != null && clinic.getFax().trim().length() > 4) { 
			organization.addTelecom().setSystem( ContactPointSystem.FAX ).setValue( clinic.getFax() );
		}
		return organization;
	}
	
	public Practitioner getPractitioner(LoggedInInfo loggedInInfo) throws CMSException{
		
		if(loggedInInfo.getLoggedInProvider().getPractitionerNo() == null || loggedInInfo.getLoggedInProvider().getPractitionerNo().trim().isEmpty()) {
			throw new CMSException("Practitioner Number can not be blank. Edit Provider details in the administration section.");
		}
		if(loggedInInfo.getLoggedInProvider().getLastName() == null || loggedInInfo.getLoggedInProvider().getLastName().trim().isEmpty()) {
			throw new CMSException("Provider's Lastname can not be blank. Edit Provider details in the administration section.");
		}
		if(loggedInInfo.getLoggedInProvider().getFirstName() == null || loggedInInfo.getLoggedInProvider().getFirstName().trim().isEmpty()) {
			throw new CMSException("Provider's Firstname can not be blank. Edit Provider details in the administration section.");
		}
		
		Practitioner practitioner = new Practitioner();
		practitioner.setId(loggedInInfo.getLoggedInProvider().getPractitionerNo());
		practitioner.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Practitioner|1.0.0");
		OneIdGatewayData oneIdGatewayData = loggedInInfo.getOneIdGatewayData();
		practitioner.addIdentifier().setSystem("https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician").setValue(loggedInInfo.getLoggedInProvider().getPractitionerNo());
		practitioner.addName().setFamily(loggedInInfo.getLoggedInProvider().getLastName()).addGiven(loggedInInfo.getLoggedInProvider().getFirstName());
		//TODO need to set qualification.
		return practitioner;
	}
	
	public Patient getPatient(LoggedInInfo loggedInInfo,Demographic demographic) throws CMSException{
		Patient patient = new Patient();
		patient.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Patient|1.0.0");
		patient.addIdentifier().setSystem( "https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-patient-hcn").setValue( demographic.getHin() );
		patient.setId( demographic.getDemographicNo() + "" );
		try {
			patient.setBirthDate( new Date( demographic.getBirthDay().getTimeInMillis() ) ); //required
		}catch(Exception e) {
			throw new CMSException("Error processing birthdate of patient.  Verify birthdate in patient's demographic record.");
		}
		Gender gender = Gender.valueOf( demographic.getSex().toUpperCase() );  
		patient.setGender( EnumMappingUtil.genderToAdministrativeGender( gender ) );  //required
		
		if(demographic.getAddress() != null && demographic.getCity() != null && demographic.getProvince() != null && demographic.getPostal() != null ) {
			patient.addAddress()
			.setUse( AddressUse.HOME )				
			.addLine( demographic.getAddress() )
			.setCity( demographic.getCity() )
			.setState( demographic.getProvince() )
			.setPostalCode( demographic.getPostal() );
		}
		
		HumanName humanName = new HumanName();
		humanName.setUse( NameUse.OFFICIAL );
		humanName.getExtensionFirstRep().setUrl( "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier" );
		
		
		if(demographic.getLastName() == null || demographic.getLastName().trim().isEmpty()) {
			throw new CMSException("Patient's Lastname can not be blank. Verify Patient's details in the demographic record.");
		}
		if(demographic.getFirstName() == null || demographic.getFirstName().trim().isEmpty()) {
			throw new CMSException("Patient's Firstname can not be blank. Verify Patient's details in the demographic record.");
		}
		
		//mandatory
		humanName.setFamily( demographic.getLastName() );  //required
		humanName.addGiven( demographic.getFirstName() );  //required
		
		//optional
		if(demographic.getTitle() != null && !demographic.getTitle().trim().isEmpty()) {
			humanName.addPrefix( demographic.getTitle() );
		}
		
		patient.addName( humanName );
		
		CodeableConcept cc = new CodeableConcept();
		Coding c = cc.addCoding();
		c.setSystem("https://www.hl7.org/fhir/valueset-languages.html");
		c.setCode("en-US");
		patient.addCommunication().setLanguage(cc);
		
		if(demographic.getPhone() != null && !demographic.getPhone().trim().isEmpty()) {
			patient.addTelecom().setUse( ContactPointUse.HOME )
			.setSystem( ContactPointSystem.PHONE )
			.setValue( demographic.getPhone() );
		}

		if(demographic.getPhone2() != null && !demographic.getPhone2().trim().isEmpty()) {
			patient.addTelecom().setUse( ContactPointUse.WORK )
			.setSystem( ContactPointSystem.PHONE )
			.setValue( demographic.getPhone2() );
		}
		
		return patient;
	}
	
	public Parameters getLanguageParameter(LoggedInInfo loggedInInfo, String id, String lang) {
		org.hl7.fhir.r4.model.Parameters parameters = new org.hl7.fhir.r4.model.Parameters();
		parameters.setId(id );
		parameters.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0.0");
		Coding coding = new Coding();
		coding.setCode(lang);
		coding.setSystem("urn:ietf:bcp:47");
		parameters.addParameter().setName("appLanguage").setValue(coding);
		return parameters;
	}
	
	public Parameters getConsentTargetParameter(LoggedInInfo loggedInfo,String id,String param) {
		org.hl7.fhir.r4.model.Parameters parameters = new org.hl7.fhir.r4.model.Parameters();
		parameters.setId(id);
		parameters.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0.0");
		StringType stringType = new StringType();
		stringType.setValue(param);
		parameters.addParameter().setName("consentTarget").setValue(stringType);
		return parameters;
	}
	
	public Parameters getContextSessionIdParameter(LoggedInInfo loggedInfo,String id,String param) {
		org.hl7.fhir.r4.model.Parameters parameters = new org.hl7.fhir.r4.model.Parameters();
		parameters.setId(id);
		parameters.getMeta().addProfile("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-cms-profile-Parameters|1.0.0");
		IdType stringType = new IdType();
		stringType.setValue(param);
		parameters.addParameter().setName("contextSessionId").setValue(stringType);
		return parameters;	
	}
	
	public String getString(BaseResource baseResource) {
		return fhirContext.newJsonParser().setPrettyPrint(true).encodeResourceToString( baseResource );
	}

}
