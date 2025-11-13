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
	import="java.util.*, oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig, oscar.OscarProperties"%>


<html:html locale="true">
<head>
<html:base />
    <title>Measurement Mapping Configuration</title>

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-migrate-3.4.0.js"></script><!-- needed for bootstrap.min.js -->
    <script src="<%=request.getContextPath()%>/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->
    <script src="${pageContext.servletContext.contextPath}/js/bootstrap.min.js"></script> <!-- needed for dropdown -->

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/DT_bootstrap.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->

    <script>
        $(document).ready(function(){
            oTable=jQuery('#measTbl').DataTable({
                "order": [],
                "lengthMenu": [ [10, 40 , 90, -1], [10, 40, 90, "<bean:message key="oscarEncounter.LeftNavBar.AllLabs"/>"] ],
                "language": {
                "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                }
            });
        });
    </script>

    <script>
            function popupStart(vheight,vwidth,varpage,windowname) {
                var page = varpage;
                windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
                var popup=window.open(varpage, windowname, windowprops);
            }

            function reloadPage(){
                document.CONFIG.action = 'removeMeasurementMap.jsp';
                return true;
            }

            function deleteMapping(id){
                var answer = confirm ("Are you sure you want to delete the mapping?")
                if (answer){
                    document.CONFIG.id.value=id;
                    return true;
                }else{
                    return false;
                }

            }

            function remap(id, identifier, name, type){
                popupStart(300, 1000, 'remapMeasurementMap.jsp?id='+id+'&identifier='+identifier+'&name='+name+'&type='+type, 'Remap Measurement')
            }

            <%String outcome = request.getParameter("outcome");
            if (outcome != null){
                if (outcome.equals("success")){
                    %>
                      alert("Successfully deleted the mapping");
                    <%
                }else{
                    %>
                      alert("Failed to delete the mapping");
                    <%
                }
            }%>
        </script>
</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
<form method="post" name="CONFIG" action="RemoveMeasurementMap.do">
<input type="hidden" name="id" value=""> <input type="hidden"
	name="identifier" value=""> <input type="hidden" name="name"
	value=""> <input type="hidden" name="type" value=""> <input
	type="hidden" name="provider_no"
	value="<%= session.getValue("user") %>">
 <%String searchstring = request.getParameter("searchstring");
    if (searchstring == null) searchstring = "";%>
<!-- Search table for name: <input type="text" size="30" name="searchstring"
					value="<%= searchstring %>" > <input type="submit" value="Search"
					onclick="return reloadPage()" >-->

<h3>Edit Measurement Mapping Table</h3>
    <table class="table table-striped table-condensed" id="measTbl">
        <thead>
            <tr>
				<th></th>
				<th></th>
				<th>Identifier</th>
				<th>Loinc Code</th>
				<th>Name</th>
				<th>Lab Type</th>
			</tr>
        </thead>
        <tbody>
			<%MeasurementMapConfig mmc = new MeasurementMapConfig();
                                ArrayList mappings = mmc.getMeasurementMap(searchstring);
                                for (int i=0; i < mappings.size(); i++){
                                    Hashtable ht = (Hashtable) mappings.get(i);%>
			<tr>
				<td class="ButtonCell"><input type="submit" value="<bean:message key="global.btnDelete"/>" class="btn-link"
					onclick="deleteMapping(<%= (String) ht.get("id") %>)"></td>
				<td class="ButtonCell"><input type="button" value="REMAP" class="btn"
					onclick="remap(<%= "'"+ (String) ht.get("id") +"','"+ (String) ht.get("ident_code") +"','"+ (String) ht.get("name") +"','"+ (String) ht.get("lab_type")+"'" %>)"></td>
				<td class="TableCell"><%= (String) ht.get("ident_code") %></td>
				<td class="TableCell"><%= (String) ht.get("loinc_code") %></td>
				<td class="TableCell"><%= (String) ht.get("name") %></td>
				<td class="TableCell"><%= (String) ht.get("lab_type") %></td>
			</tr>
			<%}%>
        </tbody>
    </table>
</form>
</body>
</html:html>