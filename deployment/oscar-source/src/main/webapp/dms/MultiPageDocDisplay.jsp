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

<%@page import="org.oscarehr.util.LoggedInInfo"%>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>" objectName="_edoc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_edoc");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>

<%@ page import="java.util.*" %>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="org.springframework.web.context.WebApplicationContext"%>

<%@ page import="org.oscarehr.common.model.Tickler" %>
<%@ page import="org.oscarehr.managers.TicklerManager" %>
<%@ page import="org.oscarehr.common.dao.*"%>
<%@ page import="org.oscarehr.common.model.*"%>
<%@ page import="org.oscarehr.PMmodule.dao.ProviderDao"%>
<%@ page import="org.oscarehr.util.LoggedInInfo" %>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.phr.util.MyOscarUtils"%>
<%@ page import="org.oscarehr.myoscar.utils.MyOscarLoggedInInfo"%>
<%@ page import="org.oscarehr.util.WebUtils"%>

<%@ page import="oscar.dms.*" %>
<%@ page import="oscar.oscarLab.ca.all.*"%>
<%@ page import="oscar.oscarMDS.data.*"%>
<%@ page import="oscar.oscarLab.ca.all.util.*"%>
<%@ page import="oscar.oscarDemographic.data.DemographicData" %>
<%@ page import="oscar.SxmlMisc" %>
<%@ page import="oscar.util.StringUtils" %>
<%@ page import="oscar.util.UtilDateUtilities"%>
<%@ page import="org.owasp.encoder.Encode" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite"%>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<jsp:useBean id="displayServiceUtil" scope="request" class="oscar.oscarEncounter.oscarConsultationRequest.config.pageUtil.EctConDisplayServiceUtil" />
<%
            LoggedInInfo loggedInInfo=LoggedInInfo.getLoggedInInfoFromSession(request);
            ResourceBundle oscarRec = ResourceBundle.getBundle("oscarResources", request.getLocale());
            WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
            ProviderInboxRoutingDao providerInboxRoutingDao = (ProviderInboxRoutingDao) ctx.getBean("providerInboxRoutingDAO");
            ProviderDao providerDao = (ProviderDao) ctx.getBean("providerDao");
            DemographicDao demographicDao = (DemographicDao)ctx.getBean("demographicDao");

            String demoName, documentNo,providerNo,searchProviderNo,status;

             demoName=(String)request.getAttribute("demoName");
             documentNo = (String)request.getAttribute("segmentID");
             providerNo = (String)request.getAttribute("providerNo");
             searchProviderNo = (String)request.getAttribute("searchProviderNo");
             status = (String)request.getAttribute("status");
            if(demoName==null && documentNo==null &&providerNo==null &&searchProviderNo==null &&status==null ){
                         demoName=request.getParameter("demoName");
                         documentNo = request.getParameter("segmentID");
                         providerNo = request.getParameter("providerNo");
                         searchProviderNo = request.getParameter("searchProviderNo");
                         status = request.getParameter("status");
            }

            Provider provider = providerDao.getProvider(providerNo);
            String creator = (String) session.getAttribute("user");
            ArrayList doctypes = EDocUtil.getActiveDocTypes("demographic");
            EDoc curdoc = EDocUtil.getDoc(documentNo);

            String demographicID = curdoc.getModuleId();

            if(demoName == null || "".equals(demoName)) {
            	Demographic d = demographicDao.getDemographic(demographicID);
            	if(d != null) {
            		demoName = d.getFormattedName();
            	}
            }

            String docId = curdoc.getDocId();
            int tabindex = 0;
            int slash = 0;
            String contentType = "";
            if ((slash = curdoc.getContentType().indexOf('/')) != -1) {
                contentType = curdoc.getContentType().substring(slash + 1);
            }
            String dStatus = "";
            if ((curdoc.getStatus() + "").compareTo("A") == 0) {
                dStatus = "active";
            } else if ((curdoc.getStatus() + "").compareTo("H") == 0) {
                dStatus = "html";
            }
            int numOfPage=curdoc.getNumberOfPages();
            String numOfPageStr="";
            if(numOfPage==0)
                numOfPageStr="unknown";
            else
                numOfPageStr=(new Integer(numOfPage)).toString();
            String url = request.getContextPath()+"/dms/ManageDocument.do?method=viewDocPage&doc_no=" + docId+"&curPage=1";
            String url2 = request.getContextPath()+"/dms/ManageDocument.do?method=display&doc_no=" + docId;


    displayServiceUtil.estSpecialist();
    String providerNoFromChart = null;
    String demoNo = request.getParameter("demographicNo");
    DemographicData demoData = null;
    Demographic demographic = null;
    String familyDoctor = null;
    String rdohip = "";

    if (demoNo != null) {
        demoData = new oscar.oscarDemographic.data.DemographicData();
        demographic = demoData.getDemographic(loggedInInfo, demoNo);

        providerNoFromChart = demographic.getProviderNo();

        familyDoctor = demographic.getFamilyDoctor();
        if (familyDoctor != null && familyDoctor.trim().length() > 0) {
            rdohip = SxmlMisc.getXmlContent(familyDoctor, "rdohip");
            rdohip = rdohip == null ? "" : rdohip.trim();
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
    <title><bean:message key='global.Document'/></title>
<!-- i18n calendar -->
    <script src="<%=request.getContextPath()%>/share/calendar/calendar.js"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/lang/<bean:message key='global.javascript.calendar'/>"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/calendar-setup.js"></script>
    <link href="<%=request.getContextPath()%>/share/calendar/calendar.css" title="win2k-cold-1" rel="stylesheet" type="text/css" media="all" >

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-ui-1.12.1.min.js"></script>

<!-- oscar -->
    <script src="<%=request.getContextPath()%>/share/javascript/Oscar.js" ></script>
    <script src="<%=request.getContextPath()%>/share/javascript/casemgmt/faxControl.js"> </script>
    <script src="<%=request.getContextPath()%>/js/demographicProviderAutocomplete.js"></script>
    <script src="<%=request.getContextPath()%>/js/documentDescriptionTypeahead.js"></script>
    <script src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>

<!-- yui -->
    <script src="<%=request.getContextPath()%>/share/yui/js/yahoo-dom-event.js"></script>
    <script src="<%=request.getContextPath()%>/share/yui/js/connection-min.js"></script>
    <script src="<%=request.getContextPath()%>/share/yui/js/animation-min.js"></script>
    <script src="<%=request.getContextPath()%>/share/yui/js/datasource-min.js"></script>
    <script src="<%=request.getContextPath()%>/share/yui/js/autocomplete-min.js"></script>

<!-- css -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->

    <link href="<%=request.getContextPath()%>/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/share/yui/css/autocomplete.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/share/css/demographicProviderAutocomplete.css" rel="stylesheet" media="all" >
    <link href="<%=request.getContextPath()%>/share/yui/css/fonts-min.css" rel="stylesheet" >
        <style>
        	.multiPage {
        		background-color: RED;
        		color: WHITE;
        		font-weight:bold;
				padding: 0px 5px;
				font-size: medium;
        	}
        	.singlePage {

        	}
        	.FieldData {
font-size: 14px;

        	}

        </style>

        <script>

        	//?segmentID=1&providerNo=999998&searchProviderNo=999998&status=A&demoName=
       	   function checkDelete(url, docDescription){
        	// revision Apr 05 2004 - we now allow anyone to delete documents
        	  if(confirm("<bean:message key="dms.documentReport.msgDelete"/> " + docDescription)) {
        	    window.location = url;
        	  }
        	}

			<%
				if(request.getParameter("delDocumentNo") != null) {
					EDocUtil.deleteDocument(request.getParameter("delDocumentNo"));
					%>
						if(window.opener != null) {
							window.opener.location.reload();
						}
						window.close();
					<%
				}
			%>
        </script>

    </head>
    <body >
        <div id="labdoc_<%=docId%>">
            <table class="docTable">
                <tr>
                    <td>
                        <div style="text-align: right; font-weight: bold">
                        <% if( numOfPage > 1 ) {%>
                        <a id="firstP" style="display: none;" href="javascript:void(0);" onclick="firstPage('<%=docId%>');"><bean:message key='global.First'/></a>
                        <a id="prevP" style="display: none;" href="javascript:void(0);" onclick="prevPage('<%=docId%>');"><bean:message key='global.Prev'/></a>
                        <a id="nextP" href="javascript:void(0);" onclick="nextPage('<%=docId%>');"><bean:message key='global.Next'/></a>
                        <a id="lastP" href="javascript:void(0);" onclick="lastPage('<%=docId%>');"><bean:message key='global.Last'/></a>&nbsp;&nbsp;
                        <%}%>
                        </div>
                        <a href="<%=url2%>" ><img alt="document" src="<%=url%>" id="docImg_<%=docId%>" ></a>
                   </td>
                    <td style="vertical-align:top; text-align:left">
                        <fieldset><legend><bean:message key="inboxmanager.document.PatientMsg"/><%=demoName%> </legend>
                            <table style="border-width:0px;">
                                <tr>
                                    <td><bean:message key="inboxmanager.document.DocumentUploaded"/></td>
                                    <td><%=curdoc.getDateTimeStamp()%></td>
                                </tr>
                                <tr>
                                    <td><bean:message key="inboxmanager.document.ContentType"/></td>
                                    <td><%=contentType%></td>
                                </tr>
                                <tr>
                                    <td><bean:message key="inboxmanager.document.NumberOfPages"/></td>
                                    <td><span id="viewedPage_<%=docId%>" class="<%= numOfPage > 1 ? "multiPage" : "singlePage" %>">1</span>&nbsp; <bean:message key="global.of"/> &nbsp;<span id="numPages_<%=docId %>" class="<%= numOfPage > 1 ? "multiPage" : "singlePage" %>"><%=numOfPageStr%></span></td>
                                </tr>
                                <tr>
                                    <td><bean:message key="dms.documentReport.msgCreator"/>:</td>
                                    <td><%=curdoc.getCreatorName()%></td>
                                </tr>
                            </table>

                            <form id="forms_<%=docId%>" onsubmit="return updateDocument(this.id);" >
                                <input type="hidden" name="method" value="documentUpdate" >
                                <input type="hidden" name="documentId" value="<%=docId%>" >
                                <input type="hidden" name="providerNo" value="<%=providerNo%>" >
                                <input type="hidden" name="searchProviderNo" value="<%=searchProviderNo%>" >
                                <input type="hidden" name="status" value="<%=status%>" >
                                <table style="border-width:0px;">
                                    <tr>
                                        <td><bean:message key="dms.documentReport.msgDocType"/>:</td>
                                        <td>
                                            <select tabindex="<%=tabindex++%>" name ="docType" id="docType">
                                                <option value=""><bean:message key="dms.addDocument.formSelect"/></option>
                                                <%for (int j = 0; j < doctypes.size(); j++) {
                String doctype = (String) doctypes.get(j);%>
                                                <option value="<%= doctype%>" <%=(curdoc.getType().equals(doctype)) ? " selected" : ""%>><%= doctype%></option>
                                                <%}%>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><bean:message key="dms.documentReport.msgDocDesc"/>:</td>
                                        <td>
                                            <input id="docDesc_<%=docId%>" tabindex="<%=tabindex++%>"  type="text" name="documentDescription" value="<%=curdoc.getDescription()%>" >
                                            <div id="docDescTypeahead_<%=docId%>" class="autocomplete"></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><bean:message key="inboxmanager.document.ObservationDateMsg"/></td>
                                        <td class="input-append" id="invoke-cal">
                                            <input tabindex="<%=tabindex++%>" style="width:90px"  id="observationDate<%=docId%>" name="observationDate" type="text" value="<%=curdoc.getObservationDate()%>" pattern="^\d{4}(-|/)((0\d)|(1[012]))(-|/)(([012]\d)|3[01])$" autocomplete="off">
                                            <span class="add-on"><i class="icon-calendar"></i></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><bean:message key="inboxmanager.document.DemographicMsg"/>
                                        </td>
                                        <td><%if(!demographicID.equals("-1")){%>
                                            <input id="saved<%=docId%>" type="hidden" name="saved" value="true" >
                                            <input type="hidden" value="<%=demographicID%>" name="demog" id="demofind<%=docId%>" >
                                            <%=demoName%><%}else{%>
                                            <input id="saved<%=docId%>" type="hidden" name="saved" value="false" >
                                            <input type="hidden" name="demog" value="<%=demographicID%>" id="demofind<%=docId%>" >
                                            <input tabindex="<%=tabindex++%>" type="text" id="autocompletedemo<%=docId%>" onchange="checkSave('<%=docId%>')" name="demographicKeyword" >
                                            <div id="autocomplete_choices<%=docId%>"class="autocomplete"></div>
                                            <%}%>

                                            <input id="mrp_<%=docId%>" tabindex="<%=tabindex++%>" onclick="sendMRP(this)" type="checkbox" name="demoLink" ><bean:message key="inboxmanager.document.SendToMRPMsg"/>
                                            <a id="mrp_fail_<%=docId%>" style="color:red; font-style:italic; display:none;" ><bean:message key="inboxmanager.document.SendToMRPFailedMsg"/></a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align:top"><bean:message key="inboxmanager.document.FlagProviderMsg"/>  </td>
                                        <td>
                                            <input type="hidden" name="provi" id="provfind<%=docId%>" >
                                            <input tabindex="<%=tabindex++%>" type="text" id="autocompleteprov<%=docId%>" name="demographicKeyword" >
                                            <div id="autocomplete_choicesprov<%=docId%>" class="autocomplete"></div>

                                            <script>
                                            jQuery.noConflict();
                                            Calendar.setup( { inputField : "observationDate<%=docId%>", ifFormat : "%Y-%m-%d", showsTime :false, button : "invoke-cal", singleClick : true, step : 1 } );
                                            function addDocComment(docId, status) {
                                            	var url="<%=request.getContextPath()%>/oscarMDS/UpdateStatus.do";
                                            	var formid = "#acknowledgeForm_" + docId;

                                            	jQuery("#ackStatus").val(status);
                                            	var data= jQuery(formid).serialize();
                                            	data += "&method=addComment";

                                            	jQuery.ajax({
                                            		type: "POST",
                                            		url: url,
                                            		data: data,
                                            		success: function(data) {
                                            			window.location.reload();
                                            		}
                                            	});

                                            }


                                            function forwardDocument(docId) {
                                            	var frm = "#reassignForm_" + docId;
                                            	var query = jQuery(frm).serialize();

                                            	jQuery.ajax({
                                            		type: "POST",
                                            		url:  "<%=request.getContextPath()%>/oscarMDS/ReportReassign.do",
                                            		data: query,
                                            		success: function (data) {
                                            			window.location.reload();
                                            		},
                                            		error: function(jqXHR, err, exception) {
                                            			alert(jqXHR.status);
                                            		}
                                            	});
                                            }

                                                var curPage=1;
                                                var totalPage=<%=numOfPage%>;
                                                showPageImg=function(docid,pn){
                                                    if(docid&&pn){
                                                        var e=document.getElementById('docImg_'+docid);
                                                        var url='<%=request.getContextPath()%>'+'/dms/ManageDocument.do?method=viewDocPage&doc_no='
                                                            +docid+'&curPage='+pn;
                                                        e.setAttribute('src',url);
                                                    }
                                                }
                                                nextPage=function(docid){
                                                    curPage++;

                                                    	document.getElementById('viewedPage_'+docid).innerHTML = curPage;
                                                        showPageImg(docid,curPage);
                                                        if(curPage==totalPage){
                                                            hideNext();
                                                            showPrev();
                                                        } else{
                                                            showNext();
                                                            showPrev();
                                                        }
                                                }
                                                prevPage=function(docid){
                                                    curPage--;
                                                    if(curPage<1){
                                                        curPage=1;
                                                        hidePrev();
                                                    }
                                                    document.getElementById('viewedPage_'+docid).innerHTML = curPage;
                                                        showPageImg(docid,curPage);
                                                       if(curPage==1){
                                                           hidePrev();
                                                           showNext();
                                                        }else{
                                                            showPrev();
                                                            showNext();
                                                        }

                                                }
                                                firstPage=function(docid){
                                                    curPage=1;
                                                    document.getElementById('viewedPage_'+docid).innerHTML = 1;
                                                    showPageImg(docid,curPage);
                                                    hidePrev();
                                                    showNext();
                                                }
                                                lastPage=function(docid){
                                                    curPage=totalPage;
                                                    document.getElementById('viewedPage_'+docid).innerHTML = totalPage;
                                                    showPageImg(docid,curPage);
                                                    hideNext();
                                                    showPrev();
                                                }
                                                hidePrev=function(){
                                                    //disable previous link
                                                    document.getElementById("prevP").style.display = 'none';
                                                    document.getElementById("firstP").style.display = 'none';
                                                    document.getElementById("prevP2").style.display = 'none';
                                                    document.getElementById("firstP2").style.display = 'none';
                                                }
                                                hideNext=function(){
                                                    //disable next link
                                                    document.getElementById("nextP").style.display = 'none';
                                                    document.getElementById("lastP").style.display = 'none';
                                                    document.getElementById("nextP2").style.display = 'none';
                                                    document.getElementById("lastP2").style.display = 'none';
                                                }
                                                showPrev=function(){
                                                    //disable previous link
                                                    document.getElementById("prevP").style.display = 'inline';
                                                    document.getElementById("firstP").style.display = 'inline';
                                                    document.getElementById("prevP2").style.display = 'inline';
                                                    document.getElementById("firstP2").style.display = 'inline';
                                                }
                                                showNext=function(){
                                                    //disable next link
                                                    document.getElementById("nextP").style.display = 'inline';
                                                    document.getElementById("lastP").style.display = 'inline';
                                                    document.getElementById("nextP2").style.display = 'inline';
                                                    document.getElementById("lastP2").style.display = 'inline';
                                                }
                                                popupStart=function(vheight,vwidth,varpage,windowname) {
                                                    oscarLog("in popupStart ");
                                                    if(!windowname)
                                                        windowname="helpwindow";
                                                    var page = varpage;
                                                    var windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
                                                    oscarLog(varpage);
                                                    oscarLog(windowname);
                                                    oscarLog(windowprops);
                                                    var popup=window.open(varpage, windowname, windowprops);
                                                }
                                                YAHOO.example.BasicRemote = function() {
                                                        var url = "<%=request.getContextPath()%>/provider/SearchProvider.do";
                                                        var oDS = new YAHOO.util.XHRDataSource(url,{connMethodPost:true,connXhrMode:'ignoreStaleResponses'});
                                                        oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;// Set the responseType
                                                        // Define the schema of the delimited resultsTEST, PATIENT(1985-06-15)
                                                        oDS.responseSchema = {
                                                            resultsList : "results",
                                                            fields : ["providerNo","firstName","lastName"]
                                                        };
                                                        // Enable caching
                                                        oDS.maxCacheEntries = 0;
                                                        //oDS.connXhrMode ="cancelStaleRequests";
                                                        //oscarLog("autocompleteprov<%=docId%>");
                                                        //oscarLog("autocomplete_choicesprov<%=docId%>");
                                                        //oscarLog(document.getElementById("autocompleteprov<%=docId%>"));
                                                        //oscarLog(document.getElementById("autocomplete_choicesprov<%=docId%>"));
                                                        // Instantiate the AutoComplete
                                                        var oAC = new YAHOO.widget.AutoComplete("autocompleteprov<%=docId%>", "autocomplete_choicesprov<%=docId%>", oDS);
                                                        oAC.queryMatchSubset = true;
                                                        oAC.minQueryLength = 3;
                                                        oAC.maxResultsDisplayed = 25;
                                                        oAC.formatResult = resultFormatter3;
                                                        //oAC.typeAhead = true;
                                                        oAC.queryMatchContains = true;
                                                        oscarLog(oAC);
                                                        oscarLog(oAC.itemSelectEvent);
                                                        oAC.itemSelectEvent.subscribe(function(type, args) {
                                                            oscarLog(args);
                                                           var myAC = args[0];
                                                           var str = myAC.getInputEl().id.replace("autocompleteprov","provfind");
                                                           oscarLog(str);
                                                           oscarLog(args[2]);
                                                           var oData=args[2];
                                                           document.getElementById(str).value = args[2][0];//li.id;
                                                           oscarLog("str value="+document.getElementById(str).value);
                                                           oscarLog(args[2][1]+"--"+args[2][0]);
                                                           myAC.getInputEl().value = args[2][2] + ","+args[2][1];
                                                           oscarLog("--"+args[0].getInputEl().value);
                                                           //selectedDemos.push(args[0].getInputEl().value);

                                                           //enable Save button whenever a selection is made
                                                            var bdoc = document.createElement('a');
                                                            bdoc.setAttribute("id", "removeProv<%=docId%>");
                                                            bdoc.setAttribute("onclick", "removeProv(this);");
                                                            bdoc.appendChild(document.createTextNode(" -remove- "));
                                                            oscarLog("--");
                                                            var adoc = document.createElement('div');
                                                            adoc.appendChild(document.createTextNode(oData[2] + " " +oData[1]));
                                                            oscarLog("--==");
                                                            var idoc = document.createElement('input');
                                                            idoc.setAttribute("type", "hidden");
                                                            idoc.setAttribute("name","flagproviders");
                                                            idoc.setAttribute("value",oData[0]);
                                                            //console.log(oData[0]);
                                                            //console.log(myAC);
                                                         //   console.log(elLI);
                                                         //   console.log(oData);
                                                         //   console.log(aArgs);
                                                         //   console.log(sType);
                                                            adoc.appendChild(idoc);

                                                            adoc.appendChild(bdoc);
                                                            var providerList = document.getElementById('providerList<%=docId%>');
                                                        //    console.log('Now HERE'+providerList);
                                                            providerList.appendChild(adoc);

                                                            myAC.getInputEl().value = '';//;oData.fname + " " + oData.lname ;

                                                        });


                                                        return {
                                                            oDS: oDS,
                                                            oAC: oAC
                                                        };
                                                    }();
                                                    refreshParent=function(){
                                                        if(window.opener != null) {
                                                            if (window.opener.autoSave) {
                                                                window.opener.autoSave(true);
                                                            }
						                                }
                                                    }
                                                    updateStatus=function(formid){
                                                    var num=formid.split("_");
                                                        var doclabid=num[1];
                                                        if(doclabid){
                                                            var demoId=document.getElementById('demofind'+doclabid).value;
                                                            var saved=document.getElementById('saved'+doclabid).value;
                                                            if(demoId=='-1'|| saved=='false' ||saved==false){
                                                                alert('Document is not assigned to a patient,please file it');
                                                            }else{
                                                                var url='<%=request.getContextPath()%>'+"/oscarMDS/UpdateStatus.do";
                                                                var data=jQuery("#"+formid).serialize(true);
                                                                jQuery.ajax( {
                                                  	                type: "POST",
                                                  	                url: url,
                                                                    data: data,
                                                                    success: function(transport) {
                                                                        refreshParent();
                                                                        window.close();
	                                                                }
                                                                });

                                                           }
                                                        }
                                                   }

                                        fileDoc=function(docId){
                                           if(docId){
                                                docId=docId.replace(/\s/,'');
                                             if(docId.length>0){
                                                    var demoId=document.getElementById('demofind'+docId).value;
                                                    var saved=document.getElementById('saved'+docId).value;
                                                    var isFile=true;
                                                     if(demoId=='-1' || saved=='false' ||saved==false){
                                                        isFile=confirm('Document is not assigned and saved to any patient, do you still want to file it?');
                                                                }
                                                     if(isFile) {
                                                             var type='DOC';
                                                             if(type){
                                                                var url='<%=request.getContextPath()%>'+'/oscarMDS/FileLabs.do';
                                                                var data='method=fileLabAjax&flaggedLabId='+docId+'&labType='+type;
                                                                jQuery.ajax( {
                                                  	                type: "POST",
                                                  	                url: url,
                                                                    data: data,
                                                                    success: function(transport) {
                                                                        refreshParent();
                                                                        window.close();
	                                                                }
                                                                });
                                                    }
                                                    }
                                              }
                                           }
                                       }
function sendMRP(ele){
                                                var doclabid=ele.id;
                                                doclabid=doclabid.split('_')[1];
                                                var demoId=document.getElementById('demofind'+doclabid).value;
                                            if(demoId=='-1'){
                                                alert('Please enter a valid demographic');
                                                ele.checked=false;
                                            }else{
                                                if(confirm('Send to Most Responsible Provider?')){
                                                    var type='DOC';
                                                    var url= "<%=request.getContextPath()%>/oscarMDS/SendMRP.do";
                                                    var data='demoId='+demoId+'&docLabType='+type+'&docLabId='+doclabid;
                                                	jQuery.ajax({
                                                		type: "POST",
                                                		url:  url,
                                                		data: data,
                                                		success: function (transport) {
                                                			ele.disabled=true;
                                                			document.getElementById('mrp_fail_'+doclabid).style.display = 'none';
                                                		},
                                                		error: function(jqXHR, err, exception) {
                                                			ele.checked=false;
                                                            document.getElementById('mrp_fail_'+doclabid).style.display = '';
                                                            console.log(jqXHR.status);
                                                		}
                                                	});
                                                }else{
                                                    ele.checked=false;
                                                }
                                             }
                                          }

                                        YAHOO.example.BasicRemote = function() {
                                          if(document.getElementById("autocompletedemo<%=docId%>") && document.getElementById("autocomplete_choices<%=docId%>")){
                                                 oscarLog('in basic remote');
                                                //var oDS = new YAHOO.util.XHRDataSource("http://localhost:8080/drugref2/test4.jsp");
                                                var url = "../demographic/SearchDemographic.do";
                                                var oDS = new YAHOO.util.XHRDataSource(url,{connMethodPost:true,connXhrMode:'ignoreStaleResponses'});
                                                oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;// Set the responseType
                                                // Define the schema of the delimited resultsTEST, PATIENT(1985-06-15)
                                                oDS.responseSchema = {
                                                    resultsList : "results",
                                                    fields : ["formattedName","fomattedDob","demographicNo","status"]
                                                };
                                                // Enable caching
                                                oDS.maxCacheEntries = 0;
                                                //oDS.connXhrMode ="cancelStaleRequests";
                                                //oscarLog("autocompletedemo<%=docId%>");
                                                //oscarLog("autocomplete_choices<%=docId%>");

                                                //var elinput=window.frames[0].document.getElementById("autocompletedemo<%=docId%>");
                                                //var elcontainer=window.frames[0].document.getElementById("autocomplete_choices<%=docId%>");
                                                //oscarLog('elinput='+elinput+';elcontainer='+elcontainer);
                                                // Instantiate the AutoComplete
                                                //var oAC = new YAHOO.widget.AutoComplete("autocompletedemo<%=docId%>", "autocomplete_choices<%=docId%>", oDS);
                                                var oAC = new YAHOO.widget.AutoComplete("autocompletedemo<%=docId%>","autocomplete_choices<%=docId%>",oDS);
                                                //oscarLog('oAc='+oAC);
                                                //oscarLog('oDs='+oDS);
                                                //oscarLog('resultFormatter2='+resultFormatter2);
                                                oAC.queryMatchSubset = true;
                                                oAC.minQueryLength = 3;
                                                oAC.maxResultsDisplayed = 25;
                                                oAC.formatResult = resultFormatter2;
                                                //oAC.typeAhead = true;
                                                oAC.queryMatchContains = true;
                                                //oscarLog(oAC);
                                                //oscarLog(oAC.itemSelectEvent);
                                                oAC.itemSelectEvent.subscribe(function(type, args) {
                                                    //oscarLog(args);
                                                    //oscarLog(args[0].getInputEl().id);
                                                    var str = args[0].getInputEl().id.replace("autocompletedemo","demofind");
                                                   //oscarLog(str);
                                                   document.getElementById(str).value = args[2][2];//li.id;
                                                   //oscarLog("str value="+document.getElementById(str).value);
                                                   //oscarLog(args[2][1]+"--"+args[2][0]);
                                                   args[0].getInputEl().value = args[2][0] + "("+args[2][1]+")";
                                                   //oscarLog("--"+args[0].getInputEl().value);
                                                   selectedDemos.push(args[0].getInputEl().value);
                                                   //enable Save button whenever a selection is made
                                                   document.getElementById('save<%=docId%>').removeAttribute('disabled');

                                                });


                                                return {
                                                    oDS: oDS,
                                                    oAC: oAC
                                                };
                                            }
                                            }();

                function updateDocument(eleId){
                    if (!checkObservationDate(eleId)) {
                        return false;
                    }
                    //save doc info
                    var url='<%=request.getContextPath()%>'+"/dms/ManageDocument.do";
                    var data=jQuery('#'+eleId).serialize();
                    jQuery.ajax( {
      	                type: "POST",
      	                url: url,
                        data: data,
                        success: function(transport) {
                            var ar=eleId.split("_");
                            var num=ar[1];
                            num=num.replace(/\s/g,''); //trim
                            if(document.getElementById("saveSucessMsg_"+num)){
                                document.getElementById("saveSucessMsg_"+num).style.display = '';
                            }
                            if(document.getElementById('saved'+num)){
                                document.getElementById('saved'+num).value='true';
                            }
                            if(document.getElementById('autocompletedemo'+num)){
                                document.getElementById('autocompletedemo'+num).disabled=true;
                            }
                            if(document.getElementById('removeProv'+num)){
                                document.getElementById('removeProv'+num).remove();
                            }
                            refreshParent();
	                    }
                    });
                    return false;
                }

                        function checkObservationDate(formid) {
                            // regular expression to match required date format
                            re = /^\d{4}\-\d{1,2}\-\d{1,2}$/;
                            re2 = /^\d{4}\/\d{1,2}\/\d{1,2}$/;

                            var form = document.getElementById(formid);
                            if(form.elements["observationDate"].value == "") {
                            	alert("Blank Date: " + form.elements["observationDate"].value);
                        		form.elements["observationDate"].focus();
                        		return false;
                            }

                            if(!form.elements["observationDate"].value.match(re)) {
                            	if(!form.elements["observationDate"].value.match(re2)) {
                            		alert("Invalid date format: " + form.elements["observationDate"].value);
                            		form.elements["observationDate"].focus();
                            		return false;
                            	} else if(form.elements["observationDate"].value.match(re2)) {
                            		form.elements["observationDate"].value=form.elements["observationDate"].value.replace("/","-");
                            		form.elements["observationDate"].value=form.elements["observationDate"].value.replace("/","-");
                            	}
                            }
                            regs= form.elements["observationDate"].value.split("-");
                            // day value between 1 and 31
                            if(regs[2] < 1 || regs[2] > 31) {
                              alert("Invalid value for day: " + regs[2]);
                              form.elements["observationDate"].focus();
                              return false;
                            }
                            // month value between 1 and 12
                            if(regs[1] < 1 || regs[1] > 12) {
                              alert("Invalid value for month: " + regs[1]);
                              form.elements["observationDate"].focus();
                              return false;
                            }
                            // year value between 1902 and 2015
                            if(regs[0] < 1902 || regs[0] > (new Date()).getFullYear()) {
                              alert("Invalid value for year: " + regs[0] + " - must be between 1902 and " + (new Date()).getFullYear());
                              form.elements["observationDate"].focus();
                              return false;
                            }
                            return true;
                          }

                          jQuery(setupDocDescriptionTypeahead(<%=docId%>));

                                            </script>
                                            <div id="providerList<%=docId%>"></div>
                                        </td>
				    </tr>
				    <tr>
                                        <td>
                                            <bean:message key="dms.documentReport.msgFlagAbnormal" />
                                        </td>
                                        <td>
                                            <input id="abnormal<%=docId%>" type="checkbox" name="abnormalFlag" <%= curdoc.isAbnormal() ? "checked='checked'" : "" %> >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="text-align:right"><a id="saveSucessMsg_<%=docId%>" style="display:none;color:blue;"><bean:message key="inboxmanager.document.SuccessfullySavedMsg"/></a><%if(!demographicID.equals("-1")){%><input type="submit" class="btn btn-primary" name="save" tabindex="<%=tabindex++%>" id="save<%=docId%>" value="<bean:message key="global.btnSave"/>" ><%} else{%><input type="submit" class="btn btn-primary" name="save" tabindex="<%=tabindex++%>" id="save<%=docId%>" disabled value="<bean:message key="global.btnSave"/>" title="<bean:message key="dms.incomingDocs.selectDemographicFirst"/>"> <%}%></td>
                                    </tr>

                                    <tr>
                                        <td colspan="2">
                                            <bean:message key="inboxmanager.document.LinkedProvidersMsg"/>
                                            <%
            Properties p = (Properties) session.getAttribute("providerBean");
            List<ProviderInboxItem> routeList = providerInboxRoutingDao.getProvidersWithRoutingForDocument("DOC", Integer.parseInt(docId));
            int countValidProvider = 0;
                                            %>
                                            <ul>
                                                <%for (ProviderInboxItem pItem : routeList) {
                                                    String s=p.getProperty(pItem.getProviderNo(), pItem.getProviderNo());
                                                    if(!s.equals("0")){  %>
                                                        <li><%=s%></li>
                                                <% countValidProvider++;}
                                                 }%>
                                            </ul>
                                        </td>
                                    </tr>
                                </table>

                            </form>
                        </fieldset>
<% if(demographicID!=null && !demographicID.equals("")){

							    TicklerManager ticklerManager = SpringUtils.getBean(TicklerManager.class);
							    List<Tickler> LabTicklers = ticklerManager.getTicklerByLabId(loggedInInfo, Integer.valueOf(documentNo), Integer.valueOf(demographicID),"DOC");

							    if(LabTicklers!=null && LabTicklers.size()>0){
							    %>
                                <fieldset>
							    <div id="ticklerWrap" class="DoNotPrint">
							    <div id="ticklerDisplay" >
							   <%
							   String flag;
							   String ticklerClass;
							   String ticklerStatus;
							   for(Tickler tickler:LabTicklers){

							   ticklerStatus = tickler.getStatus().toString();
							   if(!ticklerStatus.equals("C") && tickler.getPriority().toString().equals("High")){
							   	flag="<span style='color:red'>&#9873;</span>";
							   }else if(ticklerStatus.equals("C") && tickler.getPriority().toString().equals("High")){
							   	flag="<span>&#9873;</span>";
							   }else{
							   	flag="";
							   }

							   if(ticklerStatus.equals("C")){
							  	 ticklerClass = "completedTickler";
							   }else{
							  	 ticklerClass="";
							   }
							   %>
							   <div style="text-align:left; background-color:#fff; padding:5px; width:600px;" class="<%=ticklerClass%>">
							   	<table style="width:100%">
							   	<tr>
							   	<td><b><bean:message key="tickler.ticklerEdit.priority"/>:</b><br><%=flag%> <%=tickler.getPriority()%></td>
							   	<td><b><bean:message key="tickler.ticklerEdit.serviceDate"/>:</b><br><%=tickler.getServiceDate()%></td>
							   	<td><b><bean:message key="tickler.ticklerEdit.assignedTo"/>:</b><br><%=tickler.getAssignee() != null ? tickler.getAssignee().getLastName() + ", " + tickler.getAssignee().getFirstName() : "N/A"%></td>
							   	<td style="width:90px"><b><bean:message key="tickler.ticklerEdit.status"/>:</b><br><%=ticklerStatus.equals("C") ? "Completed" : "Active" %></td>
							   	</tr>
							   	<tr>
							   	<td colspan="4"><%=tickler.getMessage()%></td>
							   	</tr>
							   	</table>
							   </div>
							   <%
							   }
							   %>
							   		</div><!-- end ticklerDisplay -->
							   </div>
                                </fieldset>
							   <%}//no ticklers to display

}%>

                            <%
                            ArrayList ackList = AcknowledgementData.getAcknowledgements("DOC",docId);
							String curAckStatus = "N";
                                            if (ackList.size() > 0){%>
                                            <fieldset>
                                                <table style="width:100%; border-width:2px;">
                                                    <tr>
                                                            <td style="text-align:center; padding:2px; background-color:white">
                                                            <div class="FieldData">
                                                                <!--center-->
                                                                    <% for (int i=0; i < ackList.size(); i++) {
                                                                        ReportStatus report = (ReportStatus) ackList.get(i); %>
                                                                        <%= report.getProviderName() %> :

                                                                        <% String ackStatus = report.getStatus();
                                                                        	if( providerNo.equals(report.getOscarProviderNo()) ) {
                                                                        	    curAckStatus = ackStatus;
                                                                        	}
                                                                            if(ackStatus.equals("A")){
                                                                                ackStatus = oscarRec.containsKey("oscarMDS.index.Acknowledged")? oscarRec.getString("oscarMDS.index.Acknowledged") : "Acknowledged";
                                                                            }else if(ackStatus.equals("F")){
                                                                                ackStatus = oscarRec.containsKey("oscarMDS.index.Acknowledged")? oscarRec.getString("oscarMDS.index.FiledbutnotAcknowledged") : "Filed but not Acknowledged";
                                                                            }else{
                                                                                ackStatus = oscarRec.containsKey("oscarMDS.index.Acknowledged")? oscarRec.getString("oscarMDS.index.NotAcknowledged") : "Not Acknowledged";
                                                                            }
                                                                            String nocom = oscarRec.containsKey("oscarMDS.index.nocomment")? oscarRec.getString("oscarMDS.index.nocomment") : "no comment";
                                                                            String com = oscarRec.containsKey("oscarMDS.index.comment")? oscarRec.getString("oscarMDS.index.comment") : "comment";
                                                                        %>
                                                                        <span style="color:red"><%= ackStatus %></span>
                                                                       		&nbsp;
                                                                            <%= report.getTimestamp()== null ? "" : report.getTimestamp() %>,&nbsp;
                                                                            comment: <%= ( report.getComment() == null || report.getComment().equals("") ? nocom : report.getComment() ) %>

                                                                        <br>
                                                                    <% }
                                                                    if (ackList.size() == 0){
                                                                        %><span style="color:red"><bean:message key="oscarEncounter.oscarConsultationRequest.ViewConsultationRequests.formTeamNotApplicable"/></span><%
                                                                    }
                                                                    %>
                                                                <!--/center-->
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                            <%}
%>


                        <fieldset>
                            <!--<legend>--><br><span class="FieldData"><i><bean:message key="inboxmanager.document.NextAppointmentMsg"/> <oscar:nextAppt demographicNo="<%=demographicID%>"/></i></span><!--</legend>-->
                            <form id="reassignForm_<%=docId%>" name="reassignForm_<%=docId%>" method="post" action="javascript:void(0);">
                                <input type="hidden" name="flaggedLabs" value="<%=docId%>" >
                                <input type="hidden" name="selectedProviders" value="" >
                                <input type="hidden" name="labType" value="DOC" >
                                <input type="hidden" name="labType<%=docId%>DOC" value="imNotNull" >
                                <input type="hidden" name="providerNo" value="<%=providerNo%>" >
                                <input type="hidden" name="favorites" value="" >
                                <input type="hidden" name="ajax" value="yes" >
                            </form>
                            </fieldset>
                         <fieldset>
                         	<legend><bean:message key="inboxmanager.document.Comment"/></legend>
                                <form name="acknowledgeForm_<%=docId%>" id="acknowledgeForm_<%=docId%>" onsubmit="updateStatus('acknowledgeForm_<%=docId%>');" method="post" action="javascript:void(0);">

                                <table style="width:100%; height:100%; border-width:0" >
                                    <tr>
                                        <td style="vertical-align:top">
                                            <table style="width:100%; border-width:0">
                                                <tr>
                                                    <td style="width:100%; text-align:left; padding:3px;" class="">
                                                        <input type="hidden" name="segmentID" value="<%= docId%>" >
                                                        <input type="hidden" name="multiID" value="<%= docId%>" >
                                                        <input type="hidden" name="providerNo" value="<%= providerNo%>" >
                                                        <input type="hidden" name="status" value="A" id="ackStatus" >
                                                        <input type="hidden" name="labType" value="DOC" >
                                                        <input type="hidden" name="ajaxcall" value="yes" >
                                                        <textarea  tabindex="<%=tabindex++%>" name="comment" cols="40" rows="4" style="width:400px;"></textarea>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="submit" class="btn btn-primary" tabindex="<%=tabindex++%>" value="<bean:message key="oscarMDS.segmentDisplay.btnAcknowledge"/>" >
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value="<bean:message key="oscarMDS.segmentDisplay.btnComment"/>" onclick="addDocComment('<%=docId%>','<%=curAckStatus%>')" >
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value="<bean:message key="oscarMDS.index.btnForward"/>" onClick="popup(323, 685, '../oscarMDS/SelectProvider.jsp?docId=<%=docId%>&providerNo=<%=providerNo%>&searchProviderNo=<%=searchProviderNo%>&status=<%=status%>', 'providerselect')">
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value="<bean:message key="oscarMDS.index.btnFile"/>" onclick="fileDoc('<%=documentNo%>');" >
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value=" <bean:message key="global.btnClose"/> " onClick="window.close()">
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value=" <bean:message key="global.btnPrint"/> " onClick="popup(700,960,'<%=url2%>','file download')">
                                                        <% if (demographicID != null && !demographicID.equals("") && !demographicID.equalsIgnoreCase("null") && !demographicID.equals("-1")) {
                                                        	String  eURL = "../oscarEncounter/IncomingEncounter.do?providerNo=" + providerNo + "&appointmentNo=&demographicNo=" + demographicID + "&curProviderNo=&reason=" + java.net.URLEncoder.encode("Document Notes","UTF-8") + "&encType=" + java.net.URLEncoder.encode("encounter without client","UTF-8") + "&userName=" + java.net.URLEncoder.encode( provider.getFullName(),"UTF-8") + "&curDate=" + UtilDateUtilities.getToday("yyyy-MM-dd")+ "&appointmentDate=&startTime=&status=";
                                                       	%>
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value="Msg" onclick="popup(700,960,'../oscarMessenger/SendDemoMessage.do?demographic_no=<%=demographicID%>','msg')" >
                                                        <input type="button" class="btn" tabindex="<%=tabindex++%>" value="Tickler" onclick="popup(450,600,'../tickler/ForwardDemographicTickler.do?docType=DOC&docId=<%=docId%>&demographic_no=<%=demographicID%>','tickler')">
                                                        <!--<input type="button" class="btn" tabindex="<%=tabindex++%>" value="eChart" onclick="popup(710,1024,'<%=eURL%>','encounter')">-->
                                                        <%if(curdoc.getCreatorId().equals(LoggedInInfo.getLoggedInInfoFromSession(request).getLoggedInProviderNo())) {
                                                        	%>
                                                        	<input type="button" class="btn" tabindex="<%=tabindex++%>" value="Delete" onClick="javascript: checkDelete('MultiPageDocDisplay.jsp?delDocumentNo=<%=curdoc.getDocId()%>','<%=curdoc.getDescription()%>')" >

                                                        	<%
                                                        } else {
                                                        %>
                                                        <security:oscarSec roleName="<%=roleName$%>" objectName="_admin,_admin.edocdelete" rights="r">
                                                        	<input type="button" class="btn" tabindex="<%=tabindex++%>" value="Delete" onClick="javascript: checkDelete('documentReport.jsp?delDocumentNo=1&amp;function=demographic&amp;functionid=1&amp;viewstatus=active','test')" >
                                                        </security:oscarSec>
                                                        <% } %>
                                                        <%if (MyOscarUtils.isMyOscarEnabled((String) session.getAttribute("user"))){
															MyOscarLoggedInInfo myOscarLoggedInInfo=MyOscarLoggedInInfo.getLoggedInInfo(session);
															boolean enabledMyOscarButton=MyOscarUtils.isMyOscarSendButtonEnabled(myOscarLoggedInInfo, Integer.valueOf(demographicID));
														%>
														<input type="button" class="btn" <%=WebUtils.getDisabledString(enabledMyOscarButton)%> tabindex="<%=tabindex++%>" value="<bean:message key="global.btnSendToPHR"/>" onclick="popup(450, 600, '../phr/SendToPhrPreview.jsp?module=document&documentNo=<%=docId%>&demographic_no=<%=demographicID%>', 'sendtophr')" >

														<%}

                                                         }%>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </form>
                        </fieldset>
                        <% if (!StringUtils.isNullOrEmpty(demographicID) && !StringUtils.isNullOrEmpty(curdoc.getDescription()) && countValidProvider!=0){ %>
                        <fieldset>
                            <legend><bean:message key="dms.incomingDocs.fax"/></legend>
                            <script>
                                jQuery.noConflict();
                                function faxDocument(docId){

                                    var faxRecipients = "";
                                    if(document.getElementById("faxRecipients").children.length <= 0){
                                        alert("Please select at least one Fax Recipient");
                                        return false;
                                    }
                                    else{
                                        for(var i=0; i<document.getElementById("faxRecipients").children.length; i++){
                                            faxRecipients += document.getElementsByName('faxRecipients')[i].value + ",";
                                        }
                                        document.getElementsByName('faxRecipients').length
                                    }
                                    jQuery.ajax({
                                        type: "POST",
                                        url: "<%=request.getContextPath() %>/dms/ManageDocument.do",
                                        data: "method=fax&docId=" + docId + "&faxRecipients=" + faxRecipients + "&demoNo=<%=demographicID%>&docType=DOC",
                                        success: function(data) {
                                            if (data != null)
                                                location.reload();
                                        }
                                    });
                                }
                            </script>
                            <form name="faxForm_<%=docId%>" id="faxForm_<%=docId%>" onsubmit="" method="post" action="javascript:void(0);">
                                <table style="border-width:0px">
                                    <tbody>
                                    <tr>
                                        <td>
                                            <bean:message key="Appointment.formDoctor"/>:
                                        </td>
                                        <td>
                                            <select id="otherFaxSelect" style="margin-left: 5px;max-width: 300px;min-width:150px;">
                                                <%
                                                    String rdName = "";
                                                    String rdFaxNo = "";
                                                    for (int i=0;i < displayServiceUtil.specIdVec.size(); i++) {
                                                        String  specId     =  displayServiceUtil.specIdVec.elementAt(i);
                                                        String  fName      =  displayServiceUtil.fNameVec.elementAt(i);
                                                        String  lName      =  displayServiceUtil.lNameVec.elementAt(i);
                                                        String  proLetters =  displayServiceUtil.proLettersVec.elementAt(i);
                                                        String  address    =  displayServiceUtil.addressVec.elementAt(i);
                                                        String  phone      =  displayServiceUtil.phoneVec.elementAt(i);
                                                        String  fax        =  displayServiceUtil.faxVec.elementAt(i);
                                                        String  referralNo = "";
                                                        if (rdohip != null && !"".equals(rdohip) && rdohip.equals(referralNo)) {
                                                            rdName = String.format("%s, %s", lName, fName);
                                                            rdFaxNo = fax;
                                                        }
                                                        if (!"".equals(fax)) {
                                                %>

                                                <option value="<%= fax %>"> <%= String.format("%s, %s", lName, fName) %> </option>
                                                <%
                                                        }
                                                    }
                                                %>

                                            </select>
                                        </td>
                                        <td>
                                            <input type="submit" class="btn" value="<bean:message key="global.btnAdd"/>" onclick="addOtherFaxProvider(); return false;">
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><bean:message key="provider.pref.general.fax"/>:</td>
                                        <td><input type="text" id="otherFaxInput" name="otherFaxInput" style="margin-left: 5px;max-width: 300px;min-width:150px;" value="" ></td>
                                        <td>
                                            <input type="submit" class="btn"  value="<bean:message key="global.btnAdd"/>" onclick="addOtherFax(); return false;">
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                                <div id="faxOps">
                                    <div>

                                        <ul id="faxRecipients">
                                            <%
                                                if (!"".equals(rdName) && !"".equals(rdFaxNo)) {
                                            %>

                                            <input type="hidden" name="faxRecipients" value="<%= rdFaxNo %>" >

                                            <%
                                                }
                                            %>
                                        </ul>
                                    </div>
                                    <div style="margin-top: 5px; text-align: center">
                                        <input type="submit" class="btn" id="fax_button" onclick="faxDocument('<%=docId%>');" value="<bean:message key="dms.incomingDocs.fax"/>" >
                                    </div>
                                </div>
 <%
                            if(session.getAttribute("faxSuccessful")!=null){
                                if((Boolean)session.getAttribute("faxSuccessful")==true){ %><br>
                    <div class="alert alert-success alert-block fade in"><button type="button" class="close" data-dismiss="alert">&times;</button>
      <bean:message key="dms.incomingDocs.fax"/> <bean:message key="oscarMessenger.DisplayMessages.msgStatusSent"/>
    </div>
            <% }
            session.removeAttribute("faxSuccessful");
            }  %>
                            </form>
                        </fieldset>
                        <% } %>
                    </td>
                </tr>
                <tr>
                	 <td >
                        <div style="text-align: right; font-weight: bold">
                        <% if( numOfPage > 1 ) {%>
                        <a id="firstP2" style="display: none;" href="javascript:void(0);" onclick="firstPage('<%=docId%>');"><bean:message key='global.First'/></a>
                        <a id="prevP2" style="display: none;" href="javascript:void(0);" onclick="prevPage('<%=docId%>');"><bean:message key='global.Prev'/></a>
                        <a id="nextP2" href="javascript:void(0);" onclick="nextPage('<%=docId%>');"><bean:message key='global.Next'/></a>
                        <a id="lastP2" href="javascript:void(0);" onclick="lastPage('<%=docId%>');"><bean:message key='global.Last'/></a>
                        <%}%>
                        </div>

                   </td>
                   <td>&nbsp;</td>
                </tr>
                <tr><td colspan="2" ><hr style="width:100%; color:blue"></td></tr>
            </table>
        </div>

    </body>
</html>