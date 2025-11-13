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
	import="oscar.oscarRx.pageUtil.*,oscar.oscarRx.data.*,java.util.*"%>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	String roleName2$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName2$%>" objectName="_rx" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_rx");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}

	String type = request.getParameter("type");
%>

<html:html locale="true">
<head>
<script src="${ pageContext.request.contextPath }/js/global.js"></script>
<script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>

<link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet">


<script>
<%
 if (request.getParameter("ID") != null && type != null && type.equals("Edit")){ %>
	$(function() {
		var data = "pharmacyId=<%=request.getParameter("ID")%>";
		$.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=getPharmacyInfo",
				  data, function( data ) {
			if(data.name) {
			  $('#pharmacyId').val(<%=request.getParameter("ID")%>);
			  $('#pharmacyName').val(data.name);
			  $('#pharmacyAddress').val(data.address);
			  $('#pharmacyCity').val(data.city);
			  $('#pharmacyProvince').val(data.province);
			  $('#pharmacyPostalCode').val(data.postalCode);
			  $('#pharmacyPhone1').val(data.phone1);
			  $('#pharmacyPhone2').val(data.phone2);
			  $('#pharmacyFax').val(data.fax);
			  $('#pharmacyEmail').val(data.email);
			  $('#pharmacyServiceLocationId').val(data.serviceLocationIdentifier);
			  $('#pharmacyNotes').val(data.notes);
			}
			else {
				alert("Unable to retrieve pharmacy information");
			}
		},"json");
	});
<% } %>
  function savePharmacy() {

	  if( !confirm("You are about to edit/add this pharmacy for all users. Are you sure?")) {  return false;  }
	  if( !isFaxNumberCorrect() ) {   return false;  }

	  if( $("#pharmacyId").val() != null && $("#pharmacyId").val() != "" ) {

		  var data = $("#pharmacyForm").serialize();
		  $.post("<%=request.getContextPath() + "/oscarRx/managePharmacy.do?method=save"%>",
			  data, function( data ) {
		      	if( data.id ) {
					window.opener.location.reload(false);
                    window.opener.location.reload(false);
                    window.close();
		      	}
		      	else {
		      	    alert("There was a problem saving your record");
		      	}
		  }, "json"	);
	  }
	  else {
		  addPharmacy();
	  }

	  return false;
  }

  function addPharmacy() {

	  if( $("#pharmacyName").val() == "" ) {
		  alert("Please fill in the name of a pharmacy");
		  return false;
	  }

	  var data = $("#pharmacyForm").serialize();
	  $.post("<%=request.getContextPath() + "/oscarRx/managePharmacy.do?method=add"%>",
			  data, function( data ) {
				if( data.success ) {
					parent.window.refresh();
                    window.opener.location.reload(false);
                    window.close();
				}
				else {
					alert("There was an error saving your Pharmacy");
				}
			},
			"json"
		);
  }

  function isFaxNumberCorrect() {

	  var faxNumber = $("#pharmacyFax").val().trim();
	  var isCorrect = false;

	  if(faxNumber.split("-").join("").length == 12){
          isCorrect = faxNumber.match(/^1?\s?\(?[9]{1}\)?[\-\s]?[1|9]{1}\)?[\-\s]?[0-9]{3}\)?[\-\s]?[0-9]{3}[\-\s]?[0-9]{4}$/);
	  } else if (faxNumber.split("-").join("").length == 11){
	      isCorrect = faxNumber.match(/^1?\s?\(?[1|9]{1}\)?[\-\s]?[0-9]{3}\)?[\-\s]?[0-9]{3}[\-\s]?[0-9]{4}$/);
	  } else if (faxNumber.split("-").join("").length == 10){
	      isCorrect = faxNumber.match(/^1?\s?\(?[0-9]{3}\)?[\-\s]?[0-9]{3}[\-\s]?[0-9]{4}$/)
	  }

	  if(!isCorrect) {

	  	alert("Fax numbers are accepted in the following formats" +
			"\n###-###-#### " +
			"\n1-###-###-###" +
			"\n9-###-###-####" +
			"\n9-1-###-###-####" +
			"\n9-9-###-###-####");
	  	setTimeout( function() {
	  			$("#pharmacyFax").trigger( "focus" );
	  	},1);

 	  }

	  return isCorrect;
  }

</script>
<title><bean:message key="ManagePharmacy.title" /></title>
<html:base />

<logic:notPresent name="RxSessionBean" scope="session">
	<logic:redirect href="error.html" />
</logic:notPresent>
<logic:present name="RxSessionBean" scope="session">
	<bean:define id="bean" type="oscar.oscarRx.pageUtil.RxSessionBean"
		name="RxSessionBean" scope="session" />
	<logic:equal name="bean" property="valid" value="false">
		<logic:redirect href="error.html" />
	</logic:equal>
</logic:present>
<% oscar.oscarRx.pageUtil.RxSessionBean bean = (oscar.oscarRx.pageUtil.RxSessionBean)pageContext.findAttribute("bean"); %>

</head>
<body>
<form id="pharmacyForm">
<br>
<div class="DivCCBreadCrumbs"><a href="SearchDrug3.jsp" target="_parent">&nbsp;<bean:message
					key="SearchDrug.title" /></a> > <bean:message key="SelectPharmacy.title" /> > <bean:message
					key="ManagePharmacy.title" /> </div><br>
<div class="well">
		<table style="border-collapse: collapse; width:100%; height:100%;">
			<!--Start new rows here-->
			<tr>
				<td style="font-weight:bold;text-decoration:underline;">
				<div class="DivContentSectionHead">
				<% if (request.getParameter("ID") ==  null){ %> <bean:message
					key="ManagePharmacy.subTitle.add" /> <%}else{%> <bean:message
					key="ManagePharmacy.subTitle.update" /> <%}%> <br><br>
				</div>
				</td>
			</tr>
			<tr>
				<td>
					<table>
						<tr>
							<td>
							<% %>
							<input type="hidden" id="pharmacyId" name="pharmacyId">
							<input type="hidden" id="demographicNo" name="demographicNo" value="<%=bean.getDemographicNo()%>">
							<bean:message key="ManagePharmacy.txtfld.label.pharmacyName" />:</td>
							<td><input type="text" id="pharmacyName" name="pharmacyName" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.address" />:</td>
							<td><input type="text" id="pharmacyAddress" name="pharmacyAddress" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.city" />:</td>
							<td><input type="text" id="pharmacyCity" name="pharmacyCity" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.province" />:</td>
							<td><input type="text" id="pharmacyProvince" name="pharmacyProvince" ></td>
						</tr>
						<tr>
							<td><bean:message
								key="ManagePharmacy.txtfld.label.postalCode" />:</td>
							<td><input type="text" id="pharmacyPostalCode" name="pharmacyPostalCode" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.phone1" />:</td>
							<td><input type="text" id="pharmacyPhone1" name="pharmacyPhone1" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.phone2" />:</td>
							<td><input type="text" id="pharmacyPhone2" name="pharmacyPhone2" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.fax" />:
							</td>
							<td><input type="text" id="pharmacyFax" name="pharmacyFax" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.email" />:</td>
							<td><input type="text" id="pharmacyEmail" name="pharmacyEmail" ></td>
						</tr>
						<tr>
							<td><bean:message key="ManagePharmacy.txtfld.label.serviceLocationIdentifier" />:
							</td>
							<td><input type="text" id="pharmacyServiceLocationId" name="pharmacyServiceLocationId" ></td>
						</tr>

						<tr>
							<td><bean:message
								key="ManagePharmacy.txtfld.label.notes" />:</td>
							<td><textarea style="resize:none;" id="pharmacyNotes" name="pharmacyNotes" rows="4"></textarea></td>
						</tr>

						<tr>
                            <td><input type="button" onclick="savePharmacy();" class="btn btn-primary"
								value="<bean:message key="ManagePharmacy.submitBtn.label.submit"/>" >
							</td>
                            <td></td>
						</tr>
					</table>
				</td>
			</tr>
			<!--End new rows here-->
			<tr style="height:100%">
				<td></td>
			</tr>
		</table>
</div>
</form>
</body>

</html:html>