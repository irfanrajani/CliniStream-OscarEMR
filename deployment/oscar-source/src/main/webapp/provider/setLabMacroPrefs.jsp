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
<%@page import="java.util.*" %>
<%@page import="org.apache.commons.lang.StringUtils" %>
<%@page import="org.apache.logging.log4j.Logger" %>
<%@page import="org.oscarehr.util.SpringUtils" %>
<%@page import="org.oscarehr.common.model.Provider"%>
<%@page import="org.oscarehr.PMmodule.dao.ProviderDao"%>
<%@page import="org.oscarehr.common.dao.UserPropertyDAO"%>
<%@page import="org.oscarehr.common.model.UserProperty" %>
<%@page import="org.oscarehr.util.MiscUtils"%>
<%@page import="net.sf.json.JSONException"%>
<%@page import="net.sf.json.JSONSerializer"%>
<%@page import="net.sf.json.JSONArray"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="org.owasp.encoder.Encode" %>
<%
Logger logger = org.oscarehr.util.MiscUtils.getLogger();
           
String curProviderNo = (String) session.getAttribute("user"); 
ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
Provider provider = providerDao.getProvider(curProviderNo);

logger.info("user: " + curProviderNo);
List<Provider> providerList = null;
providerList = providerDao.getActiveProviders();

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
<html:html>
<head>
 <meta name="viewport" content="width=device-width, initial-scale=1.0">

<html:base />
<title><bean:message key="provider.labMacroPrefs.msgPrefs" /></title>

<!-- Bootstrap -->
<link rel="stylesheet" type="text/css" media="all" href="<c:out value="${ctx}"/>/library/bootstrap/3.0.0/css/bootstrap.min.css">
<script src="<c:out value="${ctx}"/>/js/jquery-1.12.3.js"></script>
<!-- Include all compiled plugins (below) -->
<script src="<c:out value="${ctx}"/>/library/bootstrap/3.0.0/js/bootstrap.min.js"></script>

<script>
    function assembleJSON(){
        var jsonStr ="["
        $("[id^=macro_]").each( function(index, el){
        // check to see if this has visibility
            if ( $(el).css('display') != 'none'){
                let text = this.id;
                const myArray = text.split("_");
                let suffix = myArray[1];
                // check to see if there is a name attribute for the macro
                if ( $("#name_"+suffix).val().length > 1 ){ 
                    //this.id +" is not hidden and has non zero name length"
                    jsonStr = jsonStr +"{\"name\":\"" + $("#name_"+suffix).val() + "\",\"acknowledge\":{\"comment\":\"" + $("#comment_"+suffix).val() + "\"},";
                    if ( $("#ticklerTo_"+suffix).val().length > 0 ) {
                        // there is a tickler
                        let tStart = "\"tickler\":{\"taskAssignedTo\":\"" + $("#ticklerTo_" + suffix).val()  + "\",\"message\":\"" + $("#message_"+suffix).val()+"\"";
                        let tSchedule = "";
                        if ( $("#quantity_"+suffix).val() > 0 ) {
                            //tickler set for future date
                            tSchedule = ",\"quantity\":\"" + $("#quantity_" + suffix).val() +"\",\"timeUnits\":\"" + $("#timeUnits_"+suffix).val()+"\"";
                        }
                        jsonStr = jsonStr + tStart + tSchedule + "},";
                    
                    }

                jsonStr = jsonStr + "\"closeOnSuccess\":true},\n";
                }   
            }
        })  
            jsonStr = jsonStr.substring(0,jsonStr.length-2) + "] ";
            if (jsonStr.length < 3) { jsonStr = ""; }
            $('#macroJSON').val(jsonStr);
    }
</script>
<style>
    .MainTableTopRow {
        background-color: gainsboro;
    }
</style>

</head>

<body class="BodyStyle" vlink="#0000FF">

<table class="MainTable" width="100%" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><H4>&nbsp;<bean:message key="provider.labMacroPrefs.msgPrefs" /></H4></td>
		<td style="text-align:center;" class="MainTableTopRowRightColumn"><bean:message key="provider.labMacroPrefs.title" /></td>
	</tr>
</table>
			<!-- form starts here -->
			
<form name="setProviderNoteStaleDateForm" method="post" action="<c:out value="${ctx}"/>/setProviderStaleDate.do">
						<input type="hidden" name="method" value="saveLabMacroPrefs">
<div class="container"><br>

<%
String method = request.getParameter("method");
if (method.equals("saveLabMacroPrefs")) {
%>
    <div class="alert alert-success"><bean:message key="provider.labMacroPrefs.msgSuccess" /></div>
<% } %>
<%
    UserPropertyDAO upDao = SpringUtils.getBean(UserPropertyDAO.class);
    UserProperty up = upDao.getProp(curProviderNo,UserProperty.LAB_MACRO_JSON);
    if(up != null && !StringUtils.isEmpty(up.getValue())) {

    %>  
<%
    try {
//[{"name":"APT","acknowledge":{"comment":"APT"},"tickler":{"taskAssignedTo":"101","message":"APT"},"closeOnSuccess":true},{"name":"TBS","acknowledge":{"comment":"TBS"},"tickler":{"taskAssignedTo":"101","message":"TBS"},"closeOnSuccess":true}] 
        JSONArray macros = (JSONArray) JSONSerializer.toJSON(up.getValue());
            if(macros != null) {
                for(int x=0;x<macros.size();x++) {
                JSONObject macro = macros.getJSONObject(x);
                String name = macro.getString("name");
                String comment = "";
                String ticklerTo = "";
                String message = "";
                String quantity = "0";
                String timeUnits = "1";
                if(macro.has("acknowledge")){
                    comment = Encode.forHtmlAttribute(macro.getJSONObject("acknowledge").getString("comment"));
                }
                if(macro.has("tickler")){
                    ticklerTo = Encode.forHtmlAttribute(macro.getJSONObject("tickler").getString("taskAssignedTo"));
                    message = Encode.forHtmlAttribute(macro.getJSONObject("tickler").getString("message"));
                    if(macro.getJSONObject("tickler").has("quantity") && macro.getJSONObject("tickler").has("timeUnits")){
                        quantity = Encode.forHtmlAttribute(macro.getJSONObject("tickler").getString("quantity"));
                        timeUnits = Encode.forHtmlAttribute(macro.getJSONObject("tickler").getString("timeUnits"));
                    }
                }
                boolean closeOnSuccess = macro.has("closeOnSuccess") && macro.getBoolean("closeOnSuccess");
                												  		
%>
<!--<script>
console.log("macro named " + "<%=name%>" + " with comment of " + "<%=comment%>" + " and perhaps a tickler for " + "<%=ticklerTo%>" + " message " + "<%=message%>" + " in " + "<%=quantity%>" + " " + "<%=timeUnits%>" + "/1");
</script> -->
 <div class="form-group row" id="macro_<%=x%>">

    <div class="col-sm-2">
     <label for="name_<%=x%>"><bean:message key="global.macro" /></label><br><input type="text" id="name_<%=x%>" class="" placeholder="<bean:message key="name" />" style="width:90px;" value="<%=name%>">
    </div>

    <div class="col-sm-3">
     <label for="comment_<%=x%>"><bean:message key="caseload.msgLab" />&nbsp;<bean:message key="oscarMDS.segmentDisplay.btnComment" /></label><br><input type="text" id="comment_<%=x%>" class="" style="width:95%;" value="<%=comment%>" placeholder="<bean:message key="oscarMDS.segmentDisplay.btnComment" />">
    </div>

    <div class="col-sm-2">
      <%
        String val1 = ticklerTo;
        if(val1 == null) val1 = "";
        %> 
		    <label for="ticklerTo_<%=x%>"><bean:message key="tickler.ticklerMain.msgAssignedTo" /></label><br><select id="ticklerTo_<%=x%>" name="ticklerTo_<%=x%>" class="form-control input-sm" style="width:95%;">
            <option value="" <%=(val1.equals("")?"selected=\"selected\"":"") %> ></option>
			<%for(Provider p: providerList) {%>
				<option value="<%=p.getProviderNo()%>"<%=(val1.equals(p.getProviderNo())?"selected=\"selected\"":"") %>><%=Encode.forHtmlAttribute(p.getFullName())%></option>
						<%}%>
			</select>
    </div>
    <div class="col-sm-2 ">
     <label for="message_<%=x%>"><bean:message key="global.tickler" /></label><br><input type="text" id="message_<%=x%>" class="" style="width:95%;" placeholder="<bean:message key="tickler.ticklerMain.msgMessage" />" value="<%=message%>">
    </div>
    <div class="col-sm-3 ">
     <label for="schedule_<%=x%>"><bean:message key="tickler.ticklerMain.msgDate" /></label><br><input type="number" id="quantity_<%=x%>" class="" style="width:50px;" value="<%=quantity%>"><select id="timeUnits_<%=x%>"  style="width:80px;"> 
            <option value="1" <%=(timeUnits.equals("1")?"selected=\"selected\"":"") %>><bean:message key="global.days" /></option>
            <option value="7" <%=(timeUnits.equals("7")?"selected=\"selected\"":"") %>><bean:message key="global.weeks" /></option>
            <option value="30" <%=(timeUnits.equals("30")?"selected=\"selected\"":"") %>><bean:message key="global.months" /></option>
            <option value="365" <%=(timeUnits.equals("365")?"selected=\"selected\"":"") %>><bean:message key="global.years" /></option>
        </select>
    </div>
    <div class="col-sm-2">
     &nbsp;<input type="button" id="delete_<%=x%>" class="btn btn-link" value="<bean:message key="global.btnDelete" />" onclick="$('#macro_<%=x%>').hide();">
    </div>
 </div>
         
        <%
                }
            }
        }catch(JSONException e ) {
            MiscUtils.getLogger().error("Invalid JSON for lab macros",e);
		}
}
%>

 <div class="form-group row" id="macro_new">

    <div class="col-sm-2">
     <label for="name_new"><bean:message key="global.macro" /></label><br><input type="text" id="name_new" class="" style="width:90px;" placeholder="<bean:message key="name" />" value="">
    </div>

    <div class="col-sm-3">
     <label for="comment_new"><bean:message key="caseload.msgLab" />&nbsp;<bean:message key="oscarMDS.segmentDisplay.btnComment" /></label><br><input type="text" id="comment_new" class="" style="width:95%;" value="" placeholder="<bean:message key="oscarMDS.segmentDisplay.btnComment" />">
    </div>

    <div class="col-sm-2">

					<label for="ticklerTo_new"><bean:message key="tickler.ticklerMain.msgAssignedTo" /></label><select id="ticklerTo_new" name="ticklerTo_new" class="form-control input-sm" style="width:95%;">
					<option value="" selected="selected"></option>
					<%for(Provider p: providerList) {%>
						<option value="<%=p.getProviderNo()%>"><%=Encode.forHtmlAttribute(p.getFullName())%></option>
						<%}%>
					</select>
    </div>
    <div class="col-sm-2">
     <label for="message_new"><bean:message key="global.tickler" /></label><br><input type="text" id="message_new" class="" placeholder="<bean:message key="tickler.ticklerMain.msgMessage" />" style="width:95%;" value="">
    </div>
    <div class="col-sm-3 ">
     <label for="schedule_new"><bean:message key="tickler.ticklerMain.msgDate" /></label><br><input type="number" id="timeUnits_new" class="" style="width:50px;" value="0"><select id="schedule_new"> 
            <option value="1"><bean:message key="global.days" /></option>
            <option value="7"><bean:message key="global.weeks" /></option>
            <option value="30"><bean:message key="global.months" /></option>
            <option value="365"><bean:message key="global.years" /></option>
        </select>
    </div>
    <div class="col-sm-2">
        &nbsp;<input type="button" id="add_new" class="btn btn-link" value="Add" style="visibility:hidden;">
    </div>
</div>


  <div class="form-group row">
<br>
    <div class="col-sm-5 col-sm-offset-1">
        <input type="submit" class="btn btn-primary" value="<bean:message key="global.btnSave" />" onclick="assembleJSON();"/>
<input type="button" class="btn" value="<bean:message key="global.btnClose" />" onclick="window.close();"/>
<!--<input type="button" class="btn " value="assembleJSON"  onclick="assembleJSON();"/>-->
<br> <a href="javascript:void(0);" onclick="$('#raw').toggle(); " style="color:white">Show</a>
    </div>
    <div class="col-sm-5 ">
       
    </div>
  </div>
<div>
</div>
  <div class="form-group row" style="display:none;" id="raw">
  <textarea name="labMacroJSON.value" id="macroJSON" style="width:80%;height:80%" rows="25"><%=Encode.forHtmlAttribute((up != null && !StringUtils.isEmpty(up.getValue()))?up.getValue():"")%></textarea>
  <input type="submit" class="btn" value="<bean:message key="global.btnSave" />" />
  </div>
</form>
</body>
</html:html>