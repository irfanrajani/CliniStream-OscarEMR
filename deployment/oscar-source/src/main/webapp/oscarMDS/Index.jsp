<%--

    Copyright (c) 2008-2012 Indivica Inc.

    This software is made available under the terms of the
    GNU General Public License, Version 2, 1991 (GPLv2).
    License details are available via "indivica.ca/gplv2"
    and "gnu.org/licenses/gpl-2.0.html".

--%>
<!DOCTYPE html>
<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="oscar.oscarMDS.data.*,oscar.oscarLab.ca.on.*" %>
<%@ page import="oscar.util.StringUtils,oscar.util.UtilDateUtilities" %>
<%@ page import="oscar.OscarProperties" %>
<%@ page import="org.oscarehr.common.dao.UserPropertyDAO" %>
<%@ page import="org.oscarehr.common.model.UserProperty" %>

<%@ page import="org.oscarehr.common.hl7.v2.oscar_to_oscar.OscarToOscarUtils"%>
<%@ page import="org.oscarehr.util.MiscUtils,org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="org.oscarehr.util.SpringUtils"%>
<%@ page import="org.apache.commons.collections.MultiHashMap" %>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar"%>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<%
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
            oscar.OscarProperties props = oscar.OscarProperties.getInstance();
            String help_url = (props.getProperty("HELP_SEARCH_URL","https://oscargalaxy.org/knowledge-base/")).trim();
            UserPropertyDAO userPropertyDAO = (UserPropertyDAO)SpringUtils.getBean("UserPropertyDAO");
            String providerNo = request.getParameter("providerNo");
            String curUser_no = (String) session.getAttribute("user");
            UserProperty  getRecallDelegate = userPropertyDAO.getProp(providerNo, UserProperty.LAB_RECALL_DELEGATE);
            UserProperty  getRecallTicklerAssignee = userPropertyDAO.getProp(providerNo, UserProperty.LAB_RECALL_TICKLER_ASSIGNEE);
            UserProperty  getRecallTicklerPriority = userPropertyDAO.getProp(providerNo, UserProperty.LAB_RECALL_TICKLER_PRIORITY);
            boolean recall = false;
            String recallDelegate = "";
            String ticklerAssignee = "";
            String recallTicklerPriority = "";

            if(getRecallDelegate!=null){
                recall = true;
                recallDelegate = getRecallDelegate.getValue();
                recallTicklerPriority = getRecallTicklerPriority.getValue();
                if(getRecallTicklerAssignee.getValue().equals("yes")){
	                ticklerAssignee = "&taskTo="+recallDelegate;
                }
            }

class Sortbylabnum implements Comparator<PatientInfo>
{
    public int compare (PatientInfo a, PatientInfo b)
    {
        return b.getLabCount() + b.getDocCount() -a.getLabCount() -a.getDocCount() ;
    }
}
@SuppressWarnings("unchecked")
ArrayList<PatientInfo> patients = (ArrayList<PatientInfo>) request.getAttribute("patients");
if (patients!=null) {
	Collections.sort(patients);
}

Integer unmatchedDocs   = (Integer) request.getAttribute("unmatchedDocs");
Integer unmatchedLabs   = (Integer) request.getAttribute("unmatchedLabs");
Integer totalDocs		= (Integer) request.getAttribute("totalDocs");
Integer totalLabs 		= (Integer) request.getAttribute("totalLabs");
if (totalLabs==null) { totalLabs = 0;}
Integer abnormalCount 	= (Integer) request.getAttribute("abnormalCount");
Integer normalCount 	= (Integer) request.getAttribute("normalCount");
Integer totalNumDocs    = (Integer) request.getAttribute("totalNumDocs");
Long categoryHash       = (Long) request.getAttribute("categoryHash");

String searchProviderNo = (String) request.getAttribute("searchProviderNo");
String demographicNo	= (String) request.getAttribute("demographicNo");
String ackStatus 		= (String) request.getAttribute("ackStatus");
String abnormalStatus   = (String) request.getAttribute("abnormalStatus");

String selectedCategory        = request.getParameter("selectedCategory");
String selectedCategoryPatient = request.getParameter("selectedCategoryPatient");
String selectedCategoryType    = request.getParameter("selectedCategoryType");

String patientFirstName    = (String) request.getAttribute("patientFirstName");
String patientLastName     = (String) request.getAttribute("patientLastName");
String patientHealthNumber = (String) request.getAttribute("patientHealthNumber");

String startDate = (String) request.getAttribute("startDate");
String endDate = (String) request.getAttribute("endDate");

boolean ajax = "true".equals(request.getParameter("ajax"));
%>

<% if (!ajax) { %>
<html>

<head>
<!-- i18n calendar -->
    <script src="<%=request.getContextPath()%>/share/calendar/calendar.js"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/lang/<bean:message key='global.javascript.calendar'/>"></script>
    <script src="<%=request.getContextPath()%>/share/calendar/calendar-setup.js"></script>
    <link href="<%= request.getContextPath() %>/share/calendar/calendar.css" title="win2k-cold-1" rel="stylesheet" type="text/css" media="all" >

<!-- jquery -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-3.6.4.min.js"></script>
    <script> jQuery.noConflict(); </script>
    <script src="<%=request.getContextPath()%>/library/DataTables/datatables.min.js"></script> <!-- DataTables 1.13.4 -->
    <script src="<%=request.getContextPath()%>/library/jquery/jquery-ui-1.12.1.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery.validate.js"></script>
    <script src="<%=request.getContextPath() %>/share/javascript/jquery/jquery.form.js"></script>

<!-- oscar -->
    <script src="<%=request.getContextPath()%>/js/global.js"></script>
    <script src="<%=request.getContextPath()%>/share/javascript/Oscar.js"></script>
    <script src="<%=request.getContextPath()%>/share/javascript/oscarMDSIndex.js"></script>
    <script src="<%=request.getContextPath()%>/dms/showDocument.js"></script>
    <script src="<%= request.getContextPath() %>/js/demographicProviderAutocomplete.js"></script>
    <script src="<%= request.getContextPath() %>/js/documentDescriptionTypeahead.js"></script>

<link href="<%=request.getContextPath()%>/share/css/oscarMDSIndex.css" rel="stylesheet" media="all" >
<link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet" > <!-- Bootstrap 2.3.1 -->
<link href="<%=request.getContextPath()%>/css/datepicker.css" rel="stylesheet" >
<link href="<%=request.getContextPath()%>/css/bootstrap-responsive.css" rel="stylesheet" >
<link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet" >

<link href="${pageContext.request.contextPath}/library/jquery/jquery-ui.structure-1.12.1.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/library/jquery/jquery-ui.theme-1.12.1.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/DT_bootstrap.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" rel="stylesheet">


<!-- important leave this last to override the css above -->
<style>
    form {
        margin: 0px;
    }

    body {
        line-height: 12px;
    }

    pre {
        padding:2px;
        line-height: 12px;
    }

    hr  {
        border: 1px solid black;
        margin:1px;
    }

    dt {
        line-height: 16px;
        font-size: 12px;

    }
    .header-cell {
        background-color:silver;
        border: black;
        text-align: left;
        vertical-align:bottom;
        white-space:nowrap;
        color: white;
        padding-bottom: 6px;
        padding-left: 5px;
    }

    .Cell {
        background-color:silver;
    }

    .Field2 {

    }
    .UnassignedRes {
        background-color: #FFCC00;
    }

    .MainTableTopRowRightColumn {
        background-color: silver;
    }

	#summaryView td {
		padding: 0px 5px;
	}

    .table-striped tbody > tr.UnassignedRes:nth-child(odd) > td {
         background-color:#F0D04F;
     }

    .table-striped tbody > tr.UnassignedRes:nth-child(even) > td {
         background-color:#FFCC00;
     }

    .table-striped tbody > tr.acknowledged:nth-child(odd) > td {
         background-color: lightblue;
     }
    .table-striped tbody > tr.acknowledged:nth-child(even) > td {
         background-color: #d9f1f9;
     }
</style>
<style>
/* Dropdown Button */
.dropbtns {
/*  background-color: #4CAF50;
  color: white;
  padding: 16px;
  font-size: 16px;
  border: none;*/
}

/* The container <div> - needed to position the dropdown content */
.dropdowns {
  position: relative;
  display: inline-block;
}

/* Dropdown Content (Hidden by Default) */
.dropdowns-content {
  display: none;
  position: absolute;
  background-color: #f1f1f1;
  min-width: 160px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

/* Links inside the dropdown */
.dropdowns-content a {
  color: black;
  padding: 8px 12px;
  text-decoration: none;
  display: block;
}

.dropdowns-content a.disabled {
  pointer-events: none;
  color: grey;
  padding: 8px 12px;
  text-decoration: none;
  display: block;
}

/* Change color of dropdown links on hover */
.dropdowns-content a:hover {background-color: #ddd;}

/* Show the dropdown menu on hover */
.dropdowns:hover .dropdowns-content {display: block;}

/* Change the background color of the dropdown button when the dropdown content is shown */
.dropdowns:hover .dropbtns {background-color: #e6e6e6;}

</style>



    <script>

        function openNext(segmentID){

            if (!document.getElementById('ack_next_chk').checked) {
                console.log("not feeling checked");
                if (popup) { popup.close(); }
                return "close";
            }
            var nextTr = jQuery('#labdoc_'+segmentID).next('tr');
            console.log("passed segmentID:"+segmentID);
            //skip those that have display none
            while (nextTr.css('display') == 'none') {
                console.log("not seeing the next tr");
                nextTr = nextTr.next('tr');
                if (typeof nextTr.attr('id') === "undefined" ){ break; }
            }

            //if we are at the end of the list indicate that the window can be closed
            if (typeof nextTr.attr('id') === "undefined" ) {
                if (popup) { popup.close(); }
                return "close";
            }

            var nextId = nextTr.attr('id');
            var nextName = nextTr.attr('name'); //eg HL7lab, scannedDoc
            console.log("passed segmentID:"+segmentID+"\n and the next segment:"+nextId+" of type "+ nextName);
            var nextLink = nextTr.find('td').find('a').first();

            nextLink.trigger('click'); //this will run the onclick for the nextLink element to remove any * and navigate
            return "rapidClick";

        }

        function updateCountTotal(offset) {

          // updates two different formats of DataTables footer to reflect visible count
          // ... regardless of language
          var info = jQuery('#summaryView_info').html();
          var n = jQuery('[id^="labdoc_"]:not([style*="display: none"])').length  // the number of visible rows
          var n2 = jQuery('[id^="labdoc_"]').length  // the number of total rows
          if (jQuery('#showAck').is(':checked')) { n = n2 }
          console.log(info+" n:"+n+" n2:"+n2+" offset:"+offset+" checked at "+Date.now());
          n = n + offset;
          n2 = n2;
          var regex = /(^.*1\s[^0-9]*\s)\d*(\s[^0-9]*\s)\d*(\s[^0-9]*$)/;
          if (regex.test(info)) { //unfiltered list format
            // eg "Affichage de 1 à 36 sur 36 entrées"
            var updatedinfo = info.replace(regex, "$1" + n + "$2" + n2 + "$3");
            jQuery('#summaryView_info').html(updatedinfo);
            return;
          }
          // eg "Afichage de 1 à 12 sur 12 entrées (filtrées depuis un total de 34 entrées)"
          var myRe = /(\d+)(?!.*\d)/;  // the last number in the string
          if (myRe.test(info)) {
            var myArray = myRe.exec(info);
            curTotal = myArray[1];
            total = curTotal + offset;
            var regex = /(.*1\s[^0-9]*\s)\d*(\s[^0-9]*\s)\d*(\s[^0-9]*)\d*(\s.*)/;
            if (regex.test(info)) { //filtered list format
              var updatedinfo = info.replace(regex, "$1" + n + "$2" + n + "$3" + n2 + "$4");
              jQuery('#summaryView_info').html(updatedinfo);
            }
          }
        }

        function toggleReviewed() {
            jQuery('.acknowledged').toggle(600,"swing",function(){updateCountTotal(0)});
        }

        function hideLab(id) {
            jQuery('#'+id).addClass('acknowledged');
            if (document.getElementById('showAck') && !document.getElementById('showAck').checked) {
                jQuery('#'+id).toggle(600,"swing",function(){updateCountTotal(0)});
            } else {
                updateCountTotal(0);
            }
        }


			//first check to see if lab is linked, if it is, we can send the demographicNo to the macro
			function runhl7Macro(name, formid, closeOnSuccess) {
			    var url = '<%=request.getContextPath()%>/dms/inboxManage.do';
			    var num = formid.split("_");
			    var doclabid = num[1];
			    var data = 'method=isLabLinkedToDemographic&labid=' + doclabid;
			    jQuery.ajax({
			        type: "POST",
			        url: url,
			        dataType: "json",
			        data: data,
			        success: function(result) {
			            if (result != null) {
			                var success = result.isLinkedToDemographic;
			                var demoid = '';
			                if (success) {
			                    demoid = result.demoId;
			                    runMacroInternal(name, formid, closeOnSuccess, demoid, "hl7");
			                } else {
                                alert("<bean:message key="oscarMDS.index.msgNotAttached"/>");
                            }
			            }
			        }
			    });
			}

			//first check to see if doc is linked, if it is, we can send the demographicNo to the macro
			function runMacro(name,formid, closeOnSuccess) {
				var num=formid.split("_");
				var doclabid=num[1];
				if(doclabid){
					var demoId=document.getElementById('demofind'+doclabid).value;
					var saved=document.getElementById('saved'+doclabid).value;
					if(demoId=='-1'|| saved=='false'){
						alert('<bean:message key="oscarMDS.index.msgNotAttached"/>');
					}else{
						runMacroInternal(name,formid,closeOnSuccess,demoId,"doc");
					}
				}
			}

			function runMacroInternal(name,formid,closeOnSuccess,demographicNo,type) {
				var url='<%=request.getContextPath()%>'+"/oscarMDS/RunMacro.do?name=" + name + (demographicNo.length>0 ? "&demographicNo=" + demographicNo : "");
	            var data=jQuery('#'+formid).serialize();
                var num=formid.split("_");
	            var doclabid=num[1];

                jQuery.ajax( {
      	                type: "POST",
      	                url: url,
      	                dataType: "json",
                        data: data,
                        success: function(result) {
	                    	if(closeOnSuccess) {
                                if (type == "doc") {
                        	            refreshCategoryList();
                                        updateStatus(formid);
                                }
                                if (type == "hl7") {
                        	        refreshCategoryList();
                                    jQuery('#'+formid).toggle('fade'); // jQuery UI effect
                                    //hideLab(doclabid);
                                }

                                //window.close();
	                    	}
	                    }});

			}

        contextpath='<%=request.getContextPath()%>';
        function handleDocSave(docid,action){
			var url=contextpath + "/dms/inboxManage.do";
			var data='method=isDocumentLinkedToDemographic&docId='+docid;
            jQuery.ajax({
                type: "POST",
                url: url,
                data: data,
                dataType: 'json',
                success: function(data) {
                    var json = data;
                    if (json != null) {
                        var success = json.isLinkedToDemographic;
                        var demoid = '';
                        if (success) {
                            demoid=json.demoId;
                            if(demoid!=null && demoid.length>0) {
            switch(String(action)) {
                case "msgLab":
                    popupStart(900,1280,contextpath + '/oscarMessenger/SendDemoMessage.do?demographic_no='+demoid,'msg', docid);
                    break;
                case "addTickler":
                    popupStart(450,600,contextpath + '/tickler/ForwardDemographicTickler.do?docType=DOC&docId='+docid+'&demographic_no='+demoid,'tickler');
                    break;
                case "msgLabRecall":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarMessenger/SendDemoMessage.do?demographic_no='+demoid+"&recall",'msgRecall');
                    window.popup(450,600,'<%=request.getContextPath()%>/tickler/ForwardDemographicTickler.do?docType=DOC&docId='+docid+'&demographic_no='+demoid+'<%=ticklerAssignee%>&priority=<%=recallTicklerPriority%>&recall','ticklerRecall');
                    break;
                case "msgLabMAM":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?demographic_no='+demoid+'&prevention=MAM','prevention');
                <% if (props.getProperty("billregion", "").trim().toUpperCase().equals("ON")) { %>
                    window.popup(700,1280,'<%=request.getContextPath()%>/billing/CA/ON/billingOB.jsp?billRegion=ON&billForm=MFP&hotclick=&appointment_no=0&demographic_name=&status=a&demographic_no='+demoid+'&providerview=<%=curUser_no%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curUser_no%>&appointment_date=&start_time=00:00:00&bNewForm=1&serviceCode0=Q131A','billing');
                <% } %>
                    window.popup(450,1280,'<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview='+demoid);
                    break;
                case "msgLabPAP":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?demographic_no='+demoid+'&prevention=PAP','prevention');
                <% if (props.getProperty("billregion", "").trim().toUpperCase().equals("ON")) { %>
                    window.popup(700,1280,'<%=request.getContextPath()%>/billing/CA/ON/billingOB.jsp?billRegion=ON&billForm=MFP&hotclick=&appointment_no=0&demographic_name=&status=a&demographic_no='+demoid+'&providerview=<%=curUser_no%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curUser_no%>&appointment_date=&start_time=00:00:00&bNewForm=1&serviceCode0=Q011A','billing');
                <% } %>
                    window.popup(450,1280,'<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview='+demoid);
                    break;
                case "msgLabFIT":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?demographic_no='+demoid+'&prevention=FOBT','prevention');
                    window.popup(450,1280,'<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview='+demoid);
                    break;
                case "msgLabCOLONOSCOPY":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?demographic_no='+demoid+'&prevention=COLONOSCOPY','prevention');
                <% if (props.getProperty("billregion", "").trim().toUpperCase().equals("ON")) { %>
                    window.popup(700,1280,'<%=request.getContextPath()%>/billing/CA/ON/billingOB.jsp?billRegion=ON&billForm=MFP&hotclick=&appointment_no=0&demographic_name=&status=a&demographic_no='+demoid+'&providerview=<%=curUser_no%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curUser_no%>&appointment_date=&start_time=00:00:00&bNewForm=1&serviceCode0=Q142A','billing');
                <% } %>
                    window.popup(450,1280,'<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview='+demoid);
                    break;
                case "msgLabBMD":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?demographic_no='+demoid+'&prevention=BMD','prevention');
                    window.popup(450,1280,'<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview='+demoid);
                    break;
                case "msgLabPSA":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?demographic_no='+demoid+'&prevention=PSA','prevention');
                    window.popup(450,1280,'<%=request.getContextPath()%>/tickler/ticklerDemoMain.jsp?demoview='+demoid);
                    break;
                case "msgInf":
                    window.popup(700,980,'<%=request.getContextPath()%>/oscarPrevention/AddPreventionData.jsp?search=true&demographic_no='+demoid+'&snomedId=46233009&brandSnomedId=46233009','prevention');
                <% if (props.getProperty("billregion", "").trim().toUpperCase().equals("ON")) { %>
                    window.popup(700,1280,'<%=request.getContextPath()%>/billing/CA/ON/billingOB.jsp?billRegion=ON&billForm=MFP&hotclick=&appointment_no=0&demographic_name=&status=a&demographic_no='+demoid+'&providerview=<%=curUser_no%>&user_no=<%=curUser_no%>&apptProvider_no=<%=curUser_no%>&appointment_date=&start_time=00:00:00&bNewForm=1&serviceCode0=Q130A','billing');
                <% } %>
                    break;
                default:
                    console.log('default');
                    break;
            }
}




                                }
                                else {
                                    alert("<bean:message key="oscarMDS.index.msgNotAttached"/>");
                                }
                            }
			}});
        }

		</script>
<title>
<bean:message key="oscarMDS.index.title"/>
</title>
<html:base/>


<script>
	jQuery.noConflict();

	jQuery(window).on("scroll",handleScroll());

	function renderCalendar(id,inputFieldId){
    	Calendar.setup({ inputField : inputFieldId, ifFormat : "%Y-%m-%d", showsTime :false, button : id });

	}

	function split(id) {
		var loc = "<%= request.getContextPath()%>/oscarMDS/Split.jsp?document=" + id;
		popupStart(1100, 1100, loc, "Splitter");
	}

	var page = 1;
	var pageSize = 400;
	var selected_category = <%=(selectedCategory == null ? "1" : selectedCategory)%>;
	var selected_category_patient = <%=(selectedCategoryPatient == null ? "\"\"" : selectedCategoryPatient)%>;
	var selected_category_type = <%=(selectedCategoryType == null ? "\"\"" : selectedCategoryType)%>;
	var searchProviderNo = "<%=(searchProviderNo == null ? "" : searchProviderNo)%>";
	var firstName = "<%=(patientFirstName == null ? "" : patientFirstName)%>";
	var lastName = "<%=(patientLastName == null ? "" : patientLastName)%>";
	var hin = "<%=(patientHealthNumber == null ? "" : patientHealthNumber)%>";
	var providerNo = "<%=(providerNo == null ? "" : providerNo)%>";
	var searchStatus = "<%=(ackStatus == null ? "": ackStatus)%>";
	var abnormalStatus = "<%=abnormalStatus == null || "all".equals(abnormalStatus) ? "L" : (abnormalStatus.equals("normalOnly") ? "N" : "A")%>"
	var url = "<%=request.getContextPath()%>/dms/inboxManage.do?";
	var contextpath = "<%=request.getContextPath()%>";
	var startDate = "<%= startDate %>";
	var endDate = "<%= endDate %>";
	var request = null;
	var canLoad = true;
	var isListView = false;
	var loadingDocs = false;
	var currentBold = false;
	var oldestDate = null;

	window.changePage = function (p) {
		if (p == "Next") { page++; }
		else if (p == "Previous") { page--; }
		else { page = p; }
		if (request != null) { request.transport.abort(); }
		request = updateListView();
	};

	function handleScroll(e) {
		if (!canLoad || loadingDocs) { return false; }
		var evt = e || window.event;
        if(! evt)  { console.log("ERROR: no evt"); return false; }
		var loadMore = false;
	    if (isListView && evt.scrollHeight > document.getElementById("listViewDocs").clientHeight && evt.scrollTop > 0 && evt.scrollTop + evt.offsetHeight >= evt.scrollHeight) {
	    	loadMore = true;
	    }
	    else if (isListView && evt.scrollHeight <= document.getElementById("listViewDocs").clientHeight) {
	    	loadMore = true;
	    }
	    else if (!isListView && evt.scrollTop + evt.offsetHeight >= evt.scrollHeight) {
	    	loadMore = true;
	    }
	    if (loadMore) {
	    	loadingDocs = true;
        	changePage("Next");
	    }
	}

	function fakeScroll() {
		var scroller;
		if (isListView) {
			scroller = document.getElementById("summaryView");
		}
		else {
			scroller = document.getElementById("docViews");
		}
 		handleScroll(scroller);
	}

	function updateListView() {
        jQuery('#summaryView').DataTable().destroy();
		var query = getQuery(); //method=prepareForContentPage&searchProviderNo=101&providerNo=101&status=N&page=1&pageSize=400&isListView=true&startDate=null&endDate=null&view=all&fname=&lname=&hnum=

		if (page == 1) {
			document.getElementById("docViews").innerHTML = "";
			canLoad = true;
		}

		if (isListView && page == 1) {
			document.getElementById("docViews").innerHTML =	"<div id='tempLoader'><img src='<%=request.getContextPath()%>/images/DMSLoader.gif'> Loading reports...</div>"
		}
		else if (isListView) {
			document.getElementById("loader").style.display = "block";
		}
		else {
			jQuery("#docViews").append(jQuery("<div id='tempLoader'><img src='<%=request.getContextPath()%>/images/DMSLoader.gif'> Loading reports...</div>"));
		}
		var div;
		if (!isListView || page == 1) {
			div = jQuery("#docViews:last-child");
		}
		else {
			div = jQuery("#summaryBody:last-child");
		}
		jQuery("#readerSwitcher").prop("disabled",true);
		jQuery("#listSwitcher").prop("disabled",true);

        url = '<%=request.getContextPath()%>/dms/inboxManage.do'; //still
	    jQuery.ajax({
		    type: "GET",
		    url:  url,
		    data: query,
		    success: function (code) {
                div.append(code); //jQuery("#docViews").append(code);
			    loadingDocs = false;
			    var tmp = jQuery("#tempLoader");
			    if (tmp != null) { tmp.remove(); }
			    if (isListView) {
				    if (page == 1) {
                        jQuery("#tempLoader").remove();
                    } else {
                        document.getElementById("loader").style.display = "none";
                    }
			    }
			    if (page == 1) {
				    if (isListView) {
					    document.getElementById("docViews").style.overflow = "hidden";
				    } else {
					    document.getElementById("docViews").style.overflow = "auto";
				    }
			    }
			    if (code.indexOf("<input type=\"hidden\" name=\"NoMoreItems\" value=\"true\" />") >= 0) {
				    canLoad = false;
                            if (!DataTable.isDataTable('#summaryView')){
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
			    } else {
				    // It is possible that the current amount of loaded items has not filled up the page enough
				    // to create a scroll bar. So we fake a scroll (since no scroll bar is equivalent to reaching the bottom).
				    setTimeout("fakeScroll();", 1000);
			    }

			    jQuery("#readerSwitcher").prop("disabled",false);
			    jQuery("#listSwitcher").prop("disabled",false);
		 }});
	}
        function updateLabDemoStatus(labno){
            if(document.getElementById("DemoTable"+labno)){
                document.getElementById("DemoTable"+labno).style.backgroundColor="#FFF";
            }
        }

	function getQuery() {
		var CATEGORY_ALL = 1,CATEGORY_DOCUMENTS = 2,CATEGORY_HL7 = 3,CATEGORY_NORMAL = 4,CATEGORY_ABNORMAL = 5,CATEGORY_PATIENT = 6,CATEGORY_PATIENT_SUB = 7,CATEGORY_HRM = 8,CATEGORY_TYPE_DOC = 'DOC',CATEGORY_TYPE_HL7 = 'HL7';
		var query = "method=prepareForContentPage";
		query +="&searchProviderNo="+searchProviderNo+"&providerNo="+providerNo+"&status="+searchStatus+"&page="+page
			   +"&pageSize="+pageSize+"&isListView="+(isListView?"true":"false")
			   +"&startDate=" + startDate + "&endDate=" + endDate;
		switch (selected_category) {
		case CATEGORY_ALL:
			query  += "&view=all";
			query  += "&fname=" + firstName + "&lname=" + lastName + "&hnum=" + hin;
			break;
		case CATEGORY_DOCUMENTS:
			query  += "&view=documents";
			query  += "&fname=" + firstName + "&lname=" + lastName + "&hnum=" + hin;
			if (abnormalStatus !== '') {
				query += "&abnormalStatus=" + abnormalStatus;
			}
			break;
		case CATEGORY_HRM:
			query  += "&view=hrms";
			query  += "&fname=" + firstName + "&lname=" + lastName + "&hnum=" + hin;
			if (abnormalStatus !== '') {
				query += "&abnormalStatus=" + abnormalStatus;
			}
			break;
		case CATEGORY_HL7:
			query  += "&view=labs";
			query  += "&fname=" + firstName + "&lname=" + lastName + "&hnum=" + hin;
			if (abnormalStatus !== '') {
				query += "&abnormalStatus=" + abnormalStatus;
			}
			break;
		case CATEGORY_NORMAL:
			query  += "&view=normal";
			query  += "&fname=" + firstName + "&lname=" + lastName + "&hnum=" + hin;
			break;
		case CATEGORY_ABNORMAL:
			query  += "&view=abnormal";
			query  += "&fname=" + firstName + "&lname=" + lastName + "&hnum=" + hin;
			break;
		case CATEGORY_PATIENT:
			query  += "&view=all&demographicNo=" + selected_category_patient;
			break;
	    case CATEGORY_PATIENT_SUB:
	    	query  += "&demographicNo=" + selected_category_patient;
	    	switch (selected_category_type) {
		    	case CATEGORY_TYPE_DOC:
		    		query  += "&view=documents";
					break;
		    	case CATEGORY_TYPE_HL7:
		    		query  += "&view=labs";
					break;
	    	}
	    	break;
	    }

		if (oldestLab != null)
			query += "&newestDate=" + encodeURIComponent(oldestLab);

		return query;
	}

	function changeView(type,patientId,subtype) {
		loadingDocs = true;
		selected_category = type;
		selected_category_patient = patientId;
		selected_category_type = subtype;
		document.getElementById("docViews").innerHTML = "";
		changePage(1);
	}

	function switchView() {
		loadingDocs = true;
		isListView = !isListView;
		jQuery("input[name=isListView]").val(isListView);
		document.getElementById("docViews").innerHTML = "";
		var list = document.getElementById("listSwitcher");
		var view = document.getElementById("readerSwitcher");
		var active, passive;
		if (isListView) {
			pageSize = 400;
			active = view;
			passive = list;
		}
		else {
			pageSize = 10;
			active = list;
			passive = view;
		}
		active.style.display = "inline";
		passive.style.display = "none";

		changePage(1);
	}

	jQuery(document).ready(function() {
		isListView = <%= (selectedCategoryPatient != null) %>;
		jQuery('input[name=isListView]').val(isListView);
		switchView();
		//un_bold(document.getElementById("totalAll"));
		currentBold = "totalAll";
		refreshCategoryList();

	});
	function ForwardSelectedRows() {
		var query = jQuery(document.reassignForm).formSerialize();
		var labs = jQuery("input[name='flaggedLabs']:checked");
		for (var i = 0; i < labs.length; i++) {
			query += "&flaggedLabs=" + labs[i].value;
			query += "&" + jQuery(labs[i]).next().name + "=" + jQuery(labs[i]).next().value;
		}
		jQuery.ajax({
			type: "POST",
			url:  "<%= request.getContextPath()%>/oscarMDS/ReportReassign.do",
			data: query,
			success: function (data) {
				jQuery("input[name='flaggedLabs']:checked").each(function () {
					this.checked = false;
				});
			}
		});
	}
	window.FileSelectedRows = function () {
		var query = jQuery(document.reassignForm).formSerialize();
		var labs = jQuery("input[name='flaggedLabs']:checked");
		for (var i = 0; i < labs.length; i++) {
			query += "&flaggedLabs=" + labs[i].value;
			query += "&" + jQuery(labs[i]).next().name + "=" + jQuery(labs[i]).next().value;
		}
		jQuery.ajax({
			type: "POST",
			url:  "<%= request.getContextPath()%>/oscarMDS/FileLabs.do",
			data: query,
			success: function (data) {
				updateCategoryList(); //left side panel
				updateCountTotal(-1*i); //Datatables counts

				jQuery("input[name='flaggedLabs']:checked").each(function () {
					jQuery(this).parent().parent().remove();
				});

				// We may have removed enough items that the scroll bar is missing so we need to
				// check and retrieve more items if so.
				fakeScroll();
			}
		});
	}

	function refreshCategoryList() {
		jQuery("#categoryHash").val("-1");
		updateCategoryList(); //left side panel
		//updateCountTotal(-1); //Datatables counts
	}

	function updateCategoryList() {
		jQuery.ajax({
			type: "GET",
			url: "<%=request.getContextPath()%>/dms/inboxManage.do",
			data: window.location.search.substr(1) + "&ajax=true",
			success: function (data) {
				if (jQuery("#categoryHash").length == 0 || jQuery(data)[2].value != jQuery("#categoryHash").val()) {
					jQuery("#categoryList").html(data);
					re_bold(currentBold);
				}
			}
		});
	}

	function removeReport(reportId) {
		if (document.getElementById("labdoc_" + reportId)) {
			document.getElementById("labdoc_" + reportId).remove();
		}
	}

</script>


<style type="text/css">
    h4 {

        font-size: large;
    }
    .subheader {
        background-color:silver;
    }
	.multiPage {
		background-color: RED;
		color: WHITE;
		font-weight:bold;
		padding: 0px 5px;
		font-size: medium;
	}
	.singlePage {

	}

	[id^=ticklerWrap]{position:relative;top:0px;background-color:#FF6600;width:100%;}

	.completedTickler{
	    opacity: 0.8;
	    filter: alpha(opacity=80); /* For IE8 and earlier */
	}

	@media print {
	.DoNotPrint{display:none;}
	}

	.TDISRes	{font-weight: bold; font-size: 10pt; color: black; font-family:
               Verdana, Arial, Helvetica}
</style>

<script>



</script>
</head>

<body>
    <form name="reassignForm" method="post" action="ReportReassign.do" id="lab_form">
        <table id="scrollNumber1" style="width:100%; border-width:0px;">
            <tr>
                <td style="text-align:left"><!-- colspan="10" -->
                 <table style="width:100%">

                        <tr>
                            <td style="text-align:left; vertical-align:center;" > <%-- width="30%" --%>
                                <input type="hidden" name="providerNo" value="<%= providerNo %>" >
                                <input type="hidden" name="searchProviderNo" value="<%= searchProviderNo %>" >
                                <%= (request.getParameter("lname") == null ? "" : "<input type=\"hidden\" name=\"lname\" value=\""+request.getParameter("lname")+"\">") %>
                                <%= (request.getParameter("fname") == null ? "" : "<input type=\"hidden\" name=\"fname\" value=\""+request.getParameter("fname")+"\">") %>
                                <%= (request.getParameter("hnum") == null ? "" : "<input type=\"hidden\" name=\"hnum\" value=\""+request.getParameter("hnum")+"\">") %>
                                <input type="hidden" name="status" value="<%= ackStatus %>" >
                                <input type="hidden" name="selectedProviders" >
                                <input type="hidden" name="favorites" value="" >
                                <input type="hidden" name="isListView" value="" >
<table style="width:100%;">
<tr><td style="width:120px; vertical-align:top;">
<h4><i class= "icon-beaker"></i>&nbsp;<bean:message key="oscarEncounter.Labs.title"/></h4>
</td><td>
                                <input id="listSwitcher" type="button" style="display:none;" class="btn" value="<bean:message key="inboxmanager.document.listView"/>" onClick="switchView();" >
                                <input id="readerSwitcher" type="button" class="btn" value="<bean:message key="inboxmanager.document.readerView"/>" onClick="switchView();" >
                                <% if (demographicNo == null) { %>
                                    <input type="button" class="btn" value="<bean:message key="oscarMDS.index.btnSearch"/>" onClick="window.location='<%=request.getContextPath()%>/oscarMDS/Search.jsp?providerNo=<%= providerNo %>'" >
                                <% } %>
                                <input type="button" class="btn" value="<bean:message key="oscarMDS.index.btnClose"/>" onClick="wrapUp()" >
</td></tr>
</table>

                      		</td>

                            <td style="text-align:right; width:40%;">
								<span class="HelpAboutLogout">
									<a href="<%=help_url%>inbox/" target="_blank"><bean:message key="app.top1" /></a>
                                	| <a href="javascript:popupStart(300,400,'<%=request.getContextPath()%>/oscarEncounter/About.jsp')" ><bean:message key="global.about"/></a>
								</span>
                                | <a href="javascript:parent.reportWindow('<%=request.getContextPath()%>/oscarMDS/ForwardingRules.jsp?providerNo=<%= providerNo %>');"  ><bean:message key="oscarMDS.index.ForwardingRules"/></a>
                                | <a href="javascript:popupStart(800,1000,'<%=request.getContextPath()%>/lab/CA/ALL/testUploader.jsp')" ><bean:message key="admin.admin.hl7LabUpload"/></a>
                                <% if (OscarProperties.getInstance().getBooleanProperty("legacy_document_upload_enabled", "true")) { %>
                                | <a href="javascript:popupStart(600,500,'<%=request.getContextPath()%>/dms/html5AddDocuments.jsp')" ><bean:message key="inboxmanager.document.uploadDoc"/></a>
                                <% } else { %>
                                | <a href="javascript:popupStart(800,1000,'<%=request.getContextPath()%>/dms/documentUploader.jsp')"><bean:message key="inboxmanager.document.uploadDoc"/></a>
                                <% } %>
								<br>
								<a href="javascript:popupStart(700,1100,'../dms/inboxManage.do?method=getDocumentsInQueues')" ><bean:message key="inboxmanager.document.pendingDocs"/></a>
                                                                | <a href="javascript:popupStart(800,1000,'<%=request.getContextPath() %>/dms/incomingDocs.jsp')"  ><bean:message key="inboxmanager.document.incomingDocs"/></a>
								| <a href="javascript:popupStart(800,1000, '<%=request.getContextPath() %>/oscarMDS/CreateLab.jsp')" ><bean:message key="global.createLab" /></a>
                                | <a href="javascript:popupStart(1000,1300, '<%=request.getContextPath() %>/olis/Search.jsp')" ><bean:message key="olis.olisSearch" /></a>
                                | <a href="javascript:popupPage(400, 400,'<html:rewrite page="/hospitalReportManager/hospitalReportManager.jsp"/>')" ><bean:message key="oscarMDS.index.HRMupload" /></a>

                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <table id="readerViewTable" style="table-layout: fixed; border: solid thin; width:100%; border-color:black;">
            <colgroup>
                <col style="width:140px">
                <col >
            </colgroup>
          <tr>
              <td id="categoryList" style="overflow:hidden;border:solid thin; max-height: 100vh; min-width: 140px; vertical-align:top;" >
<% } // end if(!ajax)
   else {
%>
					<input type="hidden" id="categoryHash" value="<%=categoryHash%>" />
                    <div style="height:auto; max-height: 96vh; overflow:auto; min-width: 140px; padding-top: 10px;">
                    <%
                    	//Enumeration en=patientIdNames.keys();
                        if((totalNumDocs) > 0){
                    %>
                        <div>
                        	<a id="totalAll" href="javascript:void(0);" title="<bean:message key="global.All"/> <%=totalNumDocs%>" onclick="un_bold(this);changeView(CATEGORY_ALL);">
                        		<bean:message key="global.All"/></a>
                        </div>
                        <br>

    				<% }

                       if((totalDocs)>0){
					%>
						<div>
							<a id="totalDocs" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_DOCUMENTS);"
							   title="<bean:message key="global.Documents"/> "><bean:message key="global.Documents"/> (<span id="totalDocsNum"><%=totalDocs%></span>)
						   </a>
					   </div>
                     <%} if((totalLabs)>0){%>
                       <div>
                            <a id="totalHL7s" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_HL7);" title="HL7">
                           		HL7 (<span id="totalHL7Num"><%=totalLabs%></span>)
                           	</a>
                       </div>

					<%}
					  if(totalLabs>0){%><br><%}

					%>
					    <div>
					    	<a id="totalNormals" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_NORMAL);" title="<bean:message key="global.normal"/>">
					    		<bean:message key="global.normal"/>
				    		</a>
		    			</div>

						<div>
    						<a id="totalAbnormals" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_ABNORMAL);" title="<bean:message key="global.Abnormal"/>">
    							<bean:message key="global.Abnormal"/>
   							</a>

						</div>
						<div>
    						<a id="sortbynum" href="javascript:void(0);" onclick="jQuery('#patientsdoclabs').toggle(); jQuery('#patientsdoclabsB').toggle();un_bold(this);" title="Toggle sort by number of results or by name">
    							<bean:message key="oscarMDS.index.ToggleByNo"/>
   							</a>

						</div>
						<dl id="patientsdoclabs">
				    <%
				         for (PatientInfo info : patients) {
				                        String patientId= info.id + "";
				                        String patientName= info.toString();
                                        String[] names = patientName.split(", ");
				                        String shortName= names[0]+" "+ names[1].charAt(0);
				                        int numDocs= info.getDocCount() + info.getLabCount();
				   %>

   					   <dt> <img id="plus<%=patientId%>" alt="plus" src="<%=request.getContextPath()%>/images/plus.png" onclick="showhideSubCat('plus','<%=patientId%>');"/>
       					    <img id="minus<%=patientId%>" alt="minus" style="display:none;" src="<%=request.getContextPath()%>/images/minus.png" onclick="showhideSubCat('minus','<%=patientId%>');"/>
       						<a id="patient<%=patientId%>all" class="ptall" href="javascript:void(0);"  onclick="un_bold(this);changeView(CATEGORY_PATIENT,<%=patientId%>);"
                            title="<%=patientName%>">
                            <%=shortName%> (<span id="patientNumDocs<%=patientId%>"><%=numDocs%></span>)
                            </a>
                    		<dl id="labdoc<%=patientId%>showSublist" style="display:none" >
                   <%if (info.getDocCount() > 0) {%>
                        		<dt>
                        			<a id="patient<%=patientId%>docs" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,<%=patientId%>,CATEGORY_TYPE_DOC);" title="<bean:message key="global.Documents"/> ">
                        				<bean:message key="global.Documents"/>  (<span id="pDocNum_<%=patientId%>"><%=info.getDocCount()%></span>)
                       				</a>
                        		</dt>
                   <%} if (info.getLabCount() > 0) {%>
                     			<dt>
                     				<a id="patient<%=patientId%>hl7s" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,<%=patientId%>,CATEGORY_TYPE_HL7);" title="HL7">
                     					HL7 (<span id="pLabNum_<%=patientId%>"><%=info.getLabCount()%></span>)
                   					</a>
                        		</dt>
                   <%}%>
                    		</dl>
                    	</dt>

			<% if (selectedCategoryPatient != null) { if (selectedCategoryPatient.equals(Integer.toString(info.id))) { %>
			<script>
				showhideSubCat('plus','<%=info.id%>');
				un_bold(document.getElementById('patient<%=info.id%><%=(selectedCategoryType.equals("CATEGORY_TYPE_HL7"))?"hl7s":(selectedCategoryType.equals("CATEGORY_TYPE_DOC")?"docs":"all")%>'));
			</script>
			<% } } %>
                   <%}%>

				   <% if (unmatchedDocs > 0 || unmatchedLabs > 0) { %>
						<dt> <img id="plus0" alt="plus" src="<%=request.getContextPath()%>/images/plus.png" onclick="showhideSubCat('plus','0');"/>
       					    <img id="minus0" alt="minus" style="display:none;" src="<%=request.getContextPath()%>/images/minus.png" onclick="showhideSubCat('minus','0');"/>
       						<a id="patient0all" href="javascript:void(0);"  onclick="un_bold(this);changeView(CATEGORY_PATIENT,0)" title="<bean:message key="global.Unmatched"/>"><bean:message key="global.Unmatched"/> (<span id="patientNumDocs0"><%=unmatchedDocs + unmatchedLabs%></span>)</a>
                    		<dl id="labdoc0showSublist" style="display:none" >
                   <%if (unmatchedDocs > 0) {%>
                        		<dt>
                        			<a id="patient0docs" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,0,CATEGORY_TYPE_DOC);" title="<bean:message key="global.Documents"/> ">
                        				<bean:message key="global.Documents"/> (<span id="pDocNum_0"><%=unmatchedDocs%></span>)
                       				</a>
                        		</dt>
                   <%} if (unmatchedLabs > 0) {%>
                     			<dt>
                     				<a id="patient0hl7s" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,0,CATEGORY_TYPE_HL7);" title="HL7">
                     					HL7 (<span id="pLabNum_0"><%=unmatchedLabs%></span>)
                   					</a>
                        		</dt>
                   <%}%>
                    		</dl>

                    	</dt>

					<% } %>

                  	</dl>
						<dl id="patientsdoclabsB" style="display:none">
				    <%
if (patients!=null) {
	Collections.sort(patients, new Sortbylabnum());
}
				         for (PatientInfo info : patients) {
				                        String patientId= info.id + "";
				                        String patientName= info.toString();
                                        String[] names = patientName.split(", ");
				                        String shortName= names[0]+" "+ names[1].charAt(0);
				                        int numDocs= info.getDocCount() + info.getLabCount();
				   %>

   					   <dt> <img id="plus<%=patientId%>B" alt="plus" src="<%=request.getContextPath()%>/images/plus.png" onclick="showhideSubCat('plus','<%=patientId%>');"/>
       					    <img id="minus<%=patientId%>B" alt="minus" style="display:none;" src="<%=request.getContextPath()%>/images/minus.png" onclick="showhideSubCat('minus','<%=patientId%>');"/>
       						<a id="patient<%=patientId%>allB" href="javascript:void(0);"  onclick="un_bold(this);changeView(CATEGORY_PATIENT,<%=patientId%>);"
                            title="<%=patientName%>">
                            <%=shortName%> (<span id="patientNumDocs<%=patientId%>"><%=numDocs%></span>)
                            </a>
                    		<dl id="labdoc<%=patientId%>showSublistB" style="display:none" >
                   <%if (info.getDocCount() > 0) {%>
                        		<dt>
                        			<a id="patient<%=patientId%>docsB" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,<%=patientId%>,CATEGORY_TYPE_DOC);" title="<bean:message key="global.Documents"/>">
                        				<bean:message key="global.Documents"/> (<span id="pDocNum_<%=patientId%>"><%=info.getDocCount()%></span>)
                       				</a>
                        		</dt>
                   <%} if (info.getLabCount() > 0) {%>
                     			<dt>
                     				<a id="patient<%=patientId%>hl7sB" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,<%=patientId%>,CATEGORY_TYPE_HL7);" title="HL7">
                     					HL7 (<span id="pLabNum_<%=patientId%>"><%=info.getLabCount()%></span>)
                   					</a>
                        		</dt>
                   <%}%>
                    		</dl>
                    	</dt>

			<% if (selectedCategoryPatient != null) { if (selectedCategoryPatient.equals(Integer.toString(info.id))) { %>
			<script>
				showhideSubCat('plus','<%=info.id%>');
				un_bold(document.getElementById('patient<%=info.id%><%=(selectedCategoryType.equals("CATEGORY_TYPE_HL7"))?"hl7s":(selectedCategoryType.equals("CATEGORY_TYPE_DOC")?"docs":"all")%>'));
			</script>
			<% } } %>
                   <%}%>

				   <% if (unmatchedDocs > 0 || unmatchedLabs > 0) { %>
						<dt> <img id="plus0" alt="plus" src="<%=request.getContextPath()%>/images/plus.png" onclick="showhideSubCat('plus','0');"/>
       					    <img id="minus0" alt="minus" style="display:none;" src="<%=request.getContextPath()%>/images/minus.png" onclick="showhideSubCat('minus','0');"/>
       						<a id="patient0allB" href="javascript:void(0);"  onclick="un_bold(this);changeView(CATEGORY_PATIENT,0)" title="Unmatched">Unmatched (<span id="patientNumDocs0"><%=unmatchedDocs + unmatchedLabs%></span>)</a>
                    		<dl id="labdoc0showSublistB" style="display:none" >
                   <%if (unmatchedDocs > 0) {%>
                        		<dt>
                        			<a id="patient0docsB" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,0,CATEGORY_TYPE_DOC);" title="<bean:message key="global.Documents"/>">
                        				<bean:message key="global.Documents"/> (<span id="pDocNum_0"><%=unmatchedDocs%></span>)
                       				</a>
                        		</dt>
                   <%} if (unmatchedLabs > 0) {%>
                     			<dt>
                     				<a id="patient0hl7sB" href="javascript:void(0);" onclick="un_bold(this);changeView(CATEGORY_PATIENT_SUB,0,CATEGORY_TYPE_HL7);" title="HL7">
                     					HL7 (<span id="pLabNum_0"><%=unmatchedLabs%></span>)
                   					</a>
                        		</dt>
                   <%}%>
                    		</dl>

                    	</dt>

					<% } %>

                  	</dl>
                  	</div>

<%  } //end else
	if (!ajax) {
%>
             </td>
             <td style="width:96%; height:auto; vertical-align:top">
                 <div id="docViews" style="width:100%;height:96vh;overflow:auto;" onscroll="handleScroll(this)">

                 </div>
             </td>
          </tr>
     </table>
     </form>
</body>
</html>
<% } // end if(!ajax) %>