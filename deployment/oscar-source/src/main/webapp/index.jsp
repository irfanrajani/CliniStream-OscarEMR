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

<%@page import="org.oscarehr.common.service.AcceptableUseAgreementManager"%>
<%@page import="oscar.OscarProperties, javax.servlet.http.Cookie, oscar.oscarSecurity.CookieSecurity, oscar.login.UAgentInfo" %>
<%@ page import="java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>
<caisi:isModuleLoad moduleName="ticklerplus"><%
    if(session.getValue("user") != null) {
        response.sendRedirect("provider/providercontrol.jsp");
    }
%></caisi:isModuleLoad><%
OscarProperties props = OscarProperties.getInstance();

// clear old cookies
Cookie prvCookie = new Cookie(CookieSecurity.providerCookie, "");
prvCookie.setPath("/");
response.addCookie(prvCookie);

String econsultUrl = props.getProperty("backendEconsultUrl");

// Initialize browser info variables
String userAgent = request.getHeader("User-Agent");
String httpAccept = request.getHeader("Accept");
UAgentInfo detector = new UAgentInfo(userAgent, httpAccept);

// This parameter exists only if the user clicks the "Full Site" link on a mobile device
if (request.getParameter("full") != null) {
    session.setAttribute("fullSite","true");
}

// If a user is accessing through a smartphone (currently only supports mobile browsers with webkit),
// and if they haven't already clicked to see the full site, then we set a property which is
// used to bring up iPhone-optimized stylesheets, and add or remove functionality in certain pages.
if (detector.detectSmartphone() && detector.detectWebkit()  && session.getAttribute("fullSite") == null) {
    session.setAttribute("mobileOptimized", "true");
} else {
    session.removeAttribute("mobileOptimized");
}
Boolean isMobileOptimized = session.getAttribute("mobileOptimized") != null;

String hostPath = request.getScheme() + "://" + request.getHeader("Host") +  ":" + request.getLocalPort();
String loginUrl = hostPath + request.getContextPath();

String ssoLoginMessage = "";
if (request.getParameter("email") != null) {
	ssoLoginMessage = "Hello " + request.getParameter("email") + "<br>"
						+ "Please login with your OSCAR credentials to link your accounts.";
}
else if (request.getParameter("errorMessage") != null) {
	ssoLoginMessage = request.getParameter("errorMessage");
}

//Input field styles
String login_input_style="login_txt_fields";

//Gets the request URL
StringBuffer oscarUrl = request.getRequestURL();
//Determines the initial length by subtracting the length of the servlet path from the full url's length
Integer urlLength = oscarUrl.length() - request.getServletPath().length();
//Sets the length of the URL, found by subtracting the length of the servlet path from the length of the full URL, that way it only gets up to the context path
oscarUrl.setLength(urlLength);

boolean oneIdEnabled = "true".equalsIgnoreCase(OscarProperties.getInstance().getProperty("oneid.enabled","false"));
boolean oauth2Enabled= "true".equalsIgnoreCase(OscarProperties.getInstance().getProperty("oneid.oauth2.enabled","false")); 
%>

<html:html locale="true">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="shortcut icon" href="images/Oscar.ico" />
<!-- script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script -->
        <html:base/>
        <% if (isMobileOptimized) { %><meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width"/><% } %>
        <title>
            <% if (props.getProperty("logintitle", "").equals("")) { %>
            <bean:message key="loginApplication.title"/>
            <% } else { %>
            <%= props.getProperty("logintitle", "")%>
            <% } %>
        </title>
    <!--LINK REL="StyleSheet" HREF="web.css" TYPE="text/css"-->

    <script language="JavaScript">
        function showHideItem(id){
            if(document.getElementById(id).style.display == 'none'){
                document.getElementById(id).style.display = 'block';
            } else {
                document.getElementById(id).style.display = 'none';
            }
        }      

        function setfocus() {
            document.loginForm.username.focus();
            document.loginForm.username.select();
        }

  		function addStartTime() {
            	document.getElementById("oneIdLogin").href += (Math.round(new Date().getTime() / 1000).toString());
		}

        function showPwd(id){
            if ('password' == document.getElementById(id).type ){
                document.getElementById(id).type="text"
            }else{
                document.getElementById(id).type='password';
            }
        }

        var mask=true;
        function maskMe(){
            if (!mask){
                document.getElementById('pin').value=document.getElementById('pin2').value;
                return;
            }
            var key = event.keyCode || event.charCode;
            if( key == 8 ){
            	//backspace pressed
                let str = document.getElementById('pin').value;
                str = str.substring(0, str.length - 1);
                document.getElementById('pin').value = str;
            } else {
            document.getElementById('pin').value += document.getElementById('pin2').value.slice(-1);
            document.getElementById('pin2').value = document.getElementById('pin2').value.replace(/./g,"*");
            }
        }

        function checkMe(){
            //if you have deleted
            if (document.getElementById('pin2').value == "") {
                document.getElementById('pin').value = "";
            }
        }


        function toggleMask(){
            if (document.getElementById('pin2').value.slice(0,1) != "*" ){
                document.getElementById('pin2').value = document.getElementById('pin').value.replace(/./g,"*");
                mask = true;
            }else{
                document.getElementById('pin2').value = document.getElementById('pin').value;
                mask = false;
            }
        }
    </script>
        

    <% if (isMobileOptimized) { %>
        <!-- Small adjustments are made to the mobile stylesheet -->
        <style type="text/css">
            html { -webkit-text-size-adjust: none; }
            td.topbar{ width: 75%; }
            td.leftbar{ width: 25%; }
            span.extrasmall{ font-size: small; }
            #browserInfo, #logoImg, #buildInfo { display: none; }
            #mobileMsg { display: inline; }
    </style>
    <% } %>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- link href="<%=request.getContextPath() %>/css/font-awesome.min.css" rel="stylesheet" type="text/css" -->
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">

    <style type="text/css">
             #mobileMsg { display: none; }
                       
            input[type="text"],input[type="password"] {
                width: 100%; 
                margin: 0px auto;
                height:30px;
                margin-bottom: 10px;
            }
            
            @supports (-webkit-box-reflect:unset) {  
                [class^="icon-"], [class*=" icon-"] {
                    display: none;
                }
            }

            @-moz-document url-prefix() { 
                [class^="icon-"], [class*=" icon-"] {
                    display: inline block;
                }
                i {
                    color: black;  
                    cursor: pointer; 
                    font-size:14px;
                    position: relative;
                    margin-left: -36px;
                    margin-bottom: 6px;               
                } 
            }

            .oneIdLogin {
                //background-color: #000;
                width: 60%;
                height: 34px;
                margin: 0px auto;
            }

            .oneIdLogo {
                background-color: transparent;
                background: url("./images/oneId/oneIDLogo.png");
                border: none;
                display: inline-block;
                float: left;
                vertical-align: bottom;
                width: 70px;
                height: 16px;
            }

            .oneIDText {
                display: inline-block;
                float: left;
                padding-left: 10px
            }
    </style>

     </head>
    <body onLoad="setfocus();checkMe();" >

<div class="container" style="border-style: solid; border-color: #49afcd; border-radius:25px; border-width: 1px; margin-top: 25px; padding: 14px;">

<br>
<br>

<div class="row">
        <div class="span4 text-center">
            <% if (props.getProperty("loginlogo", "").equals("")) { %>
                <html:img srcKey="loginApplication.image.logo" width="450" height="274" style="margin:auto; padding:14px;"/>
            <% } else { %>
                <img src="<%=props.getProperty("loginlogo", "")%>" <%=props.getProperty("loginlogo.attributes", "style='margin:auto; padding:14px;'")%>>              
            <% } %>
        </div> 
		<div class="span4 well">
			<legend>
                <h4><%=ssoLoginMessage%></h4>
                <%=props.getProperty("logintitle", "")%>
                <% if (props.getProperty("logintitle", "").equals("")) { %>
                    <bean:message key="loginApplication.alert"/>
                <% } %>   
            </legend>
          	
            <%
            String key2 = "loginApplication.formLabel" ;
            if((request.getParameter("login")!=null && request.getParameter("login").equals("failed") )){
                key2 = "loginApplication.formFailedLabel" ;
                %>
                <div class="alert alert-error" >                  
            <% } else { %>
                <div> 
            <% } %>
            <bean:message key="<%=key2%>"/><br>
            </div><p>
            <html:form action="login" >
                <% if(oscar.oscarSecurity.CRHelper.isCRFrameworkEnabled() && !net.sf.cookierevolver.CRFactory.getManager().isMachineIdentified(request)){ %>
                    <img src="gatekeeper/appid/?act=image&/empty<%=System.currentTimeMillis() %>.gif" width='1' height='1'>
                <% } %>
           
            <input type="text" id="username"  name="username" autocomplete="off" placeholder="<bean:message key="loginApplication.formUserName"/>">
            <input type="password" id="password2" name="password" placeholder="<bean:message key="loginApplication.formPwd"/>" >
            <i class="icon-eye-open" onclick="showPwd('password2');"></i>

            <span class="help-block"><bean:message key="loginApplication.formCmt"/></span>
			<input type="text" id="pin2" name="pin2" autocomplete="off" placeholder="<bean:message key="index.formPIN"/>" 
onkeyup="maskMe();" onchange="checkMe();">
            <i class="icon-eye-open" onclick="toggleMask();"></i>
            <input type="hidden" id="pin" name="pin" value="">
            
            <%if(oneIdEnabled && !oauth2Enabled) { %>
                <a href="<%=econsultUrl %>/SAML2/login?oscarReturnURL=<%=URLEncoder.encode(oscarUrl + "/ssoLogin.do", "UTF-8") + "?loginStart="%>" id="oneIdLogin" onclick="addStartTime()"><div class="btn btn-primary btn-block oneIDLogin"><span class="oneIDLogo"></span><span class="oneIdText">ONE ID Login</span></div></a>
            <% } %>
            <%if(oneIdEnabled && oauth2Enabled) { %>
                <a href="<%=request.getContextPath() %>/eho/login2.jsp" id="oneIdLoginOauth"><div class="btn btn-primary btn-block oneIDLogin"><span class="oneIDLogo"></span><span class="oneIdText">ONE ID Login</span></div></a>
            <% } %>
			<button type="submit" name="submit" class="btn btn-primary btn-block" style="width: 60%; margin: 0px auto;" ><bean:message key="index.btnSignIn"/></button>

               <br><p><small><%=props.getProperty("logintext", "")%></small></p> 		   
		</div>
 
    <div id='auaText' class="span3" style="display:none;">
        <h3><bean:message key="provider.login.title.confidentiality"/></h3>
        <p><%=AcceptableUseAgreementManager.getAUAText()%></p> 
    </div> <!-- loads OSCARloginText.txt from DOCUMENT_DIR -->
               
    <div id='liscence' class="span3" style="display:none;"> 
        <p><bean:message key="loginApplication.leftRmk2" /></p>
    </div>
</div>
    
<span class="span4 offset4 text-right">
        <small><bean:message key="loginApplication.gplLink" /> <a href="javascript:void(0);" onclick="showHideItem('liscence');"><bean:message key="global.showhide"/></a><br>
        <%if (AcceptableUseAgreementManager.hasAUA()){ %>
            <bean:message key="global.aua" /> &nbsp; <a href="javascript:void(0);" onclick="showHideItem('auaText');"><bean:message key="global.showhide"/></a><br>
        <% } %>
	OSCAR <%=OscarProperties.getBuildTag()%>:<%= OscarProperties.getBuildDate() %></small>&nbsp;&nbsp;
    </span>

</div>     
<input type=hidden name='propname' value='<bean:message key="loginApplication.propertyFile"/>' />
<input type="hidden" id="oneIdKey" name="nameId" value="<%=request.getParameter("nameId") != null ? request.getParameter("nameId") : ""%>"/>
<input type="hidden" id="email" name="email" value="<%=request.getParameter("email") != null ? request.getParameter("email") : ""%>"/>
</html:form>   

</html:html>