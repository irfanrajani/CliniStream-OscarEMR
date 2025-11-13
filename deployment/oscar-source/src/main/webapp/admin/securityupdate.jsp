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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
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

<%@ page import="oscar.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.security.*" %>
<%@ page import="oscar.oscarDB.*" %>
<%@ page import="oscar.log.LogAction" %>
<%@ page import="oscar.log.LogConst" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.Security" %>
<%@ page import="org.oscarehr.common.dao.SecurityDao" %>
<%@ page import="com.j256.twofactorauth.TimeBasedOneTimePasswordUtil" %>

<%
	SecurityDao securityDao = SpringUtils.getBean(SecurityDao.class);
%>

<html:html locale="true">
<head>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
<script src="<%=request.getContextPath() %>/library/qrcode.min.js"></script>
<title><bean:message key="admin.securityupdate.description" /></title>
</head>
<link rel="stylesheet" href="../web.css" />
<body topmargin="0" leftmargin="0" rightmargin="0">
<div >
    <div  id="header"><H3>&nbsp;<i class="icon-lock"></i>&nbsp;<bean:message
			key="admin.securityupdate.description" /></H3>
    </div>
</div>

<%
	StringBuffer sbTemp = new StringBuffer();
    MessageDigest md = MessageDigest.getInstance("SHA");
    byte[] btNewPasswd= md.digest(request.getParameter("password").getBytes());
    for(int i=0; i<btNewPasswd.length; i++) sbTemp = sbTemp.append(btNewPasswd[i]);

    String sPin = request.getParameter("pin");
    if (OscarProperties.getInstance().isPINEncripted()) sPin = Misc.encryptPIN(request.getParameter("pin"));

    int rowsAffected =0;
    String secret =  TimeBasedOneTimePasswordUtil.generateBase32Secret();

    Security s = securityDao.find(Integer.parseInt(request.getParameter("security_no")));
    if(s != null) {
    	if (s.getTotpSecret().equals("") || ( request.getParameter("resetSecret")!=null && "true".equals(request.getParameter("resetSecret")) )) {
    		s.setTotpSecret(secret);
    	} else {
    		secret = s.getTotpSecret();
    	}
    	s.setUserName(request.getParameter("user_name"));
	    s.setProviderNo(request.getParameter("provider_no"));
	    s.setBExpireset(request.getParameter("b_ExpireSet")==null?0:Integer.parseInt(request.getParameter("b_ExpireSet")));
	    s.setDateExpiredate(MyDateFormat.getSysDate(request.getParameter("date_ExpireDate")));
	    s.setBLocallockset(request.getParameter("b_LocalLockSet")==null?0:Integer.parseInt(request.getParameter("b_LocalLockSet")));
	    s.setBRemotelockset(request.getParameter("b_RemoteLockSet")==null?0:Integer.parseInt(request.getParameter("b_RemoteLockSet")));

    	if(request.getParameter("password")==null || !"*********".equals(request.getParameter("password"))){
    		s.setPassword(sbTemp.toString());
    		s.setPasswordUpdateDate(new java.util.Date());
    	}

    	if(request.getParameter("pin")==null || !"****".equals(request.getParameter("pin"))) {
    		s.setPin(sPin);
    		s.setPinUpdateDate(new java.util.Date());
    	}

    	if (request.getParameter("forcePasswordReset") != null && request.getParameter("forcePasswordReset").equals("1")) {
    	    s.setForcePasswordReset(Boolean.TRUE);
    	} else {
    		s.setForcePasswordReset(Boolean.FALSE);
        }

    	if (request.getParameter("2fa") != null && request.getParameter("2fa").equals("1")) {
    	    s.setTotpEnabled(Boolean.TRUE);
    	} else {
    		s.setTotpEnabled(Boolean.FALSE);
        }

    	s.setLastUpdateDate(new java.util.Date());

    	securityDao.saveEntity(s);
    	rowsAffected=1;
    }


  if (rowsAffected ==1) {
      LogAction.addLog((String) request.getSession().getAttribute("user"), LogConst.UPDATE, LogConst.CON_SECURITY,
    		request.getParameter("security_no") + "->" + request.getParameter("user_name"), request.getRemoteAddr());
%>

<div class="alert alert-success" >
    <h4><bean:message key="admin.securityupdate.msgUpdateSuccess" /> <%=request.getParameter("provider_no")%></h4>
</div>

<%
  } else {
%>
<div class="alert alert-error" >
    <h4><bean:message key="admin.securityupdate.msgUpdateFailure" /><%= request.getParameter("provider_no") %>.</h4>
</div>

<%
  }
%>
<% if (request.getParameter("2fa") != null && request.getParameter("2fa").equals("1")) {
    // the default specification will have 6 digits and SHA1 with 30 s validity
    String authUrl = "otpauth://totp/OSCAR"+request.getParameter("provider_no")+"?secret="+secret+"&issuer=Oscar%20EMR";
%>

<div class="container-fluid well" >
    <div class="control-group span4">
         <div id="qrcode" class="qrcode"></div>
    </div>

<script type="text/javascript">
    let qrcodeContainer = document.getElementById("qrcode");
    qrcodeContainer.innerHTML = "";
    new QRCode(qrcodeContainer, {
          text: "<%=authUrl%>",
          width: 200,
          height: 200
        });
</script>

    <div class="control-group span4">
        <p><bean:message
                key="admin.provider.2fa.qr"/></p><br>
        <input type="button" class="btn btn-primary" value="<bean:message
                key="global.btnPrint"/>" onclick="window.print();">
    </div>
</div>
<% } %>
</body>
</html:html>