<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<!DOCTYPE html>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
      String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
      boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_con" rights="w" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../../securityError.jsp?type=_con");%>
</security:oscarSec>
<%
if(!authed) {
	return;
}
%>

<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%
String user_no = (String) session.getAttribute("user");
String userfirstname = (String) session.getAttribute("userfirstname");
String userlastname = (String) session.getAttribute("userlastname");
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<jsp:useBean id="oscarVariables" class="java.util.Properties"
	scope="page" />
<%@ page import="java.io.*" %>
<%@ page import="java.math.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Collections" %>
<%@ page import="org.oscarehr.common.dao.SystemPreferencesDao" %>
<%@ page import="org.oscarehr.common.model.EFormData" %>
<%@ page import="org.oscarehr.common.model.SystemPreferences" %>
<%@ page import="org.oscarehr.hospitalReportManager.dao.HRMDocumentDao"%>
<%@ page import="org.oscarehr.hospitalReportManager.dao.HRMDocumentToDemographicDao"%>
<%@ page import="org.oscarehr.hospitalReportManager.model.HRMDocument"%>
<%@ page import="org.oscarehr.hospitalReportManager.model.HRMDocumentToDemographic"%>
<%@ page import="org.oscarehr.util.SessionConstants"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="oscar.*" %>
<%@ page import="oscar.MyDateFormat" %>
<%@ page import="oscar.dms.*" %>
<%@ page import="oscar.dms.data.*" %>
<%@ page import="oscar.eform.EFormUtil" %>
<%@ page import="oscar.oscarEncounter.oscarConsultationRequest.pageUtil.ConsultationAttachDocs"%>
<%@ page import="oscar.oscarLab.ca.all.Hl7textResultsData"%>
<%@ page import="oscar.oscarLab.ca.on.*"%>
<%@ page import="oscar.util.*" %>

<%@ page import="org.owasp.encoder.Encode" %>

<%

//preliminary JSP code

LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);

// "Module" and "function" is the same thing (old dms module)
String module = "demographic";
String demoNo = request.getParameter("demo");
String requestId = request.getParameter("requestId");
String providerNo = request.getParameter("provNo");

if(demoNo == null && requestId == null ) response.sendRedirect("../error.jsp");

if( demoNo == null || demoNo.equals("null")  ) {

	ConsultationAttachDocs docsUtil = new ConsultationAttachDocs(requestId);
    demoNo = docsUtil.getDemoNo();

}

HRMDocumentToDemographicDao hrmDocumentToDemographicDao = (HRMDocumentToDemographicDao) SpringUtils.getBean("HRMDocumentToDemographicDao");
HRMDocumentDao hrmDocumentDao = (HRMDocumentDao) SpringUtils.getBean("HRMDocumentDao");

String patientName = EDocUtil.getDemographicName(loggedInInfo, demoNo);
String[] docType = {"D","L", "H", "E"};
String http_user_agent = request.getHeader("User-Agent");
boolean onIPad = http_user_agent.indexOf("iPad") >= 0;
%>

<html:html locale="true">
<head>
<title><bean:message key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.title" /></title>

<script src="${ pageContext.request.contextPath }/js/global.js"></script>
<script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
<script src="${ pageContext.request.contextPath }/js/jquery_oscar_defaults.js"></script>

<link href="${ pageContext.request.contextPath }/css/bootstrap.css" rel="stylesheet" type="text/css"> <!--  bootstrap 2.3 -->
<script>
//<!--
<%
CommonLabResultData labData = new CommonLabResultData();
ArrayList<LabResultData> labs = labData.populateLabResultsData(loggedInInfo, demoNo, requestId, CommonLabResultData.ATTACHED);
ArrayList<EDoc> privatedocs = new ArrayList<EDoc>();
privatedocs = EDocUtil.listDocs(loggedInInfo, demoNo, requestId, EDocUtil.ATTACHED);

List<HRMDocumentToDemographic> hrmDocumentsToDemographics = hrmDocumentToDemographicDao.findHRMDocumentsAttachedToConsultation(requestId);
List<EFormData> eForms = EFormUtil.listPatientEformsCurrentAttachedToConsult(requestId);
String attachedDocs = "";
if (requestId == null || requestId.equals("") || requestId.equals("null")) {
	attachedDocs = "window.opener.document.EctConsultationFormRequestForm.documents.value";
}
else {
	for (int i = 0; i < privatedocs.size(); i++) {
	    attachedDocs += (attachedDocs.equals("") ? "" : "|") + "D" + (privatedocs.get(i)).getDocId();
	}

	for (int i = 0; i < labs.size(); i++) {
	    attachedDocs += (attachedDocs.equals("") ? "" : "|") + "L" + (labs.get(i)).getSegmentID();
	}

	for (HRMDocumentToDemographic hrmDocumentToDemographic : hrmDocumentsToDemographics) {
		attachedDocs += (attachedDocs.equals("") ? "" : "|") + "H" + hrmDocumentToDemographic.getHrmDocumentId();
	}
	for (EFormData eForm : eForms) {
		attachedDocs += (attachedDocs.equals("") ? "" : "|") + "E" + eForm.getId();
	}
	attachedDocs = "\"" + attachedDocs + "\"";
}
%>

//if consultation has not been saved, load existing docs into proper select boxes
function init() {
	var docs = <%= attachedDocs %>;
	docs = docs.split("|");
	checkDocuments(docs);
}

function checkDocuments(docs) {
	if (docs == null) { return; }
	for (var idx = 0; idx < docs.length; ++idx) {
        if (docs[idx].length < 2) { continue; }
		var attachmentType = "docNo";
        switch (docs[idx].charAt(0)) {
			case "L": attachmentType = "labNo"; break;
			case "H": attachmentType = "hrmNo"; break;
			case "D": attachmentType = "docNo"; break;
			case "E": attachmentType = "eFormNo"; break;
		}
        $("input[name='" + attachmentType + "']"
              +"[value='" + docs[idx].substring(1) + "']").attr("checked", "checked");
    }
}


function save() {

	if (window.opener == null) {
		window.close();
	}
    var ret;
    if(document.forms[0].requestId.value == "null") {
       var saved = "";
       var list = window.opener.document.getElementById("attachedList");
       var paragraph = window.opener.document.getElementById("attachDefault");

       paragraph.innerHTML = "";

       //delete what we have before adding new docs to list
       while(list.firstChild) {
            list.removeChild(list.firstChild);
       }

       $("input[name='docNo']:checked").each(function() {
           saved += (saved == "" ? "" : "|") + "D" + $(this).attr("value");
           listElem = window.opener.document.createElement("li");
           listElem.innerHTML = $(this).next().get(0).innerHTML;
           listElem.className = "doc";
           list.appendChild(listElem);
       });
       $("input[name='labNo']:checked").each(function() {
           saved += (saved == "" ? "" : "|") + "L" + $(this).attr("value");
           listElem = window.opener.document.createElement("li");
           listElem.innerHTML = $(this).next().get(0).innerHTML;
           listElem.className = "lab";
           list.appendChild(listElem);
       });

       $("input[name='hrmNo']:checked").each(function() {
    	  saved += (saved == "" ? "" : "|") + "H" + $(this).attr("value");
    	  listElem = window.opener.document.createElement("li");
    	  listElem.innerHTML = $(this).next().get(0).innerHTML;
          listElem.className = "hrm";
          list.appendChild(listElem);
       });
		$("input[name='eFormNo']:checked").each(function() {
			saved += (saved == "" ? "" : "|") + "E" + $(this).attr("value");
			listElem = window.opener.document.createElement("li");
			listElem.innerHTML = $(this).next().get(0).innerHTML;
			listElem.className = "eForm";
			list.appendChild(listElem);
		});

       window.opener.document.EctConsultationFormRequestForm.documents.value = saved;

       if( list.childNodes.length == 0 )
            paragraph.innerHTML = "<bean:message key="oscarEncounter.oscarConsultationRequest.AttachDoc.Empty"/>";

       ret = false;
    }
    else {
        window.opener.updateAttached();
        ret = true;
    }
    if (!ret) window.close();
    return ret;
}

function previewPDF(docId, url) {
	$("#previewPane").attr("src",
			"<%= request.getContextPath() %>/oscarEncounter/oscarConsultationRequest/displayImage.jsp?url="
					       + encodeURIComponent("<%= request.getContextPath() %>" + "/dms/ManageDocument.do?method=view&doc_no=" + docId)
					       + "&link=" + encodeURIComponent(url));
}

function previewHTML(url) {
	$("#previewPane").attr("src", url);
}

function previewImage(url) {
	$("#previewPane").attr("src", "<%= request.getContextPath() %>/oscarEncounter/oscarConsultationRequest/displayImage.jsp?url=" + encodeURIComponent(url));
}

function doShow(elem, aclass) {

    var elems = document.querySelectorAll("." + aclass);
    [].forEach.call(elems, function(el) {
        el.classList.add("un-"+aclass);
        el.classList.remove(aclass);
    });
    elem.classList.add(aclass);

}

function doHide(elem, aclass) {

    var eltoggle = document.querySelectorAll("." + aclass);
    var elems = document.querySelectorAll(".un-" + aclass);
    [].forEach.call(elems, function(el) {
        el.classList.add(aclass);
        el.classList.remove("un-"+aclass);
    });
    elem.classList.add(aclass);
    eltoggle[0].classList.remove(aclass);
    eltoggle[0].classList.add("un-"+aclass);

}

//-->
</script>
<style>
#documentList a {
    text-decoration:none;
}
.item {
    float:left;
    height:25px;
    line-height:25px;
    width: 100px;
    white-space:nowrap;
}
.item-date {
    float:right;
    height:25px;
    line-height:25px;
    text-align:right;
    width:90px;
    white-space:nowrap;
}
.hiddenDoc {
    display: none;
}
.hiddenLab {
    display: none;
}
.hiddenHRM {
    display: none;
}
.hiddeneForm {
    display: none;
}
.h3 {
    font-weight:bold;
    font-size:22px;
    padding: 2px 8px 2px 1px;
    line-height: 34px;
}
.h4 {
    font-weight:bold;
    font-size:18px;
    padding: 0px 8px 0px 1px;
    line-height: 24px;
}
.tgl {
    float:right;
    background-color:#eaeaea;
    padding: 1px 4px 1px 4px;
}

</style>

</head>
<body style="font-family: Verdana, Tahoma, Arial, sans-serif; background-color: #f5f5f5" onload="init()" >
    <html:form action="/oscarConsultationRequest/attachDoc">
	<html:hidden property="requestId" value="<%=requestId%>" />
	<html:hidden property="demoNo" value="<%=demoNo%>" />
	<html:hidden property="providerNo" value="<%=providerNo%>" />
    <span class="h3" style="text-align: left">&nbsp;<bean:message key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.header" />
        <%=patientName%></span><span style="float:right;">
            <input type="submit" class="btn"
                name="submit"
                value="<bean:message key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.submit"/>"
                onclick="return save();" ></span>

	<table style="width:1080px; font-size: x-small; background-color:white; table-layout: fixed;" >
		<tr>
			<th style="width:245px;"><bean:message
				key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.available" /></th>
			<th><bean:message
				key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.preview" /></th>
		</tr>
		<tr style="border-top:thin dotted black; vertical-align:top;">
			<td style="width: 245px; text-align: left; background-color: white; border-right:thin dotted black; position:absolute; height:655px;" >
			<ul id="documentList" style="list-style:none; padding:5px; margin-top:5px; height:600px; overflow:auto;">

            <%
            final String PRINTABLE_IMAGE = request.getContextPath() + "/images/printable.png";
            final String PRINTABLE_TITLE = "This file can be automatically printed to PDF with the consultation request.";
            final String PRINTABLE_ALT = "Printable";
            final String UNPRINTABLE_IMAGE = request.getContextPath() + "/images/notprintable.png";
            final String UNPRINTABLE_TITLE = "This file must be manually printed.";
            final String UNPRINTABLE_ALT = "Unprintable";

            privatedocs = EDocUtil.listDocs(loggedInInfo, "demographic", demoNo, null, EDocUtil.PRIVATE, EDocUtil.EDocSort.OBSERVATIONDATE);
            labData = new CommonLabResultData();
            labs = labData.populateLabResultsData(loggedInInfo, "",demoNo, "", "","","U");
            Collections.sort(labs);

            List<HRMDocumentToDemographic> hrmDocumentToDemographicList = hrmDocumentToDemographicDao.findByDemographicNo(demoNo);

            if (labs.size() == 0 && privatedocs.size() == 0 && hrmDocumentToDemographicList.size() == 0 && eForms.size() == 0) {
            %>
                <li> There are no documents to attach. </li>
            <% }
            else {
            %>
            <% if(privatedocs.size() > 0){%>
            	<li><span class="h4"><bean:message key="global.Document"/></span>
                    <span class="tgl"><input class="tightCheckbox1" id="selectAlldoc"
                        type="checkbox" onclick="$('[name=docNo]').prop('checked', $(this).prop('checked'));"
                        value="" title="<bean:message key="dms.incomingDocs.select" />/<bean:message key="admin.fieldNote.unselect" /> <bean:message key="global.Document"/>."
                        style="margin: 0px; padding: 0px;" > <bean:message key="dms.documentReport.msgAll" />&nbsp;<%=privatedocs.size()%></span>
                </li>
            <%}%>
            <%
	            EDoc curDoc;
	            String url;
	            String printTitle;
	            String printImage;
	            String printAlt;
	            String date;
	            String truncatedDisplayName;
                String currType = "";
                String newType;
                String hiddenClass = "";
                SystemPreferencesDao systemPreferencesDao = SpringUtils.getBean(SystemPreferencesDao.class);
                SystemPreferences preference =
                    systemPreferencesDao.findPreferenceByName("echart_show_group_document_by_type");
                boolean groupByType = preference != null && Boolean.parseBoolean(preference.getValue());

	            for(int idx = 0; idx < privatedocs.size(); ++idx)
	            {
	                curDoc = privatedocs.get(idx);
	                int slash = 0;
	                String contentType = "";
	                if ((slash = curDoc.getContentType().indexOf('/')) != -1) {
	                    contentType = curDoc.getContentType().substring(slash+1);
	                }
	                String dStatus = "";
	                if ((curDoc.getStatus() + "").compareTo("A") == 0) dStatus="active";
	                else if ((curDoc.getStatus() + "").compareTo("H") == 0) dStatus="html";
	                url = request.getContextPath() + "/oscarEncounter/oscarConsultationRequest/"
	                    + "documentGetFile.jsp?document=" + Encode.forUriComponent(curDoc.getFileName())
	                    + "&type=" + dStatus + "&doc_no=" + curDoc.getDocId();
	                String onClick = "";

	                if (curDoc.isPDF()) {
	                    onClick = "javascript:previewPDF('" + curDoc.getDocId() + "','" + url + "');";
	                }
	                else if (curDoc.isImage()) {
	                    onClick = "javascript:previewImage('" + url + "');";
	                }
	                else {
	                    onClick = "javascript:previewHTML('" + url + "');";
	                }

	                if (curDoc.isPrintable()) {
	                    printImage = PRINTABLE_IMAGE;
	                    printTitle = PRINTABLE_TITLE;
	                    printAlt   = PRINTABLE_ALT;

	                }
	                else {
	                    printImage = UNPRINTABLE_IMAGE;
	                    printTitle = UNPRINTABLE_TITLE;
	                    printAlt   = UNPRINTABLE_ALT;
	                }
	                date = DateUtils.getDate(MyDateFormat.getCalendar(curDoc.getObservationDate()).getTime(), "dd-MMM-yyyy", request.getLocale());
	                truncatedDisplayName = StringUtils.maxLenString(curDoc.getDescription(),13,10,"...");
	                if (StringUtils.isNullOrEmpty(truncatedDisplayName)) { truncatedDisplayName = "(none)"; }

                    if (idx > 8) {
                        hiddenClass = "hiddenDoc";
                    }

                    newType = curDoc.getType();
                    if (groupByType && !currType.equals(newType) && !newType.isEmpty()){
                        currType = newType;
	                %>
		                <li class="doc <%=hiddenClass%>"><%=Encode.forHtml(currType)%></li>
                    <%
                    }
	                %>
		                <li class="doc <%=hiddenClass%>" title="<%=Encode.forHtmlAttribute(curDoc.getDescription())%>" id="<%=docType[0]+curDoc.getDocId()%>" >
		                    <div>
		                    <div><span class="item">
		                    	<input class="tightCheckbox1"
				                        type="checkbox" name="docNo" id="docNo<%=curDoc.getDocId()%>"
				                        value="<%=curDoc.getDocId()%>"
				                        style="margin: 0px; padding: 0px;" >
				                <span class="url" style="display:none">
		                        	<a  title="<%=Encode.forHtmlAttribute(curDoc.getDescription())%>" href="<%=url%>" target="_blank">
										<img style="width:15px;height:15px" title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>" >
										<%=Encode.forHtml(truncatedDisplayName)%>
									</a>
			                    </span>
			                    <img title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>">
			                    <a class="docPreview" href="#" onclick="<%=onClick%>" >
			                        <span class="text"><%=Encode.forHtml(truncatedDisplayName)%></span>
			                    </a>
                            </span>
			               <span class="item-date">
			                    <a class="docPreview" href="#" onclick="<%=onClick%>" >
			                        <span><%=date%></span>
			                    </a></span>
		                   </div>
		                   <div style="clear:both;"></div>
		                   </div>
		                </li>
                    <%
                        if (idx == 8 && privatedocs.size() > 8) {
                    %>
                        <li><span onclick="doShow(this,'hiddenDoc');" style="color: #0088cc;"><bean:message key="global.expandall"/>&nbsp;<%=privatedocs.size()%></span></li>
	                <%
                        }
                        if (idx == privatedocs.size()-1  && privatedocs.size() > 8) {
                    %>

                        <li class="hiddenDoc"><span onclick="doHide(this,'hiddenDoc');" style="color: #0088cc;"><bean:message key="global.btnToggle"/></span></li>
	                <%
                        }
	                }
	            	if(labs.size() > 0){
	            	%>
            	<li><span class="h4"><bean:message key="caseload.msgLab"/></span>
                    <span class="tgl"><input class="tightCheckbox1" id="selectAlllab"
                        type="checkbox" onclick="$('[name=labNo]').prop('checked', $(this).prop('checked'));"
                        value="" title="<bean:message key="dms.incomingDocs.select" />/<bean:message key="admin.fieldNote.unselect" /> <bean:message key="oscarReport.LabReqReport.msgLabDocuments"/>."
                        style="margin: 0px; padding: 0px;" > <bean:message key="dms.documentReport.msgAll" />&nbsp;<%=labs.size()%></span>
                </li>
	            	<%
	            	}

	                LabResultData result;
	                String labDisplayName;
	                printImage = PRINTABLE_IMAGE;
	                printTitle = PRINTABLE_TITLE;
	                printAlt = PRINTABLE_ALT;
                    hiddenClass = "";
	                for(int idx = 0; idx < labs.size(); ++idx)
	                {
	                     result = labs.get(idx);
	                     if ( result.isMDS() ){
	                         url ="../../oscarMDS/SegmentDisplay.jsp?providerNo="+providerNo+"&segmentID="+result.segmentID+"&status="+result.getReportStatus();
	                         labDisplayName = result.getDiscipline();
	                     }else if (result.isCML()){
	                         url ="../../lab/CA/ON/CMLDisplay.jsp?providerNo="+providerNo+"&segmentID="+result.segmentID;
	                         labDisplayName = result.getDiscipline();
	                     }else if (result.isHL7TEXT()){
	                         // Modified display name to append the lab's date and time.
	                         labDisplayName = result.getDiscipline();
	                         url ="../../lab/CA/ALL/labDisplay.jsp?providerNo="+providerNo+"&segmentID="+result.segmentID;
	                     }else{
	                         url ="../../lab/CA/BC/labDisplay.jsp?segmentID="+result.segmentID+"&providerNo="+providerNo;
	                         labDisplayName = result.getDiscipline();
	                     }

	                     if(!org.apache.commons.lang.StringUtils.isEmpty(result.getLabel())) {
	                    	 labDisplayName = result.getLabel();
	                     }

	                     if (onIPad) {
	                         truncatedDisplayName = labDisplayName;
	                     }
	                     else {
	                         truncatedDisplayName = StringUtils.maxLenString(labDisplayName,13,10,"...");
	                     }
	                     date = DateUtils.getDate(result.getDateObj(), "dd-MMM-yyyy", request.getLocale());
          				 if (StringUtils.isNullOrEmpty(truncatedDisplayName)) { truncatedDisplayName = "(none)"; }
          				 if (idx > 8) { hiddenClass = "hiddenLab"; }
	                     %>
						    <li class="lab <%=hiddenClass%>" title="<%=labDisplayName%>" id="<%=docType[1]+result.segmentID%>">
						        <div>
							        <span class="item">
								        <input class="tightCheckbox1" type="checkbox"
			                               name="labNo" id="labNo<%=result.segmentID%>"
			                               value="<%=result.segmentID%>"
			                               style="margin: 0px; padding: 0px;" >
			                            <span class="url" style="display:none">
								               <a href="<%=url%>" title="<%=Encode.forHtmlAttribute(labDisplayName)%>" style="color: #CC0099; text-decoration: none;" target="_blank">
											   <img style="width:15px;height:15px" title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>" >
											<%=Encode.forHtml(truncatedDisplayName)%></a>
								        </span>
								        <img title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>">
								        <a class="labPreview" href="#" onclick="javascript:previewHTML('<%=url%>');">
								           <span class="text"><%=Encode.forHtml(truncatedDisplayName)%></span>
								        </a>

							        </span>
							        <span class="item-date">
							        	<a class="labPreview" href="#" onclick="javascript:previewHTML('<%=url%>');">
							            <span class="item-date"><%=date%></span>
							        </a>
							        </span>
							        <div style="clear:both;"></div>
						        </div>
						    </li>

                    <%
                        if (idx == 8 && labs.size() > 8) {
                    %>
                        <li><span onclick="doShow(this,'hiddenLab');" style="color: #0088cc;"><bean:message key="global.expandall"/>&nbsp;<%=labs.size()%></span></li>
	                <%
                        }
                        if (idx == labs.size()-1  && labs.size() > 8) {
                    %>

                        <li class="hiddenLab"><span onclick="doHide(this,'hiddenLab');" style="color: #0088cc;"><bean:message key="global.btnToggle"/></span></li>
	                <%
                        }
	                     }

					printImage = PRINTABLE_IMAGE;
					printTitle = PRINTABLE_TITLE;
					printAlt = PRINTABLE_ALT;

	                if(hrmDocumentToDemographicList.size() > 0) { %>
            	<li><span class="h4">HRM</span>
                    <span class="tgl"><input class="tightCheckbox1" id="selectAllHRM"
                        type="checkbox" onclick="$('[name=hrmNo]').prop('checked', $(this).prop('checked'));"
                        value="" title="<bean:message key="dms.incomingDocs.select" />/<bean:message key="admin.fieldNote.unselect" /> <bean:message key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.hrmDocuments"/>."
                        style="margin: 0px; padding: 0px;" > <bean:message key="dms.documentReport.msgAll" />&nbsp;<%=hrmDocumentToDemographicList.size()%></span>
                </li>
				<% 	}

					List<HRMDocument> docs = new ArrayList<HRMDocument>();

					for (HRMDocumentToDemographic hrmDocumentToDemographic : hrmDocumentToDemographicList)
					{
					    List<HRMDocument> documents =  hrmDocumentDao.findById(Integer.valueOf(hrmDocumentToDemographic.getHrmDocumentId()));
						if (documents!=null && !documents.isEmpty()){
							docs.add(documents.get(0));
						}
					}

					Collections.sort(docs, new Comparator<HRMDocument>() {
						@Override
						public int compare(HRMDocument o1, HRMDocument o2) {
							return o2.getReportDate().after(o1.getReportDate()) ? 1 : -1;
						}
					});

                    hiddenClass = "";
                    Integer idx = 0;
	                //For each hrmDocumentToDemographic in the list
	                for (HRMDocument hrmDocument : docs) {

						//Declares the displayName variable
	                	String hrmDisplayName;
	                	//If the HRM document has a description
	                	if (hrmDocument.getDescription() != null && !hrmDocument.getDescription().equals("")) {
	                		//Set the displayName to the description if it is present
	                		hrmDisplayName = hrmDocument.getDescription();
	                	}
	                	else {
	                		//Sets the displayName to the reportType if there is no description
	                		hrmDisplayName = hrmDocument.getReportType();
	                	}

	                	if (onIPad){
	                		truncatedDisplayName = hrmDisplayName;
	                	}
	                	else {
	                		truncatedDisplayName = StringUtils.maxLenString(hrmDisplayName,13,10,"...");
	                	}
	                	//Gets the url for the display of the HRM Report
	                	url = request.getContextPath() + "/hospitalReportManager/Display.do?id=" + hrmDocument.getId() + "&segmentID=" + hrmDocument.getId() + "&duplicateLabIds=";
	                	//Gets the report date
	                	date = DateUtils.getDate(hrmDocument.getReportDate(), "dd-MMM-yyyy", request.getLocale());
          				if (idx > 8) { hiddenClass = "hiddenHRM"; }
	                	%>
		                	<li class="hrm <%=hiddenClass%>" title="<%=Encode.forHtmlAttribute(hrmDisplayName)%>" id="hrm<%=hrmDocument.getId()%>">
								<div>
									<span class="item">
										<input class="tightCheckbox1" type="checkbox" name="hrmNo" id="hrmNo<%=hrmDocument.getId()%>" value="<%=hrmDocument.getId()%>" style="margin: 0px; padding: 0px;" >
										<span class="url" style="display:none">
											<a href="<%=url%>" title="<%=Encode.forHtmlAttribute(hrmDisplayName)%>" style="color: red; text-decoration: none;" target="_blank">
											<img style="width:15px;height:15px" title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>" >
											<%=Encode.forHtml(truncatedDisplayName)%></a>
										</span>
										<img title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>">
										<a class="hrmPreview" href="#" onclick="javascript:previewHTML('<%=url%>');">
											<span class="text"><%=Encode.forHtml(truncatedDisplayName)%></span>
										</a>

									</span>
									<span class="item-date">
										<a class="hrmPreview" href="#" onclick="javascript:previewHTML('<%=url%>');">
											<span class="item-date"><%=date%></span>
										 </a>
									</span>
									<div style="clear:both;"></div>
								</div>
					    	</li>
                    <%
                        if (idx == 8 && docs.size() > 8) {
                    %>
                        <li onclick="doShow(this,'hiddenHRM');" style="color: #0088cc;"><bean:message key="global.expandall"/>&nbsp;<%=docs.size()%></li>
	                <%
                        }
                        if (idx == docs.size()-1  && docs.size() > 8) {
                    %>

                        <li class="hiddenHRM" onclick="doHide(this,'hiddenHRM');" style="color: #0088cc;"><bean:message key="global.btnToggle"/></li>
	                <%
                        }
                    idx=idx+1;
					}

					SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy", request.getLocale());
                    hiddenClass = "";
                    idx = 0;
					//Get eforms
					eForms= EFormUtil.listPatientEformsCurrent(new Integer(demoNo), true, 0, 100);
					if (!eForms.isEmpty()) { %>

            	<li><span class="h4"><bean:message key="global.eForms"/></span>
                    <span class="tgl"><input class="tightCheckbox1" id="selectAllHRM"
                        type="checkbox" onclick="$('[name=eFormNo]').prop('checked', $(this).prop('checked'));"
                        value="" title="<bean:message key="dms.incomingDocs.select" />/<bean:message key="admin.fieldNote.unselect" /> <bean:message key="global.eForms"/>."
                        style="margin: 0px; padding: 0px;" > <bean:message key="dms.documentReport.msgAll" />&nbsp;<%=eForms.size()%></span>
                </li>
					<% }
					for (EFormData eForm : eForms) {
						url = request.getContextPath() + "/eform/efmshowform_data.jsp?fdid="+eForm.getId();
          				if (idx > 8) { hiddenClass = "hiddeneForm"; }
					%>
						<li class="eForm <%=hiddenClass%>" title="<%=eForm.getFormName()%>" id="eForm<%=eForm.getId()%>">
							<div>
								<span class="item">
									<input class="tightCheckbox1" type="checkbox" name="eFormNo" id="eFormNo<%=eForm.getId()%>" value="<%=eForm.getId()%>" style="margin: 0px; padding: 0px;" >
									<span class="url" style="display:none">
															<a href="<%=url%>" title="<%=Encode.forHtmlAttribute(eForm.getFormName())%>" style="color: #917611; text-decoration: none;" target="_blank">
															<img style="width:15px;height:15px" title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>" >
															<%=Encode.forHtml(eForm.getFormName())%></a>
														</span>
									<img title="<%= printTitle %>" src="<%= printImage %>" alt="<%= printAlt %>">
									<a class="eFormPreview" href="#" onclick="javascript:previewHTML('<%=url%>', true);">
										<span class="text"><%=(eForm.getFormName().length()>13)?Encode.forHtml(eForm.getFormName()).substring(0, 10)+"...":Encode.forHtml(eForm.getFormName())%></span>
									</a>

								</span>
								<span class="item-date">
									<a class="eFormPreview" href="#" onclick="javascript:previewHTML('<%=url%>', true);">
										<span class="item-date"><%=sdf.format(eForm.getFormDate())%></span>
									</a>
								</span>
								<div style="clear:both;"></div>
							</div>
						</li>
                    <%
                        if (idx == 8 && eForms.size() > 8) {
                    %>
                        <li><span onclick="doShow(this,'hiddeneForm');" style="color: #0088cc;"><bean:message key="global.expandall"/>&nbsp;<%=eForms.size()%></span></li>
	                <%
                        }
                        if (idx == eForms.size()-1  && eForms.size() > 8) {
                    %>

                        <li class="hiddeneForm"><span onclick="doHide(this,'hiddeneForm');" style="color: #0088cc;"><bean:message key="global.btnToggle"/></span></li>
	                <%
                        }
                    idx=idx+1;
					}
				} %>

            </ul>
            <input type="submit" class="btn" style="position: absolute; left: 35px; bottom: 5px;"
                name="submit"
                value="<bean:message key="oscarEncounter.oscarConsultationRequest.AttachDocPopup.submit" />"
                onclick="return save();" >
            </td>
            <td style="background-color:white; position:relative; text-align:left;"><iframe id="previewPane" style="width:100%; height: 600px; overflow: auto; border:0;" ></iframe></td>
		</tr>
	</table>
</html:form>
</body>
</html:html>