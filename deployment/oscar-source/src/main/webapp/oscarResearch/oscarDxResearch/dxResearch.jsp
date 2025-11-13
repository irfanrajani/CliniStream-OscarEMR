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
<%@ page import="oscar.oscarResearch.oscarDxResearch.util.dxResearchCodingSystem"%>
<%@ page
	import="oscar.OscarProperties"%>
<%@ page import="com.quatro.service.security.SecurityManager" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_dxresearch" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_dxresearch");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%

	//John's Question: Can't we just get rid of this to force use of the object _dx.code
	//String disableVal = OscarProperties.getInstance().getProperty("dxResearch_disable_entry", "false");
	//boolean disable = Boolean.valueOf(disableVal).booleanValue();
	boolean disable;
	SecurityManager sm = new SecurityManager();

	if(sm.hasWriteAccess("_dx.code",roleName$)) {
		disable=false;
	}else{
		disable=true;
	}
	boolean showQuicklist=false;

	if(sm.hasWriteAccess("_dx.quicklist",roleName$)) {
		showQuicklist=true;
	}

    String user_no = (String) session.getAttribute("user");
    String color ="";
    int Count=0;

    pageContext.setAttribute("showQuicklist", showQuicklist);
    pageContext.setAttribute("disable", disable);
%>


<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet">
<script language="JavaScript">
//<!--
function setfocus() {
	document.forms[0].xml_research1.focus();
	document.forms[0].xml_research1.select();
}

var remote=null;

function rs(n,u,w,h,x) {
	args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,top=60,left=30";
	remote=window.open(u,n,args);
	if (remote != null) {
		if (remote.opener == null)
			remote.opener = self;
	}
	if (x == 1) { return remote; }
}

function popPage(url) {
	awnd=rs('',url ,400,200,1);
	awnd.focus();
}

var awnd=null;

function ResearchScriptAttach() {
	var t0 = escape(document.forms[0].xml_research1.value);
	var t1 = escape(document.forms[0].xml_research2.value);
	var t2 = escape(document.forms[0].xml_research3.value);
	var t3 = escape(document.forms[0].xml_research4.value);
	var t4 = escape(document.forms[0].xml_research5.value);
        var codeType = document.forms[0].selectedCodingSystem.value;
        var demographicNo = escape(document.forms[0].demographicNo.value);

	awnd=rs('att','dxResearchCodeSearch.do?codeType=' + codeType + '&xml_research1='+t0 + '&xml_research2=' + t1 + '&xml_research3=' + t2 + '&xml_research4=' + t3 + '&xml_research5=' + t4 +'&demographicNo=' + demographicNo,700,750,1);
	awnd.focus();
}

function submitform(target,sysCode){
        document.forms[0].forward.value = target;

        if( sysCode != '' )
            document.forms[0].selectedCodingSystem.value = sysCode;

	document.forms[0].submit()
}

function set(target) {
     document.forms[0].forward.value=target;
}


function openNewPage(vheight,vwidth,varpage) {
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=no,menubars=no,toolbars=no,resizable=no,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="global.oscarComm"/>", windowprops);
  popup.focus();
}

document.onkeypress = processKey;

function processKey(e) {
	if (e==null) {
		e = window.event;
	} else if (e.keyCode==13) {
		ResearchScriptAttach();
	}
}

function showdatebox(x) {
    document.getElementById("startdatenew"+x).style.display="block";
    document.getElementById("startdate1st"+x).style.display="none";
}

function update_date(did, demoNo, provNo) {
    var startdate = document.getElementById("startdatenew"+did).value;
    window.location.href = "dxResearchUpdate.do?startdate="+startdate+"&did="+did+"&demographicNo="+demoNo+"&providerNo="+provNo;
}

//-->
</script>

<!-- link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  /-->
<title><bean:message key="oscarResearch.oscarDxResearch.dxResearch.title" /></title>
</head>

<body onLoad="setfocus();">
<html:form action="/oscarResearch/oscarDxResearch/dxResearch.do">
<table style="width:100%">
	<tr>
		<td>
		<table style="width:100%">
			<tr>
				<td class="subject">&nbsp;&nbsp;&nbsp;<h3><bean:message key="global.disease" /></h3></td>
				<td style="text-align: right; vertical-align: bottom;"><oscar:nameage demographicNo="<%=(String) session.getAttribute(\"demographicNo\")%>" /></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td>
			<table style="width:100%; height:500px">
				<html:errors />
				<tr>
					<td style="width:170px; vertical-align:top">

					<table style="width:100%; height:500px; vertical-align:top;">
						<tr>
							<td class="heading"><bean:message key="oscarResearch.oscarDxResearch.codingSystem" />:<br> <html:select
								property="selectedCodingSystem"  disabled="<%=disable%>">
								<logic:iterate id="codingSys" name="codingSystem" property="codingSystems">
									<option value="<bean:write name="codingSys"/>"><bean:write name="codingSys" /></option>
								</logic:iterate>

							</html:select></td>
						</tr>
						<tr>
							<td><html:text property="xml_research1" size="30" disabled="<%=disable%>" /> <input type="hidden" name="demographicNo"
								value="<bean:write name="demographicNo"/>"> <input type="hidden" name="providerNo"
								value="<bean:write name="providerNo"/>"></td>
						</tr>
						<tr>
							<td><html:text property="xml_research2" size="30" disabled="<%=disable%>"/></td>
						</tr>
						<tr>
							<td><html:text property="xml_research3" size="30" disabled="<%=disable%>"/></td>
						</tr>
						<tr>
							<td><html:text property="xml_research4" size="30" disabled="<%=disable%>"/></td>
						</tr>
						<tr>
							<td><html:text property="xml_research5" size="30" disabled="<%=disable%>"/></td>
						</tr>
						<tr>
							<td>
							<input type="hidden" name="forward" value="none" />
                               <%if(!disable) { %>
                               <input type="button" class="btn" name="codeSearch"
								value="<bean:message key="oscarResearch.oscarDxResearch.btnCodeSearch"/>"
								onClick="javascript: ResearchScriptAttach();" >

                                <input type="button" class="btn" name="codeAdd"
								value="<bean:message key="ADD"/>"
								onClick="javascript: submitform('','');">

								<% } else { %>

								 <input type="button" class="btn" name="button"
								value="<bean:message key="oscarResearch.oscarDxResearch.btnCodeSearch"/>"
								onClick="javascript: ResearchScriptAttach();"  disabled="<%=disable%>">

                                <input type="button" class="btn" name="button"
								value="<bean:message key="ADD"/>"
								onClick="javascript: submitform('','');" disabled="<%=disable%>">
								<% } %>
								</td>
						</tr>

					<%-- DX QUICK LIST - returns a table --%>
						<logic:equal name="showQuicklist" value="true" scope="page">
						<tr>
							<td>
							<jsp:include page="dxQuickList.jsp" >
								<jsp:param value="false" name="disable"/>
								<jsp:param value="${ param.quickList }" name="quickList" />
								<jsp:param value="${ demographicNo }" name="demographicNo"/>
								<jsp:param value="${ providerNo }" name="providerNo"/>
							</jsp:include>
							</td>
						</tr>
						</logic:equal>
					<%-- DX QUICK LIST --%>

					</table>



					</td>
					<td style="vertical-align:top">

					<table style="width:100%" id="dxTbl" class="table table-striped">
                    <thead>
						<tr>
							<th style="width:10%"><b><bean:message key="oscarResearch.oscarDxResearch.dxResearch.msgCode" /></b></th>
							<th style="width:35%"><b><bean:message key="oscarResearch.oscarDxResearch.dxResearch.msgDiagnosis" /></b></th>
							<th style="width:15%"><b><bean:message key="oscarResearch.oscarDxResearch.dxResearch.msgFirstVisit" /></b></th>
							<th style="width:15%"><b><bean:message key="oscarResearch.oscarDxResearch.dxResearch.msgLastVisit" /></b></th>
							<% if(!disable){ %>
							<th style="width:25%"><b><bean:message key="oscarResearch.oscarDxResearch.dxResearch.msgAction" /></b></th>
							<%} %>
						</tr>
                    </thead>
                    <tbody>
						<logic:iterate id="diagnotics" name="allDiagnostics"
							property="dxResearchBeanVector" indexId="ctr">
							<logic:equal name="diagnotics" property="status" value="A">
								<tr>
								<td class="notResolved"> <bean:write name="diagnotics" property="dxSearchCode" /></td>
									<td class="notResolved"><bean:write name="diagnotics" property="description" /></td>
									<td class="notResolved">
                                                                            <a href="#" onclick="showdatebox(<bean:write name="diagnotics" property="dxResearchNo" />);">
                                                                                <div id="startdate1st<bean:write name="diagnotics" property="dxResearchNo" />"><bean:write name="diagnotics" property="start_date" /></div></a>
                                                                                <input id="startdatenew<bean:write name="diagnotics" property="dxResearchNo" />" type="date" name="start_date" class="input-medium" value="<bean:write name="diagnotics" property="start_date" />" style="display:none" />

                                                                        </td>
									<td class="notResolved">
                                                                                <bean:write name="diagnotics" property="end_date" />
                                                                        </td>
									<% if(!disable){ %>
									<td class="notResolved">
									<a href='dxResearchUpdate.do?status=C&did=<bean:write name="diagnotics" property="dxResearchNo" />&demographicNo=<bean:write name="demographicNo" />&providerNo=<bean:write name="providerNo" />'><bean:message
										key="oscarResearch.oscarDxResearch.dxResearch.btnResolve" /></a> |
									<a href='dxResearchUpdate.do?status=D&did=<bean:write name="diagnotics" property="dxResearchNo" />&demographicNo=<bean:write name="demographicNo" />&providerNo=<bean:write name="providerNo" />' onClick="javascript: return confirm('Are you sure you would like to delete: <bean:write name="diagnotics" property="description" /> ?')"><bean:message
										key="oscarResearch.oscarDxResearch.dxResearch.btnDelete" /></a> |
									<a href='#' onclick="update_date(<bean:write name="diagnotics" property="dxResearchNo" />,<bean:write name="demographicNo" />,<bean:write name="providerNo" />);"><bean:message
										key="oscarResearch.oscarDxResearch.dxResearch.btnUpdate" /></a>
                                    </td>
                                     <%} %>
								</tr>
							</logic:equal>
							<logic:equal name="diagnotics" property="status" value="C">
								<tr bgcolor="<%=color%>">
									<td> <bean:write name="diagnotics" property="dxSearchCode" /></td>
                                    <td><bean:write name="diagnotics" property="description" /></td>
									<td><bean:write name="diagnotics" property="start_date" /></td>
									<td><bean:write name="diagnotics" property="end_date" /></td>
									<% if(!disable){ %>
									<td><bean:message key="oscarResearch.oscarDxResearch.dxResearch.btnResolve" /> |
									<a href='dxResearchUpdate.do?status=D&did=<bean:write name="diagnotics" property="dxResearchNo" />&demographicNo=<bean:write name="demographicNo" />&providerNo=<bean:write name="providerNo" />'  onClick="javascript: return confirm('Are you sure you would like to delete this?')"><bean:message key="oscarResearch.oscarDxResearch.dxResearch.btnDelete" /></a></td>
									<%} %>
								</tr>
							</logic:equal>
						</logic:iterate>
                    </tbody>
					</table>

					</td>
				</tr>
			</table></td>
	</tr>
</table>
</html:form>

</body>
</html:html>