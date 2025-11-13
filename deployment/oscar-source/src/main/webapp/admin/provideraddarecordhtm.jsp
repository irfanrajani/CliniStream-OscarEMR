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
<!DOCTYPE html>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>

<%@ page import="java.util.*"%>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.sql.*" errorPage="errorpage.jsp"%>

<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>

<%@ page import="oscar.oscarProvider.data.*"%>
<%@ page import="oscar.OscarProperties"%>
<%@ page import="oscar.*"%>
<%@ page import="oscar.log.LogAction"%>
<%@ page import="oscar.log.LogConst"%>
<%@ page import="oscar.log.*"%>
<%@ page import="oscar.oscarDB.*"%>
<%@ page import="oscar.oscarProvider.data.ProviderBillCenter"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>

<%@ page import="org.oscarehr.common.model.ProviderSite"%>
<%@ page import="org.oscarehr.common.model.ProviderSitePK"%>
<%@ page import="org.oscarehr.common.dao.ProviderSiteDao"%>
<%@ page import="org.oscarehr.common.dao.SiteDao"%>
<%@ page import="org.oscarehr.common.model.Site"%>
<%@ page import="org.oscarehr.common.model.Provider" %>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@ page import="org.oscarehr.common.dao.ProviderDataDao"%>
<%@ page import="org.oscarehr.common.model.ProviderData"%>
<%@ page import="org.oscarehr.common.model.LookupListItem"%>
<%@ page import="org.oscarehr.common.model.LookupList"%>
<%@ page import="org.oscarehr.common.model.ClinicNbr"%>
<%@ page import="org.oscarehr.common.dao.ClinicNbrDao"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="org.oscarehr.managers.LookupListManager"%>
<%@ page import="org.oscarehr.common.Gender" %>

<%@ page import="org.owasp.encoder.Encode" %>



<%
	ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
	ProviderSiteDao providerSiteDao = SpringUtils.getBean(ProviderSiteDao.class);
	boolean alreadyExists=false;


  String curProvider_no,userfirstname,userlastname;
  curProvider_no = (String) session.getAttribute("user");
  userfirstname = (String) session.getAttribute("userfirstname");
  userlastname = (String) session.getAttribute("userlastname");
  //display the main provider page
  //includeing the provider name and a month calendar

  java.util.Locale vLocale =(java.util.Locale)session.getAttribute(org.apache.struts.Globals.LOCALE_KEY);

  ProviderDataDao providerDataDao = SpringUtils.getBean(ProviderDataDao.class);
  List<ProviderData> list = providerDataDao.findAll();
  List<Integer> providerList = new ArrayList<Integer>();
  for (ProviderData h : list) {
	  try{
      String pn = h.getId();
      providerList.add(Integer.valueOf(pn));
	  }catch(Exception e){/*empty*/} /*No need to do anything. Just want to avoid a NumberFormatException from provider numbers with alphanumeric Characters*/
  }

  String suggestProviderNo = "";
  for (Integer i=100; i<1000000; i++) {
      if (!providerList.contains(i)) {
          suggestProviderNo = i.toString();
          break;
      }
  }
%>

<%
   String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");

    boolean isSiteAccessPrivacy=false;
    boolean authed=true;
%>

<security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.userAdmin" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.userAdmin");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<security:oscarSec objectName="_site_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%
		isSiteAccessPrivacy=true;
	%>
</security:oscarSec>
<html:html locale="true">


<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">

<script src="<%=request.getContextPath() %>/library/jquery/jquery-3.6.4.min.js"></script>
<!--<script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-3.4.0.js"></script>-->
<script src="<%=request.getContextPath() %>/js/jqBootstrapValidation-1.3.7.min.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/global.js"></script>
<title><bean:message key="admin.provideraddrecordhtm.title" /></title>

   <script>

     $(function () { $("input,textarea,select").jqBootstrapValidation(
                    {
                        preventSubmit: true,
                        submitError: function($form, event, errors) {
                            // Here I do nothing, but you could do something like display
                            // the error messages to the user, log, etc.
                            event.preventDefault();
                        },

                        submitSuccess: function($form, event) {

                           // aSubmit();
                        },
                        filter: function() {
                            return $(this).is(":visible");
                        },

                    }
                );

                $("a[data-toggle=\"tab\"]").on( "click", function(e) {
                    e.preventDefault();
                    $(this).tab("show");
                });

            });

</script>


<script>
function formatPhone(obj) {
    // formats to North American xxx-xxx-xxxx standard numbers that are exactly 10 digits long
    var x=obj.value;
    //strip the formatting to get the numbers
    var matches = x.match(/\d+/g);
    if (!matches || x.substring(0,1) == "+"){
        // don't do anything if non numberic and or international format
        return;
    }
    var num = '';
    for (var i=0; i< matches.length; i++) {
        console.log(matches[i]);
        num = num + matches[i];
    }
    if (num.length == 10){
        obj.value = num.substring(0,3)+"-"+num.substring(3,6) + "-"+ num.substring(6);
    } else {
        if (num.length == 11 && x.substring(0,1) == "1"){
            obj.value = num.substring(0,1)+"-"+num.substring(1,4) + "-"+ num.substring(4,7)+ "-"+ num.substring(7);
        }
    }
}



</script>

<style>
input {
       height: 26px;
}
</style>

</style>
<script LANGUAGE="JavaScript">

function upCaseCtrl(ctrl) {
  ctrl.value = ctrl.value.toUpperCase();
}

</script>
</head>

<body onLoad="$('#registrationNumbers').hide();$('#provider_type_div').hide();$('#contact_div').hide();" topmargin="0" leftmargin="0" rightmargin="0">


<div width="100%">
    <div id="header"><H4><bean:message
			key="admin.provideraddrecordhtm.description" /></H4>
    </div>
</div>

<%
    String sName = request.getParameter("last_name");
    if ( sName != null && sName != "" ){


boolean isOk = false;
int retry = 0;
String curUser_no = (String)session.getAttribute("user");

Provider p = new Provider();
p.setProviderNo(request.getParameter("provider_no"));
p.setLastName(request.getParameter("last_name"));
p.setFirstName(request.getParameter("first_name"));
p.setProviderType(request.getParameter("provider_type"));
p.setSpecialty(request.getParameter("specialty"));
p.setTeam(request.getParameter("team"));
p.setSex(request.getParameter("sex"));
p.setDob(MyDateFormat.getSysDate(request.getParameter("dob")));
p.setAddress(request.getParameter("address"));
p.setPhone(request.getParameter("phone"));
p.setWorkPhone(request.getParameter("workphone"));
p.setEmail(request.getParameter("email"));
p.setOhipNo(request.getParameter("ohip_no"));
p.setRmaNo(request.getParameter("rma_no"));
p.setBillingNo(request.getParameter("billing_no"));
p.setHsoNo(request.getParameter("hso_no"));
p.setStatus(request.getParameter("status"));
p.setComments(SxmlMisc.createXmlDataString(request,"xml_p"));
p.setProviderActivity(request.getParameter("provider_activity"));
p.setPractitionerNo(request.getParameter("practitionerNo"));
p.setPractitionerNoType(request.getParameter("practitionerNoType"));
p.setLastUpdateUser((String)session.getAttribute("user"));
p.setLastUpdateDate(new java.util.Date());
p.setSupervisor(request.getParameter("supervisor"));
p.setSignedConfidentiality(MyDateFormat.getSysDate(request.getParameter("confidentiality")));

//multi-office provide id formalize check, can be turn off on properties multioffice.formalize.provider.id
boolean isProviderFormalize = true;
String  errMsgProviderFormalize = "admin.provideraddrecord.msgAdditionFailure";
Integer min_value = 0;
Integer max_value = 0;

if (org.oscarehr.common.IsPropertiesOn.isProviderFormalizeEnable()) {

	String StrProviderId = request.getParameter("provider_no");
	OscarProperties props = OscarProperties.getInstance();

	String[] provider_sites = {};

	// get provider id ranger
	if (request.getParameter("provider_type").equalsIgnoreCase("doctor")) {
		//provider is doctor, get provider id range from Property
		min_value = new Integer(props.getProperty("multioffice.formalize.doctor.minimum.provider.id", ""));
		max_value = new Integer(props.getProperty("multioffice.formalize.doctor.maximum.provider.id", ""));
	}
	else {
		//non-doctor role
		provider_sites = request.getParameterValues("sites");
		provider_sites = (provider_sites == null ? new String[] {} : provider_sites);

		if (provider_sites.length > 1) {
			//non-doctor can only have one site
			isProviderFormalize = false;
			errMsgProviderFormalize = "admin.provideraddrecord.msgFormalizeProviderIdMultiSiteFailure";
		}
		else {
			if (provider_sites.length == 1) {
				//get provider id range from site
				String provider_site_id =  provider_sites[0];
				SiteDao siteDao = (SiteDao)WebApplicationContextUtils.getWebApplicationContext(application).getBean("siteDao");
				Site provider_site = siteDao.getById(new Integer(provider_site_id));
				min_value = provider_site.getProviderIdFrom();
				max_value = provider_site.getProviderIdTo();
			}
		}
	}
	if (isProviderFormalize) {
		try {
			    Integer providerId = Integer.parseInt(StrProviderId);
			    if (request.getParameter("provider_type").equalsIgnoreCase("doctor") ||  provider_sites.length == 1) {
				    if  (!(providerId >= min_value && providerId <=max_value)) {
				    	// providerId is not in the range
						isProviderFormalize = false;
						errMsgProviderFormalize = "admin.provideraddrecord.msgFormalizeProviderIdFailure";
				    }
			    }
		} catch(NumberFormatException e) {
			//providerId is not a number
			isProviderFormalize = false;
			errMsgProviderFormalize = "admin.provideraddrecord.msgFormalizeProviderIdFailure";
		}
	}
}

if (!org.oscarehr.common.IsPropertiesOn.isProviderFormalizeEnable() || isProviderFormalize) {

  // check if the provider no need to be auto generated
  if (OscarProperties.getInstance().isProviderNoAuto())
  {
  	p.setProviderNo(suggestProviderNo);
  }


  Pattern pattern = Pattern.compile("[<>/\";&]");
  if(providerDao.providerExists(p.getProviderNo())) {
	  isOk=false;
	  alreadyExists=true;
  } else if(pattern.matcher(p.getLastName()).find()) {
	  isOk = false;
  } else if ((StringUtils.isNumeric(p.getProviderNo()) ||
		  (StringUtils.isNotEmpty(p.getProviderNo())) && p.getProviderNo().equals("-new-")) &&
  			StringUtils.isNotEmpty(p.getLastName()) &&
  			StringUtils.isNotEmpty(p.getFirstName()) &&
  			StringUtils.isNotEmpty(p.getProviderType())) {
		providerDao.saveProvider(p);
		isOk = true;
  }

if (isOk && org.oscarehr.common.IsPropertiesOn.isMultisitesEnable()) {
	String[] sites = request.getParameterValues("sites");
	if (sites!=null)
		for (int i=0; i<sites.length; i++) {
			ProviderSite ps = new ProviderSite();
        	ps.setId(new ProviderSitePK(p.getProviderNo(),Integer.parseInt(sites[i])));
        	providerSiteDao.persist(ps);
		}
}

if (isOk) {
	String proId = p.getPractitionerNo();
	String ip = request.getRemoteAddr();
	LogAction.addLog(curUser_no, LogConst.ADD, "adminAddUser", proId, ip);

	ProviderBillCenter billCenter = new ProviderBillCenter();
	billCenter.addBillCenter(request.getParameter("provider_no"),request.getParameter("billcenter"));

%>
<p>
<div class="alert alert-success">
    <h4><bean:message key="admin.provideraddrecord.msgAdditionSuccess" />
    </h4>
</div>
<%
  } else {
%>
<div class="alert alert-error" >
    <h4><bean:message key="admin.provideraddrecord.msgAdditionFailure" /></h4>
</div>
<%
	if(alreadyExists) {
        %>
        <div class="alert alert-error" >
		    <h4><bean:message key="admin.provideraddrecord.msgAlreadyExists" /></h4>
        </div>
        <%
	}

  }
}
else {
		if 	(!isProviderFormalize) {
	%>
        <div class="alert alert-error" >
		<h1><bean:message key="<%=errMsgProviderFormalize%>" /> </h1>
        </div>
        <div class="alert alert-info">
		Provider # range from : <%=min_value %> To : <%=max_value %>
        </div>
	<%
		}
	}
%>



<% } %>

<form method="post" action="provideraddarecordhtm.jsp" name="searchprovider" autocomplete="off" novalidate >
<div class="container-fluid well form-horizontal span12" >

 <div  id="requiredSection" class="span11">
		<fieldset>
			<legend><bean:message key="admin.provider.professional" /></legend>
		</fieldset>
    <div class="control-group span5">
        <label class="control-label" for="provider_no"><bean:message
                key="admin.provider.formProviderNo" /><span style="color:red">*</span></label>
        <div class="controls">
		<%
			if(OscarProperties.getInstance().isProviderNoAuto()){
		%> <input
			type="text" name="provider_no" maxlength="6" readonly="readonly"
			value="-new-">
        <%
 	        } else {
        %> <input type="text"
			name="provider_no" maxlength="6" required ="required"
                pattern="\d{1,6}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formProviderNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" />"
                data-validation-required-message="<bean:message key="global.missing" /> <bean:message
                key="admin.provider.formProviderNo" />">
            <input type="button" class="btn" value=<bean:message key="admin.provideraddrecordhtm.suggest"/>
                        onclick="provider_no.value='<%=suggestProviderNo%>'"<%}%>
        <p class="help-block text-danger"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="last_name"><bean:message
                key="admin.provider.formLastName" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="text" name="last_name" maxlength="30" required ="required" data-validation-required-message="<bean:message key="global.missing" /> <bean:message key="admin.provider.formOfficialLastName" />">
            <p class="help-block text-danger"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="first_name"><bean:message
                key="admin.provider.formFirstName" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="text" name="first_name" maxlength="30" required ="required" data-validation-required-message="<bean:message key="global.missing" /> <bean:message key="admin.provider.formOfficialFirstName" />">
            <p class="help-block text-danger"></p>
        </div>
    </div>

<%
		if (org.oscarehr.common.IsPropertiesOn.isMultisitesEnable()) {
	%>
    <div class="control-group span5">
        <label class="control-label" for="sites"><bean:message
                key="admin.provider.sitesAssigned" /><span style="color:red">*</span></label>
        <div class="controls">

<%
	SiteDao siteDao = (SiteDao)WebApplicationContextUtils.getWebApplicationContext(application).getBean("siteDao");
List<Site> sites = ( isSiteAccessPrivacy ? siteDao.getActiveSitesByProviderNo(curProvider_no) : siteDao.getAllActiveSites());
for (int i=0; i<sites.size(); i++) {
%>
	<input type="checkbox" name="sites" minchecked="1" data-validation-minchecked-message="<bean:message key="global.missing" /> <bean:message
                key="admin.provider.sitesAssigned" />" value="<%=sites.get(i).getSiteId()%>"><%=Encode.forHtml(sites.get(i).getName())%><br />
<%
	}
%>
            <p class="help-block text-danger"></p>
        </div>
    </div>
<%
	}
%>

    <div class="control-group span5" id="provider_type_div">
        <label class="control-label" for="provider_type"><bean:message
                key="admin.provider.formType" /><span style="color:red">*</span></label>
        <div class="controls">
		    <select id="provider_type" name="provider_type" required ="required" data-validation-required-message="<bean:message key="global.missing" />">
			<option value="doctor" selected="selected"><bean:message
				key="admin.provider.formType.optionDoctor" /></option>
			<option value="receptionist"><bean:message
				key="admin.provider.formType.optionReceptionist" /></option>
			<option value="nurse"><bean:message
				key="admin.provider.formType.optionNurse" /></option>
			<option value="resident"><bean:message
				key="admin.provider.formType.optionResident" /></option>
			<option value="midwife"><bean:message
				key="admin.provider.formType.optionMidwife" /></option>
			<option value="admin"><bean:message
				key="admin.provider.formType.optionAdmin" /></option>
			<caisi:isModuleLoad moduleName="survey">
				<option value="er_clerk"><bean:message
					key="admin.provider.formType.optionErClerk" /></option>
			</caisi:isModuleLoad>
		</select>
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="status"><bean:message
                key="admin.provider.formStatus" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="radio" id="statusActive" name="status" value="1" checked><bean:message key="admin.provider.formStatusActive"/>&nbsp;&nbsp;
				<input type="radio" id="statusInactive" name="status" value="0"><bean:message key="admin.provider.formStatusInactive"/>
            <p class="help-block text-danger"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for"confidentiality"><bean:message
                key="admin.provider.confidentialityagreement" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="date" name="confidentiality" >
            <p class="help-block text-danger"></p>
        </div>
    </div>
        <%

            List<ProviderData>providerL = providerDataDao.findAllBilling("1");
        %>
    <div class="control-group span5">
        <label class="control-label" for="supervisor"><bean:message
                key="admin.provider.supervisor" /></label>
        <div class="controls">
		      <select id="supervisor" name="supervisor">
                    <option value="">- <bean:message
                key="admin.provider.supervisor" /> -</option>
                    <%
                    for( ProviderData p : providerL ) {
                    %>
                    <option value="<%=p.getId()%>"><%=Encode.forHtmlContent(p.getLastName() + ", " + p.getFirstName())%></option>

                    <%
                    }
                    %>
            </select>
            <p class="help-block text-danger"></p>
        </div>
    </div>

	<caisi:isModuleLoad moduleName="TORONTO_RFQ" reverse="true">
		<%
			if (OscarProperties.getInstance().getBooleanProperty("rma_enabled", "true")) {
		%>
    <div class="control-group span5">
        <label class="control-label" for="xml_p_nbr">Default Clinic NBR</label>
        <div class="controls">
						<select name="xml_p_nbr">
			<%
				ClinicNbrDao clinicNbrDAO = (ClinicNbrDao)SpringUtils.getBean("clinicNbrDao");
					List<ClinicNbr> nbrList = clinicNbrDAO.findAll();
					Iterator<ClinicNbr> nbrIter = nbrList.iterator();
					while (nbrIter.hasNext()) {
						ClinicNbr tempNbr = nbrIter.next();
						String valueString = tempNbr.getNbrValue() + " | " + tempNbr.getNbrString();
			%>
				<option value="<%=tempNbr.getNbrValue()%>" ><%=valueString%></option>
			<%}%>

			</select>
            <p class="help-block"></p>
        </div>
    </div>
		<%} %>

	</caisi:isModuleLoad>

    <div class="control-group span5">
        <label class="control-label" for="practitionerNoType"><bean:message
                key="admin.provider.formCPSIDType" /></label>
        <div class="controls">
		    <select name="practitionerNoType" id="practitionerNoType" onchange="if (this.value==''){$('#registrationNumbers').hide()}else{$('#registrationNumbers').show();}">
					<option value="">- <bean:message key="admin.provider.formCPSIDType" /> -</option>
					<%
						LookupListManager lookupListManager = SpringUtils.getBean(LookupListManager.class);
						LookupList ll = lookupListManager.findLookupListByName(LoggedInInfo.getLoggedInInfoFromSession(request), "practitionerNoType");
                        if(ll != null) {
						    for(LookupListItem llItem : ll.getItems()) {
							    %>
								    <option value="<%=llItem.getValue()%>"><%=llItem.getLabel()%></option>
							    <%
						    }
                        } else {
							%>
							<option value="" ><bean:message key="global.missing" /></option>
						    <%
						}
					%>
			</select>
            <p class="help-block"></p>
        </div>
    </div>

<div id="registrationNumbers">
    <div class="control-group span5">
        <label class="control-label" for="practitionerNo"><bean:message
                key="admin.provider.formCPSID" />#<span style="color:red">*</span></label>
        <div class="controls">
		    <input type="text" name="practitionerNo" id="practitionerNo" required="required"  maxlength="20"
                pattern="\d{1,20}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formPractitionerNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" />"
                data-validation-required-message="<bean:message key="global.missing" /> <bean:message
                key="admin.provider.formPractitionerNo" />">
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="ohip_no"><bean:message
                key="admin.provider.formOhipNo" /></label>
        <div class="controls">
		    <input type="text" name="ohip_no" maxlength="20"
                pattern="\d{1,20}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formOhipNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" />"
                >
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="rma_no"><bean:message
                key="admin.provider.formRmaNo"  /></label>
        <div class="controls">
		    <input type="text" name="rma_no" maxlength="20"
                pattern="\d{1,20}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formRmaNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" />"
                >
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="billing_no"><bean:message
                key="admin.provider.formBillingNo" /></label>
        <div class="controls">
		    <input type="text" name="billing_no" maxlength="20"
                pattern="[A-Z]?\d{1,20}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formBillingNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" />
                <oscar:oscarPropertiesCheck property="billregion" value="BC">
                    or in the pattern A1234
                </oscar:oscarPropertiesCheck>"
                >
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="hso_no"><bean:message
                key="admin.provider.formHsoNo"  /></label>
        <div class="controls">
		    <input type="text" name="hso_no" maxlength="10"
                pattern="\d{1,10}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formHsoNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" />"
                >
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="xml_p_specialty_code"><bean:message
                key="admin.provider.formSpecialtyCode" /></label>
        <div class="controls">
		    <input type="text" name="xml_p_specialty_code" maxlength="2"
                pattern="\d{2}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formSpecialtyCode" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.numericValue" /> nn"
                >
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="xml_p_billinggroup_no"><bean:message
                key="admin.provider.formBillingGroupNo" /></label>
        <div class="controls">
		    <input type="text" name="xml_p_billinggroup_no" maxlength="4"
                pattern="[A-Z\d]{4}"
                data-validation-pattern-message="<bean:message
                key="admin.provider.formBillingGroupNo" /> <bean:message
                key="oscarEncounter.oscarMeasurements.MeasurementsAction.mustBe" />  XXXX"
                >
            <p class="help-block"></p>
        </div>
    </div>
    <div class="control-group span5">
        <label class="control-label" for="admin.provider.billcenter"><bean:message
                key="admin.provider.billcenter" /></label>
        <div class="controls">
		    <select name="billcenter">
				<option value=""></option>
				<%
                    ProviderBillCenter billCenter = new ProviderBillCenter();
                    String billCode = "";
                    String codeDesc = "";
                    Enumeration<?> keys = billCenter.getAllBillCenter().propertyNames();
                    String defaultBillCenter = OscarProperties.getInstance().getProperty("default_bill_center","");

                    for(int i=0;i<billCenter.getAllBillCenter().size();i++){

                        billCode=(String)keys.nextElement();

                        String selectedBillCenter = "";
                        if (billCode.equalsIgnoreCase(defaultBillCenter))
                            selectedBillCenter = "selected=\"selected\"";

                        codeDesc=billCenter.getAllBillCenter().getProperty(billCode);
                %>
				<option value=<%=Encode.forHtmlAttribute(billCode) %> <%=selectedBillCenter%>><%= Encode.forHtmlContent(codeDesc)%></option>
				<%
                    }
                %>
			</select>
            <p class="help-block"></p>
        </div>
    </div>
</div> <!-- end registration nummber division -->

 </div>
<div id="contact_div">
 <div  id="optionalSection" class="span11">
		<fieldset>
			<legend><bean:message key="admin.provider.contactinfo" /></legend>
		</fieldset>


    <div class="control-group span5">
        <label class="control-label" for="team"><bean:message
                key="admin.provider.formTeam" /></label>
        <div class="controls">
		    <input type="text" name="team" maxlength="20">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="specialty"><bean:message
                key="admin.provider.formSpecialty" /></label>
        <div class="controls">
		    <input type="text" name="specialty"
				onBlur="upCaseCtrl(this)" maxlength="40">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="sex"><bean:message
                key="admin.provider.formSex" /></label>
        <div class="controls">
            <select  name="sex" id="sex" >//Value are Codes F M T O U Texts are Female Male Transgender Other Undefined
                <option value=""></option>
                <%
            	java.util.ResourceBundle oscarResources = ResourceBundle.getBundle("oscarResources", request.getLocale());
                String iterSex = "";
                String sexTag = "";
                for(Gender gn : Gender.values()){
                    sexTag = "global."+gn.getText();
                try{
                        iterSex = oscarResources.getString(sexTag) ;
                    } catch(Exception ex) {
                        //MiscUtils.getLogger().error("Error", ex);
                        //Fine then lets use the English default
                        iterSex = gn.getText();
                }
                %>
                <option value=<%=gn.name()%> ><%=iterSex%></option>
			                        <% } %>
            </select>
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="dob"><bean:message
                key="admin.provider.formDOB" /></label>
        <div class="controls">
		    <input type="date" name="dob" maxlength="11">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="address"><bean:message
                key="admin.provider.formAddress" /></label>
        <div class="controls">
		    <input type="text" name="address" size="40" maxlength="40">
            <p class="help-block"></p>
        </div>
    </div>


    <div class="control-group span5">
        <label class="control-label" for="phone"><bean:message
				key="admin.provider.formHomePhone" /></label>
        <div class="controls">
            <input type="text" name="phone" maxlength="20" onblur="formatPhone(this);">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="workphone"><bean:message
                key="admin.provider.formWorkPhone" /></label>
        <div class="controls">
			<input type="text" name="workphone" value="" maxlength="20" onblur="formatPhone(this);">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="email"><bean:message
                key="admin.provider.formEmail" /></label>
        <div class="controls">
			<input type="email" name="email" value=""
                data-validation-email-message="<bean:message key="global.alertinvalid" />">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="xml_p_pager"><bean:message
                key="admin.provider.formPager" /></label>
        <div class="controls">
			<input type="text" name="xml_p_pager" value="" onblur="formatPhone(this);">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="xml_p_cell"><bean:message
                key="admin.provider.formCell" /></label>
        <div class="controls">
			<input type="text" name="xml_p_cell" value="" onblur="formatPhone(this);">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="xml_p_phone2"><bean:message
                key="admin.provider.formOtherPhone" /></label>
        <div class="controls">
			<input type="text" name="xml_p_phone2" value="" onblur="formatPhone(this);">
            <p class="help-block"></p>
        </div>
    </div>

    <div class="control-group span5">
        <label class="control-label" for="xml_p_fax"><bean:message
                key="admin.provider.formFax" /></label>
        <div class="controls">
			<input type="text" name="xml_p_fax" value="" onblur="formatPhone(this);">
            <p class="help-block"></p>
        </div>
    </div>
		<input type="hidden" name="provider_activity" value="">

		<input type="hidden" name="xml_p_slpusername">
		<input type="hidden" name="xml_p_slppassword">


 </div>
</div>
</div>

		<div width="100%" align="center" class="span12">

		<input type="submit" name="submitbtn" class="btn btn-primary"
			value="<bean:message key="admin.provideraddrecordhtm.btnProviderAddRecord"/>">&nbsp;&nbsp;
<a class="btn-link" onclick="$('#contact_div').toggle();"><bean:message key="global.showhide"/> <bean:message key="admin.provider.contactinfo"/></a>
		</div>
</form>


</body>
</html:html>