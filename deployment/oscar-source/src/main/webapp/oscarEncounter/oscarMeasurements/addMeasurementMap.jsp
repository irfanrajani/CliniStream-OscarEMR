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
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page
	import="java.util.*, oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig, oscar.OscarProperties, oscar.util.StringUtils"%>

<%

MeasurementMapConfig mmc = new MeasurementMapConfig();
%>

<html:html locale="true">
<head>
<html:base />
<head>
    <title>Measurement Mapping Configuration</title>
    <script>

            function popupStart(vheight,vwidth,varpage,windowname) {
                var page = varpage;
                windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
                var popup=window.open(varpage, windowname, windowprops);
            }

            function newWindow(varpage, windowname){
                var page = varpage;
                windowprops = "fullscreen=yes,toolbar=yes,directories=no,resizable=yes,dependent=yes,scrollbars=yes,location=yes,status=yes,menubar=yes";
                var popup=window.open(varpage, windowname, windowprops);
            }

            function reloadPage(){
                document.CONFIG.action = 'addMeasurementMap.jsp';
                return true;
            }


            <%String outcome = request.getParameter("outcome");
            if (outcome != null){
                if (outcome.equals("success")){
                    %>
                      alert("Successfully updated the measurement mappings");
                    <%
                }else if (outcome.equals("failedcheck")){
                    %>
                      alert("Unable to update measurement mappings: A measurement is already mapped to the specified code for that measurement type");
                    <%
                }else{
                    %>
                      alert("Failed to update the measurement mappings");
                    <%
                }
            }%>

    </script>
<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">
</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<html:errors />
<form method="post" name="CONFIG" action="AddMeasurementMap.do">
    <h3>Map Unmapped Identifier Codes</h3>
    <div class="well">
		<table>
			<tr>
				<td colspan="2" class="Header">Map Unmapped Identifier Codes</td>
			</tr>
			<tr>
				<td class="Cell" style="width:20%">Select unmapped code:</td>
				<td class="Cell" style="width:80%"><select name="identifier">
					<option value="0">None Selected</option>
					<%String identifier = request.getParameter("identifier");
                                                if (identifier == null) identifier = "";
                                                ArrayList measurements = mmc.getUnmappedMeasurements("");
                                                for (int i=0; i < measurements.size(); i++) {
                                                Hashtable ht = (Hashtable) measurements.get(i);
                                                String value = (String) ht.get("identifier")+","+(String) ht.get("type")+","+(String) ht.get("name");%>
					<option value="<%= value %>"
						<%= value.equals(identifier) ? "selected" : "" %>><%= "("+(String) ht.get("type")+") "+(String) ht.get("identifier")+" - "+((String) ht.get("name")).trim() %></option>
					<% }%>
				</select></td>
			</tr>
			<tr>
				<td class="Cell" style="width:20%">Search codes by name:</td>
				<td class="Cell" style="width:80%">
				<%String searchstring = request.getParameter("searchstring");
                                                if (searchstring == null)
                                                    searchstring = "";%>
				<input type="text" size="30" name="searchstring"
					value="<%= searchstring %>" /> <input type="submit" class="btn" value="Search"
					onclick="return reloadPage()" /></td>
			<tr>
				<td class="Cell" style="width:20%">Select code to map to:</td>
				<td class="Cell" style="width:80%"><select name="loinc_code">
					<option value="0">None Selected</option>
					<%ArrayList loincCodes = mmc.getLoincCodes(searchstring);
                                                for (int i=0; i < loincCodes.size(); i++) {
                                                Hashtable ht = (Hashtable) loincCodes.get(i);%>
					<option value="<%= (String) ht.get("code") %>"><%= (String) ht.get("code")+" - "+((String) ht.get("name")).trim()%></option>
					<% }%>
				</select></td>
			</tr>
			<tr>
				<td colspan="2" class="Cell" align="center"><input class="btn"
					type="submit" value=" Update Measurement Mapping "> <input class="btn"
					type="button" value=" Add New Loinc Code "
					onclick="javascript:popupStart('300','600','newMeasurementMap.jsp','Add_New_Loinc_Code')">
				</td>
			</tr>
			<tr>
				<td colspan="2" class="Cell" align="center">NOTE: It
				is suggested that you refer to appropriate reference material to determine
				correct loinc codes.
				<span class="HelpAboutLogout"><oscar:help keywords="&Title=Measurements+Admin&portal_type%3Alist=Document" key="app.top1" style="color:blue; font-size:10px;font-style:normal;"/>&nbsp;
				</span>
				</td>
			</tr>
		</table>
    </div>

</form>
</body>
</html:html>