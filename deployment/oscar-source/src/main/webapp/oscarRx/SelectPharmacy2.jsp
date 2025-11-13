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
<%@page import="java.io.StringWriter"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="oscar.OscarProperties,oscar.log.*"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ page import="oscar.oscarRx.data.*,java.util.*"%>
<%@ page import="org.oscarehr.common.model.PharmacyInfo" %>
<%@ page import="org.owasp.encoder.Encode" %>

<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_rx" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_rx");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
OscarProperties oscarProps = OscarProperties.getInstance();
String help_url = (oscarProps.getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/")).trim();
%>

<html:html locale="true">
<head>
<script src="${ pageContext.request.contextPath }/js/global.js"></script>
<script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
<script src="${ pageContext.request.contextPath }/library/jquery/jquery-ui-1.12.1.min.js"></script>
<script src="${ pageContext.request.contextPath }/share/javascript/Oscar.js"></script>

<title><bean:message key="SelectPharmacy.title" /></title>

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

<%
oscar.oscarRx.pageUtil.RxSessionBean bean = (oscar.oscarRx.pageUtil.RxSessionBean)pageContext.findAttribute("bean");
%>

<bean:define id="patient"
	type="oscar.oscarRx.data.RxPatientData.Patient" name="Patient" />

<link rel="stylesheet" href="${ pageContext.request.contextPath }/oscarRx/styles.css">



<style>
.ui-autocomplete {
	background-color: #CEF6CE;
	border: 3px outset #2EFE2E;
	width:300px;
}

.ui-menu-item:hover {
		background-color:#426FD9;
		color:#FFFFFF;
}
th {
    font-size:14px;
}

</style>
<script>
( function($) {
	$(function() {
		var demo = $("#demographicNo").val();
		$.get("<%=request.getContextPath() + "/oscarRx/managePharmacy.do?method=getPharmacyFromDemographic&demographicNo="%>"+demo,
			function( data ) {
                if(data && data.length && data.length > 0){
					$("#preferredList").html("");
					var json;
					var preferredPharmacyInfo;
					for( var idx = 0; idx < data.length; ++idx  ) {
						preferredPharmacyInfo = data[idx];
						json = JSON.stringify(preferredPharmacyInfo);

						var pharm = "<div prefOrder='"+idx+"' pharmId='"+preferredPharmacyInfo.id+"'><table><tr><td class='prefAction prefUp'> Up </td>";
						pharm += "<td rowspan='3' style='padding-left: 5px'>" + preferredPharmacyInfo.name + "<br /> ";
						pharm += preferredPharmacyInfo.address + ", " + preferredPharmacyInfo.city + " " +preferredPharmacyInfo.province + "<br /> ";
						pharm += preferredPharmacyInfo.postalCode + "<br />";
						pharm += "Main Phone: " + preferredPharmacyInfo.phone1 + "<br />";
						pharm += "Fax: " + preferredPharmacyInfo.fax + "<br />";
                        pharm += "<a href='#'  onclick='viewPharmacy(" + preferredPharmacyInfo.id  + ");'>View Details</a>" + "</td>";
						pharm += "</tr><tr><td class='prefAction prefUnlink'> Unlink </td></tr><tr><td class='prefAction prefDown'>Down</td></tr></table></div>";

						$("#preferredList").append(pharm);
					}

					$(".prefUnlink").on( "click", function(){
						  var data = "pharmacyId=" + $(this).closest("div").attr("pharmId") + "&demographicNo=" + demo;
						  $.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=unlink",
							  data, function( data ) {
								if( data.id ) {
									window.location.reload(false);
								}
								else {
									alert("Unable to unlink pharmacy");
								}
							}, "json");
					  });

					$(".prefUp").on( "click", function(){
						if($(this).closest("div").prev() != null){
							var $curr = $(this).closest("div");
							var $prev = $(this).closest("div").prev();

							var data = "pharmId=" + $curr.attr("pharmId") + "&demographicNo=" + demo + "&preferredOrder=" + (parseInt($curr.attr("prefOrder")) - 1);
							$.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=setPreferred",
							  data, function( data2 ) {
									if( data2.id ) {
										data = "pharmId=" + $prev.attr("pharmId") + "&demographicNo=" + demo + "&preferredOrder=" + (parseInt($prev.attr("prefOrder")) + 1);
										$.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=setPreferred",
										  data, function( data3 ) {
												if( data3.id ) {
													window.location.reload(false);
												}
										}, "json");
									}
							}, "json");
						}
					  });

					$(".prefDown").on( "click", function(){
						if($(this).closest("div").next() != null){
							var $curr = $(this).closest("div");
							var $next = $(this).closest("div").next();

							var data = "pharmId=" + $curr.attr("pharmId") + "&demographicNo=" + demo + "&preferredOrder=" + (parseInt($curr.attr("prefOrder")) + 1);
							$.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=setPreferred",
							  data, function( data2 ) {
									if( data2.id ) {
										data = "pharmId=" + $next.attr("pharmId") + "&demographicNo=" + demo + "&preferredOrder=" + (parseInt($next.attr("prefOrder")) - 1);
										$.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=setPreferred",
										  data, function( data3 ) {
												if( data3.id ) {
													window.location.reload(false);
												}
										}, "json");
									}
							}, "json");
						}
					  });
				}
		}, "json");

		var pharmacyNameKey = new RegExp($("#pharmacySearch").val(), "i");
		var pharmacyCityKey = new RegExp($("#pharmacyCitySearch").val(), "i");
		var pharmacyPostalCodeKey =  new RegExp($("#pharmacyPostalCodeSearch").val(), "i");
		var pharmacyFaxKey = new RegExp($("#pharmacyFaxSearch").val(), "i");
		var pharmacyPhoneKey = new RegExp($("#pharmacyPhoneSearch").val(), "i");
		var pharmacyAddressKey =  new RegExp($("#pharmacyAddressSearch").val(), "i");

		$("#pharmacySearch").on( "keyup", function(){
			updateSearchKeys();
		  $(".pharmacyItem").hide();
		  $.each($(".pharmacyName"), function( key, value ) {
			if($(value).html().toLowerCase().search(pharmacyNameKey) >= 0){
				if($(value).siblings(".city").html().search(pharmacyCityKey) >= 0){
                    if($(value).siblings(".postalCode").html().search(pharmacyPostalCodeKey) >= 0) {
                        if ($(value).siblings(".fax").html().search(pharmacyFaxKey) >= 0) {
							if ($(value).siblings(".fax").html().search(pharmacyAddressKey) >= 0) {
								$(value).parent().show();
							}
                        }
                    }
				}
			}
		  });
	  });

	  $("#pharmacyCitySearch").on( "keyup", function(){
		  updateSearchKeys();
		  $(".pharmacyItem").hide();
		  $.each($(".city"), function( key, value ) {
			if($(value).html().toLowerCase().search(pharmacyCityKey) >= 0){
				if($(value).siblings(".pharmacyName").html().search(pharmacyNameKey) >= 0){
                    if($(value).siblings(".postalCode").html().search(pharmacyPostalCodeKey) >= 0) {
                        if ($(value).siblings(".fax").html().search(pharmacyFaxKey) >= 0) {
							if ($(value).siblings(".fax").html().search(pharmacyAddressKey) >= 0) {
								$(value).parent().show();
							}
                        }
                    }
				}
			}
		  });
	  });

        $("#pharmacyPostalCodeSearch").on( "keyup", function(){
			updateSearchKeys();
            $(".pharmacyItem").hide();
            $.each($(".postalCode"), function( key, value ) {
                if($(value).html().toLowerCase().search(pharmacyPostalCodeKey) >= 0){
                    if($(value).siblings(".pharmacyName").html().search(pharmacyNameKey) >= 0){
                        if($(value).siblings(".city").html().search(pharmacyCityKey) >= 0){
                            if($(value).siblings(".fax").html().search(pharmacyFaxKey) >= 0){
                                $(value).parent().show();
                            }
                        }
					}
                }
            });
        });

	  $("#pharmacyFaxSearch").on( "keyup", function(){
		  updateSearchKeys();
		  $(".pharmacyItem").hide();
		  $.each($(".fax"), function( key, value ) {
			if($(value).html().search(pharmacyFaxKey) >= 0 || $(value).html().split("-").join("").search(pharmacyFaxKey) >= 0){
				if($(value).siblings(".pharmacyName").html().search(pharmacyNameKey) >= 0) {
					if ($(value).siblings(".city").html().search(pharmacyCityKey) >= 0) {
						if ($(value).siblings(".postalCode").html().search(pharmacyPostalCodeKey) >= 0) {
							$(value).parent().show();
						}
					}
				}
			}
		  });
	  });

        $("#pharmacyPhoneSearch").on( "keyup", function(){
			updateSearchKeys();
            $(".pharmacyItem").hide();
            $.each($(".phone"), function( key, value ) {
                if($(value).html().search(pharmacyPhoneKey) >= 0 || $(value).html().split("-").join("").search(pharmacyPhoneKey) >= 0){
                    if($(value).siblings(".pharmacyName").html().search(pharmacyNameKey) >= 0){
                        if($(value).siblings(".city").html().search(pharmacyCityKey) >= 0){
                            if($(value).siblings(".postalCode").html().search(pharmacyPostalCodeKey) >= 0) {
                                $(value).parent().show();
                            }
                        }
                    }
                }
            });
        });

		$("#pharmacyAddressSearch").on( "keyup", function(){
			updateSearchKeys()
			$(".pharmacyItem").hide();
			$.each($(".address"), function( key, value ) {
				if($(value).html().search(pharmacyAddressKey) >= 0 || $(value).html().split("-").join("").search(pharmacyAddressKey) >= 0){
					if($(value).siblings(".pharmacyName").html().search(pharmacyNameKey) >= 0){
						if($(value).siblings(".city").html().search(pharmacyCityKey) >= 0){
							if($(value).siblings(".postalCode").html().search(pharmacyPostalCodeKey) >= 0) {
								$(value).parent().show();
							}
						}
					}
				}
			});
		});

      $(".pharmacyItem").on( "click", function(){
		  var pharmId = $(this).attr("pharmId");

		  $("#preferredList div").each(function(){
			  if($(this).attr("pharmId") == pharmId){
				  alert("Selected pharamacy is already selected");
				  return false;
			  }
		  });

		  var data = "pharmId=" + pharmId + "&demographicNo=" + demo + "&preferredOrder=" + $("#preferredList div").length;

		  $.post("<%=request.getContextPath() + "/oscarRx/managePharmacy.do?method=setPreferred"%>", data, function( data ) {
			if( data.id ) {
				window.location.reload(false);
			}
			else {
				alert("There was an error setting your preferred Pharmacy");
			}
		  },"json");
      });

	$(".deletePharm").on( "click", function(){
		if( confirm("You are about to remove this pharmacy for all users. Are you sure you want to continue?")) {
			var data = "pharmacyId=" + $(this).closest("tr").attr("pharmId");
			$.post("<%=request.getContextPath()%>/oscarRx/managePharmacy.do?method=delete",
					data, function( data ) {
				if( data.success ) {
					window.location.reload(false);
				}
				else {
					alert("There was an error deleting the Pharmacy");
				}
			},"json");
		}
	});


		function updateSearchKeys() {
			pharmacyNameKey = new RegExp($("#pharmacySearch").val(), "i");
			pharmacyCityKey = new RegExp($("#pharmacyCitySearch").val(), "i");
			pharmacyPostalCodeKey =  new RegExp($("#pharmacyPostalCodeSearch").val(), "i");
			pharmacyFaxKey = new RegExp($("#pharmacyFaxSearch").val(), "i");
			pharmacyPhoneKey = new RegExp($("#pharmacyPhoneSearch").val(), "i");
			pharmacyAddressKey =  new RegExp($("#pharmacyAddressSearch").val(), "i");
		}
})}) ( jQuery );

function activateWindow(arg){
    window.open(arg.href,"_blank","width="+arg.width+",height="+arg.height);
}

function addPharmacy(){
	activateWindow({
		href: "<%= request.getContextPath() %>/oscarRx/ManagePharmacy2.jsp?type=Add",
		width: 450,
		height: 750
	});
}

function editPharmacy(id){
	activateWindow({
		href: "<%= request.getContextPath() %>/oscarRx/ManagePharmacy2.jsp?type=Edit&ID=" + id,
		width: 450,
		height: 750
	});
}

function viewPharmacy(id){
    activateWindow({
        href: "<%= request.getContextPath() %>/oscarRx/ViewPharmacy.jsp?type=View&ID=" + id,
        width: 395,
        height: 450
    });
}



function returnToRx(){
	//var rx_enhance = <%=OscarProperties.getInstance().getProperty("rx_enhance")%>;

	//if(rx_enhance){
	//    opener.window.refresh();
	//    window.close();
	//} else {
        window.location.href="SearchDrug3.jsp";
	//}
}

</script>
</head>
<body>
<form id="pharmacyForm">
<input type="hidden" id="demographicNo" name="demographicNo" value="<%=bean.getDemographicNo()%>">


		<table style="border-collapse: collapse; width:100%; height:100%;">
			<tr>
				<td style="vertical-align: top;" colspan="1">
				<div class="DivCCBreadCrumbs"><a href="SearchDrug3.jsp"> <bean:message
					key="SearchDrug.title" /></a> >  <bean:message key="SelectPharmacy.title" /></div>
				</td>

				<td colspan="1" style="text-align:right; vertical-align: top;">
				<div class="DivCCBreadCrumbs">
				<a style="color:black;" href="<%=help_url%>pharmacies/" target="_blank">Help</a> |
                 		<a style="color:black;" href="<%=request.getContextPath() %>/oscarEncounter/About.jsp" target="_blank">About</a></div>
            			</td>
			</tr>
			<!--Start new rows here-->

			<tr>
				<td colspan="2">
				<hr style="border:1px solid black;">
				<div class="DivContentTitle"><b><bean:message
					key="SearchDrug.nameText" /></b> <jsp:getProperty name="patient"
					property="surname" />, <jsp:getProperty name="patient"
					property="firstName" />&nbsp;&nbsp;&nbsp;

					<input type=button class="ControlPushButton" onclick="returnToRx();" value="<bean:message key="SelectPharmacy.ReturnToRx" />" >
				</div>
				<br>
				</td>
			</tr>
			<tr>
				<th style="width:33%;"  class="DivContentSectionHead">
					<p><bean:message key="SelectPharmacy.linkedPreferredPharmacy" /></p>
				</th>
				<th class="DivContentSectionHead">
					<bean:message key="SelectPharmacy.searchExistingLabel" />: &nbsp;&nbsp;<input placeholder="Pharmacy Name" type="text" id="pharmacySearch">&nbsp;&nbsp;
					<input placeholder="<bean:message key="SelectPharmacy.table.city" />" type="text" id="pharmacyCitySearch" style="width: 82px"> &nbsp;&nbsp;
					<input placeholder="<bean:message key="SelectPharmacy.table.postalCode" />" type="text" id="pharmacyPostalCodeSearch" style="width: 82px"> &nbsp;&nbsp;
					<input placeholder="<bean:message key="SelectPharmacy.table.phone" />" type="text" id="pharmacyPhoneSearch" style="width: 82px"> &nbsp;&nbsp;
					<input placeholder="<bean:message key="SelectPharmacy.table.fax" />" type="text" id="pharmacyFaxSearch" style="width: 82px"> &nbsp;&nbsp;
					<input placeholder="<bean:message key="SelectPharmacy.table.address" />" type="text" id="pharmacyAddressSearch" style="width: 125px">  &nbsp;&nbsp;
					<a href="javascript:void(0)" onclick="addPharmacy();"><bean:message key="SelectPharmacy.addLink" /></a>
				</th>
			</tr>
			<tr>
				<td id="preferredList">

					<div>
							<bean:message key="SelectPharmacy.noPharmaciesSelected" />
					</div>
				</td>
				<td>
					<% RxPharmacyData pharmacy = new RxPharmacyData();
                         List< org.oscarehr.common.model.PharmacyInfo> pharList = pharmacy.getAllPharmacies();
                       %>
					<div style="width:100%; height:560px; overflow:auto;">
					<table id="pharmacyList" style="width:100%;">
						<tr>
							<th><bean:message key="SelectPharmacy.table.pharmacyName" /></th>
							<th><bean:message key="SelectPharmacy.table.address" /></th>
							<th><bean:message key="SelectPharmacy.table.city" /></th>
							<th><bean:message key="SelectPharmacy.table.postalCode" /></th>
							<th><bean:message key="SelectPharmacy.table.phone" /></th>
							<th><bean:message key="SelectPharmacy.table.fax" /></th>
							<th>&nbsp;</th>
							<th>&nbsp;</th>
						</tr>
						<tr><td colspan="8"><br><hr style="border:1px solid black;">
						<p style="padding:4px;background-color:#FDFEC7;font-size:12px; text-align:center;"><bean:message key="SelectPharmacy.instructions" /></p>
                        </td></tr>
						<% for (int i = 0 ; i < pharList.size(); i++){
								   org.oscarehr.common.model.PharmacyInfo ph = pharList.get(i);
								%>

						<tr class="pharmacyItem" pharmId="<%=ph.getId()%>">
							<td class="pharmacyName" ><%=Encode.forHtml(ph.getName())%></td>
							<td class="address" ><%=Encode.forHtml(ph.getAddress())%></td>
							<td class="city" ><%=Encode.forHtml(ph.getCity())%></td>
							<td class="postalCode" ><%=Encode.forHtml(ph.getPostalCode())%></td>
							<td class="phone" ><%=Encode.forHtml(ph.getPhone1())%></td>
							<td class="fax" ><%=Encode.forHtml(ph.getFax())%></td>

							<td onclick='event.stopPropagation();return false;'><a href="#"  onclick="editPharmacy(<%=ph.getId()%>);"><bean:message
								key="SelectPharmacy.editLink" /></a></td>
							<td onclick='event.stopPropagation();return false;'><a href="#" class="deletePharm"><bean:message
								key="SelectPharmacy.deleteLink" /></a></td>

						</tr>
						<% } %>
					</table>
					</div>
				</td>
			</tr>
			<!--End new rows here-->
			<tr style="height:100%;">
				<td colspan="2"></td>
			</tr>
		</table>

</form>
</body>

</html:html>