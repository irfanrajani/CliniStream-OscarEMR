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
<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ page import="oscar.oscarDemographic.data.DemographicData"%>
<%@ page import="oscar.OscarProperties"%>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_msg" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_msg");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%
OscarProperties oscarProps = OscarProperties.getInstance();
String help_url = (oscarProps.getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/")).trim();

int pageType = 0;
String boxType = request.getParameter("boxType");
if (boxType == null || boxType.equals("")){
    pageType = 0;
}else if (boxType.equals("1")){
    pageType = 1;
}else if (boxType.equals("2")){
    pageType = 2;
}else if (boxType.equals("3")){
    pageType = 3;
}else{
    pageType = 0;
}   //messageid

String demographic_no = request.getParameter("demographic_no");
String demographic_name = "";
if ( demographic_no != null ) {
    DemographicData demographic_data = new DemographicData();
    org.oscarehr.common.model.Demographic demographic = demographic_data.getDemographic(LoggedInInfo.getLoggedInInfoFromSession(request), demographic_no);
    if (demographic != null){
       demographic_name = demographic.getLastName() + ", " + demographic.getFirstName();
    }
}


pageContext.setAttribute("pageType",""+pageType);

if (request.getParameter("orderby") != null){
    String orderby = request.getParameter("orderby");
    String sessionOrderby = (String) session.getAttribute("orderby");
    if (sessionOrderby != null && sessionOrderby.equals(orderby)){
        orderby = "!"+orderby;
    }
    session.setAttribute("orderby",orderby);
}
String orderby = (String) session.getAttribute("orderby");

int pageNum = request.getParameter("page")==null ? 1 : Integer.parseInt(request.getParameter("page"));
%>

<logic:notPresent name="msgSessionBean" scope="session">
    <logic:redirect href="index.jsp" />
</logic:notPresent>
<logic:present name="msgSessionBean" scope="session">
    <bean:define id="bean" type="oscar.oscarMessenger.pageUtil.MsgSessionBean" name="msgSessionBean" scope="session" />
    <logic:equal name="bean" property="valid" value="false">
        <logic:redirect href="index.jsp" />
    </logic:equal>
</logic:present>
<%
oscar.oscarMessenger.pageUtil.MsgSessionBean bean = (oscar.oscarMessenger.pageUtil.MsgSessionBean)pageContext.findAttribute("bean");
%>
<jsp:useBean id="DisplayMessagesBeanId" scope="session" class="oscar.oscarMessenger.pageUtil.MsgDisplayMessagesBean" />
<% DisplayMessagesBeanId.setProviderNo(bean.getProviderNo());
bean.nullAttachment();
%>
<jsp:setProperty name="DisplayMessagesBeanId" property="*" />
<jsp:useBean id="ViewMessageForm" scope="session" class="oscar.oscarMessenger.pageUtil.MsgViewMessageForm"/>


<html:html locale="true">
<head>
<html:base />

<title>
<bean:message key="oscarMessenger.DisplayMessages.title"/>
</title>
<script src="<%= request.getContextPath() %>/js/global.js"></script>
<script src="<%=request.getContextPath() %>/library/jquery/jquery-3.6.4.min.js"></script>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet">

<link href="<%=request.getContextPath() %>/css/bootstrap-responsive.css" rel="stylesheet" >
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">

<style>
tr.newMessage td {
     font-weight: bold;
}

.TopStatusBar{
width:100% !important;
}

.integratedMessage {
	background-color: #FFCCCC;
	color: black;
}

span.recipientList:hover{
	position: relative;
    text-overflow:clip;
    width:auto;
    white-space: normal;
}


</style>

<script>
function BackToOscar()
{
    if (opener.callRefreshTabAlerts) {
	opener.callRefreshTabAlerts("oscar_new_msg");
        setTimeout("window.close()", 100);
    } else {
        window.close();
    }
}

function uload(){
    if (opener.callRefreshTabAlerts) {
	opener.callRefreshTabAlerts("oscar_new_msg");
        setTimeout("window.close()", 100);
        return false;
    }
    return true;
}

function checkAll(formId){
   var f = document.getElementById(formId);
   var val = f.checkA.checked;
   for (i =0; i < f.messageNo.length; i++){
      f.messageNo[i].checked = val;
   }
}

$(document).ready(function(){

	var lengthText = 30;
	const recipientLists = $('.recipientList');

	$.each(recipientLists, function(key, value){
		var text = $(value).text();
        var shortText = $.trim(text).substring(0, lengthText);
        var names = shortText.split(",");
        if ( names.length > 1 ) {
            shortText = names[0] + ", "+names[1].substring(0,2)+ "...";
        }
		$(value).text(shortText);
		$(value).attr("title", $.trim(text));
	})
})

</script>
</head>

<body class="BodyStyle" onload="window.focus()" onunload="return uload()">
<div id="pop-up"><p></p></div>
<table style="width: 100%;">
  <tr>
    <td>
			<h4>&nbsp;<i class="icon-envelope" title="<bean:message key="oscarMessenger.DisplayMessages.msgMessenger"/>"></i>&nbsp;
                        <% String inbxStyle = "messengerButtonsA";
                           String sentStyle = "messengerButtonsA";
                           String delStyle  = "messengerButtonsA";
                        switch(pageType){
                            case 0: %>
     		                    <bean:message key="oscarMessenger.DisplayMessages.msgInbox"/>
                        <%      inbxStyle = "messengerButtonsD";
                            break;
                            case 1: %>
                                <bean:message key="oscarMessenger.DisplayMessages.msgSentTitle"/>
                        <%      sentStyle = "messengerButtonsD";
                            break;
                            case 2: %>
                                <bean:message key="oscarMessenger.DisplayMessages.msgArchived"/>
                        <%      delStyle =  "messengerButtonsD";
                            break;
                            case 3: %>
                                Messages related to <%=demographic_name%>
                        <%      delStyle =  "messengerButtonsD";
                            break;
                        }%>
        </h4>
    </td>
<td>

                            <html:form action="/oscarMessenger/DisplayMessages">
                            <input name="boxType" type="hidden" value="<%=pageType%>">
                            <input name="searchString" type="text" class="input-large"  value="<jsp:getProperty name="DisplayMessagesBeanId" property="filter"/>">
                            <input name="btnSearch" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.btnSearch"/>">
                            <input name="btnClearSearch" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.btnClearSearch"/>">
                            </html:form>

</td>
    <td style="text-align: right;" >
		<i class=" icon-question-sign"></i>
	                        <a href="<%=help_url%>messenger/" target="_blank"><bean:message key="app.top1"/></a>
	                        <i class=" icon-info-sign" style="margin-left:10px;"></i>
                            <a href="javascript:void(0)"  onClick="window.open('<%=request.getContextPath()%>/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,left=0,top=0')" ><bean:message key="global.about" /></a>
    </td>
</tr>
</table>
                    <%String strutsAction = "/oscarMessenger/DisplayMessages";
                        if (pageType == 2){
                            strutsAction = "/oscarMessenger/ReDisplayMessages";
                        }
                    %>
<html:form action="<%=strutsAction%>" styleId="msgList" >
    <table  class="MainTable" id="scrollNumber1" style="width: 100%;">
        <tr>
            <td class="MainTableRightColumn" >
                <table style="width: 100%;">

                    <tr>
                        <td>
                            <ul class="nav nav-tabs"><li>
                                        <html:link page="/oscarMessenger/CreateMessage.jsp" styleClass="messengerButtons">
                                         <bean:message key="oscarMessenger.DisplayMessages.btnCompose"/>
                                        </html:link>
                                    </li>
                                    <li <% if (pageType == 0) { %>class="active"<% } %>>
                                        <html:link page="/oscarMessenger/DisplayMessages.jsp" styleClass="messengerButtons">
                                         <bean:message key="oscarMessenger.DisplayMessages.btnRefresh"/>
                                        </html:link>
                                    </li>
                                    <li <% if (pageType == 1) { %>class="active"<% } %> >
                                        <html:link page="/oscarMessenger/DisplayMessages.jsp?boxType=1" styleClass="messengerButtons">
                                         <bean:message key="oscarMessenger.DisplayMessages.btnSent"/><!-- sentMessage link-->
                                        </html:link>
                                    </li>
                                    <li <% if (pageType == 2) { %>class="active"<% } %>>
                                        <html:link page="/oscarMessenger/DisplayMessages.jsp?boxType=2" styleClass="messengerButtons">
                                         <bean:message key="oscarMessenger.DisplayMessages.btnDeletedMessage"/><!--deletedMessage link-->
                                        </html:link>
                                    </li>
                                    <li >
                                        <a href="javascript:BackToOscar()" class="messengerButtons"><bean:message key="oscarMessenger.DisplayMessages.btnExit"/></a>
                                    </li>
                                    </ul>
                        </td>
                    </tr>



                    <%
                           java.util.Vector theMessages2 = new java.util.Vector() ;
                        switch(pageType){
                            case 0:
                                theMessages2 = DisplayMessagesBeanId.estInbox(orderby,pageNum);
                            break;
                            case 1:
                                theMessages2 = DisplayMessagesBeanId.estSentItemsInbox(orderby,pageNum);
                            break;
                            case 2:
                                theMessages2 = DisplayMessagesBeanId.estDeletedInbox(orderby,pageNum);
                            break;
                            case 3:
                                theMessages2 = DisplayMessagesBeanId.estDemographicInbox(orderby,demographic_no);
                            break;
                        }   //messageid
%>
                    <tr>
                        <td ><span>
                            <%if (pageType == 0){%>
                                    <input name="btnDelete" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.formArchive"/>">
                                    <input name="btnRead" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.markRead"/>">
                                    <input name="btnUnread" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.markUnRead"/>">
                            <%}else if (pageType == 2){%>
                                    <input type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.formUnarchive"/>">
                            <%}%>
                            &nbsp;</span>
                        <span class="pull-right">
		                    <%
		                    int recordsToDisplay = 25;

		                    String previous = "";
		                    String next = "";
		                    String path = request.getContextPath()+"/oscarMessenger/DisplayMessages.jsp?boxType=" + pageType + "&page=";
		                    Boolean search = false;
		                    if(request.getParameter("searchString")!=null){
		                    	search = true;
		                    }

		                    if (pageType != 3){

		                    int totalMsgs = DisplayMessagesBeanId.getTotalMessages(pageType);

		                    int totalPages = totalMsgs / recordsToDisplay + (totalMsgs % recordsToDisplay == 0 ? 0 : 1);

		                    if(pageNum>1){
		                    	previous = "<a href='" + path + (pageNum-1) + "' title='previous page'><< Previous</a> ";
		                    	out.print(previous);
							}

		                    if(pageNum<totalPages){
		                    	next = "<a href='" + path + (pageNum+1) + "' title='next page'>Next >></a>";
		                    	out.print(next);
		                    }
		                    }%></span>
                        </td>
                   </tr>
                    <tr>
                        <td>
                            <table class="table table-condensed table-striped">


                                <tr>
                                    <th style="text-align: left;">
                                    <%if( pageType!=1 ) {%>
                                       <input type="checkbox" name="checkAll2" onclick="checkAll('msgList')" id="checkA" />
                                    <%} %>
                                    </th>
                                    <th style="text-align: left;">
                                        <html:link page="/oscarMessenger/DisplayMessages.jsp?orderby=status"  paramId="boxType" paramName="pageType">
                                        <bean:message key="oscarMessenger.DisplayMessages.msgStatus"/>
                                        </html:link>
                                    </th>
                                    <th style="text-align: left;">
                                      <%if( pageType == 1 ) {%>
                                                <html:link page="/oscarMessenger/DisplayMessages.jsp?orderby=sentto" paramId="boxType" paramName="pageType">
                                                <bean:message key="oscarMessenger.DisplayMessages.msgTo"/>
                                                </html:link>
                                       <%} else {%>
                                                <html:link page="/oscarMessenger/DisplayMessages.jsp?orderby=from" paramId="boxType" paramName="pageType">
                                                <bean:message key="oscarMessenger.DisplayMessages.msgFrom"/>
                                                </html:link>
                                       <% } %>
                                    </th>
                                    <th style="text-align: left;">
                                            <html:link page="/oscarMessenger/DisplayMessages.jsp?orderby=subject" paramId="boxType" paramName="pageType">
                                            <bean:message key="oscarMessenger.DisplayMessages.msgSubject"/>
                                            </html:link>
                                    </th>
                                    <th style="text-align: left;">
                                            <html:link page="/oscarMessenger/DisplayMessages.jsp?orderby=date" paramId="boxType" paramName="pageType">
                                            <bean:message key="oscarMessenger.DisplayMessages.msgDate"/>
                                            </html:link>
                                    </th>
                                    <th style="text-align: left;" >
                                            <html:link page="/oscarMessenger/DisplayMessages.jsp?orderby=linked" paramId="boxType" paramName="pageType">
                                            <bean:message key="oscarMessenger.DisplayMessages.msgLinked"/>
                                            </html:link>
                                    </th>
                                </tr>


                                <!--   for loop Control Initiliation variabe changed to nextMessage   -->
                            <%
                                    for (int i = 0; i < theMessages2.size() ; i++) {
                                        oscar.oscarMessenger.data.MsgDisplayMessage dm;
                                        dm = (oscar.oscarMessenger.data.MsgDisplayMessage) theMessages2.get(i);
                                        String key = "oscarMessenger.DisplayMessages.msgStatus"+dm.getStatus().substring(0,1).toUpperCase()+dm.getStatus().substring(1);
                                        %>

                                <% if ("oscarMessenger.DisplayMessages.msgStatusNew".equals(key) || "oscarMessenger.DisplayMessages.msgStatusUnread".equals(key)){%>
                                <tr class="newMessage">
                                <%}else{%>
                                <tr>
                                <%}%>
                                    <td class='<%= dm.getType() == 3 ? "integratedMessage" : "normalMessage" %>' style="width:25px;">
                                    <%if (pageType != 1){%>
                                        <html:checkbox property="messageNo" value="<%=dm.getMessageId() %>" />
                                     <% } %>
                                    &nbsp;
                                    <%
                                       String atta = dm.getAttach();
                                       String pdfAtta = dm.getPdfAttach();
                                       if (atta.equals("1") || pdfAtta.equals("1") ){ %>
                                            <img src="img/clip4.jpg">
                                    <% } %>


                                    </td>
                                    <td class='<%= dm.getType() == 3 ? "integratedMessage" : "normalMessage" %>'>
                                     <bean:message key="<%= key %>"/>
                                    </td>
                                    <td class='<%= dm.getType() == 3 ? "integratedMessage" : "normalMessage" %>'>

                                        <%
                                            if( pageType == 1 ) {
%>
<span class="recipientList">
<%
                                                out.print(Encode.forHtml(dm.getSentto()));
%>
</span>
<%
                                            }
                                            else
                                            {
                                                out.print(Encode.forHtml(dm.getSentby()));
                                            }
                                        %>

                                    </td>
                                    <td class='<%= dm.getType() == 3 ? "integratedMessage" : "normalMessage" %>'>
                                    <a href="<%=request.getContextPath()%>/oscarMessenger/ViewMessage.do?messageID=<%=dm.getMessageId()%>&boxType=<%=pageType%>">
                                        <%=Encode.forHtml(dm.getThesubject())%>
                                    </a>

                                    </td>
                                    <td class='<%= dm.getType() == 3 ? "integratedMessage" : "normalMessage" %>' title="<%= dm.getThedate() %>&nbsp;&nbsp;<%= dm.getThetime() %>">
                                    	<%=Encode.forHtml(dm.getThedate())%>

                                    </td>
                                    <td class='<%= dm.getType() == 3 ? "integratedMessage" : "normalMessage" %>'>

                                    <%if(dm.getDemographic_no() != null  && !dm.getDemographic_no().equalsIgnoreCase("null")) {%>
                                        <oscar:nameage demographicNo="<%=dm.getDemographic_no()%>"></oscar:nameage>
                                    <%} %>

                                    </td>
                                </tr>
                            <%}%>

                            <tr><td colspan="6">
                        <span>
                            <%if (pageType == 0){%>
                                    <input name="btnDelete" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.formArchive"/>">
                                    <input name="btnRead" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.markRead"/>">
                                    <input name="btnUnread" type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.markUnRead"/>">
                            <%}else if (pageType == 2){%>
                                    <input type="submit" class="btn" style="margin-bottom:10px;" value="<bean:message key="oscarMessenger.DisplayMessages.formUnarchive"/>">
                            <%}%>
                            &nbsp;</span>
                        <span class="pull-right">

                                    <%
                                    if(pageType!=3){
                                    	out.print(previous + next);
                                    }
                                    %>
</span>
                            </td></tr>
                            </table>



                        </td>
                    </tr>
                </table>

            </td>
        </tr>
        <tr>
            <td class="MainTableBottomRowLeftColumn">

            </td>

        </tr>
    </table>
</html:form>
</body>
</html:html>