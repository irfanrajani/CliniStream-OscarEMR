<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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

--%>
<!DOCTYPE html>
<%@ page import="java.util.*, java.sql.*, oscar.*, java.text.*, java.lang.*,java.net.*, oscar.appt.*, org.oscarehr.common.dao.AppointmentTypeDao, org.oscarehr.common.model.AppointmentType, org.oscarehr.util.SpringUtils" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ include file="../admin/dbconnection.jsp" %>
<%--RJ 07/07/2006 --%>
<%
  String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");

  String sError = "";
  if (request.getParameter("err")!=null &&  !request.getParameter("err").equals(""))
  	sError = "Error: " + request.getParameter("err");
%>

<%@ page errorPage="../errorpage.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="oscar.util.*" %>
<%@ page import="oscar.login.*" %>
<%@ page import="oscar.log.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<html:html locale="true">
<head>
      <title>
        APPOINTMENT TYPES
      </title>
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">
<script>
	function popupPage(vheight,vwidth,title,varpage) {
		var page = "" + varpage;
		var leftVal = (screen.width-850) / 2;
		var topVal = (screen.height-300) / 2;
		windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,top="+topVal+",left="+leftVal;
		var popup=window.open(page, title, windowprops);
  		if (popup != null) {
    		if (popup.opener == null) {
      			popup.opener = self;
    		}
    		popup.focus();
		}
	}
	function popupResponce(href)
	{
		window.location.href = href;
	}
	function setfocus() {
		this.focus();
	  document.forms[0].name.focus();
	  document.forms[0].name.select();
	}

	function upCaseCtrl(ctrl) {
		ctrl.value = ctrl.value.toUpperCase();
	}

	function onBlockFieldFocus(obj) {
	  obj.blur();
	  document.forms[0].name.focus();
	  document.forms[0].name.select();
	  window.alert("Please enter appointment type name");
	}

	function checkTypeNum(typeIn) {
		var typeInOK = true;
		var i = 0;
		var length = typeIn.length;
		var ch;
		// walk through a string and find a number
		if (length>=1) {
		  while (i <  length) {
			  ch = typeIn.substring(i, i+1);
			  if (ch == ":") { i++; continue; }
			  if ((ch < "0") || (ch > "9") ) {
				  typeInOK = false;
				  break;
			  }
		    i++;
	      }
		} else typeInOK = false;
		return typeInOK;
	}
	function checkTimeTypeIn(obj) {
	  if(!checkTypeNum(obj.value) ) {
//		  alert ("Please enter numeric value in Duration field");
		} else {
		  if(obj.value == '') {
		    alert("Please enter value in Names field");
			onBlockFieldFocus(obj);
		  }
		}
	}
</script>
<script>
function delType(url) {
var answer = confirm("Type will be deleted! Are you sure?")
	if (answer){
		window.location = url;
	}
}
</script>

    </head>
    <body>
<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<html:errors/></span>
<h3>Appointment Types</h3><br>
	<table style="width:100%;">
	  <tr>
	  <td>&nbsp;</td>
	  <td >


				<html:form action="appointment/appointmentTypeAction">
  					<input TYPE="hidden" NAME="oper" VALUE="save" >
  					<input TYPE="hidden" NAME="id" VALUE="<bean:write name="AppointmentTypeForm" property="id"/>" >
  					<table style="width:100%;" >
    					<tr>
      						<th>EDIT APPOINTMENT TYPE</th>
    					</tr>
  					</table>
  					<table style="width:100%;">
    					<tr>
      						<td style="width:100%;">
      							<table style="width:100%;" >
          							<tr>
            							<td style="text-align:right;"> Name:</td>
			            				<td> <INPUT TYPE="TEXT" NAME="name" VALUE="<bean:write name="AppointmentTypeForm" property="name"/>" maxlength="50" onChange="checkTimeTypeIn(this)">
            							<td style="text-align:right;">Duration:</td>
			            				<td> <INPUT TYPE="TEXT" NAME="duration" VALUE="<bean:write name="AppointmentTypeForm" property="duration"/>" onChange="checkTimeTypeIn(this)"> </td>
          							</tr>
          							<tr >
            							<td style="text-align:right;">Reason:</td>
            							<td > <TEXTAREA NAME="reason" COLS="40" ROWS="2"><bean:write name="AppointmentTypeForm" property="reason"/></TEXTAREA> </td>
            							<td style="text-align:right;">Notes:</td>
            							<td > <TEXTAREA NAME="notes"  COLS="40" ROWS="2"><bean:write name="AppointmentTypeForm" property="notes"/></TEXTAREA> </td>
          							</tr>
          							<tr>
            							<td style="text-align:right;">Location:</td>
            							<td>
            							  <logic:notEmpty name="locationsList">
											<html:select property="location" >
												<html:option value="0">Select Location</html:option>
												<logic:iterate id="location" name="locationsList">
												    <bean:define id="locValue" ><bean:write name='location' property='label'/></bean:define>
													<html:option value="<%= locValue %>">
														<bean:write name="location" property="label"/>
													</html:option>
												</logic:iterate>
											</html:select>
										  </logic:notEmpty>
										  <logic:empty name="locationsList">
            								<INPUT TYPE="TEXT" NAME="location" VALUE="<bean:write name="AppointmentTypeForm" property="location"/>" maxlength="30" >
										  </logic:empty>
										</td>
            							<td style="text-align:right">Resources:</td>
            							<td ><INPUT TYPE="TEXT" NAME="resources" VALUE="<bean:write name="AppointmentTypeForm" property="resources"/>" maxlength="10" > </td>
          							</tr>
        						</table>
        					</td>
    					</tr>
  					</table>
  					<table style="width:100%;">
    					<tr >
      						<TD> <input type="submit" value="Save"  class="btn btn-primary" >
      						</TD>
    					</tr>
  					</table>
				</html:form>
            </td>
          </tr>
</table>
<br><br>
<table class="table table-hover table-striped table-condensed">
        <thead>
          <tr>
            <th>
              Name
            </th>
            <th>
              Duration
            </th>
            <th>
              Reason
            </th>
            <th>
              Notes
            </th>
            <th>
              Location
            </th>
            <th>
              Resources
            </th>
            <th>
            </th>
          </tr>
        </thead>
        <tbody>
<%
boolean bMultisites = org.oscarehr.common.IsPropertiesOn.isMultisitesEnable();
List<AppointmentType> types = new ArrayList<AppointmentType>();
AppointmentTypeDao dao = (AppointmentTypeDao) SpringUtils.getBean("appointmentTypeDao");
types = dao.listAll();

  int rowNum = 0;
  if(types != null && types.size()>0) {
  	for(AppointmentType type : types) {
%>
          <tr>
            <td>
              <%= type.getName() %>
            </td>
            <td>
              <%= Integer.toString(type.getDuration()) %> min
            </td>
            <td>
              <%= type.getReason() %>
            </td>
            <td>
              <%= type.getNotes() %>
            </td>
            <td>
              <%= type.getLocation() %>
            </td>
            <td>
              <%= type.getResources() %>
            </td>
            <td>
              <a href="appointmentTypeAction.do?oper=edit&no=<%= type.getId() %>">edit</a>
              &nbsp;&nbsp;<a href="javascript:delType('appointmentTypeAction.do?oper=del&no=<%= type.getId() %>')">delete</a>
            </td>
          </tr>
<%
  	}
  }
%>
            </tbody>
        </table>

	</body>
</html:html>