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
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ page import="java.lang.*, java.util.*, java.text.*,java.sql.*, oscar.*"%>

<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Security" %>
<%@ page import="org.oscarehr.common.dao.SecurityDao" %>
<%@ page import="org.owasp.encoder.Encode" %>

<%!
	OscarProperties op = OscarProperties.getInstance();
%>

<html:html locale="true">
<head>
<script src="<%= request.getContextPath() %>/js/checkPassword.js.jsp"></script>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

<script src="<%=request.getContextPath() %>/library/jquery/jquery-3.6.4.min.js"></script>
<script src="<%=request.getContextPath() %>/js/jqBootstrapValidation-1.3.7.min.js"></script>
<title><bean:message key="admin.securityupdatesecurity.title" /></title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet"></script>
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

<!--
	function setfocus(el) {
		this.focus();
		document.updatearecord.elements[el].focus();
		document.updatearecord.elements[el].select();
	}
	function onsub() {
		if (document.updatearecord.user_name.value=="") {
			alert('<bean:message key="admin.securityrecord.formUserName" /> <bean:message key="admin.securityrecord.msgIsRequired"/>');
			setfocus('user_name');
			return false;
		}
		if (document.updatearecord.password.value=="") {
			alert('<bean:message key="admin.securityrecord.formPassword" /> <bean:message key="admin.securityrecord.msgIsRequired"/>');
			setfocus('password');
			return false;
		}
		if (document.updatearecord.password.value != "*********" && !validatePassword(document.updatearecord.password.value)) {
			setfocus('password');
			return false;
		}
		if (document.forms[0].password.value != document.forms[0].conPassword.value) {
			alert('<bean:message key="admin.securityrecord.msgPasswordNotConfirmed" />');
			setfocus('conPassword');
			return false;
		}
		if (document.updatearecord.provider_no.value=="") {
			return false;
		}
		if (document.forms[0].b_ExpireSet.checked && document.forms[0].date_ExpireDate.value.length<10) {
			alert('<bean:message key="admin.securityrecord.formDate" /> <bean:message key="admin.securityrecord.msgIsRequired"/>');
			setfocus('date_ExpireDate');
			return false;
		}
		if (document.forms[0].b_RemoteLockSet.checked || document.forms[0].b_LocalLockSet.checked) {
			if (document.forms[0].pin.value=="") {
				alert('<bean:message key="admin.securityrecord.formPIN" /> <bean:message key="admin.securityrecord.msgIsRequired"/>');
				setfocus('pin');
				return false;
			}
		}

		if (document.forms[0].pin.value != "****" && !validatePin(document.forms[0].pin.value)) {
			setfocus('pin');
			return false;
		}
		if (document.forms[0].pin.value != document.forms[0].conPin.value) {
			alert('<bean:message key="admin.securityrecord.msgPinNotConfirmed" />');
			setfocus('conPin');
			return false;
		}
		return true;
	}
//-->
<script>
	function togglePins() {
		var is2fa = document.getElementById('2fa').value;
		var pin1 = document.getElementById("pin1");
		var pin2 = document.getElementById("pin2");
		if (is2fa == 1) {
			pin1.style.display = "none";
			pin2.style.display = "none";
            document.getElementById("reset2fa").style.display = "block";
		} else {
			pin1.style.display= "block";
			pin2.style.display= "block";
            document.getElementById("reset2fa").style.display = "none";
		}
	}
</script>
</head>

<body onLoad="togglePins();" >
<div style="width:100%">
    <div id="header"><H4><i class="icon-lock"></i>&nbsp;<bean:message
			key="admin.securityupdatesecurity.description" /></H4>
    </div>
</div>


	<form method="post" action="securityupdate.jsp" name="updatearecord" autocomplete="off"
	novalidate>
<table style="width:400px; text-align:center">
<%
	SecurityDao securityDao = SpringUtils.getBean(SecurityDao.class);
	Integer securityId = Integer.valueOf(request.getParameter("keyword"));
	Security security = securityDao.find(securityId);

	if(security == null) {
%>
	<tr>
		<td>
            <div class="alert alert-error" >
                <h4><bean:message key="admin.securityupdatesecurity.msgFailed" /></h4>
            </div>
        </td>
	</tr>
<%
	}
	else {
%>
<tr><td>
<div class="container-fluid well form-horizontal" >
    <div class="control-group span7">
        <label class="control-label" for="user_name"><bean:message
                key="admin.securityrecord.formUserName" /><span style="color:red">*</span></label>
        <div class="controls">
		    <input type="text" name="user_name" id="user_name"
		    value="<%= Encode.forHtmlContent(security.getUserName()) %>"
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
value="*********"
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
            value="*********"
		    data-validation-match-match="password"
            data-validation-match-message='<bean:message key="admin.securityrecord.msgPasswordNotConfirmed" />'
            required ="required"
            data-validation-required-message="<bean:message key="global.missing" /> <bean:message key="admin.securityrecord.formConfirm" />">
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label"><bean:message
                key="admin.securityrecord.formProviderNo" /><span style="color:red">*</span></label>
        <div class="controls">
		    <%=  Encode.forHtmlContent(security.getProviderNo()) %>
		<input type="hidden" name="provider_no" id="provider_no"
			value="<%= security.getProviderNo() %>">
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="date_ExpireDate"><bean:message
                key="admin.securityrecord.formExpiryDate" /></label>
        <div class="controls">
		    <input type="checkbox" name="b_ExpireSet" value="1" <%= security.getBExpireset()==0?"":"checked" %>>
            <bean:message
			key="admin.securityrecord.formDate" />: <input type="date" name="date_ExpireDate" id="date_ExpireDate"
			value="<%=  security.getDateExpiredate() ==null?"": security.getDateExpiredate()  %>" class="input-medium" >
            <p class="help-block text-danger"></p>
        </div>
    </div>
        <div class="control-group span7">
        <label class="control-label" for="2fa"><bean:message
                key="admin.provider.2fa" /></label>
        <div class="controls">
			<select name="2fa" id="2fa" onchange="togglePins()">
				<option value="1" <% if (security != null && security.isTotpEnabled()!= null && security.isTotpEnabled()) { %>
					     SELECTED <%}%>><bean:message key="global.yes" /></option>
				<option value="0" <% if (security != null && security.isTotpEnabled()!= null && !security.isTotpEnabled()) { %>
					     SELECTED <%}%>><bean:message key="global.no" /></option>
			</select>
            <input type="button" id="reset2fa" class="btn" value="<bean:message key="admin.provider.2fa.reset" />" onclick="document.getElementById('resetSecret').value='true';this.disabled = true;">
            <input type="hidden"  id="resetSecret" name="resetSecret">
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="b_RemoteLockSet"><bean:message
                key="admin.securityrecord.formRemotePIN" /></label>
        <div class="controls">
		    <input type="checkbox" name="b_RemoteLockSet" id="b_RemoteLockSet" value="1" <%= security.getBRemotelockset()==0?"":"checked" %>>
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div class="control-group span7">
        <label class="control-label" for="b_LocalLockSet"><bean:message
                key="admin.securityrecord.formLocalPIN" /></label>
        <div class="controls">
		    <input type="checkbox" name="b_LocalLockSet" id="b_LocalLockSet"
			value="1" <%= security.getBLocallockset()==0?"":"checked" %>>
            <p class="help-block text-danger"></p>
        </div>
    </div>
    <div id="pin1" class="control-group span7">
        <label class="control-label" for="pin"><bean:message
                key="admin.securityrecord.formPIN"  /></label>
        <div class="controls">
		    <input type="password" name="pin" id="pin"
            autocomplete="off"
            value="****"
            minlength="<%=op.getProperty("password_pin_min_length")%>"
            data-validation-minlength-message="<bean:message key="admin.securityrecord.msgAtLeast" /> <%=op.getProperty("password_pin_min_length")%> <bean:message
			key="admin.securityrecord.msgDigits" />"
            pattern="\**|\d*"
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
            value="****"
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
								<option value="1" <% if (security != null && security.isForcePasswordReset()!= null && security.isForcePasswordReset()) { %>
					                          SELECTED <%}%>><bean:message key="global.yes" /></option>
								<option value="0" <% if (security != null && security.isForcePasswordReset()!= null && !security.isForcePasswordReset()) { %>
					                          SELECTED <%}%>><bean:message key="global.no" /></option>
			</select>
            <p class="help-block text-danger"></p>
        </div>
    </div>

   <%} %>
</div>

		<div style="text-align:center" class="span9">
            <input type="hidden" name="security_no" value="<%= security.getSecurityNo() %>">
			<input type="submit" name="subbutton" class="btn btn-primary" value='<bean:message key="admin.securityupdatesecurity.btnSubmit"/>'>
			<input type="button" class="btn" value="<bean:message key="admin.securityupdatesecurity.btnDelete"/>" onclick="window.location='securitydelete.jsp?keyword=<%=security.getSecurityNo()%>'">
		</div>


<%
		}
%>
</td></tr>
</table>
	</form>
<p></p>
</body>
</html:html>