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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    		boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.userAdmin" rights="r"
	reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.userAdmin");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<%
    String curProvider_no = (String) session.getAttribute("user");

    boolean isSiteAccessPrivacy=false;
%>

<security:oscarSec objectName="_site_access_privacy" roleName="<%=roleName$%>" rights="r" reverse="false">
	<%isSiteAccessPrivacy=true; %>
</security:oscarSec>


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>

<%@ page import="oscar.*" errorPage="errorpage.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.*" %>

<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Provider" %>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao" %>
<%@page import="org.oscarehr.common.model.Security" %>
<%@page import="org.oscarehr.common.dao.SecurityDao" %>
<%@page import="com.quatro.web.admin.SecurityAddSecurityHelper"%>
<%@ page import="com.j256.twofactorauth.TimeBasedOneTimePasswordUtil" %>

<%
	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	SecurityDao securityDao = SpringUtils.getBean(SecurityDao.class);

	OscarProperties op = OscarProperties.getInstance();
%>

<html:html locale="true">
<head>
<style>
	/* Style for providers with security records */
	.providerSecurity1 {
		color: gray;
	}

	/* Style for providers without security records */
	.providerSecurity0 {
		color: black;
	}
</style>
<style media="print">
 .DoNotPrint {
	display: none;
 }
</style>
<script src="<%= request.getContextPath() %>/js/checkPassword.js.jsp"></script>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

<script src="<%=request.getContextPath() %>/library/jquery/jquery-3.6.4.min.js"></script>
<script src="<%=request.getContextPath() %>/js/jqBootstrapValidation-1.3.7.min.js"></script>
<title><bean:message key="admin.securityaddarecord.title" /></title>
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

	function togglePins() {
		var is2fa = document.getElementById('2fa').value;
		var pin1 = document.getElementById("pin1");
		var pin2 = document.getElementById("pin2");
		if (is2fa == 1) {
			pin1.style.display = "none";
			pin2.style.display = "none";
		} else {
			pin1.style.display= "block";
			pin2.style.display= "block";

		}
	}

	function selected() {
		var selectedOption = $('#provider_no option:selected');
		if (selectedOption) {
			var optionClass = selectedOption.attr("class");
			if (optionClass == "providerSecurity1") {
				alert('<bean:message key="admin.securityrecord.msgProviderAlreadyHasSecurityRec" />');
			}
		}
    }
</script>



</head>

<body onLoad="togglePins();" >
<div style="width:100%">
    <div id="header"><H4><i class="icon-lock"></i>&nbsp;<bean:message
			key="admin.securityaddarecord.description" /></H4>
    </div>
</div>

<%
    String sPass = request.getParameter("password");
    if ( sPass != null && sPass != "" ){
    SecurityAddSecurityHelper helper = new SecurityAddSecurityHelper();
	helper.addProvider(pageContext);
%>
<div class="alert alert-info" >
    <strong><bean:message key="${message}" />&nbsp;<%=request.getParameter("provider_no")%><strong>
</div>

    <% if (request.getParameter("2fa") != null && request.getParameter("2fa").equals("1")) {

    List<Security> s = securityDao.findByProviderNo(request.getParameter("provider_no"));
        String secret = s.get(0).getTotpSecret();
	    String qrUrl =  TimeBasedOneTimePasswordUtil.qrImageUrl("OSCAR",secret);
    %>
    <div class="container-fluid well" id="qrdisplay">
        <div class="control-group span4">
	        <p><img src="<%=qrUrl%>" alt="<%=secret%>"></p>
        </div>
        <div class="control-group span4">
            <p><bean:message
                    key="admin.provider.2fa.qr"/></p><br>
            <input type="button" class="btn btn-primary DoNotPrint" value="<bean:message
                    key="global.btnPrint"/>" onclick="window.print();">
        </div>
    </div>
<input type="button" class="btn DoNotPrint" value="<bean:message
                    key="global.btnReset"/>" onclick="document.getElementById('addnew').style.display='block';document.getElementById('qrdisplay').style.display='none';">
    <div id="addnew" style="display:none;">
    <% } else { %>
    <div id="addnew">
    <% } %>
<% } %>

<form method="post" action="securityaddarecord.jsp" name="searchprovider" autocomplete="off"
	novalidate>
<table style="width:400px; text-align:center" class="DoNotPrint">
<tr><td >
<div class="container-fluid well form-horizontal" >
    <div class="control-group span7">
        <label class="control-label" for="user_name"><bean:message
                key="admin.securityrecord.formUserName" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="text" name="user_name" id="user_name"
		    value=""
		    maxlength="30" required ="required"
            data-validation-required-message='<bean:message key="admin.securityrecord.formUserName" /> <bean:message key="admin.securityrecord.msgIsRequired"/>'>
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="password"><bean:message
                key="admin.securityrecord.formPassword" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="password"
            autocomplete="new-password" name="password" id="password" required ="required"
            data-validation-required-message='<bean:message key="admin.securityrecord.formPassword" /> <bean:message key="admin.securityrecord.msgIsRequired"/>'
            data-validation-compexity-regex="^(?:(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\d\W])|(?=.*\W)(?=.*\d))|(?=.*\W)(?=.*[A-Z])(?=.*\d)).{8,}$"
            data-validation-compexity-message="<bean:message key="password.policy.violation.msgPasswordStrengthError"/>
        <%=op.getProperty("password_min_groups")%>   <bean:message key="password.policy.violation.msgPasswordGroups"/>"
            data-validation-length-regex=".{<%=op.getProperty("password_min_length")%>,255}"
            data-validation-length-message="<bean:message key="password.policy.violation.msgPasswordStrengthError"/> <%=op.getProperty("password_min_length")%> <bean:message key="admin.securityrecord.msgSymbols" />"
		    >
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="conPassword"><bean:message
                key="admin.securityrecord.formConfirm"  /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="password"
            autocomplete="off" name="conPassword" id="conPassword"
		    data-validation-match-match="password"
            data-validation-match-message='<bean:message key="admin.securityrecord.msgPasswordNotConfirmed" />'
            required ="required"
            data-validation-required-message="<bean:message key="global.missing" /> <bean:message key="admin.securityrecord.formConfirm" />">
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="provider_no"><bean:message
                key="admin.securityrecord.formProviderNo" /><span style="color:red">*</span></label>
        <div class="controls">
		    <select name="provider_no" id="provider_no" onchange="selected();"
            required ="required"
            data-validation-required-message='<bean:message key="admin.securityrecord.formProviderNo" /> <bean:message key="admin.securityrecord.msgIsRequired"/>'>
			<option value="">- <bean:message
                key="admin.securityrecord.formProviderNo" /> -</option>
<%
	List<Map<String,Object>> resultList ;

    	for(Provider p : providerDao.getActiveProviders()) {
    		List<Security> s = securityDao.findByProviderNo(p.getProviderNo());
    		if(s.size() == 0) {
    			%>
    			<option value="<%=p.getProviderNo()%>" class="providerSecurity0"><%=p.getFormattedName()%></option>
    			<%
    		} else {
    			%>
    			<option value="<%=p.getProviderNo()%>" class="providerSecurity1"><%=p.getFormattedName()%></option>
    			<%
            }
    	}

%>
		</select>
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="date_ExpireDate"><bean:message
                key="admin.securityrecord.formExpiryDate" /></label>
        <div class="controls">
		    <input type="checkbox" name="b_ExpireSet" value="1" <%="checked" %> > <bean:message
			key="admin.securityrecord.formDate" />: <input type="date" name="date_ExpireDate" id="date_ExpireDate"
			value="" class="input-medium" >
            <p class="help-block text-danger"></p>
        </div>
    </div>
	<input type="hidden" name="pinIsRequired" value="0" >
    <div class="control-group span7">
        <label class="control-label" for="2fa"><bean:message
                key="admin.provider.2fa"  /></label>
        <div class="controls">
			<select name="2fa" id="2fa" onchange="togglePins()">
								<option value="1"><bean:message key="global.yes" /></option>
								<option value="0"><bean:message key="global.no" /></option>
			</select>
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="b_RemoteLockSet"><bean:message
                key="admin.securityrecord.formRemotePIN" /></label>
        <div class="controls">
		    <input type="checkbox" name="b_RemoteLockSet" id="b_RemoteLockSet" value="1" <%="checked" %> >
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="b_LocalLockSet"><bean:message
                key="admin.securityrecord.formLocalPIN" /></label>
        <div class="controls">
		    <input type="checkbox" name="b_LocalLockSet" id="b_LocalLockSet"
			value="1" <%=op.getBooleanProperty("caisi","on")?"checked":"" %> >
            <p class="help-block text-danger"></p>
        </div>
    </div>


    <div id="pin1" class="control-group span7">
        <label class="control-label" for="pin"><bean:message
                key="admin.securityrecord.formPIN"  /></label>
        <div class="controls">
		    <input type="password" name="pin" id="pin"
            autocomplete="off"
            minlength="<%=op.getProperty("password_pin_min_length")%>"
            data-validation-minlength-message="<bean:message key="admin.securityrecord.msgAtLeast" /> <%=op.getProperty("password_pin_min_length")%> <bean:message
			key="admin.securityrecord.msgDigits" />"
            pattern="\d*"
            data-validation-pattern-message="<bean:message key="password.policy.violation.msgPinGroups"/>"
            >
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div id="pin2" class="control-group span7">
        <label class="control-label" for="conPin"><bean:message
                key="admin.securityrecord.formConfirm"  /></label>
        <div class="controls">
		    <input type="password" name="conPin" id="conPin"
            autocomplete="off"
		    data-validation-match-match="pin"
            data-validation-match-message='<bean:message key="admin.securityrecord.msgPinNotConfirmed" />'
             >
            <p class="help-block text-danger"></p>
        </div>
    </div>

	<%
		if (!OscarProperties.getInstance().getBooleanProperty("mandatory_password_reset", "false")) {
	%>
    <div class="control-group span7">
        <label class="control-label" for="forcePasswordReset"><bean:message
                key="admin.provider.forcePasswordReset"  /></label>
        <div class="controls">
			<select name="forcePasswordReset" id="forcePasswordReset">
								<option value="1"><bean:message key="global.yes" /></option>
								<option value="0"><bean:message key="global.no" /></option>
			</select>
            <p class="help-block text-danger"></p>
        </div>
    </div>
   <%} %>
</div>

		<div style="text-align:center" class="span9">

		<input type="submit" name="subbutton" class="btn btn-primary"
			value='<bean:message key="admin.securityaddarecord.btnSubmit"/>'>
		</div>
</td></tr>
</table>

</form>

</body>
</html:html>