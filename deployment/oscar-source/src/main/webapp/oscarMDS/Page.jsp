<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<%@ page language="java" %>

<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.collections.MultiHashMap" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="org.apache.logging.log4j.Logger "%>
<%@ page import="org.oscarehr.common.dao.OscarLogDao "%>
<%@ page import="org.oscarehr.common.hl7.v2.oscar_to_oscar.OscarToOscarUtils"%>
<%@ page import="org.oscarehr.util.MiscUtils "%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="oscar.oscarLab.ca.on.* "%>
<%@ page import="oscar.oscarMDS.data.* "%>
<%@ page import="oscar.util.StringUtils "%>
<%@ page import="oscar.util.UtilDateUtilities" %>
<%@ page import="oscar.OscarProperties" %>

<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<% // Page.jsp is a fragment referenced in index.jsp

      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	  boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_lab" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_lab");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%
Logger logger=MiscUtils.getLogger();

oscar.OscarProperties props = oscar.OscarProperties.getInstance();
String rapid_review = (props.getProperty("RAPID_REVIEW","")).trim();
String view = (String)request.getAttribute("view");
Integer pageSize=(Integer)request.getAttribute("pageSize");
Integer pageNum=(Integer)request.getAttribute("pageNum");
Integer pageCount=(Integer)request.getAttribute("pageCount");
Map<String,String> docType=(Map<String,String>)request.getAttribute("docType");
Map<String,List<String>> patientDocs=(Map<String,List<String>>)request.getAttribute("patientDocs");
String providerNo=(String)request.getAttribute("providerNo");
String searchProviderNo=(String)request.getAttribute("searchProviderNo");
Map<String,String> patientIdNames=(Map<String,String>)request.getAttribute("patientIdNames");
String patientIdNamesStr=(String)request.getAttribute("patientIdNamesStr");
Map<String,String> docStatus=(Map<String,String>)request.getAttribute("docStatus");
String patientIdStr =(String)request.getAttribute("patientIdStr");
Map<String,List<String>> typeDocLab =(Map<String,List<String>>)request.getAttribute("typeDocLab");
String demographicNo=(String)request.getAttribute("demographicNo");
String ackStatus = (String)request.getAttribute("ackStatus");
List labdocs=(List)request.getAttribute("labdocs");
Map<String,Integer> patientNumDoc=(Map<String,Integer>)request.getAttribute("patientNumDoc");
Integer totalDocs=(Integer) request.getAttribute("totalDocs");
Integer totalHL7=(Integer)request.getAttribute("totalHL7");
List<String> normals=(List<String>)request.getAttribute("normals");
List<String> abnormals=(List<String>)request.getAttribute("abnormals");
Integer totalNumDocs=(Integer)request.getAttribute("totalNumDocs");
String selectedCategory = request.getParameter("selectedCategory");
String selectedCategoryPatient = request.getParameter("selectedCategoryPatient");
String selectedCategoryType = request.getParameter("selectedCategoryType");
boolean isListView = Boolean.valueOf(request.getParameter("isListView"));

OscarLogDao oscarLogDao = (OscarLogDao) SpringUtils.getBean("oscarLogDao");
String curUser_no = (String) session.getAttribute("user");

%>

<% if (isListView && pageNum == 0) { %>
		<script type="text/javascript">
			function submitLabel(lblval){
		       	 document.forms['TDISLabelForm'].label.value = document.forms['acknowledgeForm'].label.value;
	       	}
            if (!DataTable.isDataTable('#summaryView')) {
                oTable=jQuery('#summaryView').DataTable({
                    "bPaginate": false,
                    "dom": "lrtip",
                    "order": [],
                    "language": {
                                "url": "<%=request.getContextPath() %>/library/DataTables/i18n/<bean:message key="global.i18nLanguagecode"/>.json"
                            }
                });
                jQuery('#myFilterTextField').keyup(function(){
                    oTable.search(jQuery(this).val()).draw();
                });
            }

		</script>

        <table id="scrollNumber1" style="width:100%">
            <tr>
                <td class="subheader" colspan="10" style="text-align:left">

                               <% if (labdocs.size() > 0) { %>
                                   <input id="topFBtn" type="button" class="btn" value="<bean:message key="oscarMDS.index.btnForward"/>" onClick="parent.checkSelected(document)">
                                   <% if (ackStatus.equals("N") || ackStatus.isEmpty()) {%>
                                       <input id="topFileBtn" type="button" class="btn" value="<bean:message key="global.File"/>" onclick="parent.submitFile(document)"/>
                                   <% }
                                    %>
                                       &nbsp; <bean:message key="oscarMDS.index.RapidReview"/>: <input type="checkbox" id="ack_next_chk" onclick="toggleRapidReview();" <%=rapid_review%>>
&nbsp; <bean:message key="oscarMDS.search.formReportStatusAcknowledged"/>: <input type="checkbox" id="showAck" onclick='toggleReviewed()'>
                                    <%
                               }%><span style="float:right;">
                               <label><bean:message key="oscarMDS.index.btnSearch"/>: <input type="text" style="height:20px;" id="myFilterTextField"></label></span>
                               <input type="hidden" id="currentNumberOfPages" value="0">
                  </td>
            </tr>
            <tr>
                <td style="margin:0px;padding:0px;">
					<div id="listViewDocs" style="max-height:850px; overflow-y:scroll;" onscroll="handleScroll(this)">

					<table id="summaryView" class="table-striped table-hover" style="width:100%; margin:0px; padding:0px;">
					<thead>
						<tr>
                            <th class="header-cell">
                                <input type="checkbox" onclick="checkAllLabs('lab_form');" name="checkA" >
                                <bean:message key="oscarMDS.index.msgHealthNumber"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgPatientName"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgSex"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgResultStatus"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgDateTest"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgOrderPriority"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgRequestingClient"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgDiscipline"/>
                            </th>
                            <th class="header-cell">
                                <bean:message key="oscarMDS.index.msgReportStatus"/>
                            </th>
                            <th class="header-cell">
                                Ack #
                            </th>
                        </tr>
                          </thead>
                          <!--<tbody>-->
                                            <%
							} // End if(pageNum == 1)
                            List<String> doclabid_seq=new ArrayList<String>();
                            Integer number_of_rows_per_page=pageSize;
                            Integer totalNoPages=pageCount;
                            Integer total_row_index=labdocs.size()-1;
                            if (total_row_index < 0 || (totalNoPages != null && totalNoPages.intValue() == (pageNum+1))) {
                                	%> <input type="hidden" name="NoMoreItems" value="true" /> <%
                            		if (isListView) { %>
		                                <!--<tr>
		                                    <td colspan="9" style="text-align:center">
		                                        <i>	<% if (pageNum == 1 && totalNoPages != null) { %>
		                                        	<bean:message key="oscarMDS.index.msgNoReports"/>
		                                        	<% } else { %>
		                                        	<bean:message key="oscarMDS.index.msgNoMoreReports"/>
		                                        	<% } %>
		                                        </i>

		                                    </td>
		                                </tr>-->
	                         	<%	}
                            		else {
                            		%>

                            			<div style="text-align:center">
                            			<% if (pageNum < 1) { %>
                                       	<bean:message key="oscarMDS.index.msgNoReports"/>
                                       	<% } else { %>
                                       	<bean:message key="oscarMDS.index.msgNoMoreReports"/>
                                       	<% } %>
                            			</div>

                            		<%
                            		}

                                }
                            for (int i = 0; i < labdocs.size(); i++) {

                                LabResultData   result =  (LabResultData) labdocs.get(i);

                                String segmentID        =  result.getSegmentID();
                                String status           =  result.getAcknowledgedStatus();

								String labRead = "";
                                Boolean newLab = false;

                                if(result.isHRM() && !oscarLogDao.hasRead(curUser_no,"hrm",segmentID)){
                                    newLab = true;
                                	labRead = "<i class='icon-asterisk' style='font-size: 8px; color:gray; padding-right: 4px;'></i>"; // font-awesome
                                }

                                if( !result.isHRM() && result.isDocument() && !oscarLogDao.hasRead(curUser_no,"document",segmentID)){
                                    newLab = true;
                                    labRead = "<i class='icon-asterisk' style='font-size: 8px; color:gray; padding-right: 4px;'></i>";
                                }

                                if(!result.isHRM() && !result.isDocument() && !oscarLogDao.hasRead(curUser_no,"lab",segmentID)){
                                    newLab = true;
                                	labRead = "<i class='icon-asterisk' style='font-size: 8px; color:gray; padding-right: 4px;'></i>";
                                }


                                String discipline=result.getDiscipline();
                                if(discipline==null || discipline.equalsIgnoreCase("null"))
                                    discipline="";
                                MiscUtils.getLogger().debug("result.isAbnormal()="+result.isAbnormal());
                                doclabid_seq.add(segmentID);
                                request.setAttribute("segmentID", segmentID);
                                String demoName = StringEscapeUtils.escapeJavaScript(result.getPatientName());

                                if (!isListView) {
                                	try {
                                		if (result.isDocument()) { %>
                                <!-- segment ID <%= segmentID %>  -->
                                <!-- demographic name <%=StringEscapeUtils.escapeJavaScript(result.getPatientName()) %>  -->
                                <form id="frmDocumentDisplay_<%=segmentID%>">
                                	<input type="hidden" name="segmentID" value="<%=segmentID%>"/>
									<input type="hidden" name="demoName" value="<%=demoName%>"/>
									<input type="hidden" name="providerNo" value="<%=providerNo%>"/>
									<input type="hidden" name="searchProviderNo" value="<%=searchProviderNo%>"/>
									<input type="hidden" name="status" value="<%=status%>"/>
								</form>
                                <div id="document_<%=segmentID%>">
                        			<jsp:include page="../dms/showDocument.jsp" flush="true">
                        				<jsp:param name="segmentID" value="<%=segmentID%>"/>
                        				<jsp:param name="demoName" value="<%=demoName%>"/>
                        				<jsp:param name="providerNo" value="<%=providerNo%>"/>
                        				<jsp:param name="searchProviderNo" value="<%=searchProviderNo%>"/>
                        				<jsp:param name="status" value="<%=status%>"/>
                        			</jsp:include>
								</div>
                        		<%
                                		}
                                		else if (result.isHRM()) {

                                			StringBuilder duplicateLabIds=new StringBuilder();
                                        	for (Integer duplicateLabId : result.getDuplicateLabIds())
                                        	{
                                        		if (duplicateLabIds.length()>0) duplicateLabIds.append(',');
                                        		duplicateLabIds.append(duplicateLabId);
                                        	}
                                		%>

                                	<jsp:include page="../hospitalReportManager/Display.do" flush="true">
                                		<jsp:param name="id" value="<%=segmentID %>" />
                                		<jsp:param name="segmentID" value="<%=segmentID %>" />
                                		<jsp:param name="providerNo" value="<%=providerNo %>" />
                                		<jsp:param name="searchProviderNo" value="<%=searchProviderNo %>" />
                                		<jsp:param name="status" value="<%=status %>" />
                                		<jsp:param name="demoName" value="<%=result.getPatientName() %>" />
                                		<jsp:param name="duplicateLabIds" value="<%=duplicateLabIds.toString() %>" />
                                	</jsp:include>
		                        		<% } else {

		                        		%>
		                        		<%--
		                        				<iframe src="../lab/CA/ALL/labDisplayAjax.jsp?segmentID=<%=segmentID %>" style="height:100%;width:100%;border:0px;"></iframe>
		                        		--%>
		                        		<jsp:include page="../lab/CA/ALL/labDisplayAjax.jsp" flush="true">
		                        			<jsp:param name="segmentID" value="<%=segmentID%>"/>
		                        			<jsp:param name="demoName" value="<%=demoName%>"/>
				                        	<jsp:param name="providerNo" value="<%=providerNo%>"/>
		                        			<jsp:param name="searchProviderNo" value="<%=searchProviderNo%>"/>
		                        			<jsp:param name="status" value="<%=status%>"/>
		                        			<jsp:param name="showLatest" value="true" />
		                        		</jsp:include>

		                        		<%
		                        		}
                                	}
                                	catch (Exception e) { logger.error(e.toString()); }
                                }
                                else {
                        		%>
                                <tr id="labdoc_<%=segmentID%>" <%if(result.isDocument()){%> name="scannedDoc" <%} else{%> name="HL7lab" <%}%> class="<%= (result.isAbnormal() ? "AbnormalRes error" : "NormalRes" ) + " " + (result.isMatchedToPatient() ? "AssignedRes" : "UnassignedRes") %>">
                                <td style="width:130px; white-space:nowrap;">
                                    <input type="checkbox" name="flaggedLabs" value="<%=segmentID%>">
                                    <input type="hidden" name="labType<%=segmentID+result.labType%>" value="<%=result.labType%>"/>
                                    <input type="hidden" name="ackStatus" value="<%= result.isMatchedToPatient() %>" />
                                    <input type="hidden" name="patientName" value="<%=StringEscapeUtils.escapeHtml(result.patientName) %>"/>
                                    <%=result.getHealthNumber() %>
                                </td>
                                <td style="white-space:nowrap;">
                                    <% if ( result.isMDS() ){ %>
                                    <%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)"  onclick="parent.reportWindow('SegmentDisplay.jsp?segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%>'); if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%= StringEscapeUtils.escapeHtml(result.getPatientName())%></a>
                                    <% }else if (result.isCML()){ %>
                                    <%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)"  onclick="parent.reportWindow('<%=request.getContextPath()%>/lab/CA/ON/CMLDisplay.jsp?segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%>'); if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%=StringEscapeUtils.escapeHtml(result.getPatientName())%></a>
                                    <% }else if (result.isHL7TEXT())
                                   	{
                                    	String categoryType=result.getDiscipline();

                                    	if ("REF_I12".equals(categoryType))
                                    	{
	                                    	%>
                                      			<%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)"  onclick="parent.popupConsultation('<%=segmentID%>'); if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%=StringEscapeUtils.escapeHtml(result.getPatientName())%></a>
                                    		<%
                                    	}
                                    	else if (categoryType!=null && categoryType.startsWith("ORU_R01:"))
                                    	{
	                                    	%>
                                      			<%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)" onclick="parent.reportWindow('<%=request.getContextPath()%>/lab/CA/ALL/viewOruR01.jsp?segmentId=<%=segmentID%>)'; if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%=StringEscapeUtils.escapeHtml(result.getPatientName())%></a>
                                    		<%
                                    	}
                                    	else
                                    	{
	                                    	%>
	                                    		<%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)"  onclick="parent.reportWindow('<%=request.getContextPath()%>/lab/CA/ALL/labDisplay.jsp?segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%>&showLatest=true'); if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%=StringEscapeUtils.escapeHtml(result.getPatientName())%></a>
	                                    	<%
                                    	}
                                    }
                                    else if (result.isDocument()){
                                	String patientName = result.getPatientName();
                                    	StringBuilder url = new StringBuilder(request.getContextPath());
                                    	url.append("/dms/showDocument.jsp?inWindow=true&segmentID=");
                                    	url.append(segmentID);
                                    	url.append("&providerNo=");
                                    	url.append(providerNo);
                                    	url.append("&searchProviderNo=");
                                    	url.append(searchProviderNo);
                                    	url.append("&status=");
                                    	url.append(status);
                                    	url.append("&demoName=");

                                    	//the browser html parser does not understand javascript so we need to account for the opening
                                    	//and closing quotes used in the onclick event handler
                                    	patientName = StringEscapeUtils.escapeHtml(patientName);

                                    	//now that the html parser will pass the correct characters to the javascript engine we need to
                                    	//escape chars for javascript that are not transformed by the html escape.
                                    	url.append(StringEscapeUtils.escapeJavaScript(patientName));
                                    %>

                                    <%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)" onclick="javascript:parent.reportWindow('<%=url.toString()%>'); if(this.previousElementSibling) this.previousElementSibling.outerHTML=''" ><%=StringEscapeUtils.escapeHtml(result.getPatientName())%></a>

                                    <% }else if(result.isHRM()){
                                    	StringBuilder duplicateLabIds=new StringBuilder();
                                    	for (Integer duplicateLabId : result.getDuplicateLabIds())
                                    	{
                                    		if (duplicateLabIds.length()>0) duplicateLabIds.append(',');
                                    		duplicateLabIds.append(duplicateLabId);
                                    	}
                                    %>
                                    <%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)" onclick="parent.reportWindow('<%=request.getContextPath()%>/hospitalReportManager/Display.do?id=<%=segmentID%>&segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%>&demoName=<%=StringEscapeUtils.escapeHtml(demoName)%>&duplicateLabIds=<%=duplicateLabIds.toString()%> '); if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%=result.getPatientName()%></a>
                                    <% }else {%>
                                    <%=labRead%><a id="a<%=segmentID%>" href="javascript:void(0)" onclick="parent.reportWindow('<%=request.getContextPath()%>/lab/CA/BC/labDisplay.jsp?segmentID=<%=segmentID%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%>'); if(this.previousElementSibling) this.previousElementSibling.outerHTML='';"><%=StringEscapeUtils.escapeJavaScript(result.getPatientName())%></a>
                                    <% }%>
                                </td>
                                <td style="white-space:nowrap;">
                                    <%=result.getSex() %>
                                </td>
                                <td style="white-space:nowrap;">
                                    <%
                                    if(newLab) {
                                    %>
                                    <bean:message key="WriteScript.msgRxStatus.New"/>&nbsp;
                                    <%
                                    }
                                    if (result.isAbnormal()) {
                                    %>
                                    <bean:message key="global.Abnormal"/>
                                    <% } %>
                                </td>
                                <td style="white-space:nowrap;">
                                    <%=result.getDateTime() + (result.isDocument() ? " / " + result.lastUpdateDate : "")%>
                                </td>
                                <td style="white-space:nowrap;">
                                    <%=result.getPriority()%>
                                </td>
                                <td style="white-space:nowrap;">
                                    <%=(result.getRequestingClient() == "null" ? "" : result.getRequestingClient())%>
                                </td>
                                <td style="white-space:nowrap;">
                                    <%=result.isDocument() ? result.description == null ? "" : result.description : result.getDisciplineDisplayString()%>
                                </td>
                                <td style="white-space:nowrap;"> <!--  -->
                                    <%= ((result.isReportCancelled())? "Cancelled" : result.isFinal() ? "Final" : "Partial")%>
                                </td>
                                <td style="white-space:nowrap;">
                                    <% int multiLabCount = result.getMultipleAckCount(); %>
                                    <%= result.getAckCount() %>&#160<% if ( multiLabCount >= 0 ) { %>(<%= result.getMultipleAckCount() %>)<%}%>
                                </td>
                            </tr>
                         <% }


                            } // End else from if(isListView)
                            if (isListView && pageNum == 0) { %>
                            </tbody>
                       	</table>

                       	<table style="margin:0px;padding:0px; width: 100%;" >
                       		<tr><td>
                       			<div id='loader' style="display:none"><img src='<%=request.getContextPath()%>/images/DMSLoader.gif'> <bean:message key="caseload.msgLoading"/></div>
                       		</td></tr>
                       	</table>
                       	</div>
                       	<% if (labdocs.size() > 0) { %>
                       	<table width="100%" style="margin:0px;padding:0px;" cellpadding="0" cellspacing="0">
                            <tr class="MainTableBottomRow">
                                <td class="subheader"  colspan="10" style="text-align:left;">
                                    <table style="width: 100%;">
                                        <tr>
                                            <td style="width: 30%; text-align:left; vertical-align:middle;">

                                                    <input type="button" class="btn" value="<bean:message key="oscarMDS.index.btnForward"/>" onClick="parent.checkSelected(document)">
                                                    <% if (ackStatus.equals("N")) {%>
                                                        <input type="button" class="btn" value="<bean:message key="global.File"/>" onclick="parent.submitFile(document)"/>
                                                    <% }  %>
                                            </td>
                                        <script type="text/javascript">
                                                var doclabid_seq='<%=doclabid_seq%>';
                                                doclabid_seq=doclabid_seq.replace('[','');
                                                doclabid_seq=doclabid_seq.replace(']','');
                                                var arr=doclabid_seq.split(',');
                                                var arr2=new Array();
                                                for(var i=0;i<arr.length;i++){
                                                    var ele=arr[i];
                                                    ele=ele.replace(' ','');
                                                    arr2.push(ele);
                                                }
                                                doclabid_seq=arr2;

                                                oldestLab = '<%=request.getAttribute("oldestLab") %>';

	                                            for( var i = 0; i < localStorage.length; i++ ) {
		                                            var key = localStorage.key(i);
	                                            	if( key == "rapidreview" && typeof document.getElementById('ack_next_chk') !== 'undefined'){
                                                        console.log("rapid review checkbox set to "+localStorage.getItem(key));
                                                        if (localStorage.getItem(key) == "true" ){
                                            			    document.getElementById('ack_next_chk').checked = true;
                                                        }
                                                    }
		                                        }

                                                function toggleRapidReview() {
                                                    localStorage.setItem("rapidreview",document.getElementById('ack_next_chk').checked);

                                                }
                                        </script>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                    </table>
                    <% } %>
                </td>
            </tr>
        </table>

    <% } // End if (pageNum == 1) %>