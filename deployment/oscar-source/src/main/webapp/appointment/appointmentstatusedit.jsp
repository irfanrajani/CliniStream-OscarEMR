<%--

    Copyright (c) 2007 Peter Hutten-Czapski based on OSCAR general requirements
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
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>

<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.userAdmin,_admin.schedule" rights="r" reverse="<%=true%>">
	<%response.sendRedirect("../logout.jsp");%>
</security:oscarSec>

<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message key="admin.appt.status.mgr.title" /></title>
    <link href="${ pageContext.servletContext.contextPath }/css/bootstrap.min.css" rel="stylesheet">
    <script src="${ pageContext.servletContext.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
    <link href="${ pageContext.servletContext.contextPath }/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">
    <link href="${ pageContext.servletContext.contextPath }/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">
    <script src="${ pageContext.servletContext.contextPath }/library/jquery/jquery-ui-1.12.1.min.js"></script>
<oscar:customInterface section="apptStatusEdit"/>

	<style>
	#red, #green, #blue {
		float: left;
		clear: left;
		width: 300px;
		margin: 15px;
	}
	#swatch {
		width: 120px;
		height: 100px;
		margin-top: 18px;
		margin-left: 350px;
		background-image: none;
	}
	#red .ui-slider-range { background: #ef2929; }
	#red .ui-slider-handle { border-color: #ef2929; }
	#green .ui-slider-range { background: #8ae234; }
	#green .ui-slider-handle { border-color: #8ae234; }
	#blue .ui-slider-range { background: #729fcf; }
	#blue .ui-slider-handle { border-color: #729fcf; }
	</style>
<script>



    function hexToRgb(hex) {
      var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      } : null;
    }

	$( function() {
		function hexFromRGB(r, g, b) {
			var hex = [
				r.toString( 16 ),
				g.toString( 16 ),
				b.toString( 16 )
			];
			$.each( hex, function( nr, val ) {
				if ( val.length === 1 ) {
					hex[ nr ] = "0" + val;
				}
			});
			return hex.join( "" );
		}
		function refreshSwatch() {
			var red = $( "#red" ).slider( "value" ),
				green = $( "#green" ).slider( "value" ),
				blue = $( "#blue" ).slider( "value" ),
				hex = hexFromRGB( red, green, blue );
			    $( "#swatch" ).css( "background-color", "#" + hex );
                $('#apptColor').val( "#" + hex );
		}

		$( "#red, #green, #blue" ).slider({
			orientation: "horizontal",
			range: "min",
			max: 255,
			value: 127,
			slide: refreshSwatch,
			change: refreshSwatch
		});

        var hex = $('#old_color').val();
	   	$( "#red" ).slider( "value", hexToRgb(hex).r );
		$( "#green" ).slider( "value", hexToRgb(hex).g );
		$( "#blue" ).slider( "value", hexToRgb(hex).b );

	} );
	</script>
</head>
<body class="ui-widget-content" style="border:0;">

<h4><bean:message
			key="admin.appt.status.mgr.title" /></h4>



<div id="red"></div>
<div id="green"></div>
<div id="blue"></div>

<div id="swatch" class="ui-widget-content ui-corner-all"></div>
<html:form action="/appointment/apptStatusSetting">
<br>
	<table>
		<tr>
			<td class="tdLabel"><bean:message
				key="admin.appt.status.mgr.label.status" />:</td>
			<td><html:text readonly="true" property="apptStatus" size="40" /></td>
		</tr>
		<tr>
			<td class="tdLabel"><bean:message
				key="admin.appt.status.mgr.label.desc" />:</td>
			<td><html:text property="apptDesc" size="40" /></td>
		</tr>
		<tr>
			<td class="tdLabel"><bean:message
				key="admin.appt.status.mgr.label.oldcolor" />:</td>
			<td><html:text readonly="true" styleId="old_color" property="apptOldColor" size="40" />
			</td>
		</tr>
		<tr>
			<td class="tdLabel"><bean:message
				key="admin.appt.status.mgr.label.newcolor" />:</td>
			<td>
				<input id="apptColor" name="apptColor" value="" size="20" />

			</td>
		</tr>


		<tr>
			<td colspan="2"><html:hidden property="ID" /> <input
				type="hidden" name="dispatch" value="update" /> <br />
			<input type="submit" class="btn btn-primary"
				value="<bean:message key="oscar.appt.status.mgr.label.submit"/>" />
			</td>
		</tr>
	</table>

</html:form>
</body>
</html>