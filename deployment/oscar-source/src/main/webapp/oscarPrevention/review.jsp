<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>

<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="org.hl7.fhir.r4.model.Extension"%>
<%@page import="org.oscarehr.integration.fhirR4.api.DHIR"%>
<%@page import="org.hl7.fhir.r4.model.StringType"%>
<%@page import="org.joda.time.LocalDate"%>
<%@page import="org.joda.time.Days"%>
<%@page import="org.hl7.fhir.r4.model.Coding"%>
<%@page import="org.hl7.fhir.r4.model.CodeableConcept"%>
<%@page import="org.hl7.fhir.r4.model.Practitioner.PractitionerQualificationComponent"%>
<%@page import="org.hl7.fhir.r4.model.codesystems.PractitionerSpecialty"%>
<%@page import="org.hl7.fhir.r4.model.ContactPoint"%>
<%@page import="org.hl7.fhir.r4.model.Identifier"%>
<%@page import="org.hl7.fhir.r4.model.HumanName"%>
<%@page import="org.hl7.fhir.r4.model.Immunization"%>
<%@page import="org.hl7.fhir.r4.model.Patient"%>
<%@page import="org.hl7.fhir.r4.model.Practitioner"%>
<%@page import="org.hl7.fhir.r4.model.Organization"%>
<%@page import="org.hl7.fhir.r4.model.MessageHeader"%>
<%@page import="org.hl7.fhir.r4.model.Bundle.BundleEntryComponent"%>
<%@page import="org.oscarehr.common.model.Prevention"%>
<%@page import="org.oscarehr.common.model.Demographic"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao"%>
<%@page import="org.oscarehr.common.model.Provider"%>
<%@page import="org.oscarehr.common.model.CVCMapping"%>
<%@page import="org.oscarehr.common.dao.CVCImmunizationDao"%>
<%@page import="org.oscarehr.common.dao.CVCMappingDao"%>
<%@page import="org.oscarehr.common.model.CVCMedicationLotNumber"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="org.oscarehr.common.model.CVCImmunization"%>
<%@page import="org.oscarehr.managers.CanadianVaccineCatalogueManager"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@page import="oscar.oscarProvider.data.ProviderData"%>
<%@ page import="oscar.oscarDemographic.data.DemographicData,java.text.SimpleDateFormat, java.util.*,oscar.oscarPrevention.*,oscar.oscarProvider.data.*,oscar.util.*"%>
<%@ page import="org.oscarehr.casemgmt.model.CaseManagementNoteLink" %>
<%@ page import="org.oscarehr.casemgmt.service.CaseManagementManager" %>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@page import="org.oscarehr.common.dao.DemographicExtDao" %>
<%@page import="org.oscarehr.common.dao.PreventionsLotNrsDao" %>
<%@page import="org.oscarehr.common.model.PreventionsLotNrs" %>
<%@page import="org.hl7.fhir.r4.model.Bundle" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_prevention" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_prevention");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%
  DemographicExtDao demographicExtDao = SpringUtils.getBean(DemographicExtDao.class);
  CanadianVaccineCatalogueManager cvcManager = SpringUtils.getBean(CanadianVaccineCatalogueManager.class);
  CVCMappingDao cvcMappingDao = SpringUtils.getBean(CVCMappingDao.class);
  CVCImmunizationDao cvcImmunizationDao = SpringUtils.getBean(CVCImmunizationDao.class);
  ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
  
  LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);

 Bundle bundle = (Bundle)request.getAttribute("bundle");
 String errorMsg = (String)request.getAttribute("error");
 
 Integer preventionId = (Integer)request.getAttribute("preventionId");
 String demographicNo = (String)request.getAttribute("demographicNo");
 String submittingProviderNo = null;
 String senderReference = null;
 String sender = null;
 String sourceName = null;
 String sourceSoftware=null;
 String sourceVersion=null;
 String sourceEndpoint = null;
 String destinationName = null;
 String destinationEndpoint = null;
 String phu = null;
 String phuName = null;
 Date timestamp = null;
 
 String submitterOrganizationName = null;
 String submitterOrganizationAddress = null;
 String submitterOrganizationCity = null;
 String submitterOrganizationProvince = null;
 String submitterOrganizationPostalCode = null;
 
 Practitioner submittingPractitioner = null;
 Map<String,Practitioner> performingPractitioners = new HashMap<String,Practitioner>();
 Patient patient = null;
 
 Map<String,Immunization> immunizations = new HashMap<String,Immunization>();
 
 SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
 
 for(BundleEntryComponent bec : bundle.getEntry()) {
		if(bec.getResource().fhirType().equals("MessageHeader")) {
			MessageHeader mh  = (MessageHeader)bec.getResource();
			if(mh.getAuthor() != null && mh.getAuthor().getReference() != null) {
				submittingProviderNo = mh.getAuthor().getReference().split("/")[1];
			}
			if(mh.getSender() != null) {
				senderReference = mh.getSender().getReference();
			}
			if(mh.getSource() != null) {
				sourceName = mh.getSource().getName();
				sourceSoftware = mh.getSource().getSoftware();
				sourceVersion = mh.getSource().getVersion();
				sourceEndpoint = mh.getSource().getEndpoint();
			}
			if(mh.getDestination() != null && mh.getDestination().size() > 0) {
				destinationName = mh.getDestination().get(0).getName();
				destinationEndpoint = mh.getDestination().get(0).getEndpoint();
			}
			//timestamp = mh.getTimestamp();
		}
		if(bec.getResource().fhirType().equals("Organization")) {
			Organization organization = (Organization)bec.getResource();
			if(senderReference.equals("Organization/" + organization.getId())) {
				submitterOrganizationName =  organization.getName();
				submitterOrganizationAddress = new String();
				if(organization.getAddressFirstRep() != null) {
					for(StringType st : organization.getAddressFirstRep().getLine()) {
						if(st != null && st.getValue() != null) {
							if(submitterOrganizationAddress.length()>0) {
								submitterOrganizationAddress = "<br/>";
							}
							submitterOrganizationAddress = st.getValue() + submitterOrganizationAddress;
						}
					}
					submitterOrganizationCity = organization.getAddressFirstRep().getCity();
					submitterOrganizationProvince = organization.getAddressFirstRep().getState();
					submitterOrganizationPostalCode = organization.getAddressFirstRep().getPostalCode(); 
				}
			}
			
		}
		if(bec.getResource().fhirType().equals("Practitioner")) {
			Practitioner p = (Practitioner)bec.getResource();
			if(submittingProviderNo.equals(p.getId())) {
				submittingPractitioner = p;
			} else {
				performingPractitioners.put(p.getId(),p);
			}
		}
		if(bec.getResource().fhirType().equals("Patient")) {
			patient  = (Patient)bec.getResource();
		}
		
		if(bec.getResource().fhirType().equals("Immunization")) {
			Immunization i = (Immunization)bec.getResource();
			immunizations.put(i.getId(),i);			
		}
  }
 
  List<String> validationErrors = new ArrayList<String>();
  
  //Organization validations
  
  
  if(submitterOrganizationCity == null || submitterOrganizationCity.trim().isEmpty()){
		validationErrors.add("Missing Clinic City");
  }

  if(submitterOrganizationProvince == null || submitterOrganizationProvince.trim().isEmpty()){
		validationErrors.add("Missing Clinic Province");
  }
  
  if(submitterOrganizationPostalCode == null || submitterOrganizationPostalCode.trim().isEmpty()){
		validationErrors.add("Missing Clinic Postal Code");
  }
					
				
  
  
  //Submitting Practitioner Resource
  if(submittingPractitioner == null) {
	  validationErrors.add("Missing Submitting Practitioner resource");
  }
  String submitterName = getPractitionerName(submittingPractitioner);
  String submitterUsername = getOneId(submittingPractitioner);
  String submitterPhone = getPractitionerPhone(submittingPractitioner);
  
  if(submitterName == null) {
	  validationErrors.add("Submitter name is not set");
  }
  if(submitterUsername == null) {
	  validationErrors.add("Submitter OneID is not set. Please make sure you're logged into OneID SSO");
  }/*
  if(submitterPhone == null) {
	  validationErrors.add("Submitter phone is missing. Please set your work phone # in provider record");
  }*/
  
  if(StringUtils.isEmpty(senderReference)) {
	  validationErrors.add("Sender is not set.");
  }
  
  if(StringUtils.isEmpty(submitterOrganizationName)) {
	  validationErrors.add("Submitting Organization name not set. Please set up Clinic info.");
  }
  
  if(StringUtils.isEmpty(sourceVersion)) {
	  validationErrors.add("OSCAR version is not set. Please set build information in properties file");
  }
  
  /*
  if(StringUtils.isEmpty(phu) || StringUtils.isEmpty(phuName)) {
	  validationErrors.add("No PHU found. Please set clinic wide PHU in properties file or set in patient master record");
  }
  */
  
  
  String patientId = null;
  String patientName = null;
  String patientHin = null;
  String patientGender = null;
  String patientDOB = null;
 
  
  if(patient != null) {
	  patientId = patient.getId();
	  patientName = getPatientName(patient);
	  patientHin = getHIN(patient); 
	  patientGender = patient.getGender().toString();
	  patientDOB = patient.getBirthDate().toString();
	  
  }
  
  if(patient == null) {
	  validationErrors.add("Missing Patient resource");
  }
  
  if(StringUtils.isEmpty(patientName)) {
	  validationErrors.add("Patient name is required");
  }
  
  if(StringUtils.isEmpty(patientHin)) {
	  validationErrors.add("Patient health card # is required");
  }
  
  if(StringUtils.isEmpty(patientGender)) {
	  validationErrors.add("Patient gender is required");
  }
  
  if(StringUtils.isEmpty(patientDOB)) {
	  validationErrors.add("Patient birth date is required");
  }
  
	Iterator iter1 = immunizations.keySet().iterator();
	
	while(iter1.hasNext()) {
		Immunization immunization = immunizations.get((String)iter1.next());
		
		String apProviderNo = immunization.getPerformer().get(0).getActor().getReference().split("/")[1];

		Practitioner performer = performingPractitioners.get(apProviderNo);
		
		if(immunization == null) {
			validationErrors.add("Missing Immunization");
		} else {
			//is this an ISPA?. Is this internal or external, What is the date on it
			CVCImmunization cvcImm = cvcManager.getBrandNameImmunizationBySnomedCode(LoggedInInfo.getLoggedInInfoFromSession(request), getVaccineCode(immunization,0));
			boolean ispa = false;
			boolean external = !immunization.getPrimarySource();
			//MARC
			boolean historical = false;
			
			if(cvcImm != null) {
				ispa = cvcImm.isIspa();
			}
			
			if(getVaccineCode(immunization) == null) {
				validationErrors.add("Missing required immunization SNOMED identifier");
			}
			
			/*
			if(immunization.getDate() == null) {
				validationErrors.add("Missing required immunization date");
			}
			*/
			
			if(!immunization.getPrimarySource() && immunization.getReportOrigin() == null) {
				validationErrors.add("Missing required report origin. This is requied when primary source is false");
			}
			/* OMD validation said these weren't required fields
			if(StringUtils.isEmpty(immunization.getLotNumber())) {
				validationErrors.add("Lot# is required");
			}
			if(immunization.getExpirationDate() == null) {
				validationErrors.add("Expiration Date is required");
			}
			if(getRoute(immunization) == null) {
				validationErrors.add("Route is required");
			}
			
			if(getSite(immunization) == null) {
				validationErrors.add("Site is required");
			}
			
			*/
			
			if(getDoseQuantity(immunization) == null || getDoseUnit(immunization) == null) {
				validationErrors.add("Dose is required");
			}
			
			if(performer == null) {
				validationErrors.add("Missing Performing Practitioner for immunization");
			} else {
				
				//if(ispa && !historical && !external) {
					if(!external && (getPractitionerCollegeIdType(performer) == null || getPractitionerCollegeId(performer) == null)) {
						validationErrors.add("Set college ID and Type for performing practitioner");
					}
				
					if(getPractitionerName(performer) == null) {
						validationErrors.add("Name required for performing practitioner");
					}
					
					if(!external && getPractitionerQualification(performer) == null) {
						validationErrors.add("Missing qualifications for performing practitioner");
					}
				//} 
			}
		}
	}
	
%>


<html:html locale="true">

<head>
<title>OSCAR Prevention Review Screen</title><!--I18n-->
<link rel="stylesheet" type="text/css" href="../share/css/OscarStandardLayout.css">
<link rel="stylesheet" type="text/css" media="all" href="../share/calendar/calendar.css" title="win2k-cold-1" />

<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
<script type="text/javascript" src="../share/calendar/calendar.js" ></script>
<script type="text/javascript" src="../share/calendar/lang/<bean:message key="global.javascript.calendar"/>" ></script>
<script type="text/javascript" src="../share/calendar/calendar-setup.js" ></script>

<style type="text/css">
  div.ImmSet { background-color: #ffffff; }
  div.ImmSet h2 {  }
  div.ImmSet ul {  }
  div.ImmSet li {  }
  div.ImmSet li a { text-decoration:none; color:blue;}
  div.ImmSet li a:hover { text-decoration:none; color:red; }
  div.ImmSet li a:visited { text-decoration:none; color:blue;}


  ////////
  div.prevention {  background-color: #999999; }
  div.prevention fieldset {width:35em; font-weight:bold; }
  div.prevention legend {font-weight:bold; }

  ////////
</style>



<style type="text/css">
	table.outline{
	   margin-top:50px;
	   border-bottom: 1pt solid #888888;
	   border-left: 1pt solid #888888;
	   border-top: 1pt solid #888888;
	   border-right: 1pt solid #888888;
	}
	table.grid{
	   border-bottom: 1pt solid #888888;
	   border-left: 1pt solid #888888;
	   border-top: 1pt solid #888888;
	   border-right: 1pt solid #888888;
	}
	td.gridTitles{
		border-bottom: 2pt solid #888888;
		font-weight: bold;
		text-align: center;
	}
        td.gridTitlesWOBottom{
                font-weight: bold;
                text-align: center;
        }
	td.middleGrid{
	   border-left: 1pt solid #888888;
	   border-right: 1pt solid #888888;
           text-align: center;
	}


label{
float: left;
width: 120px;
font-weight: bold;
}

label.checkbox{
float: left;
width: 116px;
font-weight: bold;
}

label.fields{
float: left;
width: 80px;
font-weight: bold;
}

span.labelLook{
font-weight:bold;

}

input, textarea,select{

//margin-bottom: 5px;
}

textarea{
width: 450px;
height: 100px;
}


.boxes{
width: 1em;
}

#submitbutton{
margin-left: 120px;
margin-top: 5px;
width: 90px;
}

br{
clear: left;
}
</style>

<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
<script>
function refuse() {
	$("#action").val("refuse");
	$("#theForm").trigger( "submit" );
	return true;
	
}

function checkConsent() {
	if(document.getElementById("patientConsent").checked){
		document.getElementById("submitButton").disabled = false;
	}else{
		document.getElementById("submitButton").disabled = true;	
	}
		
}

</script>

</head>

<body class="BodyStyle" vlink="#0000FF" onload="disableifchecked(document.getElementById('neverWarn'),'nextDate');">
<!--  -->
    <table  class="MainTable" id="scrollNumber1" name="encounterTable">
        <tr class="MainTableTopRow">
            <td class="MainTableTopRowLeftColumn" width="100" >
              DHIR Submission Review
            </td>
            <td class="MainTableTopRowRightColumn">
                <table class="TopStatusBar">
                    <tr>
                        <td >
                            
                        </td>
                        <td  >&nbsp;

                        </td>
                        <td style="text-align:right">
                                <oscar:help keywords="prevention" key="app.top1"/> | <a href="javascript:popupStart(300,400,'About.jsp')" ><bean:message key="global.about" /></a> | <a href="javascript:popupStart(300,400,'License.jsp')" ><bean:message key="global.license" /></a>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="MainTableLeftColumn" valign="top">
               &nbsp;
            </td>
            <td valign="top" class="MainTableRightColumn">
<%
			if(session.getAttribute("oneIdEmail") == null) {
		%>
		<div style="width:100%;background-color:pink;text-align:center;font-weight:bold;font-size:13pt">
			Warning: You are not logged into OneId and will not be able to submit data to DHIR
		</div>
		<% } %>
		
		<br/>
		
		<table style="width:100%">
		<tr><td style="width:80%">
			<table style="width:100%;background-color: lightblue">
				<thead>
					<tr>
						<th colspan="2" style="text-align:left;background-color:#6699CC">Submitter</th>
					</tr>
					<tr>
						<th colspan="2" vheight="10px"></th>
					</tr>
				</thead>
				<tr>
					<td width="15%"><b>Name:</b></td>
					<td><%=submitterName != null ? submitterName : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>OneId username:</b></td>
					<td><%=submitterUsername != null ? submitterUsername : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Phone:</b></td>
					<td><%=submitterPhone != null ? submitterPhone : "N/A" %></td>
				</tr>
			</table>
		
			<br/>
			
			<table style="width:100%;background-color: lightblue">
				<thead>
					<tr>
						<th colspan="2" style="text-align:left;background-color:#6699CC">Source</th>
					</tr>
					<tr>
						<th colspan="2" vheight="10px"></th>
					</tr>
				</thead>
				<tr>
					<td width="15%"><b>Name:</b></td>
					<td><%=sourceName %></td>
				</tr>
				<tr>
					<td width="15%"><b>Software:</b></td>
					<td><%=sourceSoftware %></td>
				</tr>
				<tr>
					<td width="15%"><b>Version:</b></td>
					<td><%=sourceVersion != null ? sourceVersion : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Endpoint:</b></td>
					<td><%=(sourceEndpoint != null) ? sourceEndpoint : "N/A" %></td>
				</tr>
			</table>
			
			<br/>
			
			<table style="width:100%;background-color: lightblue">
				<thead>
					<tr>
						<th colspan="2" style="text-align:left;background-color:#6699CC">Submitting Organization</th>
					</tr>
					<tr>
						<th colspan="2" vheight="10px"></th>
					</tr>
				</thead>
				<tr>
					<td width="15%"><b>Name:</b></td>
					<td><%=submitterOrganizationName != null ? submitterOrganizationName : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Address:</b></td>
					<td>
						<%=submitterOrganizationAddress != null ? submitterOrganizationAddress : ""%><br/>
						<%=submitterOrganizationCity != null ? submitterOrganizationCity : ""%><br/>
						<%=submitterOrganizationProvince != null ? submitterOrganizationProvince : ""%><br/>
						<%=submitterOrganizationPostalCode != null ? submitterOrganizationPostalCode : ""%><br/>
					</td>
				</tr>
				
			</table>
			
			<br/>
			
			<table style="width:100%;background-color: lightblue">
				<thead>
					<tr>
						<th colspan="2" style="text-align:left;background-color:#6699CC">Patient</th>
					</tr>
					<tr>
						<th colspan="2" vheight="10px"></th>
					</tr>
				</thead>
				<tr>
					<td width="15%"><b>Demographic No:</b></td>
					<td><%=patientId %></td>
				</tr>
				<tr>
					<td width="15%"><b>Name:</b></td>
					<td><%=patientName != null ? patientName : "N/A"%></td>
				</tr>
				<tr>
					<td width="15%"><b>HIN:</b></td>
					<td><%=patientHin != null ? patientHin : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Gender:</b></td>
					<td><%=patientGender != null ? patientGender : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>DOB:</b></td>
					<td><%=patientDOB != null ? patientDOB : "N/A"%></td>
				</tr>
				
				
			</table>
		
		<br/>
			
			<%
				Iterator iter = immunizations.keySet().iterator();
			
				while(iter.hasNext()) {
					Immunization immunization = immunizations.get((String)iter.next());
					String apProviderNo = immunization.getPerformer().get(0).getActor().getReference().split("/")[1];
					Practitioner performer = performingPractitioners.get(apProviderNo);
					
			%>
			
			<table style="width:100%;background-color: lightblue">
				<thead>
					<tr>
						<th colspan="2" style="text-align:left;background-color:#6699CC">Immunization</th>
					</tr>
					<tr>
						<th colspan="2" vheight="10px"></th>
					</tr>
				</thead>
				<!-- 
				<tr>
					<td width="15%"><b>Status:</b></td>
					<td><%=immunization.getStatus() %></td>
				</tr>
				<tr>
					<td width="15%"><b>Not Given:</b></td>
					<td>TODO</td>
				</tr>
				-->
				<tr>
					<td width="15%"><b>Vaccine Code:</b></td>
					<td><%=getVaccineCode(immunization,0)%></td>
				</tr>
				<tr>
					<td width="15%"><b>Vaccine Code Display:</b></td>
					<td><%=getVaccineCodeDisplay(immunization,0)%></td>
				</tr>
				
				<tr>
					<td width="15%"><b>Date Given:</b></td>
					<td><%=getImmunizationDateDisplay(immunization)%> </td>
				</tr>
				<tr>
					<td width="15%"><b>Primary Source:</b></td>
					<td><%=immunization.getPrimarySource() %></td>
				</tr>
				<%if(!immunization.getPrimarySource()) { %>
					<tr>
						<td width="15%"><b>Report Origin:</b></td>
						<td><%=getReportOrigin(immunization) %></td>
					</tr>
				<% } %>
				<tr>
					<td width="15%"><b>Lot #:</b></td>
					<td><%=immunization.getLotNumber() != null ? immunization.getLotNumber() : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Expiration Date:</b></td>
					<td><%=immunization.getExpirationDate() != null ? dateFormatter.format(immunization.getExpirationDate()) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Site:</b></td>
					<td><%=getSite(immunization) != null ? getSite(immunization) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Route Display:</b></td>
					<td><%=getRoute(immunization) != null ? getRoute(immunization) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Dose Qty:</b></td>
					<td><%=getDoseQuantity(immunization) != null ? getDoseQuantity(immunization) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Dose Unit:</b></td>
					<td><%=getDoseUnit(immunization) != null ? getDoseUnit(immunization) : "N/A"%></td>
				</tr>
				
			
				<tr>
					<th colspan="2" style="text-align:left;background-color:#6699CC">Performer Information</th>
				</tr>
		
				<tr>
					<td width="15%"><b>Provider No:</b></td>
					<td><%=performer != null ? performer.getId() : ""%></td>
				</tr>
				<tr>
					<td width="15%"><b>Name:</b></td>
					<td><%=getPractitionerName(performer) != null ? getPractitionerName(performer) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Id Type:</b></td>
					<td><%=getPractitionerCollegeIdType(performer) != null ? getPractitionerCollegeIdType(performer) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Id:</b></td>
					<td><%=getPractitionerCollegeId(performer) != null ? getPractitionerCollegeId(performer) : "N/A" %></td>
				</tr>
				<tr>
					<td width="15%"><b>Qualification:</b></td>
					<td><%=getPractitionerQualification(performer) != null ? getPractitionerQualification(performer) : "N/A" %></td>
				</tr>
			</table>
			
					<br/>
		
		<h4><input onclick="checkConsent()" type="checkbox" id="patientConsent" name="patientConsent" <%=(!validationErrors.isEmpty())?" disabled=\"disabled\" ":"" %> />Check here to acknowledge that you have received express consent from the patient or their legal guardian to submit this immunization data to the Digital Health Immunization Repository.  If the patient or their legal guardian has refused consent, select Cancel - Refusal to save the immunization record in your EMR and exit this screen.</h4>
		
			<br/>
			
		</td>
		
		<td valign="top">
		<table style="width:100%;color:red" border="0">
			<head>
				<tr>
					<th style="color:black;font-weight:bold">Validation Errors</th>
				</tr>
			</head>
			<tbody>
				<!-- enter validation errors here -->
				<%for(String error:validationErrors) { %>
					<tr>
						<td><%=error %></td>
					</tr>
				<% } %>
			</tbody>
		</table>		
			
		</td>
		
		
		</tr></table>
			<br/>
			
			<% } %>
			
			<form id="theForm" action="<%=request.getContextPath()%>/dhir/submit.do">
				<input type="hidden" name="uuid" value="<%=bundle.getId()%>"/>
				<input type="hidden" name="demographicNo" value="<%=demographicNo%>"/>
				<input type="hidden" name="preventionId" value="<%=preventionId%>"/>
				<input type="hidden" id="action" name="action" value="Submit" />
				<input type="submit" value="Submit"  disabled="disabled" id="submitButton"/>
				&nbsp;&nbsp;&nbsp;
				<input type="button" value="Edit Prevention" onClick="window.location.href='<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?id=<%=preventionId %>&demographic_no=<%=demographicNo%>'"/>
				&nbsp;&nbsp;
				<input type="submit" value="Cancel - Refusal" <%=(!validationErrors.isEmpty())?" disabled=\"disabled\" ":"" %> onClick="return refuse()"/>
				&nbsp;&nbsp;
				<input type="button" value="Cancel" onClick="window.close()"/>
				&nbsp;&nbsp;
				
				
			</form>
            </td>
        </tr>
        <tr>
            <td class="MainTableBottomRowLeftColumn">
            &nbsp;
            </td>
            <td class="MainTableBottomRowRightColumn" valign="top">
            &nbsp;
            </td>
        </tr>
    </table>

</body>
</html:html>
<%!
	String getPractitionerName(Practitioner p) {
		if (p == null || p.getName() == null || p.getName().size() == 0) {return null;}
		HumanName name = p.getName().get(0);
		String lastName = name.getFamily();
		String given = name.getGiven().get(0).asStringValue();
		return lastName + ", " + given;
	}

	String getOneId(Practitioner p) {
		if (p == null || p.getIdentifier() == null) {return null;}
		for(Identifier i : p.getIdentifier()) {
			if((DHIR.ID_SYSTEM_GLOBAL_BASE +  "/ca-on-provider-oneid").equals(i.getSystem())) {
				return i.getValue();				
			}
		}
		return null;
	}
	
	String getPractitionerPhone(Practitioner p) {
		if (p == null || p.getTelecom() == null) {return null;}
		for(ContactPoint cp : p.getTelecom()) {
			if(cp.getSystem().toString().equals("PHONE") && cp.getUse().toString().equals("WORK")) {
				return cp.getValue();
			}
		}
		return null;
	}
	
	String getPatientName(Patient p) {
		if (p == null || p.getName() == null || p.getName().size() == 0) {return null;}
		HumanName name = p.getName().get(0);
		String lastName = name.getFamily();
		String given = name.getGiven().get(0).asStringValue();
		return lastName + ", " + given;
	}
	
	String getHIN(Patient p) {
		if (p == null || p.getIdentifier() == null) {return null;}
		for(Identifier i : p.getIdentifier()) {
			if("https://ehealthontario.ca/API/FHIR/NamingSystem/ca-on-patient-hcn".equals(i.getSystem())) {
				return i.getValue();				
			}
		}
		return null;
	}
	
	
	String getPractitionerCollegeId(Practitioner p) {
		if (p == null || p.getIdentifier() == null) {return null;}
		if(p.getIdentifier() != null && p.getIdentifier().size()>0) {
			Identifier id = p.getIdentifier().get(0);
			return id.getValue();
		}
		return null;
	}
	
	String getPractitionerQualification(Practitioner p) {
		if (p == null || p.getQualification() == null) {return null;}
		if(p.getQualification() != null && p.getQualification().size()>0) {
			PractitionerQualificationComponent pqc =  p.getQualification().get(0);
			CodeableConcept cc = pqc.getCode();
			if(cc != null) {
				if(cc.getCoding() != null && cc.getCoding().size()>0) {
					Coding c = cc.getCoding().get(0);
					//http://ehealthontario.ca/fhir/NamingSystem/ca-on-immunizations-practitioner-designation
					if((DHIR.CODE_SYSTEM_LOCAL_BASE + "/ca-on-immunizations-practitioner-designation").equals(c.getSystem())) {
						if(c.getCode() != null && c.getDisplay() != null) {
							return c.getCode();
						}
					}
				}
			}
		}
		return null;
	}
	
	String getPractitionerCollegeIdType(Practitioner p) {
		if(p != null && p.getIdentifier() != null && p.getIdentifier().size()>0) {
			Identifier id = p.getIdentifier().get(0);
			if((DHIR.ID_SYSTEM_GLOBAL_BASE + "/ca-on-license-nurse").equals(id.getSystem())) {
				return "CNO";
			}
			//https://fhir.infoway-inforoute.ca/NamingSystem/ca-on-license-physician
			if((DHIR.ID_SYSTEM_GLOBAL_BASE + "/ca-on-license-physician").equals(id.getSystem())) {
				return "CPSO";
			}
			if((DHIR.ID_SYSTEM_GLOBAL_BASE + "/ca-on-license-pharmacist").equals(id.getSystem())) {
				return "OCP";
			}
			if((DHIR.ID_SYSTEM_GLOBAL_BASE + "/ca-on-license-midwife").equals(id.getSystem())) {
				return "CMO";
			}
			
		}
		return null;
	}

	String getVaccineCode(Immunization i, int index) {
		if(i != null && i.getVaccineCode() != null && i.getVaccineCode().getCoding() != null && i.getVaccineCode().getCoding().size() > index) {
			return i.getVaccineCode().getCoding().get(index).getCode();
		}
		return null;
	}
	
	String getVaccineCode(Immunization i) {
		return getVaccineCode(i,0);
	}
	
	String getVaccineCodeDisplay(Immunization i) {
		return getVaccineCodeDisplay(i,0);
	}
	
	String getVaccineCodeDisplay(Immunization i, int index) {
		if(i != null && i.getVaccineCode() != null && i.getVaccineCode().getCoding() != null && i.getVaccineCode().getCoding().size() > index) {
			String disp =  i.getVaccineCode().getCoding().get(index).getDisplay();
			return disp != null ? disp : "";
		}
		return "";
	}
	
	String getReportOrigin(Immunization i) {
		if(i != null && i.getReportOrigin() != null && i.getReportOrigin().getCoding() != null && i.getReportOrigin().getCoding().size() > 0) {
			return i.getReportOrigin().getCoding().get(0).getDisplay();
		}
		return null;
	}
	
	String getSite(Immunization immunization) {
		if(immunization.getSite() != null) {
			return immunization.getSite().getCodingFirstRep().getDisplay();
		}
		return null;
	}
	
	String getRoute(Immunization immunization) {
		if(immunization.getRoute()!= null && immunization.getRoute().getCoding() != null &&  immunization.getRoute().getCoding().size() > 0) {
			return immunization.getRoute().getCoding().get(0).getDisplay();
		}
		return null;
	}
	
	String getDoseQuantity(Immunization i) {
		if(i != null && i.getDoseQuantity() != null && i.getDoseQuantity().getValue() != null) {
			return i.getDoseQuantity().getValue().toString();
		}
		return null;
	
	}
	
	String getDoseUnit(Immunization i) {
		if(i != null && i.getDoseQuantity() != null) {
			return i.getDoseQuantity().getUnit();
		}
		return null;
	}
	
	
	boolean isHistorical(Date dateOfAdministration, Date timestamp) {
		int days = Days.daysBetween(new LocalDate(dateOfAdministration), new LocalDate(timestamp)).getDays();
		if(days > 14) {
			return true;
		}
		return false;
	}
	
	String getImmunizationDateDisplay(Immunization i) {
		
		if(i != null) {
			if(i.hasOccurrenceDateTimeType()) {
		
				return i.getOccurrenceDateTimeType().getValueAsString();
				/* is this needed ???
				String estimated = " ";
				Extension ext = null;
				if( (ext = i.getOccurrenceDateTimeType().getExtensionByUrl("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-extension-estimated-date") ) != null){ 
					if("true".equals(ext.getValueAsPrimitive().getValueAsString())) {
						estimated += " (ESTIMATED)";
					}
				}
				Calendar cal = i.getOccurrenceDateTimeType().getValueAsCalendar();
				SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						
				return formatter.format(i.getOccurrenceDateTimeType().getValueAsCalendar().getTime()) + estimated;
				*/
			} else if(i.hasOccurrenceStringType()) {
				String estimated = " ";
				Extension ext = null;
				if((ext = i.getOccurrenceDateTimeType().getExtensionByUrl("http://ehealthontario.ca/fhir/StructureDefinition/ca-on-extension-estimated-date")) != null){ 
					if("true".equals(ext.getValueAsPrimitive().getValueAsString())) {
						
						return null;
						//estimated += " (ESTIMATED)";
					}
				}
				return i.getOccurrenceStringType().getValue() + estimated;
			}
			return "";
		}
		return "";
	}
	
%>