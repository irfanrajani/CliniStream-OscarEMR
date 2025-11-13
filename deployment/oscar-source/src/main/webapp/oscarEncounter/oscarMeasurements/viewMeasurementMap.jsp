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
	import="java.util.*, oscar.oscarEncounter.oscarMeasurements.data.MeasurementMapConfig, oscar.OscarProperties, oscar.util.StringUtils"%>

<%

%>

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
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/DT_bootstrap.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet">

<script>
    $(document).ready(function(){
        oTable=jQuery('#measTbl').DataTable({
            "order": [],
            "lengthMenu": [ [15, 30, 90, -1], [15, 30, 90, "<bean:message key="oscarEncounter.LeftNavBar.AllLabs"/>"] ],
            "language": {
            "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
            }
        });
    });
</script>
<script>
function newWindow(varpage, windowname){
    var page = varpage;
    windowprops = "fullscreen=yes,toolbar=yes,directories=no,resizable=yes,dependent=yes,scrollbars=yes,location=yes,status=yes,menubar=yes";
    var popup=window.open(varpage, windowname, windowprops);
}

function addLoinc(){
    var loinc_code = document.LOINC.loinc_code.value;
    var name = document.LOINC.name.value;

    if (loinc_code.length > 0 && name.length > 0){
        if (modCheck(loinc_code)){
				document.LOINC.identifier.value=loinc_code+',PATHL7,'+name;
				return true;
        }
    }else{
        alert("Please specify both a loinc code and a name before adding.");
    }

    return false;
}

function modCheck(code){
    if (code.charAt(0) == 'x' || code.charAt(0) == 'X'){
        return true;
    }else{

        var codeArray = new Array();
        codeArray = code.split('-');
        var length = codeArray[0].length;

        var even = false;
        if ( (length % 2) == 0 ) even = true;


        var oddNums = '';
        var evenNums = '';

        length--;
        for (length; length >= 0; length--){
				if (even){
				    even = false;
				    evenNums = evenNums+codeArray[0].charAt(length);
				}else{
				    even = true;
				    oddNums = oddNums+codeArray[0].charAt(length);
				}
        }

        oddNums = oddNums*2;
        var newNum = evenNums+oddNums;
        var sum = 0;


        for (var i=0; i < newNum.length; i++){
				sum = sum + parseInt(newNum.charAt(i));
        }

        var newSum = sum;

        while((newSum % 10) != 0){
				newSum++;
        }

        var checkDigit = newSum - sum;
        if (checkDigit == codeArray[1]){
				return true;
        }else{
				alert("The loinc code specified is not a valid loinc code, please start the code with an 'X' if you would like to make your own.");
				return false;
        }

    }

}

<%String outcome = request.getParameter("outcome");
if (outcome != null){
    if (outcome.equals("success")){
        %>
          alert("Successfully added loinc code");
          window.opener.location.reload()
          window.close();
        <%
    }else if (outcome.equals("failedcheck")){
        %>
          alert("Unable to add code: The specified code already exists in the database");
        <%
    }else{
        %>
          alert("Failed to add the new code");
        <%
    }
}%>



window.onload = stripe;

</script>
</head>
<body>
<%@ include file="measurementTopNav.jspf"%>
    <form method="post" name="LOINC" action="NewMeasurementMap.do">
        <input type="hidden" name="identifier" value="">
        <h3>Measurement Mapping Table</h3>
		<table class="table table-striped table-condensed" id="measTbl">
            <thead>
                <tr>
                    <th valign="bottom" class="Header">MEAS</th>
					<th valign="bottom" class="Header">Loinc Code</th>
					<th valign="bottom" class="Header">Desc</th>
					<th valign="bottom" class="Header">--</th>
					<%
					MeasurementMapConfig map = new MeasurementMapConfig();
					List<String> types = map.getLabTypes();
					types.remove("FLOWSHEET");
					for(String type:types){%>
					<th valign="bottom" class="Header"><%=type%></th>
					<%}%>
                </tr>
            </thead>
            <tbody>
				<%
				List<String> list =map.getDistinctLoincCodes();
				boolean odd = true;
				for(String s:list){
					List<Hashtable<String,String>> codesHash = map.getMappedCodesFromLoincCodes(s);
				    String desc = "";
				    if (codesHash.size() > 0 ){
				        desc = getDesc(codesHash.get(0));
				    }
				    String mappings = getCodeMap(codesHash);
				    Hashtable<String, Hashtable<String,String>> h = map.getMappedCodesFromLoincCodesHash(s);
				    String measurement = getDisplay(h,"FLOWSHEET");
				%>
				<tr>
				    <td class="Cell" >
				        <% if (measurement != null && !measurement.equals("&nbsp;")){%>
				        <%=measurement%>
				        <%}else{%>
				        <a href="addMeasurementMap2.jsp?loinc=<%=s%>">map</a>
				        <%}%>
				    </td>
				    <td class="Cell"><%=s%></td>
				    <td class="Cell"><%=desc%></td>
				    <td class="Cell">&nbsp;</td>
				    <%for(String type:types){%>
				        <td class="Cell" ><%=getDisplay(h,type)%></td>
				    <%}%>
				</tr>
				<%
				odd = !odd;
				}%>
            </tbody>
		</table>
    </form>
</body>
</html:html>
<%!
  String rowColour(Boolean b){
      if (b.booleanValue()){
          b = Boolean.valueOf(!b);
          return "#DDDDDD";
      }else{

          return "#FFFFFF";
      }

  }



  String getDesc(Hashtable<String,String> h){
      return h.get("name");
  }

  String getDisplay(Hashtable<String, Hashtable<String,String>> h, String type){
      Hashtable<String,String> data = h.get(type);
      if (data == null ){ return "&nbsp;";}
      return data.get("name")+": "+data.get("ident_code");
  }

  String getCodeMap(List<Hashtable<String,String>> list){
      StringBuffer sb = new StringBuffer();

        for(Hashtable<String,String> h : list){
            sb.append(h.get("name")+" : "+h.get("lab_type")+"("+h.get("ident_code")+ ")   |  ");
        }
        return sb.toString();
  }
%>