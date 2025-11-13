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
<!DOCTYPE HTML>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    String user=(String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>
<html:html locale="true">
<head>
<title>Form Export</title>
	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/library/bootstrap/3.0.0/css/bootstrap.min.css" />
 	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/css/jquery.dataTables.min.css" />
	<link rel="stylesheet" type="text/css" href="${ pageContext.request.contextPath }/web/css/Dashboard.css" />
	<script src="${ pageContext.request.contextPath }/library/jquery/jquery-3.6.4.min.js"></script>
	 <!-- migrate needed for 3.0.0/js/bootstrap.min.js to support at least jQuery.fn.focus() but manages quietly without it -->
	<script src="${ pageContext.request.contextPath }/library/bootstrap/3.0.0/js/bootstrap.min.js" ></script>
	<script src="${ pageContext.request.contextPath }/library/DataTables/datatables.min.js"></script>
	<!--<script src="${ pageContext.request.contextPath }/library/DataTables-1.10.12/media/js/dataTables.bootstrap.min.js" ></script>-->


<style>

</style>
<script>
$(function () {
    $("#formset").change(function() {
    var val = $(this).val();
    if(val === ""){
        $("#hidden_url").show();
    } else {
        $("#hidden_url").hide();
    }
    $("#info").text($(this).val());
    });
});

function openPage(url,demo,id) {
    return new Promise((resolve)=>{
         url=url+id+"&demographic_no="+demo;
         console.log("opening "+url);
         let newWindow = window.open(url);
         resolve(newWindow);
    });
}

function printPage(theWindow) {
     return new Promise((resolve)=>{
        setTimeout(()=>{
            console.log("clicking print submit");
            $(theWindow.document).ready(function(){
                if ($(theWindow.document).find('input[type="submit"][value="Print All"]').length) {
                    $(theWindow.document).find('input[type="submit"][value="Print All"]').first().trigger("click");
                } else {
                    $(theWindow.document).find('input[type="submit"][value="Print"]').first().trigger("click");
                }
                onarenhanced(theWindow);
                resolve(theWindow);
            });
        },600);
      });
}

function closeWindow(theWindow) {
     return new Promise((resolve)=>{
        setTimeout(()=>{
            theWindow.close();
            resolve("Process Complete");
        },500);
      });
}

function onarenhanced(theWindow) {
    // code to bypass the dynamic modal print dialog for ON AR Enhanced
    if ($('#formset option:selected').text() != 'ON AR Enhanced') { return; } //sanity check
    theWindow.document.forms[0].submit.value="print";
	theWindow.document.forms[0].target="_blank";
	var url = "../form/createpdf?";
	var multiple=0;
	url += "__title=Antenatal+Record+Part+1&__cfgfile=onar1enhancedPrintCfgPg1&__template=onar1&__numPages=1&postProcessor=ONAR1EnhancedPostProcessor";
	multiple++;
	url+="__title"+multiple+"=Antenatal+Record+Part+2&__cfgfile"+multiple+"=onar2enhancedPrintCfgPg1&__cfgGraphicFile"+multiple+"=onar2PrintGraphCfgPg1&__template"+multiple+"=onar2&postProcessor"+multiple+"=ONAR2EnhancedPostProcessor";
url=url+"&multiple="+(multiple+1);
	theWindow.document.forms[0].action=url;
	$(theWindow.document).find('#printBtn').trigger("click");

}

function process(){
    $('.alert').show();
    console.log("processing");
    const jsonString = document.getElementById("patientset").value;
    const jsonArrayObject = JSON.parse(jsonString);

    var selectElement = document.getElementById("formset");
    var url = selectElement.value;
    var selectedIndex = selectElement.selectedIndex;
    var selectedOption = selectElement.options[selectedIndex];
    var displayValue = selectedOption.text;
    if (displayValue == "other"){
        url = document.getElementById("hidden_url").value;
    }
    var i = 0;
    jsonArrayObject.forEach((item) => {
            console.log(item.demo + ", id of="+item.id);
            openPage(url, item.demo, item.id)
            .then(page => printPage(page))
            .then(page => closeWindow(page))
            .then(finalMessage => console.log(finalMessage))
            .catch(error => console.error('An error has occured:', error));
        i += 1;
        $('#alertspan').append("<br>"+i+". demo:"+ item.demo + " form " + displayValue + " printed to pdf");
    });
}
</script>
</head>

<body>

<div class="span12">
    <div id="header"><h4>&nbsp;&nbsp;PDF Form Export
        </h4>
    </div>
</div>
<div>

    <div class="container-fluid well" >
    <form class="form-horizontal">
        <div class="row">
            <h4>Instructions:</h4>
            <ol>
                <li>Alter firefox options to print without dialog<br>settings>general>pdf>save file</li>
                <li>Select the form type in the dropdown</li>
                <li>Insert a JSON pair of demographic id and max(id) into the text area<br>
                    SELECT
                        CONCAT('{"demo":',`demographic_no`,',"id":', MAX(`ID`),'},') AS json
                    FROM
                        formRourke2009
                    GROUP BY
                        `demographic_no`;
                    <br>
                    </li>
                <li>Click go</li>
            </ol>
        </div>
        <div class="row">
            <div class="col-md-4">
                <label for="formset">Form Set:</label>
                <select name="formset" id="formset">
                    <option value="../form/forwardshortcutname.jsp?formname=Rourke2009&formId=">Rourke 2009</option>
                    <option value="../form/forwardshortcutname.jsp?formname=Rourke2006&formId=">Rourke 2006</option>
                    <option value="../form/formonarpg2.jsp?view=1&user=<%=user%>&formId=">AR2005 p1</option>
                    <option value="../form/formonarpg3.jsp?view=1&user=<%=user%>&formId=">AR2005 p2</option>
                    <option value="../form/forwardshortcutname.jsp?formname=ON AR Enhanced&formId=">ON AR Enhanced</option>
                    <option value="">other</option>
                </select>
                <input type="text" id="hidden_url" style="display:none" placeholder="form url"><br>
                <span id="info">../form/forwardshortcutname.jsp?formname=Rourke2009&formId=</span>
            </div>
            <div class="row col-md-6">
                <label for="patientset">JSON of demo and id pairs:</label><br>eg [{"demo":7592,"id":7},{"demo":7719,"id":509}]
                <div class="form-group gorm-group-lg">
                <textarea class="input-lg" id="patientset">
                </textarea>
                &nbsp;&nbsp;<input type="button" class="btn btn-primary" value="go" onclick="process()">
                </div>
            </div>
        </div>
    </form>
    <div class="alert alert-success" role="alert" style="display: none;">
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
        <span id="alertspan">Processing..</span>
    </div>
    </div>

</div>
</body>

</html:html>