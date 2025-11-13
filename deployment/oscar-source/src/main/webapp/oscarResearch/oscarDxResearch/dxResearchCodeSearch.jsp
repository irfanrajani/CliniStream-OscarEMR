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

<%
    String user_no;
    user_no = (String) session.getAttribute("user");
%>

<html:html locale="true">
<head>
<title><bean:message key="oscarResearch.oscarDxResearch.dxResearchCodeSearch.title" /></title>
    <script LANGUAGE="JavaScript">

    function CodeAttach(File0) {

        self.close();
        self.opener.document.forms[0].xml_research1.value = File0;
        self.opener.document.forms[0].xml_research2.value = '';
        self.opener.document.forms[0].xml_research3.value = '';
        self.opener.document.forms[0].xml_research4.value = '';
        self.opener.document.forms[0].xml_research5.value = '';

    }

    function CodesAttach() {

        var nbSearchCodes = document.codeSearchForm.searchCodes;
	    if (nbSearchCodes.length==undefined) {
		    if (nbSearchCodes.checked) self.opener.document.forms[0].xml_research1.value = nbSearchCodes.value;
	    } else {
		    var j = 0;
		    for(var i=0; i<nbSearchCodes.length; i++){
			    if (nbSearchCodes[i].checked) {
				    if (j==0) {
					    self.opener.document.forms[0].xml_research1.value = nbSearchCodes[i].value;
					    j++;
				    } else if (j==1) {
					    self.opener.document.forms[0].xml_research2.value = nbSearchCodes[i].value;
					    j++;
				    } else if (j==2) {
					    self.opener.document.forms[0].xml_research3.value = nbSearchCodes[i].value;
					    j++;
				    } else if (j==3) {
					    self.opener.document.forms[0].xml_research4.value = nbSearchCodes[i].value;
					    j++;
				    } else if (j==4) {
					    self.opener.document.forms[0].xml_research5.value = nbSearchCodes[i].value;
					    j++;
				    } else {
					    break;
				    }
			    }
		    }
	    }
        self.close();
    }

    </script>

    <link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!-- Bootstrap 2.3.1 -->
    <link href="${ pageContext.request.contextPath }/css/DT_bootstrap.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet" >
    <script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="${ pageContext.request.contextPath }/js/global.js"></script>
    <script src="${ pageContext.request.contextPath }/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->
    <script>
	    jQuery(document).ready( function () {
	        jQuery('#tblDxs').DataTable({
            "order": [],
            "language": {
                        "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                    }
            });
	    });
    </script>
</head>
<body>
<h3>&nbsp;<%=session.getAttribute("codeType").toString().toUpperCase()%> <bean:message key="oscarResearch.oscarDxResearch.dxResearchCodeSearch.msgCodeSearch" /></h3>
<form name="codeSearchForm" method="post">
<div class="well">
<table style="width:600px;" id="tblDxs" class="table-striped table display">
    <thead>
	    <tr class="heading">
		    <th style="width:20%"><bean:message key="oscarResearch.oscarDxResearch.dxResearchCodeSearch.msgCode" /></th>
		    <th style="width:80%"><bean:message key="oscarResearch.oscarDxResearch.dxResearchCodeSearch.msgDescription" /></th>
	    </tr>
    </thead>
    <tbody>
	<%
    int intCount=0;
    String color="#EEEEFF";
    int Count=0;
  %>
	<logic:iterate id="code" name="allMatchedCodes"
		property="dxCodeSearchBeanVector">
		<%
        if (Count == 0){
            Count = 1;
            color = "#FFFFFF";
        }
        else {
            Count = 0;
            color="#EEEEFF";
        }
     %>
		<tr>
			<td><input type="checkbox" name="searchCodes"
				value="<bean:write name='code' property='dxSearchCode'/>"
				<bean:write name='code' property='exactMatch'/> />&nbsp;<bean:write
				name='code' property='dxSearchCode' /></td>
			<td><bean:write name='code' property='description' /></td>
		</tr>
		<% intCount++; %>
	</logic:iterate>
	<%  if (intCount == 0 ) { %>
	<tr>
		<td colspan="2"><bean:message
			key="oscarResearch.oscarDxResearch.dxResearchCodeSearch.msgNoMatch" />.
		<%// =i%>
		</td>

	</tr>
	<%  }%>


  <% if (intCount == 1) { %>
  <logic:iterate id="code" name="allMatchedCodes" property="dxCodeSearchBeanVector">
      <script LANGUAGE="JavaScript">
        CodeAttach('<bean:write name='code' property='dxSearchCode'/>');
      </script>
  </logic:iterate>
<% } %>

    </tbody>
</table>
</div> <!-- well end -->
&nbsp;
<input type="button" name="confirm" value="Confirm" class="btn btn-primary"
	onclick="javascript:CodesAttach();">
<input type="button" class="btn"
	name="<bean:message key="global.btnCancel"/>" value="Cancel"
	onclick="javascript:window.close()">

<p></p>
<p>&nbsp;</p>
<h3>&nbsp;</h3>

</form>
</body>
</html:html>