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

<%@ page import="org.oscarehr.util.LoggedInInfo"%>
<%@ page import="java.lang.*"%>
<%@ page import="oscar.OscarProperties"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>

<%
        boolean fromMessenger = request.getParameter("fromMessenger") == null ? false : (request.getParameter("fromMessenger")).equalsIgnoreCase("true")?true:false;
		String roleName = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security" %>
<%@ taglib uri="/WEB-INF/caisi-tag.tld" prefix="caisi" %>

<script language="JavaScript">
function searchInactive() {
    document.titlesearch.ptstatus.value="inactive";
    if (checkTypeIn()) document.titlesearch.submit();
}

function searchAll() {
    document.titlesearch.ptstatus.value="";
    if (checkTypeIn()) document.titlesearch.submit();
}

function searchOutOfDomain() {
    document.titlesearch.outofdomain.value="true";
    if (checkTypeIn()) document.titlesearch.submit();
}

</script>

<form method="get" name="titlesearch" action="<%=request.getContextPath()%>/demographic/demographiccontrol.jsp"
	onsubmit="return checkTypeIn()">
<div class="searchBox">
    <div class="RowTop header" style="width:100%">
	        <div class="title">
		        <h4>&nbsp;<i class="icon-search" title="<bean:message key="demographic.search.msgSearchPatient" />"></i>&nbsp;<bean:message key="demographic.search.msgSearchPatient" /></h4>
	        </div>
    </div>
    <div class="form-inline">
        <label class="select">

	    <% String searchMode = request.getParameter("search_mode");
             String keyWord = request.getParameter("keyword");
             if (searchMode == null || searchMode.equals("")) {
                 searchMode = OscarProperties.getInstance().getProperty("default_search_mode","search_name");
             }
             if (keyWord == null) {
                 keyWord = "";
             }
         %>
             <select class="wideInput" name="search_mode">
                <option value="search_name" <%=searchMode.equals("search_name")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formName" />
                </option>
                <option value="search_phone" <%=searchMode.equals("search_phone")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formPhone" />
                </option>
                <option value="search_dob" <%=searchMode.equals("search_dob")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formDOB" />
                </option>
                <option value="search_address" <%=searchMode.equals("search_address")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formAddr" />
                </option>
                <option value="search_hin" <%=searchMode.equals("search_hin")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formHIN" />
                </option>
                <option value="search_chart_no" <%=searchMode.equals("search_chart_no")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formChart" />
                </option>
                <option value="search_demographic_no" <%=searchMode.equals("search_demographic_no")?"selected":""%>>
                    <bean:message key="demographic.zdemographicfulltitlesearch.formDemographicNo" />
                </option>
             </select>
        </label>
        <label class="text">
            <input type="text" name="keyword" id="keyword" value="<%=StringEscapeUtils.escapeHtml(keyWord)%>" MAXLENGTH="100" placeholder='<bean:message key="demographic.zdemographicfulltitlesearch.keyterm" />'>
        </label>
            <input type="hidden" name="orderby" value="last_name, first_name">
            <input type="hidden" name="dboperation" value="search_titlename">
            <input type="hidden" name="limit1" value="0">
            <input type="hidden" name="limit2" value="10">
            <input type="hidden" name="displaymode" value="Search">
            <input type="hidden" name="ptstatus" value="active">
            <input type="hidden" name="fromMessenger" value="<%=fromMessenger%>">
            <input type="hidden" name="outofdomain" value="">

            <input type="submit" class="btn btn-primary"
                value="<bean:message key="demographic.zdemographicfulltitlesearch.msgSearch" />"
                title="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchActive"/>">
            &nbsp;&nbsp;&nbsp;
            <input type="button" class="btn" onclick="searchInactive();"
                title="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchInactive"/>"
                value="<bean:message key="demographic.search.Inactive"/>">
            <input type="button" class="btn" onclick="searchAll();"
                title="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchAll"/>"
                value="<bean:message key="demographic.search.All"/>">

            <%
            LoggedInInfo loggedInInfo2 = LoggedInInfo.getLoggedInInfoFromSession(request);
            if(loggedInInfo2.getCurrentFacility().isIntegratorEnabled()) {
            %>
            <input type="checkbox" name="includeIntegratedResults" value="true"/>Include Integrator
            <%}%>

        <security:oscarSec roleName="<%=roleName%>" objectName="_search.outofdomain" rights="r">
            <input type="button" class="btn" onclick="searchOutOfDomain();"
                title="<bean:message key="demographic.zdemographicfulltitlesearch.tooltips.searchOutOfDomain"/>"
                value="<bean:message key="demographic.search.OutOfDomain"/>">
        </security:oscarSec>

        <caisi:isModuleLoad moduleName="caisi">
            <input type="button" class="btn" value="cancel" onclick="location.href='<html:rewrite page="/PMmodule/ProviderInfo.do"/>'" >
        </caisi:isModuleLoad>
            <input type="button" value="<bean:message key="demographic.demographicsearchresults.msgMostRecentPatients" />" onclick="getElementById('keyword').value='';document.titlesearch.submit();" class="btn btn-link" >
            <input type="button" value="<bean:message key="global.btnCancel" />" onclick="window.close();window.opener.location.reload();" class="btn btn-link" >
    </div> <!-- end inline form-->
</div> <!-- end searchbox-->
</form>