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

<%@ include file="/casemgmt/taglibs.jsp"%>

<%
if(session.getValue("user") == null)
    response.sendRedirect("../logout.htm");
  String curUser_no;
  curUser_no = (String) session.getAttribute("user");

  boolean bFirstLoad = request.getAttribute("status") == null;

%>
<!DOCTYPE html>
<c:set var="ctx" value="${pageContext.request.contextPath}"
	scope="request" />
<html:html>
<head>
<html:base />
<title><bean:message key="provider.setNoteStaleDate.title" /></title>

<link href="<c:out value="${ctx}"/>/css/bootstrap.css" rel="stylesheet"> <!-- Bootstrap 2.3.1 -->

</head>
<body class="BodyStyle">

<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><h4><bean:message
			key="provider.setNoteStaleDate.msgPrefs" /></h4></td>
		<td class="MainTableTopRowRightColumn"><h4>&nbsp;&nbsp;<bean:message
			key="provider.setNoteStaleDate.msgProviderStaleDate" /></h4></td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn">&nbsp;</td>
		<td class="MainTableRightColumn">
		<%
               if( request.getAttribute("status") == null )
               {

            %> <html:form styleId="frmProperty"
			action="/setProviderStaleDate.do">
			<input type="hidden" id="method" name="method" value="save">
			<html:hidden property="dateProperty.name" />
			<html:hidden property="dateProperty.providerNo" />
			<html:hidden property="dateProperty.id" />
			<bean:message key="provider.setNoteStaleDate.msgEdit" />
			<html:select property="dateProperty.value" styleId="staleDate">
				<html:option value="A">All</html:option>
				<html:option value="0">0</html:option>
				<html:option value="-1">1</html:option>
				<html:option value="-2">2</html:option>
				<html:option value="-3">3</html:option>
				<html:option value="-4">4</html:option>
				<html:option value="-5">5</html:option>
				<html:option value="-6">6</html:option>
				<html:option value="-7">7</html:option>
				<html:option value="-8">8</html:option>
				<html:option value="-9">9</html:option>
				<html:option value="-10">10</html:option>
				<html:option value="-11">11</html:option>
				<html:option value="-12">12</html:option>
				<html:option value="-13">13</html:option>
				<html:option value="-14">14</html:option>
				<html:option value="-15">15</html:option>
				<html:option value="-16">16</html:option>
				<html:option value="-17">17</html:option>
				<html:option value="-18">18</html:option>
				<html:option value="-19">19</html:option>
				<html:option value="-20">20</html:option>
				<html:option value="-21">21</html:option>
				<html:option value="-22">22</html:option>
				<html:option value="-23">23</html:option>
				<html:option value="-24">24</html:option>
				<html:option value="-25">25</html:option>
				<html:option value="-26">26</html:option>
				<html:option value="-27">27</html:option>
				<html:option value="-28">28</html:option>
				<html:option value="-29">29</html:option>
				<html:option value="-30">30</html:option>
				<html:option value="-31">31</html:option>
				<html:option value="-32">32</html:option>
				<html:option value="-33">33</html:option>
				<html:option value="-34">34</html:option>
				<html:option value="-35">35</html:option>
				<html:option value="-36">36</html:option>
			</html:select>
			<br/>
			<html:hidden property="singleViewProperty.name" />
			<html:hidden property="singleViewProperty.providerNo" />
			<html:hidden property="singleViewProperty.id" />
			Use Single Line View:
			<html:select property="singleViewProperty.value" styleId="staleDate">
				<html:option value="no">No</html:option>
				<html:option value="yes">Yes</html:option>
			</html:select>

			<br/>
			<input type="submit" class="btn btn-primary"
				value="<bean:message key="provider.setNoteStaleDate.btnSubmit"/>" />
			<input type="submit" class="btn" onclick="$('method').value='remove';"
				value="<bean:message key="provider.setNoteStaleDate.btnReset"/>" />
		</html:form> <%
               }
               else {
            %> <div class="alert alert-success" style="width:100%"><bean:message key="provider.setNoteStaleDate.msgSuccess" /></div>
		<br>

		<%
               }
            %>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>
</body>
</html:html>