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

<%-- 
  Author: Adrian Starzynski
  --%>


<!DOCTYPE html>
<html>
<head>
<title>Online Booking Integration</title>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/datepicker.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
<link rel="stylesheet" href="../css/helpdetails.css" type="text/css">
</head>

<body>

<h4>Online Booking Integration</h4>
<p>OSCAR can integrate with various third-party booking systems via REST API.</p>
<p>Online booking systems use the REST API to connect with OSCAR. For this reason, an oscar.properties file setting needs to be changed to enable this connectivity.</p>
<br>
<p>By default in the oscar.properties file, there is the following line that is commented by default with # which makes it disabled: <code>#ModuleNames=Caisi,ERx,HRM,OLIS,Indivo</code></p>
<p>In order for you to be able to create a REST client to be able to integrate your online booking system, you have to change this line to enable the REST module (uncomment it - in other words, remove the #). If you have multiple modules you want to enable, use a comma to separate the modules.</p>
<p>Example: <code>ModuleNames=REST,Caisi,OLIS,HRM</code></p>
<hr>
<h6>About Online Booking Systems</h6>
<p>Due to OSCAR's open-source nature, you are able to integrate the online booking app of your choosing with OSCAR relatively easily. Follow these steps to integrate:</p>
<ol>
<li>Create a provider record for the online booking provider with type as DOCTOR. <i>Note: It is suggested to name the provider record the online booking app's name so you can reference it easily in the future (e.g. if you need to view audit logs).</i></li>
<li>Create a security [login] record for the online booking provider. Since most online booking apps make you input the password and PIN only once, it is suggested to make the password as long and complex as possible since nobody will be using it to login every day. Be careful aware of the security record expiry date because once it expires, you will need to extend the expiry date for your online booking integration to continue working. For most situations, it's recommended to disable the expriy date for an online booking integration provider.</li>
<li>In <a href="<%=request.getContextPath() %>/admin/api/clients.jsp">REST Clients</a>, add a new client. Set the API client name/URI/token lifetime as values the online booking provider gives you.</li>
<li>The online booking provider will now require the credentials for the provider record and REST client you just created.</li>
</ol>
<p><i>Make sure you trust the online booking vendor, as once you give them the credentials to your OSCAR system, they have full access and can remove any users or do anything they want on your system. Be very careful and always make sure credentials are secure.</i></p>

<hr>

</body>
</html>