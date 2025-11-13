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
<%@ page import="org.oscarehr.managers.MessagingManager" %>
<%@ page import="org.oscarehr.common.model.Groups" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.util.MiscUtils"%>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO"%>
<%@ page import="org.oscarehr.common.model.UserProperty"%>

<%@ page import="oscar.OscarProperties"%>
<%@ page import="oscar.oscarMessenger.util.Msgxml"%>
<%@ page import="oscar.oscarDemographic.data.*"%>
<%@ page import="oscar.oscarMessenger.data.MsgProviderData" %>

<%@ page import="org.w3c.dom.*"%>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<%
	  String providerNo = (String) request.getAttribute("providerNo");
      String curUser_no = (String) session.getAttribute("user");
      String roleName$ = (String)session.getAttribute("userrole") + "," + curUser_no;
		
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


<logic:notPresent name="msgSessionBean" scope="session">
	<logic:redirect href="index.jsp" />
</logic:notPresent>
<logic:present name="msgSessionBean" scope="session">
	<bean:define id="bean"
		type="oscar.oscarMessenger.pageUtil.MsgSessionBean"
		name="msgSessionBean" scope="session" />
	<logic:equal name="bean" property="valid" value="false">
		<logic:redirect href="index.jsp" />
	</logic:equal>
</logic:present>


<%
org.oscarehr.managers.MessengerGroupManager groupManager = SpringUtils.getBean(org.oscarehr.managers.MessengerGroupManager.class);
Map<Groups, List<MsgProviderData>> groups = groupManager.getAllGroupsWithMembers(LoggedInInfo.getLoggedInInfoFromSession(request));
Map<String, List<MsgProviderData>> remoteMembers = groupManager.getAllRemoteMembers(LoggedInInfo.getLoggedInInfoFromSession(request));
List<MsgProviderData> localMembers = groupManager.getAllLocalMembers(LoggedInInfo.getLoggedInInfoFromSession(request));
MessagingManager messagingManager = SpringUtils.getBean(MessagingManager.class);

request.setAttribute("groupManager", groups);
request.setAttribute("remoteMembers", remoteMembers);
request.setAttribute("localMembers", localMembers);

pageContext.setAttribute("messageSubject", request.getParameter("subject"));
pageContext.setAttribute("messageSubject", request.getAttribute("ReSubject"));
pageContext.setAttribute("messageBody", request.getAttribute("ReText"));

oscar.oscarMessenger.pageUtil.MsgSessionBean bean = (oscar.oscarMessenger.pageUtil.MsgSessionBean)pageContext.findAttribute("bean");

String demographic_no = (String) request.getAttribute("demographic_no");
DemographicData demoData = new DemographicData();
org.oscarehr.common.model.Demographic demo = demoData.getDemographic(LoggedInInfo.getLoggedInInfoFromSession(request), demographic_no);
String demoName = "";
if (demo != null) {
	demoName = Encode.forJavaScript(demo.getLastName()+", "+demo.getFirstName());
}

String delegate = "";
String delegateName = "";
boolean recall = (request.getParameter("recall") != null);

if(recall){
	String subjectText = Encode.forJavaScript(messagingManager.getLabRecallMsgSubjectPref(LoggedInInfo.getLoggedInInfoFromSession(request)));
	delegate = messagingManager.getLabRecallDelegatePref(LoggedInInfo.getLoggedInInfoFromSession(request));
	if(delegate!=null || delegate != ""){
		delegateName = Encode.forHtml(messagingManager.getDelegateName(delegate));
	}
	pageContext.setAttribute("delegateName", delegateName);
	pageContext.setAttribute("messageSubject", subjectText);
}

UserPropertyDAO userPropertyDao = (UserPropertyDAO) SpringUtils.getBean("UserPropertyDAO");
UserProperty markdownProp = userPropertyDao.getProp(curUser_no, UserProperty.MARKDOWN);
boolean renderMarkdown = false;
if ( markdownProp == null ) {
    renderMarkdown = oscar.OscarProperties.getInstance().getBooleanProperty("encounter.render_markdown", "true");
} else {
    renderMarkdown = oscar.OscarProperties.getInstance().getBooleanProperty("encounter.render_markdown", "true") && Boolean.parseBoolean(markdownProp.getValue());
}
%>

<html:html locale="true">
<head>
<title><bean:message key="oscarMessenger.CreateMessage.title" /></title>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>

<style type="text/css">
    .subheader {
	    background-color:silver;
	}

	summary {
		cursor: pointer;
	}
	.muted {
	    color:silver;
	}
	
	.group_member_contact, .remote_member_contact {
		margin-left:15px;
	}
	
	summary label {
		font-weight: bold;
	}
</style>

<script type="text/javascript" src="<%=request.getContextPath()%>/js/jquery-1.12.3.js" ></script>
 
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="<%=request.getContextPath() %>/css/bootstrap.css" rel="stylesheet" type="text/css">

<% if (renderMarkdown) { 
	ResourceBundle oscarRec = ResourceBundle.getBundle("oscarResources", request.getLocale());
	String lowercasei18n = oscarRec.getString("global.i18nLanguagecode").toLowerCase();
%>
<link rel="stylesheet" href="<%=request.getContextPath() %>/library/toastui/toastui-editor.min.css" />
<script src="<%=request.getContextPath() %>/library/toastui/toastui-editor-all.min.js"></script>
<script src="<%=request.getContextPath() %>/library/toastui/i18n/<%=lowercasei18n %>.js"></script>
<% } %>

<style type="text/css">
    .toastui-editor-contents{
        font-size: 17px;
    }
 </style>

<script type="text/javascript">

    function disableArchive(){
        var theLink=document.referrer;
        if (theLink.indexOf('messageID') == -1 ) {
            $('#sendArchive').hide();
        }
    }

    function checkGroup(group)
    {
    	$.each($("input." + group.id), function(){
            $(this).prop("checked", $(group).prop("checked") ? "checked" : false);
		})
    }

	function validatefields(){
		
		// cannot send attachments to remote facilities
		$("input:checked").each(function () {
			if(this.id.split("-")[2] > 0 && $("#attachmentAlert").val())
			{
				alert("<bean:message key="oscarMessenger.CreateMessage.attachmentsNotPermitted"/>");
				return false;
			}
		})	
		
	  if (document.forms[0].message.value.length == 0){
	    alert("<bean:message key="oscarMessenger.CreateMessage.msgEmptyMessage"/>");
	    return false;
	  }
	  val = validateCheckBoxes(document.forms[0]);
	  if (val  == 0)
	  {
	    alert("<bean:message key="oscarMessenger.CreateMessage.msgNoProvider"/>");
	    return false;
	  }
	  return true
	}
	
	function validateCheckBoxes(form)
	{
	  var retval = "0";
	  for (var i =0; i < form.provider.length;i++)
	    if  (form.provider[i].checked)
	      retval = "1";
	  return retval
	}
	
	function BackToOscar()
	{
	    if (opener.callRefreshTabAlerts) {
		opener.callRefreshTabAlerts("oscar_new_msg");
	        setTimeout("window.close()", 100);
	    } else {
	        window.close();
	    }
	}
	
	function XMLHttpRequestSendnArch() {
		var oRequest = new XMLHttpRequest();
		var theLink=document.referrer;
		var theLinkComponents=theLink.split('?');
		var theQueryComponents=theLinkComponents[1].split('&');
	
		for (index = 0; index < theQueryComponents.length; ++index) {
	    		var theKeyValue=theQueryComponents[index].split('=');
			if(theKeyValue[0]=='messageID'){
				var theArchiveLink=theLinkComponents[0].substring(0,theLinkComponents[0].lastIndexOf('/'))+'/DisplayMessages.do?btnDelete=archive&messageNo='+theKeyValue[1];
			}
		}
		oRequest.open('GET', theArchiveLink, false);
		oRequest.send();
		document.forms[0].submit();
	}

	function popupSearchDemo(keyword){ // open a new popup window
	    var vheight = 700;
	    var vwidth = 980;  
	    windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";    
	    var page = 'msgSearchDemo.jsp?keyword=' +keyword +'&firstSearch='+true;
	    var popUp=window.open(page, "msgSearchDemo", windowprops);
	    if (popUp != null) {
	        if (popUp.opener == null) {
	          popUp.opener = self; 
	        }
	        popUp.focus();
	    }
	}
	
	function popupAttachDemo(demographic){ // open a new popup window
	    var subject = document.forms[0].subject.value;
	    var message = document.forms[0].message.value;
	    var formData = "subject=" + subject + "&message=" + message;
	
	    $.ajax({
	    	type: "post",
	    	data : formData,
	    	success: function(data){
	    		console.log(data);
	    	},
	    	error: function (jqXHR, textStatus, errorThrown){
	 			console.log("Error: " + textStatus);
	    	}
		});
	
	    var vheight = 700;
	    var vwidth = 900;  
	    windowprops = "height="+vheight+",width="+vwidth+",location=0,scrollbars=1,menubar=0,toolbar=1,resizable=1,screenX=0,screenY=0,top=0,left=0";    
	    var page = 'attachmentFrameset.jsp?demographic_no=' +demographic;
	    var demo_no  = demographic;
	    
	   
	    if ( demographic == "" || !demographic || demographic == null || demographic == "null") {
	        alert("Please select a demographic.");
	    }
	    else { 
	        var popUp=window.open(page, "msgAttachDemo", windowprops);
	        if (popUp != null) {
	            if (popUp.opener == null) {
	              popUp.opener = self; 
	            }
	            popUp.focus();
	        }
	    }
	
	}

	/*
	 * Throw an error returned from the action
	 */
	$(document).ready(function(){
		var submissionerror = '${createMessageError}';
		if(submissionerror)
		{
			alert(submissionerror);
		}
 <% if (renderMarkdown) { %>
        document.getElementsByName("message")[0].setAttribute("style", "display:none;");
        editor.setMarkdown("<br>" + document.getElementsByName("message")[0].value);
        editor.moveCursorToStart();
 <% } %>
        disableArchive();
	})
	 	 
</script>
<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
</head>
<body class="BodyStyle" >


<table width=100%>
    <tr>
        <td valign="top">
            <h4>&nbsp;<i class="icon-envelope" title='<bean:message key="oscarMessenger.DisplayMessages.msgMessenger"/>'></i>&nbsp;
            <bean:message key="oscarMessenger.CreateMessage.msgCreate" />
            </h4>  	
        </td>
        <td>
        </td>
        <td align="right" >
            <i class=" icon-question-sign"></i> 
            <a href="javascript:void(0)" onClick ="popupPage(700,960,'<%=(OscarProperties.getInstance()).getProperty("HELP_SEARCH_URL")%>'+'Messenger create')"><bean:message key="app.top1"/></a>
            <i class=" icon-info-sign" style="margin-left:10px;"></i> 
            <a href="javascript:void(0)"  onClick="window.open('<%=request.getContextPath()%>/oscarEncounter/About.jsp','About OSCAR','scrollbars=1,resizable=1,width=800,height=600,left=0,top=0')" ><bean:message key="global.about" /></a>
        </td>
    </tr>
</table>

<table class="MainTable" id="scrollNumber1" width="100%">

	<tr>
		<td class="MainTableRightColumn">
		<table width=100%">

			<tr>

						<td>
						    <a class="btn" href="<%=request.getContextPath()%>/oscarMessenger/DisplayMessages.jsp">
								<bean:message key="oscarMessenger.ViewMessage.btnInbox" />
							</a>
                            <a class="btn" href="<%=request.getContextPath()%>/oscarMessenger/ClearMessage.do">
								<bean:message key="oscarMessenger.CreateMessage.btnClear" />
							</a>
                            <a href="javascript:BackToOscar()" class="btn">
                                <bean:message key="oscarMessenger.CreateMessage.btnExit" />
                            </a>
                            <br>&nbsp;
						</td>


			</tr>

			<tr>
				<td colspan="3">
				<html:form action="/oscarMessenger/CreateMessage" onsubmit="return validatefields()">
				<table class="well" width="100%">
						<tr class="subheader">
							<th><bean:message
								key="oscarMessenger.CreateMessage.msgRecipients" /></th>
							<th colspan="2" align="left"><bean:message
								key="oscarMessenger.CreateMessage.msgMessage" /></th>
						</tr>
						<tr>
						
						<td valign=top><br>

							<div class="ChooseRecipientsBox" style="max-height: <%=renderMarkdown?"576px;":"420px;"%> overflow-y: scroll;">
							<table>                                                     
                                <tr>
								<td style="padding: 10px 5px; min-width:fit-content;"  class="form-inline"><!--list of the providers cell Start-->												
									<%if(recall){ %>
										<div>
											<input name="provider" value="<%=delegate%>" type="checkbox" checked> 
											<strong><a title="default recall delegate: <%=delegateName%>">default: <%=delegateName%></a></strong>								
										</div>
									<%} %>
																	
										<!-- Display Member Groups -->
										<div id="member-groups">

											<strong><bean:message key="oscarMessenger.CreateMessage.memberGroups" /></strong>
										
											<c:forEach items="${ groupManager }" var="group">
											<details>										
												<summary>			
													<input type="checkbox" name="tableDFR" id="member_group_${ group.key.id }" 
															value="${ group.key.id }" onclick="checkGroup(this)" />
													<label for="member_group_${ group.key.id }" >${ group.key.groupDesc }</label>
												</summary>
																																			
												<c:forEach items="${ group.value }" var="member">
													<div class="group_member_contact" style="white-space: nowrap;">
														<input type="checkbox" name="provider" class="member_group_${ group.key.id }" 
															id="${ group.key.id }-${ member.id.compositeId }" value="${ member.id.compositeId }" />
														
														<label for="${ group.key.id }-${ member.id.compositeId }" >
															<c:out value="${ member.lastName }" />, <c:out value="${ member.firstName }" />															
														</label>
													</div>
												</c:forEach>
												
											</details>
											</c:forEach>
								
										</div>
										
										<!-- Display Members by remote locations -->
										<c:if test="${ not empty remoteMembers }" >
										
										<hr style="border-top:1px solid #dcdcdc; border-bottom:none;" />
										
										<div id="remote-locations">
										<details>
											<summary>
												<strong><bean:message key="oscarMessenger.CreateMessage.remoteMembers" /></strong>
											</summary>
											<c:forEach items="${ remoteMembers }" var="location" >
												<details>										
													<summary>			
														<input type="checkbox" name="tableDFR" id="remote_group_${ location.key }" 
																value="${ location.key }" onchange="checkGroup(this)" />
														<label for="remote_group_${ location.key }" >${ location.key }</label>
													</summary>

													<c:forEach items="${ location.value }" var="member">
													
														<%-- this is horrible. try not to repeat it --%>
														<c:set var="providerChecked" value="false" />
														<c:forEach var="replyId" items="${ replyList }">
															<c:if test="${ replyId.compositeId eq member.id.compositeId }">
																<c:set var="providerChecked" value="true" />
															</c:if>
														</c:forEach>
																	
														<div class="remote_member_contact">												
															<input type="checkbox" name="provider" class="remote_group_${ location.key }" 
																id="${ member.id.compositeId }" value="${ member.id.compositeId }"  ${ providerChecked ? 'checked' : '' }/>
															<label for="${ member.id.compositeId }" >
																<c:out value="${ member.lastName }" />, <c:out value="${ member.firstName }" />															
															</label>
														</div>
													</c:forEach>
													
												</details>
											</c:forEach>
										</details>
										</div>
										</c:if>
										
										<hr style="border-top:1px solid #dcdcdc; border-bottom:none;" />
										
										<details open="true">
											<summary>
												<strong><bean:message key="oscarMessenger.CreateMessage.localMembers" /></strong>
											</summary>

											<!-- Display all local members -->
											<c:forEach items="${ localMembers }" var="member">
											
												<%-- this is horrible. try not to repeat it --%>
												<c:set var="providerChecked" value="false" />
												<c:forEach var="replyId" items="${ replyList }">
													<c:if test="${ replyId.compositeId eq member.id.compositeId }">
														<c:set var="providerChecked" value="true" />
													</c:if>
												</c:forEach>
	                                            
												<div class="member_contact" style="white-space: nowrap;">								
													<input type="checkbox" name="provider" id="0-${ member.id.compositeId }" 
														value="${ member.id.compositeId }"  ${ providerChecked ? 'checked' : '' }/>
													<label for="0-${ member.id.compositeId }" >
														<c:out value="${ member.lastName }" />, <c:out value="${ member.firstName }" />															
													</label>												
												</div>
                                                   
											</c:forEach>
										</details>
									</td><!--list of the providers cell end-->
								</tr>
							</table>
						</div> <!-- end ChooseRecipientsBox -->
					</td>
					<td valign=top colspan="2"><!--Message and Subject Cell-->
                    <br>
					<bean:message key="oscarMessenger.CreateMessage.formSubject" /> :
					<html:text name="msgCreateMessageForm" property="subject" styleClass="input-xxlarge" value="${messageSubject}"/> <br>
					<br>
                    <div id="messagediv"></div>
					<html:textarea name="msgCreateMessageForm" property="message" rows="15" style="min-width: 100%" value="${messageBody}"/> 
							<table>
								<tr>
									<td><input type="submit" class="btn btn-primary" onclick="writeToMessage();"
										value="<bean:message key="oscarMessenger.CreateMessage.btnSendMessage"/>">
									</td>
									<td><input type="button" class="btn" id="sendArchive" onclick="writeToMessage();XMLHttpRequestSendnArch();"
										value="<bean:message key="oscarMessenger.CreateMessage.btnSendnArchiveMessage"/>" >
									</td>
								</tr>
							</table>
					<%
                       String att = bean.getAttachment();
                       String pdfAtt = bean.getPDFAttachment();
                       if (att != null || pdfAtt != null){ 
                    %>
							<br>
							<bean:message key="oscarMessenger.CreateMessage.msgAttachments" />
							<input type="hidden" id="attachmentAlert" name="attachmentAlert" value="true" />
							<% 
							bean.setSubject(null);
							bean.setMessage(null);
						}%>
					</td>
				</tr>

				<tr>
					<td class="subheader"></td>
					<td class="subheader" colspan="2"><font style="font-weight: bold"><bean:message key="oscarMessenger.CreateMessage.msgLinkThisMessage" /></font></td>
				</tr>
                                                      
				<tr>
					<td><br><br>&nbsp;</td>
					<td>
                      <input type="text" name="keyword" class="input-medium" /> <input type="hidden" name="demographic_no" value="<%=demographic_no%>" /> 
                    </td>
	                <td> 
                      <input type="button" class="btn" name="searchDemo" value="<bean:message key="oscarMessenger.CreateMessage.msgSearchDemographic" />" onclick="popupSearchDemo(document.forms[0].keyword.value)" />
                  	</td>
				</tr>
				<tr>
					<td></td>
					<td colspan="2"><font style="font-weight: bold"><bean:message key="oscarMessenger.CreateMessage.msgSelectedDemographic" /></font></td>
				</tr>
				<tr>
					<td></td>
					
					<td>

						<c:choose>					
							<c:when test="${ not empty unlinkedIntegratorDemographicName }">
								<input type="text" name="selectedDemo" value="${ unlinkedIntegratorDemographicName }" 
									class="input-medium" style="border: none;" readonly />
							</c:when>
							<c:otherwise>
								<input type="text" name="selectedDemo" class="input-medium" readonly style="border: none" value="none" /> 
								<script type="text/javascript">
			                          if ( "<%=demoName%>" != "null" && "<%=demoName%>" != "") {
			                              document.forms[0].selectedDemo.value = "<%=demoName%>";
			                              document.forms[0].demographic_no.value = "<%=demographic_no%>";
			                          }
			                     </script>						
							</c:otherwise>					
						</c:choose>
				           
	                </td>
	                <td> 
                    <input type="button"
						class="btn" name="clearDemographic"
						value="<bean:message key="oscarMessenger.CreateMessage.msgClearSelectedDemographic" />"
						onclick='document.forms[0].demographic_no.value = ""; document.forms[0].selectedDemo.value = "none"' />
					<input type="button" class="btn" name="attachDemo"
						value="<bean:message key="oscarMessenger.CreateMessage.msgAttachDemographic" />"
						onclick="popupAttachDemo(document.forms[0].demographic_no.value)"
						style="display: " />
					</td>

				</tr>

		</table>
		</html:form>
			</td>
		</tr>
		<tr>
			<td>
			<script language="JavaScript">
                 document.forms[0].message.focus();
            </script>
            </td>
		</tr>

	</table>
	</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn">&nbsp;</td>
		<td class="MainTableBottomRowRightColumn">&nbsp;</td>
	</tr>
</table>
</body>
<script>
 <% if (renderMarkdown) { %>
    // note that global.language.code != global.i18nLanguagecode
    const Editor = toastui.Editor;
    const editor = new Editor({
      el: document.getElementById('messagediv'),
        initialEditType:'wysiwyg',
        usageStatistics: false,
        height: '500px',
        language:'<bean:message key="global.language.code" />'
	    })

    function writeToMessage() {
        document.getElementsByName("message")[0].value = editor.getMarkdown();
    }
<% } else { %>

    function writeToMessage() {
        console.log("saving");
    }

<% } %>
</script>
</html:html>