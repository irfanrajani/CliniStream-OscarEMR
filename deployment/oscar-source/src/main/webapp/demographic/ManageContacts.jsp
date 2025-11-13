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

<%@ page import="java.util.List"%>
<%@ page import="org.oscarehr.common.model.Contact"%>
<%@page import="org.oscarehr.common.model.DemographicContact"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="java.util.GregorianCalendar" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="org.oscarehr.common.model.Demographic" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
	String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_demographic" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect(request.getContextPath() + "/securityError.jsp?type=_demographic");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%
	LoggedInInfo loggedInInfo = LoggedInInfo.getLoggedInInfoFromSession(request);
	OscarProperties oscarProps = OscarProperties.getInstance();
	@SuppressWarnings("unchecked")
	List<DemographicContact> dcs = (List<DemographicContact>) request.getAttribute("contacts");


	String sortColumn = request.getAttribute("sortColumn") != null ? request.getAttribute("sortColumn").toString() : "category";
	String sortOrder = request.getAttribute("sortOrder") != null ? request.getAttribute("sortOrder").toString() : "asc";
	String list = request.getAttribute("list") != null ? request.getAttribute("list").toString() : "active";

	GregorianCalendar now = new GregorianCalendar();
	int curYear = now.get(Calendar.YEAR);
	int curMonth = (now.get(Calendar.MONTH)+1);
	int curDay = now.get(Calendar.DAY_OF_MONTH);
	String providerNo = loggedInInfo.getLoggedInProviderNo();

	java.util.ResourceBundle oscarResources = ResourceBundle.getBundle("oscarResources", request.getLocale());
	String noteReason = oscarResources.getString("oscarEncounter.noteReason.TelProgress");

	String demographic_no = request.getParameter("demographic_no");
	if(demographic_no == null) {
		demographic_no = (String)request.getAttribute("demographic_no");
	}
	boolean independentHealthCareTeam = oscarProps.getProperty("NEW_CONTACTS_UI_HEALTH_CARE_TEAM_LINKED", "true").equals("false");

%>


<%@ include file="/taglibs.jsp"%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html:html locale="true">

	<head>
		<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
		<script type="text/javascript" src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
		<script src="<%=request.getContextPath() %>/library/bootstrap/3.0.0/js/bootstrap.min.js"></script>

		<script src="../library/typeahead.js/typeahead.min.js"></script>
		<script src="../library/typeahead.js/typeahead-0.11.1.js"></script>

		<script src="<%=request.getContextPath() %>/demographic/manageContacts.js"></script>
		<title>Demographic Contact Manager</title>
<script src="<%=request.getContextPath()%>/JavaScriptServlet" type="text/javascript"></script>
		<!--I18n-->
		<link rel="stylesheet" href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.min.css" />
		<!-- <link rel="stylesheet" type="text/css" href="../share/css/OscarStandardLayout.css" /> -->
		<!-- <link rel="stylesheet" type="text/css" href="../css/main-kai.min.css" /> -->
		<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css" />
		<link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/demographic/manageContacts.css" />
		<!-- <link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css" /> -->
		<script type="text/javascript">
            var contacts = [];
			var $independentHealthCareTeam = <%=independentHealthCareTeam%>;

            $(document).ready(function() {

                var sortColumn = $("#sortColumn").val();
                var sortOrder = $("#sortOrder").val();

                if (sortOrder === "desc") {
                    $("#" + sortColumn).append("<i class='icon icon-caret-down' style='float:right;'></i>")
                } else {
                    $("#" + sortColumn).append("<i class='icon icon-caret-up' style='float:right;'></i>")
                }

                var list = '<%=list%>';
                $('#' + list + 'Contacts').addClass('active');
            });

		</script>
	</head>

	<body class="BodyStyle">
	<table class="MainTable" id="scrollNumber1" style="font-size: 100%">
		<tr class="MainTableTopRow">
			<th class="MainTableTopRowLeftColumn" style="font-size: medium">Manage Contacts</th>
			<td class="MainTableTopRowRightColumn">
				<table class="TopStatusBar">
					<tr>
						<td><oscar:nameage demographicNo="<%=demographic_no%>" /></td>
						<td>&nbsp;</td>
						<td style="text-align: right">
							<oscar:help keywords="contact" key="app.top1"/> |
							<a href="javascript:popup(300,400,'<%=request.getContextPath()%>/oscarEncounter/About.jsp')" ><bean:message key="global.about" /></a> |
							<a href="javascript:popup(300,400,'<%=request.getContextPath()%>/oscarEncounter/License.jsp')"><bean:message key="global.license" /></a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="MainTableLeftColumn" valign="top" style="font-size: small;">
				&nbsp;
				<ul id="contactListNav" class="nav nav-pills nav-stacked nav-list">
					<li id="activeContacts" onclick="updateList('active')">
						<a href="javascript:void(0)">Active</a>
					</li>
					<li id="allContacts" onclick="updateList('all')">
						<a href="javascript:void(0)">All</a>
					</li>
					<li id="inactiveContacts" onclick="updateList('inactive')">
						<a href="javascript:void(0)">Inactive</a>
					</li>
					<li class="divider"><hr></li>
					<li><a href="javascript:window.close();">Close Window</a></li>
				</ul>
			</td>
			<td valign="top" class="MainTableRightColumn">
				<% if (request.getSession().getAttribute("success") != null) { %>
				<div id="success" class="alert alert-success" role="alert">
					<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					<strong>Success</strong><br/>
					<%=request.getSession().getAttribute("success")%>
				</div>
				<script type="text/javascript">
                    self.opener.refresh();
				</script>
				<%	request.getSession().removeAttribute("success");
				}
				else if (request.getSession().getAttribute("errorMessage") != null) { %>
				<div id="error" class="alert alert-danger" role="alert">
					<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					<strong>Error</strong><br/>
					<%=request.getSession().getAttribute("errorMessage")%>
				</div>
				<%
						request.getSession().removeAttribute("errorMessage");
					}
				%>

				<form method="post" name="contactList" id="contactList" action="Contact.do?demographic_no=<%=demographic_no%>">
					<input type="hidden" name="method" value="manage"/>

					<input type="hidden" id="sortColumn" name="sortColumn" value="<%=sortColumn%>"/>
					<input type="hidden" id="sortOrder" name="sortOrder" value="<%=sortOrder%>"/>
					<input type="hidden" id="list" name="list" value="<%=list%>"/>
					<input type="hidden" id="demographicNo" name="demographic_no" value="<%=demographic_no%>"/>

					<br/>

					<table class="table table-hover" id="bListTable">
						<thead>
						<th id="category" style="min-width: 100px;">
							<a href="javascript:void(0)" onclick="updateSort('category')">Category</a>
						</th>
						<th id="name">
							<a href="javascript:void(0)" onclick="updateSort('name')">Name</a>
						</th>
						<th>Preferred Contact</th>
						<th id="role">
							<a href="javascript:void(0)" onclick="updateSort('role')">Relationship</a>

						</th>
						<th>Notes</th>
						<th>&nbsp;</th>
						</thead>

						<tbody style="font-size: 11px;">
						<%
							if(dcs != null && !dcs.isEmpty()) {
								for(DemographicContact dc:dcs) {
									Gson gson = new Gson();
									String contact = gson.toJson(dc);
									Integer id = dc.getId();
									String contactId = dc.getContactId();
									String category = dc.getCategory();

									String contactClass = "contact";

									if (!dc.isActive()) {
									    contactClass += " inactive";
									}
						%>
						<script type="text/javascript">
                            contacts.push(<%=contact%>);
						</script>
						<tr id="contact_<%=id%>" class="<%=contactClass%>">
							<td onclick="setContactView(<%=id%>)" style="text-transform: capitalize">
								<%=Encode.forHtmlContent(category)%>
							</td>

							<td style="text-transform: uppercase" onclick="setContactView(<%=id%>)">
								<%=Encode.forHtmlContent(dc.getContactName())%>

								<%
									if (dc.getCategory().equals("personal") && dc.getType() == DemographicContact.TYPE_DEMOGRAPHIC) {
								%>
								&nbsp;
								<a title="Master File" href="#" onclick="popup(700,1027,'demographiccontrol.jsp?demographic_no=<%=contactId%>&displaymode=edit&dboperation=search_detail', 'demographic')">M</a>
								|
								<a title="Encounter" href="#" onclick="popup(710,1024,'<%=request.getContextPath() %>/oscarEncounter/IncomingEncounter.do?providerNo=<%=providerNo%>&appointmentNo=&demographicNo=<%=contactId%>&curProviderNo=&reason=<%=URLEncoder.encode(noteReason, "UTF-8")%>&encType=&curDate=<%=""+curYear%>-<%=""+curMonth%>-<%=""+curDay%>&appointmentDate=&startTime=&status=', 'encounter');return false;">E</a>
								<%
									}
								%>
							</td>

							<td onclick="setContactView(<%=id%>)">
								<%
									String preferredContact = "Not Set";
									if (dc.isConsentToContact()) {
										Contact details = dc.getDetails();
										if (details != null) {
											if (DemographicContact.CONTACT_CELL.equals(dc.getBestContact()) && StringUtils.trimToNull(details.getCellPhone()) != null) {
												preferredContact = details.getCellPhone();
											} else if (DemographicContact.CONTACT_EMAIL.equals(dc.getBestContact()) && StringUtils.trimToNull(details.getEmail()) != null) {
												preferredContact = details.getEmail();
											} else if (DemographicContact.CONTACT_PHONE.equals(dc.getBestContact()) && StringUtils.trimToNull(details.getResidencePhone()) != null) {
												preferredContact = details.getResidencePhone();
											} else if (DemographicContact.CONTACT_WORK.equals(dc.getBestContact()) && StringUtils.trimToNull(details.getWorkPhone()) != null) {
												preferredContact = details.getWorkPhone() + (StringUtils.isEmpty(details.getWorkPhoneExtension()) ? "" : "  ext: " + details.getWorkPhoneExtension());
											}
										}
									} else {
										preferredContact = "<span class=\"text-danger\" style=\"font-weight: bold\">No Consent</span>";
									}
								%>
								<%=preferredContact%>
							</td>

							<td onclick="setContactView(<%=id%>)">
								<%=Encode.forHtmlContent(dc.getRole())%>
							</td>

							<td onclick="setContactView(<%=id%>)">
								<%
									String ecSdm = "";
									if("true".equals(dc.getEc())) {
										ecSdm += "EC";
									}

									if ("true".equals(dc.getSdm())) {
										ecSdm += ecSdm.length() > 0 ? "/SDM" : "SDM";
									}
								%>

								<label class="label label-warning"><%=ecSdm%></label>
								<%=Encode.forHtmlContent(StringUtils.trimToEmpty(dc.getNote()))%>
							</td>

							<td>
								<a href="javascript:void(0)" onclick="setContactView(<%=id%>)">Edit</a>
								|
								<a href="javascript:void(0)" onclick="deleteContact(<%=id%>)">Delete</a>
							</td>
						</tr>

						<%
								}
							} else { %>
						<tr class="text-center">
							<td colspan="5">No contacts to display</td>
						</tr>

						<%	} %>

						</tbody>
					</table>
					<% if (!"inactive".equals(list)) { %>
					<button class="btn btn-primary btn-sm" onclick="return addContact();">ADD</button>
					<% } %>
				</form>

			</td>
		</tr>
		<tr>
			<td class="MainTableBottomRowLeftColumn">&nbsp;</td>
			<td class="MainTableBottomRowRightColumn" valign="top">&nbsp;</td>
		</tr>
	</table>

	<div class="modal fade" id="contactView" role="dialog">
		<div class="modal-dialog modal-lg">
			<form method="post" name="contactForm" id="contactForm" action="Contact.do?demographic_no=<%=demographic_no%>" style="margin: 0">
				<input type="hidden" name="method" value="save"/>
				<input type="hidden" name="demographic_no" value="<%=demographic_no%>"/>
				<input type="hidden" name="sortColumn" value="<%=sortColumn%>"/>
				<input type="hidden" name="sortOrder" value="<%=sortOrder%>"/>
				<input type="hidden" name="list" value="<%=list%>"/>

				<div id="contactContainer" class="modal-content">

				</div>
			</form>
		</div>
	</div>


	</body>
</html:html>