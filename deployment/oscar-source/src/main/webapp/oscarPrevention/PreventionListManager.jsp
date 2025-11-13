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
<%@page import="org.oscarehr.managers.PreventionManager"%>
<%@page import="org.oscarehr.util.SpringUtils"%>
<%@page import="java.util.*"%>
<%@page import="org.oscarehr.util.LoggedInInfo"%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
String roleName$ = (String) session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
boolean authed = true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_prevention"
	rights="r" reverse="<%=true%>">
	<%
	authed = false;
	%>
	<%
	response.sendRedirect("../securityError.jsp?type=_prevention");
	%>
</security:oscarSec>
<%
if (!authed) {
	return;
}
%>
<!DOCTYPE html>
<html>
<head>
<title><bean:message
		key="oscarprevention.preventionlistmanager.title" /></title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="<%=request.getContextPath()%>/css/bootstrap.min.css"
	rel="stylesheet" media="screen">

<style type="text/css">
.table tbody tr:hover td, .table tbody tr:hover th {
	background-color: #FFFFAA;
	cursor: pointer;
	cursor: hand;
}

.table tbody td.item-active {
	background-color: #009900 !important;
}
</style>
</head>

<body>

	<div class="container">
		<h1>
			<bean:message key="oscarprevention.preventionlistmanager.title" />
		</h1>
		<p class="lead">
			<bean:message key="oscarprevention.preventionlistmanager.lead" />
		</p>
		<p style="margin-top: -20px">
			<span class="label label-info"><bean:message key="global.info" /></span>
			<bean:message
				key="oscarprevention.preventionlistmanager.instructions" />
		</p>

		<table class="table table-striped table-hover table-bordered">

			<thead>
				<tr>
					<th></th>
					<th width="200px"><bean:message key="global.name" /></th>
					<th><bean:message key="global.description" /></th>
				</tr>
			</thead>

			<tbody>
				<%
				PreventionManager preventionManager = SpringUtils.getBean(PreventionManager.class);

				if (request.getParameter("formAction") != null && request.getParameter("formAction").equals("update")) {
					preventionManager.addCustomPreventionShownItems(request.getParameter("prevention-bin"));
				}

				LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
				ArrayList<HashMap<String, String>> prevList = preventionManager.getPreventionTypeDescList();

				String customPreventionItems = "Tuberculosis,PAP,HPV-CERVIX,MAM,PSA,FOBT,COLONOSCOPY,BMD,HIV,HepB screen,HepC,screen,VDRL,chlamydia,ghonorrhea PCR,PHV,Smoking,OtherB";

				boolean propertyExists = preventionManager.isHidePrevItemExist();
				boolean propertyShowExists = preventionManager.isShowPrevItemExist();

				if (propertyExists && !propertyShowExists) {
				%>
				<script type="text/javascript">
				alert("<bean:message
						key="oscarprevention.preventionlistmanager.reset" />");
				</script>
				<%
				}

				if (propertyShowExists) {
				customPreventionItems = preventionManager.getCustomPreventionShownItems();
				}

				String prevId = null;
				String prevName = null;
				String prevDesc = null;
				String regex = "[`~!@#$%^&*()=+\\[{\\]}\\\\|;:'\",<.>/?\\s]";
				for (int e = 0; e < prevList.size(); e++) {
				HashMap<String, String> h = prevList.get(e);
				prevId = h.get("name").replaceAll(regex, "");
				prevName = h.get("name");
				prevDesc = h.get("desc");
				%>
				<tr class="prevention-item" id="<%=prevId%>"
					prevention-data="<%=prevName%>">
					<td class="" title="Removed from master list"></td>
					<td><%=prevName%></td>
					<td><%=prevDesc%></td>
				</tr>

				<%
				}
				%>
			</tbody>
		</table>

		<!-- Button to trigger modal confirmation -->
		<button id="btnVoid" class="btn pull-right" disabled
			style="display: none"><bean:message
						key="global.btnSave" /></button>
		<a href="#modalConfirm" id="btnConfirm"
			class="btn btn-primary pull-right" data-toggle="modal"
			data-backdrop="false"><bean:message
						key="global.btnSave" /></a>

	</div>
	<!-- container -->


	<form action="PreventionListManager.jsp?formAction=update"
		method="post">
		<!-- Modal -->
		<div id="modalConfirm" class="modal hide fade" tabindex="-1"
			role="dialog" aria-labelledby="modalConfirmLabel" aria-hidden="true">
			<div class="modal-header" style="background-color: silver">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">x</button>
				<h3 id="modalConfirmLabel"><bean:message
						key="oscarprevention.preventionlistmanager.modal.title" /></h3>
			</div>
			<div class="modal-body">
				<p><bean:message
						key="oscarprevention.preventionlistmanager.modal.confirmchanges" />:</p>
				<div class="well" id="modalItems"></div>
			</div>
			<div class="modal-footer">
				<button class="btn" data-dismiss="modal" aria-hidden="true"><bean:message
						key="oscarprevention.preventionlistmanager.modal.btnBack" /></button>
				<button type="submit" class="btn btn-danger"><bean:message
						key="oscarprevention.preventionlistmanager.modal.btnSave" /></button>
			</div>
		</div>

		<!-- property value to be saved: hidden-->
		<input type="hidden" name="prevention-bin" id="prevention-bin">
	</form>


	<!-- property value from database: hidden-->
	<input type="hidden" name="property-bin" id="property-bin"
		style="width: 1200px" value="<%=customPreventionItems%>">


	<script type="text/javascript"
		src="<%=request.getContextPath()%>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
	<script type="text/javascript"
		src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>

	<script type="text/javascript">
$(".prevention-item").on( "click", function () {
    var id = $(this).attr("id");
    var name = $(this).attr("prevention-data");
    bin = $("#prevention-bin");
    indicatorDisplay(id, name);
});


function indicatorDisplay(id, name){
    if($('#'+id+' td:first-child').length){
	    indicator = $('#'+id+' td:first-child');
        
        console.log("   id="+id+"\n name="+name);
	    if(!indicator.hasClass("item-active")){
		    indicator.addClass('item-active');
		    indicator.attr("title", "<bean:message
					key="oscarprevention.preventionlistmanager.listed" />");	    
		    addPreventionToBin(name);
	        
	    }else{
		    indicator.removeClass('item-active');
		    indicator.attr("title", "<bean:message
					key="oscarprevention.preventionlistmanager.notlisted" />");
		    removePreventionFromBin(name);
	    }

	    //btnSaveDisplay();
    }
}

function indicatorAllDisplay(items){
    var regex = /[`~!@#$%^&*()+=\[{\]}\\|;:'",<.>\/?\s]/g;
	preventions = items.split(',');
	n = preventions.length;
	if(n>1){
		for(i=0;i<n;i++){
			id = preventions[i].replace(regex, "");
			indicatorDisplay(id, preventions[i]);
		}
	}else{			
		id = items.replace(regex, "");
		indicatorDisplay(id, items);
	}
}

function addPreventionToBin(name){
	bin = $("#prevention-bin");
	if(bin.val()!=""){
		bin.val(bin.val() + "," + name.trim());
        console.log("added to show list="+name);
	}else{
		bin.val(name);
	}
}

function removePreventionFromBin(itemToBeRemoved){
	bin = $("#prevention-bin");
	if(bin.val()!=""){
	preventions = bin.val().split(',');
    preventions.map(s => s.trim());
	n = preventions.length;
		if(n>1){
			index = preventions.indexOf(itemToBeRemoved);
			console.log("removing item no. "+index);
			if(index > -1){
				preventions.splice(index, 1);
				bin.val(preventions);
                console.log("removed from show list="+itemToBeRemoved);
			}
			
		}else{
			bin.val("");
		}
	}
}

function btnSaveDisplay() {
	bin = $("#prevention-bin");
	prop = $("#property-bin");
	
	if(bin.val()!="" || prop.val()!=""){
		$("#btnVoid").hide();
		$("#btnConfirm").show();
	}else{
		$("#btnConfirm").hide();
		$("#btnVoid").show();
		$('#modalItems').html('');
	}
}

function setModalItems(){
	$('#modalItems').html('');
	bin = $("#prevention-bin");
	if(bin.val()!=""){
	preventions = bin.val().split(',');
	n = preventions.length;
	
	$('#modalItems').html("<h5><bean:message
			key="oscarprevention.preventionlistmanager.modal.show" /></h5>");
		if(n>1){
			for(i=0;i<n;i++){
			
				$('#modalItems').append(preventions[i]+"<br>");
			}
		}else{			
			$('#modalItems').append(bin.val()+"<br>");
		}
	}else{
		$('#modalItems').html("<bean:message
				key="oscarprevention.preventionlistmanager.modal.none" />");
	}
}



$("#btnConfirm").on( "click", function () {
	$('html, body', window.parent.document).animate({scrollTop:230}, 'slow');
	setModalItems();
});

$( document ).ready(function() {	

if($('#property-bin').val()!=""){
	indicatorAllDisplay($('#property-bin').val());
}	

    parent.parent.resizeIframe($('html').height());	
});
</script>
</body>
</html>