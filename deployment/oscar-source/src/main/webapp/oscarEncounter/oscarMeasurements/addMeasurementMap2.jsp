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
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ page
	import="java.util.*, oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig, oscar.OscarProperties, oscar.util.StringUtils,oscar.oscarEncounter.oscarMeasurements.bean.*"%>

<%

MeasurementMapConfig mmc = new MeasurementMapConfig();

EctMeasurementTypesBeanHandler hd = new EctMeasurementTypesBeanHandler();
            Vector<EctMeasurementTypesBean> vec = hd.getMeasurementTypeVector();

String loinc = request.getParameter("loinc");
            %>

<html:html locale="true">
<head>
<html:base />
    <title>Measurement Mapping Configuration</title>

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="${pageContext.servletContext.contextPath}/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">

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
              alert("Unable to update measurement mappings: A message is already mapped to the specified code for that message type");
            <%
        }else{
            %>
              alert("Failed to update the measurement mappings");
            <%
        }
    }%>
    </script>
</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<form method="post" name="CONFIG" action="AddMeasurementMap.do">
    <h3>Map Unmapped Identifier Codes</h3>
    <div class="well">
        <table>
			<tr>
				<td class="Cell" >Select Measurement:</td>
				<td class="Cell" >
				    <select name="identifier">
					    <option value="0">None Selected</option>
				    <% for (EctMeasurementTypesBean measurementTypes : vec){ %>
				        <option value="<%=measurementTypes.getType()%>,FLOWSHEET,<%=measurementTypes.getTypeDisplayName()%>" ><%=measurementTypes.getTypeDisplayName()%> (<%=measurementTypes.getType()%>) </option>
				    <% } %>
				    </select>
                    <input class="btn"
					    type="submit" value=" Update Measurement Mapping ">
				 </td>
			</tr>
			<tr>
				<td class="Cell"><input type="hidden" name="loinc_code" value="<%=loinc%>"/></td>
				<td class="Cell" >To Map to Loinc Code : <%=loinc%></td>
			</tr>
			<tr>
                <td></td>
				<td class="Cell" > <input class="btn"
					type="button" value=" Add New Loinc Code "
					onclick="javascript:popupStart('300','600','newMeasurementMap.jsp','Add_New_Loinc_Code')">
				</td>
			</tr>
			<tr>
				<td colspan="2" class="Cell" >NOTE: <a
					href="javascript:newWindow('https://loinc.org','RELMA')">It
				is suggested that you use the RELMA application to help determine
				correct loinc codes.</a></td>
			</tr>
		</table>
    </div>
<a href="javascript:" onclick="getElementById('list').style.display = 'block'">View all types</a>
<div id="list" style="display:none">
    <ul>
    <% for (EctMeasurementTypesBean measurementTypes : vec){ %>
        <li><%=measurementTypes.getTypeDisplayName()%> (<%=measurementTypes.getType()%>) </li>
    <% } %>
    </ul>
</div>
</form>
</body>
</html:html>