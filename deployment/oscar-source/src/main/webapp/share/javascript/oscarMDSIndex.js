/**
 *  Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved. *
 *  This software is published under the GPL GNU General Public License.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version. *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details. * * You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *
 *
 *
 *  This software was written for the
 *  Department of Family Medicine
 *  McMaster University
 *  Hamilton
 *  Ontario, Canada   Creates a new instance of CommonLabResultData

 */


/************init global data methods*****************/
var oldestLab = null;
var popup;

function  updateDocStatusInQueue(docid){//change status of queue document link row to I=inactive
    //console.log('in updateDocStatusInQueue, docid '+docid);
    var url="../dms/inboxManage.do"
    var data="docid="+docid+"&method=updateDocStatusInQueue";

	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (transport) {	},
		error: function(jqXHR, err, exception) {
			//alert("Error " + jqXHR.status + " " + err);
		}
	});

}

function saveNext(docid) {
	updateDocumentAndNext('forms_'+docid);
}

function initPatientIds(s){
	var r= new Array();
	var t=s.split(',');
	for(var i=0;i<t.length;i++){
		var e=t[i];
		e.replace(/\s/g,'');
		if(e.length>0){
			r.push(e);
		}
	}
	return r;
}
function initTypeDocLab(s){
	return initHashtableWithList(s);
}
function initPatientDocs(s){
	return initHashtableWithList(s);
}
function initDocStatus(s){
	return initHashtableWithString(s);
}
function initDocType(s){
	return initHashtableWithString(s);
}
function initNormals(s){
	return initList(s);
}
function initAbnormals(s){
	return initList(s);
}
function initPatientIdNames(s){//;1=abc,def;2=dksi,skal;3=dks,eiw
var ar=s.split(';');
var r=new Object();
for(var i=0;i<ar.length;i++){
	var e=ar[i];
	if(e.length>0){
		var ear=e.split('=');
		if(ear && ear!=null && ear.length>1){
			var k=ear[0];
			var v=ear[1];
			r[k]=v;
		}
	}
}
return r;
}
function initHashtableWithList(s){//for typeDocLab,patientDocs
	s=s.replace('{','');
s=s.replace('}','');
if(s.length>0){
	var sar=s.split('],');
	var r=new Object();
	for(var i=0;i<sar.length;i++){
		var ele=sar[i];
		ele=ele.replace(/\s/g,'');
		var elear=ele.split('=');
		var key=elear[0];
		var val=elear[1];
		val=val.replace('[','');
		val=val.replace(']','');
		val=val.replace(/\s/g,'');
		//console.log(key);
		//console.log(val);
		var valar=val.split(',');
		r[key]=valar;
	}
	return r;
}else{
	return new Object();
}

}

function initHashtableWithString(s){//for docStatus,docType
	s=s.replace('{','');
	s=s.replace('}','');
	s=s.replace(/\s/g,'');
	var sar=s.split(',');
	var r=new Object();
	for(var i=0;i<sar.length;i++){
		var ele=sar[i];
		if(ele.length>0){
			var ear=ele.split('=');
			if(ear.length>0){
				var key=ear[0];
				var val=ear[1];
				r[key]=val;}
		}}
	return r;
}

function initList(s){//normals,abnormals
	s=s.replace('[','');
	s=s.replace(']','');
	s=s.replace(/\s/g,'');
	if(s.length>0){
		var sar=s.split(',');
		return sar;
	}else{
		var re=new Arrays();
		return re;
	}
}
/********************global data util methods *****************************/
function getDocLabFromCat(cat){
	if(cat.length>0){
		return typeDocLab[cat];
	}
}
function removeIdFromDocStatus(doclabid){
	delete docStatus[doclabid];
}
function removeIdFromDocType(doclabid){
	if(doclabid&&doclabid!=null){
		delete docType[doclabid];
	}
}
function removeIdFromTypeDocLab(doclabid){
	for(var j=0;j<types.length;j++){
		var cat=types[j];
		var a=typeDocLab[cat];
		if(a && a!=null){
			if(a.length>0){
				var i=a.indexOf(doclabid);
				if(i!=-1){
					a.splice(i,1);
					typeDocLab[cat]=a;
				}
			}else{
				delete typeDocLab[cat];
			}
		}
	}
}
function removeNormal(doclabid){
	var index=normals.indexOf(doclabid);
	if(index!=-1){
		normals.splice(index,1);
	}
}
function removeAbnormal(doclabid){
	var index=abnormals.indexOf(doclabid);
	if(index!=-1){
		abnormals.splice(index,1);
	}
}
function removePatientId(pid){
	if(pid){
		var i=patientIds.indexOf(pid);
		//console.log('i='+i+'patientIds='+patientIds);
		if(i!=-1){
			patientIds.splice(i,1);
		}
		//console.log(patientIds);
	}}
function removeEmptyPairFromPatientDocs(){
	var notUsedPid=new Array();
	for(var i=0;i<patientIds.length;i++){
		var pid=patientIds[i];
		var e=patientDocs[pid];

		if(!e){
			notUsedPid.push(pid);
		}
		else if(e==null || e.length==0){
			delete patientDocs[pid];
		}
	}
	//console.log(notUsedPid);
	for(var i=0;i<notUsedPid.length;i++){
		removePatientId(notUsedPid[i]);//remove pid if it doesn't relate to any doclab
	}
}
function removeIdFromPatientDocs(doclabid){
//	console.log('in removeidfrompatientdocs'+doclabid);
//console.log(patientIds);
//console.log(patientDocs);
for(var i=0;i<patientIds.length;i++){
	var pid=patientIds[i];
	var a=patientDocs[pid];
	//console.log('a');
	//console.log(a);
	if(a&&a.length>0){
		var f=a.indexOf(doclabid);
		//console.log('before splice');
		//console.log(patientDocs);
		if(f!=-1){
			a.splice(f, 1);
			patientDocs[pid]=a;
		}
		//console.log('after splice');
		//console.log(patientDocs);
	}
	else{
		delete patientDocs[pid];
		//console.log('after delete');
		//console.log(patientDocs);
	}
}
//console.log('after remove');
//console.log(patientDocs);
}
function addIdToPatient(did,pid){
	var a=patientDocs[pid];
	if(a && a!=null){
		a.push(did);
		patientDocs[pid]=a;
	}else{
		var ar=[did];
		patientDocs[pid]=ar;
	}
}
function addPatientId(pid){
	patientIds.push(pid);
}
function addPatientIdName(pid,name){
	var n=patientIdNames[pid];
	if(n || n==null){
		patientIdNames[pid]=name;
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
			var type=checkType(doclabid);
			var url=contextpath + "/oscarMDS/SendMRP.do";
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
			        console.log(jqXHR.status);
				    ele.checked=false;
				    document.getElementById('mrp_fail_'+doclabid).style.display = '';
		        }
	        });


		}else{
			ele.checked=false;
		}
	}
}

function forwardDocument(docId) {
	var frm = "#reassignForm_" + docId;
	var query = jQuery(frm).serialize();

	jQuery.ajax({
		type: "POST",
		url:  contextpath + "/oscarMDS/ReportReassign.do",
		data: query,
		success: function (data) {
			frm = "#frmDocumentDisplay_" + docId;
			query = jQuery(frm).serialize();
			jQuery.ajax({
				type: "POST",
				url: contextpath + "/dms/showDocument.jsp",
				data: query,
				success: function(data) {
					jQuery("#document_"+docId).html(data);
				}
			});
		},
		error: function(jqXHR, err, exception) {
			alert(jqXHR.status);
		}
	});
}


function rotate180(id) {
	jQuery("#rotate180btn_" + id).attr('disabled', 'disabled');
    var displayDocumentAs=document.getElementById('displayDocumentAs_'+id).value;
    var url = contextpath + "/dms/SplitDocument.do";
    var data = "method=rotate180&document=" + id;
	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (data) {
		    jQuery("#rotate180btn_" + id).removeAttr('disabled');
            if(displayDocumentAs=="PDF") {
                showPDF(id,contextpath);
            } else {
                jQuery("#docImg_" + id).attr('src', contextpath + "/dms/ManageDocument.do?method=viewDocPage&doc_no=" + id + "&curPage=1&rand=" + (new Date().getTime()));
            }
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});


}

function rotate90(id) {
	jQuery("#rotate90btn_" + id).attr('disabled', 'disabled');
	var displayDocumentAs=document.getElementById('displayDocumentAs_'+id).value;
    var url = contextpath + "/dms/SplitDocument.do";
    var data = "method=rotate90&document=" + id;
	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (data) {
		    jQuery("#rotate90btn_" + id).removeAttr('disabled');
            if(displayDocumentAs=="PDF") {
                showPDF(id,contextpath);
            } else {
                jQuery("#docImg_" + id).attr('src', contextpath + "/dms/ManageDocument.do?method=viewDocPage&doc_no=" + id + "&curPage=1&rand=" + (new Date().getTime()));
            }
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});
}

function removeFirstPage(id) {
	jQuery("#removeFirstPagebtn_" + id).attr('disabled', 'disabled');
	var displayDocumentAs=document.getElementById('displayDocumentAs_'+id).value;
    var url = contextpath + "/dms/SplitDocument.do";
    var data = "method=removeFirstPage&document=" + id;
	jQuery.ajax({
		type: "POST",
		url:  url,
		data: data,
		success: function (data) {
		    jQuery("#removeFirstPagebtn_" + id).removeAttr('disabled');
            if(displayDocumentAs=="PDF") {
                 showPDF(id,contextpath);
            } else {
                jQuery("#docImg_" + id).attr('src', contextpath + "/dms/ManageDocument.do?method=viewDocPage&doc_no=" + id + "&curPage=1&rand=" + (new Date().getTime()));
            }
		    var numPages = parseInt(jQuery("#numPages_" + id).text())-1;
		    jQuery("#numPages_" + id).text("" + numPages);
    		if (numPages <= 1) {
			    jQuery("#numPages_" + id).removeClass("multiPage");
			    jQuery("#removeFirstPagebtn_" + id).remove();
		    }
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});
}


function split(id) {
        	var loc = contextpath+"/oscarMDS/Split.jsp?document=" + id;
        	popupStart(1400, 1400, loc, "Splitter");
        }

function hideTopBtn(){
	document.getElementsByName('topFRBtn').style.display = 'none';
	if(document.getElementsByName('topFBtn') && document.getElementsByName('topFileBtn')){
		document.getElementsByName('topFBtn').style.display = 'none';
		document.getElementsByName('topFileBtn').style.display = 'none';
	}
}
function showTopBtn(){
	document.getElementsByName('topFRBtn').style.display = '';
	if(document.getElementsByName('topFBtn') && document.getElementsByName('topFileBtn')){
		document.getElementsByName('topFBtn').style.display = '';
		document.getElementsByName('topFileBtn').style.display = '';
	}
}

function popupStart(vheight,vwidth,varpage) {
	popupStart(vheight,vwidth,varpage,"helpwindow");
}

function popupStart(vheight,vwidth,varpage,windowname) {
	//console.log("in popupstart 4 args");
	//console.log(vheight+"--"+ vwidth+"--"+ varpage+"--"+ windowname);
	if(!windowname)
		windowname="helpwindow";
	//console.log(vheight+"--"+ vwidth+"--"+ varpage+"--"+ windowname);
	var page = varpage;
	windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
	popup=window.open(varpage, windowname, windowprops);
}

function reportWindow(page,height,width) {
	//console.log(page);
	if(height && width){
		windowprops="height="+height+", width="+width+", location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0" ;
	}else{
		windowprops="height=800, width=1200, location=no, scrollbars=yes, menubars=no, toolbars=no, resizable=yes, top=0, left=0";
	}
	popup = window.open(encodeURI(page), "labreport", windowprops);
	popup.focus();
}


function submitFile(doc){
	aBoxIsChecked = false;
	submitLabs = true;
	//var labs = doc.getElementsByName("flaggedLabs");
	var labs = jQuery("input[name='flaggedLabs']");
	var acks = jQuery("input[name='ackStatus']");
	var pats = jQuery("input[name='patientName']");
	for (i=0; i < labs.length; i++) {
		if (labs[i].checked == true) {
			if (acks[i].value == "false") {
				aBoxIsChecked = confirm("The lab for "+pats[i].value+" has not been attached to a demographic, would you like to file it anyways?");
				if(!aBoxIsChecked) {
					break;
				}
			}
			else {
				aBoxIsChecked = true;
			}
		}
	}
	if (aBoxIsChecked) {
		window.FileSelectedRows();
	}
}


function isRowShown(rowid){
	if(document.getElementById(rowid).style.display=='none')
	//if($(rowid).style.display=='none')
		return false;
	else
		return true;
}
function checkAllLabs(formId){
	var val = document.getElementsByName("checkA")[0].checked;
	var labs = document.getElementsByName("flaggedLabs");
	for (i =0; i < labs.length; i++){
		labs[i].checked = val;
	}
}

function wrapUp() {
	if (opener.callRefreshTabAlerts) {
		opener.callRefreshTabAlerts("oscar_new_lab");
		setTimeout("window.close();",100);
	} else {
		window.close();
	}
}

function showDocLab(childId,docNo,providerNo,searchProviderNo,status,demoName,showhide){//showhide is 0 = document currently hidden, 1=currently shown
	//create child element in docViews
	docNo=docNo.replace(' ','');//trim
	var type=checkType(docNo);
	//console.log('type'+type);
	//var div=childId;

	//var div=window.frames[0].document.getElementById(childId);
	var div=document.getElementsByName(childId);
	//alert(div);
	var url='';
	if(type=='DOC')
		url="../dms/showDocument.jsp";
	else if(type=='MDS')
		url="";
	else if(type=='HL7')
		url="../lab/CA/ALL/labDisplayAjax.jsp";
	else if(type=='CML')
		url="";
	else
		url="";

	docNo = docNo.replace('d', '');
	//console.log('url='+url);
	var data="segmentID="+docNo+"&providerNo="+providerNo+"&searchProviderNo="+searchProviderNo+"&status="+status+"&demoName="+demoName;

	jQuery.ajax({
		type: "GET",
		url:  url,
		data: data,
		success: function (code) {
            jQuery("#"+childid+":last-child").append(code);
		    //jQuery("#"+childid).html(code);
		    focusFirstDocLab();
    	},
		error: function(jqXHR, err, exception) {
			console.log(jqXHR.status);
		}
	});

}

function createNewElement(parent,child){
	//console.log('11 create new leme');
	var newdiv=document.createElement('div');
	//console.log('22 after create new leme');
	newdiv.setAttribute('id',child);
	var parentdiv=document.getElementsByName(parent);
	parentdiv.appendChild(newdiv);
	//console.log('55 after create new leme');
}

function clearDocView(){
	var docview=document.getElementsByName('docViews');
	//var docview=window.frames[0].document.getElementById('docViews');
	docview.innerHTML='';
}
function showhideSubCat(plus_minus,patientId){
	if(plus_minus=='plus'){
		document.getElementById('plus'+patientId).style.display = 'none';
		document.getElementById('minus'+patientId).style.display = '';
		document.getElementById('labdoc'+patientId+'showSublist').style.display = '';
	}else{
		document.getElementById('plus'+patientId).style.display = '';
		document.getElementById('minus'+patientId).style.display = 'none';
		document.getElementById('labdoc'+patientId+'showSublist').style.display = 'none';
	}
}
function un_bold(ele){
	if(ele == null || currentBold==ele.id){
		;
	}else{
		if(currentBold && document.getElementById(currentBold)!=null) {
			document.getElementById(currentBold).style.fontWeight='';
		}
		ele.style.fontWeight='bold';
		currentBold=ele.id;
	}
}
function re_bold(id) {
	if (id && document.getElementById(id)!=null) {
		document.getElementById(id).style.fontWeight='bold';
	}
}

function showPageNumber(page){
	var totalNoRow=document.getElementById('totalNumberRow').value;
	var newStartIndex=number_of_row_per_page*(parseInt(page)-1);
	var newEndIndex=parseInt(newStartIndex)+19;
	var isLastPage=false;
	if(newEndIndex>totalNoRow){
		newEndIndex=totalNoRow;
		isLastPage=true;
	}
	for(var i=0;i<totalNoRow;i++){
		if(document.getElementById('row'+i) && parseInt(newStartIndex)<=i && i<=parseInt(newEndIndex)) {
			document.getElementById('row'+i).style.display = '';
			//jQuery('#row'+i).show();
		}else if(jQuery('#row'+i)){
			document.getElementById('row'+i).style.display = 'none';
			//jQuery('#row'+i).hide();
		}
	}
	//update current page
	jQuery('#currentPageNum').html()=page;
	if(page==1)
	{
		if(jQuery('#msgPrevious')) jQuery('#msgPrevious').hide();
	}else if(page>1){
		if(jQuery('#msgPrevious')) jQuery('#msgPrevious').show();
	}
	if(isLastPage){
		if(jQuery('#msgNext'))    jQuery('#msgNext').hide();
	}
	else{
		if(jQuery('#msgNext'))    jQuery('#msgNext').show();
	}
}
function showTypePageNumber(page,type){
	var eles;
	var numberPerPage=20;
	if(type=='D'){
		eles=document.getElementsByName('scannedDoc');
		var length=eles.length;
		var startindex=(parseInt(page)-1)*numberPerPage;
		var endindex=startindex+numberPerPage-1;
		if(endindex>length-1){
			endindex=length-1;
		}
		//only display current page
		for(var i=startindex;i<endindex+1;i++){
			var ele=eles[i];
			ele.setStyle({display:'table-row'});
		}
		//hide previous page
		for(var i=0;i<startindex;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide later page
		for(var i=endindex;i<length;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide all labs
		eles=document.getElementsByName('HL7lab');
		for(i=0;i<eles.length;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
	}else if (type=='H'){
		eles=document.getElementsByName('HL7lab');
		var length=eles.length;
		var startindex=(parseInt(page)-1)*numberPerPage;
		var endindex=startindex+numberPerPage-1;
		if(endindex>length-1){
			endindex=length-1;
		}
		//only display current page
		for(var i=startindex;i<endindex+1;i++){
			var ele=eles[i];
			ele.setStyle({display:'table-row'});
		}
		//hide previous page
		for(var i=0;i<startindex;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide later page
		for(var i=endindex;i<length;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide all labs
		eles=document.getElementsByName('scannedDoc');
		for(i=0;i<eles.length;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
	}else if (type=='N'){
		var eles1=document.getElementsByClassName('NormalRes');
		var length=eles.length;
		var startindex=(parseInt(page)-1)*numberPerPage;
		var endindex=startindex+numberPerPage-1;
		if(endindex>length-1){
			endindex=length-1;
		}

		for(var i=startindex;i<endindex+1;i++){
			var ele=eles1[i];
			ele.setStyle({display:'table-row'});
		}
		//hide previous page
		for(var i=0;i<startindex;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide later page
		for(var i=endindex;i<length;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide all abnormals
		var eles2=document.getElementsByClassName('AbnormalRes');
		i=0;
		for(i=0;i<eles2.length;i++){
			var ele=eles2[i];
			ele.setStyle({display:'none'});
		}
	}else if (type=='AB'){
		var eles1=document.getElementsByClassName('AbnormalRes');
		var length=eles.length;
		var startindex=(parseInt(page)-1)*numberPerPage;
		var endindex=startindex+numberPerPage-1;
		if(endindex>length-1){
			endindex=length-1;
		}
		for(var i=startindex;i<endindex+1;i++){
			var ele=eles1[i];
			ele.setStyle({display:'table-row'});
		}
		//hide previous page
		for(var i=0;i<startindex;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide later page
		for(var i=endindex;i<length;i++){
			var ele=eles[i];
			ele.setStyle({display:'none'});
		}
		//hide all normals
		var eles2=document.getElementsByClassName('NormalRes');
		for(var i=0;i<eles2.length;i++){
			var ele=eles2[i];
			ele.setStyle({display:'none'});
		}
	}
}
function setTotalRows(){
	var ds=document.getElementsByName('scannedDoc');
	var ls=document.getElementsByName('HL7lab');
	for(var i=0;i<ds.length;i++){
		var ele=ds[i];
		total_rows.push(ele.id);
	}
	for(var i=0;i<ls.length;i++){
		var ele=ls[i];
		total_rows.push(ele.id);
	}
	total_rows=sortRowId(uniqueArray(total_rows));
	current_category=new Array();
	current_category[0]=document.getElementsByName('scannedDoc');
	current_category[1]=document.getElementsByName('HL7lab');
	current_category[2]=document.getElementsByClassName('NormalRes');
	current_category[3]=document.getElementsByClassName('AbnormalRes');
}
function checkBox(){
	var view = "all";

	if(jQuery('#documentCB').checked==1){
		view = "documents";
	}
	else if(jQuery('#hl7CB').checked==1){
		view = "labs";
	}
	else if(jQuery('#normalCB').checked==1){
		checkedArray.push('normal');
		view = "normal";
	}
	else if(jQuery('#abnormalCB').checked==1){
		view = "abnormal";
	}
	else if(jQuery('#unassignedCB').checked==1){
		view = "unassigned";
	}
	window.location.search = replaceQueryString(window.location.search, "view", view);
}

function displayCategoryPage(page){
	//console.log('in displaycategorypage, page='+page);
	//write all row ids to an array
	var displayrowids=new Array();
	for(var p=0;p<current_category.length;p++){
		var elements=new Array();
		elements=current_category[p];
		//console.log("elements.lenght="+elements.length);
		for(var j=0;j<elements.length;j++){
			var e=elements[j];
			var rowid=e.id;
			displayrowids.push(rowid);
		}
	}
	//make array unique
	displayrowids=uniqueArray(displayrowids);
	displayrowids=sortRowId(displayrowids);
	//console.log('sort and unique displaywords='+displayrowids);

	var numOfRows=displayrowids.length;
	//console.log(numOfRows);
	current_numberofpages=Math.ceil(numOfRows/number_of_row_per_page);
	//console.log(current_numberofpages);
	var startIndex=(parseInt(page)-1)*number_of_row_per_page;
	var endIndex=startIndex+(number_of_row_per_page-1);
	if(endIndex>displayrowids.length-1){
		endIndex=displayrowids.length-1;
	}
	//set current displaying rows
	current_rows=new Array();
	for(var i=startIndex;i<endIndex+1;i++){
		if(document.getElementById(displayrowids[i])){
			current_rows.push(displayrowids[i]);
		}
	}
	//loop through every thing,if it's in displayrowids, show it , if it's not hide it.
	for(var i=0;i<total_rows.length;i++){
		var rowid=total_rows[i];
		if(a_contain_b(current_rows,rowid)){
			document.getElementById('rowid').style.display = '';
		}else
			document.getElementById('rowid').style.display = 'none';
	}
}

function initializeNavigation(){
	jQuery('#currentPageNum').html()=1;
	//update the page number shown and update previous and next words
	if(current_numberofpages>1){
		jQuery('#msgNext').show();
		jQuery('#msgPrevious').hide();
	}else if(current_numberofpages<1){
		jQuery('#msgNext').hide();
		jQuery('#msgPrevious').hide();
	}else if(current_numberofpages==1){
		jQuery('#msgNext').hide();
		jQuery('#msgPrevious').hide();
	}
	//console.log("current_numberofpages "+current_numberofpages);
	jQuery('#current_individual_pages').html()="";
		if(current_numberofpages>1){
			for(var i=1;i<=current_numberofpages;i++){
				jQuery('#current_individual_pages').html()+='<a style="text-decoration:none;" href="javascript:void(0);" onclick="navigatePage('+i+')> [ '+i+' ] </a>';
			}
		}

}
function sortRowId(a){
	var numArray=new Array();
	//sort array
	for(var i=0;i<a.length;i++){
		var id=a[i];
		var n=id.replace('row','');
		numArray.push(parseInt(n));
	}
	numArray.sort(function(a,b){return a-b;});
	a=new Array();
	for(var i=0;i<numArray.length;i++){
		a.push('row'+numArray[i]);
	}
	return a;
}
function a_contain_b(a,b){//a is an array, b maybe an element in a.
	for(var i=0;i<a.length;i++){
		if(a[i]==b){
			return true;
		}
	}
	return false;
}

function uniqueArray(a){
	var r=new Array();
	o:for(var i=0,n=a.length;i<n;i++){
		for(var x=0,y=r.length;x<y;x++){
			if(r[x]==a[i]) continue o;
		}
		r[r.length]=a[i];
	}
	return r;
}

function navigatePage(p){
	var pagenum=parseInt(jQuery('#currentPageNum').html());
	if(p=='Previous'){
		navigatePage(pagenum-1);
	}
	else if(p=='Next'){
		navigatePage(pagenum+1);
	}
	else if(parseInt(p)>0){
		window.location.search = replaceQueryString(window.location.search, "page", parseInt(p));
	}
}

// TODO: Remove unused function.
function changeNavigationBar(){
	var pagenum=parseInt(jQuery('#currentPageNum').html());
	if(current_numberofpages==1){
		jQuery('#msgNext').hide();
		jQuery('#msgPrevious').hide();
	}
	else if(current_numberofpages>1 && current_numberofpages==pagenum){
		jQuery('#msgNext').hide();
		jQuery('#msgPrevious').show();
	}
	else if(current_numberofpages>1 && pagenum==1){
		jQuery('#msgNext').show();
		jQuery('#msgPrevious').hide();
	}else if(pagenum<current_numberofpages && pagenum>1){
		jQuery('#msgNext').show();
		jQuery('#msgPrevious').show();
	}
}
function syncCB(ele){
	var id=ele.id;
	if(id=='documentCB'){
		if(ele.checked==1)
			document.getElementById('documentCB2').checked=true;
		else
			document.getElementById('documentCB2').checked=false;
	}
	else if(id=='documentCB2'){
		if(ele.checked==1)
			document.getElementById('documentCB').checked=1;
		else
			document.getElementById('documentCB').checked=0;
	}
	else if(id=='hl7CB'){
		if(ele.checked==1)
			document.getElementById('hl7CB2').checked=1;
		else
			document.getElementById('hl7CB2').checked=0;
	}
	else if(id=='hl7CB2'){
		if(ele.checked==1)
			document.getElementById('hl7CB').checked=1;
		else
			document.getElementById('hl7CB').checked=0;
	}
	else if(id=='normalCB'){
		if(ele.checked==1)
			document.getElementById('normalCB2').checked=1;
		else
			document.getElementById('normalCB2').checked=0;
	}
	else if(id=='normalCB2'){
		if(ele.checked==1)
			document.getElementById('normalCB').checked=1;
		else
			document.getElementById('normalCB').checked=0;
	}
	else if(id=='abnormalCB'){
		if(ele.checked==1)
			document.getElementById('abnormalCB2').checked=1;
		else
			document.getElementById('abnormalCB2').checked=0;
	}
	else if(id=='abnormalCB2'){
		if(ele.checked==1)
			document.getElementById('abnormalCB').checked=1;
		else
			document.getElementById('abnormalCB').checked=0;
	}
}
function showAb_Normal(ab_normal){

	var ids=new Array();
	if(ab_normal=='normal'){
		ids=normals;
	}
	else if(ab_normal=='abnormal'){
		ids=abnormals;
	}
	var childId;
	if(ab_normal=='normal'){
		childId='normals';
	}else if (ab_normal=='abnormal'){
		childId='abnormals';
	}
	//console.log(childId);
	if(childId!=null && childId.length>0){
		clearDocView();
		createNewElement('docViews',childId);
		for(var i=0;i<ids.length;i++){
			var docLabId=ids[i].replace(/\s/g,'');
			var ackStatus=getAckStatusFromDocLabId(docLabId);
			var patientId=getPatientIdFromDocLabId(docLabId);
			var patientName=getPatientNameFromPatientId(patientId);
			if(current_first_doclab==0) current_first_doclab=docLabId;
			showDocLab(childId,docLabId,providerNo,searchProviderNo,ackStatus,patientName,ab_normal+'show');
		}
	}
}

function showSubType(patientId,subType){
	var labdocsArr=getLabDocFromPatientId(patientId);
	if(labdocsArr && labdocsArr!=null){
		var childId='subType'+subType+patientId;
		if(labdocsArr.length>0){
			//if(toggleElement(childId));
			// else{
			clearDocView();
			createNewElement('docViews',childId);
			for(var i=0;i<labdocsArr.length;i++){
				var labdoc=labdocsArr[i];
				labdoc=labdoc.replace(' ','');
				//console.log('check type input='+labdoc);
				var type=checkType(labdoc);
				var ackStatus=getAckStatusFromDocLabId(labdoc);
				var patientName=getPatientNameFromPatientId(patientId);
				if(current_first_doclab==0) current_first_doclab=labdoc;
				//console.log("type="+type+"--subType="+subType);
				if(type==subType)
					showDocLab(childId,labdoc,providerNo,searchProviderNo,ackStatus,patientName,'subtype'+subType+patientId+'show');
				else;
			}
			//toggleMarker('subtype'+subType+patientId+'show');
			//}
		}
	}
}

function getPatientNameFromPatientId(patientId){
	var pn=patientIdNames[patientId];
	if(pn&&pn!=null){
		return pn;
	}else{
		var url=contextpath+"/dms/ManageDocument.do";
		var data='method=getDemoNameAjax&demo_no='+patientId;

	    jQuery.ajax({
		    type: "POST",
		    url:  url,
		    data: data,
		    success: function (transport) {
			    var json=jQuery.parseJSON(transport);
			    if(json!=null ){
				    var pn=json.demoName;//get name from id
				    addPatientIdName(patientId,pn);
				    addPatientId(patientId);
				    return pn;
			    }
        	},
		    error: function(jqXHR, err, exception) {
			    console.log(jqXHR.status);
		    }
	    });
    }
}

function getAckStatusFromDocLabId(docLabId){
	return docStatus[docLabId];
}
function showAllDocLabs(){

	clearDocView();
	for(var i=0;i<patientIds.length;i++){
		var id=patientIds[i];
		//console.log("ids in showalldoclabs="+id);
		if(id.length>0){
			showThisPatientDocs(id,true);

		}
	}

}
function showCategory(cat){
	if(cat.length>0){
		var sA=getDocLabFromCat(cat);
		if(sA && sA.length>0){
			//console.log("sA="+sA);
			var childId="category"+cat;
			//if(toggleElement(childId));
			// else{
			clearDocView();
			createNewElement('docViews',childId);
			for(var i=0;i<sA.length;i++){
				var docLabId=sA[i];
				docLabId=docLabId.replace(/\s/g, "");
				//console.log("docLabId="+docLabId);
				var patientId=getPatientIdFromDocLabId(docLabId);
				//console.log("patientId="+patientId);
				var patientName=getPatientNameFromPatientId(patientId);
				var ackStatus=getAckStatusFromDocLabId(docLabId);
				//console.log("patientName="+patientName);
				//console.log("ackStatus="+ackStatus);

				if(patientName!=null) {
					if(current_first_doclab==0) current_first_doclab=docLabId;
					showDocLab(childId,docLabId,providerNo,searchProviderNo,ackStatus,patientName,cat+'show');
				}
			}

		}
	}
}

function getPatientIdFromDocLabId(docLabId){

	var notUsedPid=new Array();
	for(var i=0;i<patientIds.length;i++){

		var pid=patientIds[i];
		var e=patientDocs[pid];
		//console.log('e'+e);
		if(!e){
			//console.log('if');
			notUsedPid.push(pid);
		}else{
			//console.log('in else='+docLabId);
			if(e.indexOf(docLabId)>-1){
				return pid;
			}
		}
	}
	//console.log(notUsedPid);
	for(var i=0;i<notUsedPid.length;i++){

		removePatientId(notUsedPid[i]);
	}
}
function getLabDocFromPatientId(patientId){//return array of doc ids and lab ids from patient id.
	//console.log(patientId+"--");
	//console.log(patientDocs);
	return patientDocs[patientId];
}

function showThisPatientDocs(patientId,keepPrevious){
	//console.log("patientId in show this patientdocs="+patientId);
	var labDocsArr=getLabDocFromPatientId(patientId);
	var patientName=getPatientNameFromPatientId(patientId);
	if(patientName!=null && patientName.length>0 && labDocsArr!=null && labDocsArr.length>0){
		//console.log(patientName);
		var childId='patient'+patientId;
		//if(toggleElement(childId));
		//else{
		if(keepPrevious);
		else clearDocView();
		createNewElement('docViews',childId);
		for(var i=0;i<labDocsArr.length;i++){
			var docId=labDocsArr[i].replace(' ', '');
			if(current_first_doclab==0) current_first_doclab=docId;
			var ackStatus=getAckStatusFromDocLabId(docId);
			//console.log('childId='+childId+',docId='+docId+',ackStatus='+ackStatus);
			showDocLab(childId,docId,providerNo,searchProviderNo,ackStatus,patientName,'labdoc'+patientId+'show');
		}
	}
}
function popupConsultation(segmentId) {
	var page =contextpath+ '/oscarEncounter/ViewRequest.do?segmentId='+segmentId;
	var windowprops = "height=960,width=700,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
	popup=window.open(page, msgConsReq, windowprops);
	if (popup != null) {
		if (popup.opener == null) {
			popup.opener = self;
		}
	}
}

function checkType(docNo){
	return docType[docNo];
}
function checkSelected(doc) {

	//console.log('in checkSelected()');
	aBoxIsChecked = false;
	var labs = doc.getElementsByName("flaggedLabs");
	if (labs.length == undefined) {
		if (labs.checked == true) {
			aBoxIsChecked = true;
		}
	} else {
		for (i=0; i < labs.length; i++) {
			if (labs[i].checked == true) {
				//console.log(document.reassignForm.flaggedLabs[i].value);
				aBoxIsChecked = true;
			}
		}
	}
	if (aBoxIsChecked) {
		var isListView = jQuery("input[name=isListView]").val();
		var url = contextpath + "/oscarMDS/SelectProvider.jsp?isListView="+isListView;
		popupStart(355, 685, url, 'providerselect');
	} else {
		alert(msgSelectOneLab);
	}
}

function updateDocLabData(doclabid){//remove doclabid from global variables
	console.log('in updatedoclabdata='+doclabid);
		var doclabidNum = doclabid
		//if (checkType(doclabid +"d") == "DOC") {
		//	doclabid += "d";
		//}

		console.log('aa');
		//trim doclabid
		doclabid=doclabid.replace(/\s/g,'');
		updateSideNav(doclabid);
		console.log('aa_aa11');
		hideRowUsingId(doclabidNum);
		console.log('aa_aa');
		//change typeDocLab
		removeIdFromTypeDocLab(doclabid);
		console.log('bb');
		//change docType
		removeIdFromDocType(doclabid);
		console.log('cc');
		//change patientDocs
		removeIdFromPatientDocs(doclabid);
		console.log('dd');

		//change patientIdNames and patientIdStr
		removeEmptyPairFromPatientDocs();
		console.log('ee');

		//change docStatus
		removeIdFromDocStatus(doclabid);
		console.log('ff');

		//remove from normals
		removeNormal(doclabid);
		//remove from abnormals
		removeAbnormal(doclabid);

		console.log(typeDocLab);
                           console.log(docType);
                           console.log(patientDocs);
                           console.log(patientIdNames);
                           console.log(patientIds);
                           console.log(docStatus);
                           console.log(normals);


}
function checkAb_normal(doclabid){
	if(normals.indexOf(doclabid)!=-1)
		return 'normal';
	else if(abnormals.indexOf(doclabid)!=-1)
		return 'abnormal';
}
function updateSideNav(doclabid){
	//console.log('in updatesidenav');
	var n=document.getElementById('totalNumDocs').innerHTML;
	n=parseInt(n);
	if(n>0){
		n=n-1;
		document.getElementById('totalNumDocs').innerHTML=n;
	}
	var type=checkType(doclabid);
	//console.log('type='+type);
	if(type=='DOC'){
		n=document.getElementById('totalDocsNum').innerHTML;
		//console.log('n='+n);
		n=parseInt(n);
		if(n>0){
			n=n-1;
			document.getElementById('totalDocsNum').innerHTML=n;
		}
	}else if (type=='HL7'){
		n=document.getElementById('totalHL7Num').innerHTML;
		n=parseInt(n);
		if(n>0){
			n=n-1;
			document.getElementById('totalHL7Num').innerHTML=n;
		}
	}
	var ab_normal=checkAb_normal(doclabid);
	//console.log('normal or abnormal?'+ab_normal);
	if(ab_normal=='normal'){
		n=document.getElementById('normalNum').innerHTML;
		//console.log('normal inner='+n);
		n=parseInt(n);
		if(n>0){
			n=n-1;
			document.getElementById('normalNum').innerHTML=n;
		}
	}else if(ab_normal=='abnormal'){
		n=document.getElementById('abnormalNum').innerHTML;
		n=parseInt(n);
		if(n>0){
			n=n-1;
			document.getElementById('abnormalNum').innerHTML=n;
		}
	}

	//update patient and patient's subtype
	var patientId=getPatientIdFromDocLabId(doclabid);
	//console.log('xx '+patientId+'--'+n);
	n=document.getElementById('patientNumDocs'+patientId).innerHTML;
	//console.log('xx xx '+patientId+'--'+n);
	n=parseInt(n);
	if(n>0){
		document.getElementById('patientNumDocs'+patientId).innerHTML=n-1;
	}

	if(type=='DOC'){
		n=document.getElementById('pDocNum_'+patientId).innerHTML;
		n=parseInt(n);
		if(n>0){
			document.getElementById('pDocNum_'+patientId).innerHTML=n-1;
		}
	}
	else if(type=='HL7'){
		n=document.getElementById('pLabNum_'+patientId).innerHTML;
		n=parseInt(n);
		if(n>0){
			document.getElementById('pLabNum_'+patientId).innerHTML=n-1;
		}
	}
}

function getRowIdFromDocLabId(doclabid){
	var rowid;
	for(var i=0;i<doclabid_seq.length;i++){
		if(doclabid==doclabid_seq[i]){
			rowid='row'+i;
			break;
		}
	}
	return rowid;
}

function hideRowUsingId(doclabid){
	if(doclabid!=null ){
		var rowid;
		doclabid=doclabid.replace(' ','');
		rowid=getRowIdFromDocLabId(doclabid);
		document.getElementById(rowid).remove();
	}
}
function resetCurrentFirstDocLab(){
	current_first_doclab=0;
}

function focusFirstDocLab(){
	if(current_first_doclab>0){
		var doc_lab=checkType(current_first_doclab);
		if(doc_lab=='DOC'){
			//console.log('docDesc_'+current_first_doclab);
			document.getElementById('docDesc_'+current_first_doclab).focus();
		}
		else if(doc_lab=='HL7'){
			//do nothing
		}
	}
}

/***methos for showDocument.jsp***/
function updateGlobalDataAndSideNav(doclabid,patientId){
	doclabid=doclabid.replace(/\s/g,'');

	if(doclabid.length>0){
		//delete doclabid from not assigned list
		var na=patientDocs['-1'];
		var index=na.indexOf(doclabid);
		if(index!=-1){
			na.splice(index,1);
			addIdToPatient(doclabid,patientId);//add to patient
		}
		return true;
	}
}
function  updatePatientDocLabNav(num,patientId){
	//console.log(num+';;'+patientId);
	if(num && patientId){
		var changed=false;
		var type=checkType(num);
		//console.log(document.getElementById('patient'+patientId+'all'));
		if(document.getElementById('patient'+patientId+'all')){
			//console.log('if');
			//case 1,patientName exists
			//check the type of doclab,
			//check if the type is present, if yes, increase by 1; if not, create and set to 1.

			if(type=='DOC'){
				if(document.getElementById('patient'+patientId+'docs')){
					increaseCount('pDocNum_'+patientId);
					changed=true;
				}else{
					var newEle=createNewDocEle(patientId);
					//console.log(document.getElementById('labdoc'+patientId+'showSublist'));
                    jQuery('#labdoc'+patientId+'showSublist:last-child').append(newEle);
					//new Insertion.Bottom('labdoc'+patientId+'showSublist',newEle);
					changed=true;
				}
			}
			else if(type=='HL7'){
				if(document.getElementById('patient'+patientId+'hl7s')){
					increaseCount('pLabNum_'+patientId);
					changed=true;
				}else{
					var newEle=createNewHL7Ele(patientId);
                    jQuery('#labdoc'+patientId+'showSublist:last-child').append(newEle);
					//new Insertion.Bottom('labdoc'+patientId+'showSublist',newEle);
					changed=true;
				}
			}
			if(changed){
				increaseCount('patientNumDocs'+patientId);
			}
		}else{
			//console.log('else');
			//case 2, patientname doesn't exists in nav bar at all
			//create patientname, check if labdoc is a lab or a doc.
			//create lab/doc nav
			var ele=createPatientDocLabEle(patientId,num);
			changed=true;
		}
		if(changed){//decrease Not,Assigned by 1
			decreaseCount('patientNumDocs-1');
			if(type=='DOC'){
				decreaseCount('pDocNum_-1');
			}else if(type=='HL7'){
				decreaseCount('pLabNum_-1');
			}
			return true;
		}
	}
}
function createPatientDocLabEle(patientId,doclabid){
	var url=contextpath+"/dms/ManageDocument.do";
	var data='method=getDemoNameAjax&demo_no='+patientId;

    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
		    var json=jQuery.parseJSON(transport);
		    if(json!=null ){
			    var patientName=json.demoName;//get name from id
			    addPatientId(patientId);
			    addPatientIdName(patientId,patientName);
			    var e='<dt><img id="plus'+patientId+'" alt="plus" src="../images/plus.png" onclick="showhideSubCat(\'plus\',\''+patientId+'\');"/><img id="minus'+patientId+'" alt="minus" style="display:none;" src="../images/minus.png" onclick="showhideSubCat(\'minus\',\''+patientId+'\');"/>'+
			    '<a id="patient'+patientId+'all" href="javascript:void(0);"  onclick="resetCurrentFirstDocLab();showThisPatientDocs(\''+patientId+'\');un_bold(this);" title="'+patientName+'">'+patientName+' (<span id="patientNumDocs'+patientId+'">1</span>)</a>'+
			    '<dl id="labdoc'+patientId+'showSublist" style="display:none" >';
			    var type=checkType(doclabid);
			    var s;
			    if(type=='DOC'){
				    s=createNewDocEle(patientId);
			    }else if(type=='HL7'){
				    s=createNewHL7Ele(patientId);
			    }else{return '';}
			    e+=s;
			    e+='</dl></dt>';
                // Insert the html into the page as the last child of element.
                jQuery("#patientsdoclabs:last-child").append(e);
			    //new Insertion.Bottom('patientsdoclabs',e);
			    return e;
		    }
        }
    });

}

function createNewDocEle(patientId){
	var newEle='<dt><a id="patient'+patientId+'docs" href="javascript:void(0);" onclick="resetCurrentFirstDocLab();showSubType(\''+patientId+'\',\'DOC\');un_bold(this);" title="Documents">Documents(<span id="pDocNum_'+patientId+'">1</span>)</a></dt>';
	//console.log('newEle='+newEle);
	return newEle;
}
function createNewHL7Ele(patientId){
	var newEle='<dt><a id="patient'+patientId+'hl7s" href="javascript:void(0);" onclick="resetCurrentFirstDocLab();showSubType(\''+patientId+'\',\'HL7\');un_bold(this);" title="HL7s">HL7s(<span id="pLabNum_'+patientId+'">1</span>)</a></dt>';
	//console.log('newEle='+newEle);
	return newEle;
}
function   increaseCount(eleId){
	if(document.getElementById(eleId)){
		var n=document.getElementById(eleId).innerHTML;
		if(n.length>0){
			n=parseInt(n);
			n++;
			document.getElementById(eleId).innerHTML=n;
		}
	}
}
function   decreaseCount(eleId){
	if(document.getElementById(eleId)){
		var n=document.getElementById(eleId).innerHTML;
		if(n.length>0){
			n=parseInt(n);
			if(n>0){
				n--;
			}else{
				n=0;
			}
			document.getElementById(eleId).innerHTML=n;
		}
	}
}
function  popupStart(vheight,vwidth,varpage,windowname) {
	//console.log("in popupStart ");
	if(!windowname)
		windowname="helpwindow";
	var page = varpage;
	var windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes";
	popup=window.open(varpage, windowname, windowprops);
}

function updateDocumentAndNext(eleId){//save doc info
	var url="../dms/ManageDocument.do";
    var data= jQuery('#'+eleId).serialize();

    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
		    var json=jQuery.parseJSON(transport);
		    //console.log(json);
		    if(json!=null ){
			    patientId=json.patientId;
                var ar=eleId.split("_");
                var num=ar[1];
                num=num.replace(/\s/g,'');
                document.getElementById("saveSucessMsg_"+num).style.display = '';
                document.getElementById('saved'+num).value='true';
                document.getElementById("msgBtn_"+num).onclick = function() { popup(700,960, contextpath +'/oscarMessenger/SendDemoMessage.do?demographic_no='+patientId,'msg'); };
                //Hide document like Effect.BlindUp
                jQuery('#labdoc_'+num).hide('fade'); //jQueryUI
                //document.getElementById('labdoc_'+num).style.display = 'none';
                updateDocStatusInQueue(num);
                var success= updateGlobalDataAndSideNav(num,patientId);
                if(success){
                    success=updatePatientDocLabNav(num,patientId);
                    if(success){
                        //disable demo input
                        document.getElementById('autocompletedemo'+num).disabled=true;
                        //console.log('updated by save');
                        //console.log(patientDocs);
                    }
                }
		    }
        }
    });

	return false;
}

function updateDocument(eleId){
	if (!checkObservationDate(eleId)) {
		return false;
	}
	//save doc info
	var url="../dms/ManageDocument.do";
    var data= jQuery('#'+eleId).serialize();


    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
		    var json=jQuery.parseJSON(transport);
		    //console.log(json);
		    if(json!=null ){
			    patientId=json.patientId;
                var ar=eleId.split("_");
                var num=ar[1];
                num=num.replace(/\s/g,'');
                document.getElementById("saveSucessMsg_"+num).style.display = '';
                document.getElementById('saved'+num).value='true';
                document.getElementById('demofind'+num).value=patientId;
                document.getElementById('demofindName'+num).value=document.getElementById('autocompletedemo'+num).value;
                document.getElementById('assignedPId_'+num).textContent=document.getElementById('autocompletedemo'+num).value;
                document.getElementById("msgBtn_"+num).onclick = function() { popup(700,960, contextpath +'/oscarMessenger/SendDemoMessage.do?demographic_no='+patientId,'msg'); };
                // enable buttons that need a pid
	            jQuery('a').removeClass('disabled');
                document.getElementById('save'+num).removeAttribute('disabled');
	            //document.getElementById('saveNext'+num).removeAttribute('disabled');
	            document.getElementById('dropdown_'+num).removeAttribute('disabled');
	            document.getElementById('dropdown2_'+num).removeAttribute('disabled');
	            document.getElementById('msgBtn_'+num).removeAttribute('disabled');
	            document.getElementById('ticklerBtn_'+num).removeAttribute('disabled');
	            document.getElementById('recallBtn_'+num).removeAttribute('disabled');
	            document.getElementById('rxBtn_'+num).removeAttribute('disabled');
			    updateDocStatusInQueue(num);
			    var success= updateGlobalDataAndSideNav(num,patientId);
    			if(success){
				    success=updatePatientDocLabNav(num,patientId); /// PHC
				    if(success){
					    //disable demo input
					    document.getElementById('autocompletedemo'+num).disabled=true;
    					//console.log('updated by save');
    					//console.log(patientDocs);
    				}
			    }
		    }
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

function updateStatus(formid){//acknowledge Document
	var num=formid.split("_");
	var doclabid=num[1];
	if(doclabid){
		var demoId=document.getElementById('demofind'+doclabid).value;
		var saved=document.getElementById('saved'+doclabid).value;
		if(demoId=='-1'|| saved=='false'){
			alert('Document is not assigned and saved to a patient,please file it');
		}else{
			var url=contextpath+"/oscarMDS/UpdateStatus.do";
            var data= jQuery('#'+formid).serialize();

	        jQuery.ajax({
		        type: "POST",
		        url:  url,
		        data: data,
		        success: function (transport) {
				    if(doclabid){
                        // hide similar to Effect.Blindup()
					    jQuery('#labdoc_'+doclabid).hide('fade'); //jQueryUI if not loaded a simple hide will occur
					    updateDocStatusInQueue(doclabid);

				    }

				    if (typeof _in_window !== 'undefined' && _in_window) {

					    jQuery(':button').prop('disabled',true);
					    jQuery(':submit').prop('disabled',true);
					    jQuery('#loader').show();

					    if (typeof data.multiID !== 'undefined'){
						    // The version _in_window may be newer than the one in the list
						    const multiIds = data.multiID.split(",");
						    // Hide any in the list that are older versions
						    for (const id of multiIds) {
					            window.opener.hideLab('labdoc_'+id);
					            if (id === doclabid) break;
						    }
					    } else {
						// if only one Id eg all Docs you can simply hide it
						    window.opener.hideLab('labdoc_'+doclabid);
					    }
					    close = window.opener.openNext(doclabid);
					    window.opener.refreshCategoryList();
					    window.opener.updateCountTotal(0);
					    //self.opener.removeReport(doclabid);
					    //if (close == "close" ) { popup.close(); }
				    }
				    else {
					    refreshCategoryList();
					    fakeScroll();
				    }
            	},
		        error: function(jqXHR, err, exception) {
			        console.log(jqXHR.status);
		        }
	        });
		}
	}
}



function fileDoc(docId){
	if(docId){
		docId=docId.replace(/\s/,'');
		if(docId.length>0){
			var demoId=document.getElementById('demofind'+docId).value;
			var isFile=true;
			if(demoId=='-1'){
				isFile=confirm('Document is not assigned to any patient, do you still want to file it?');
			}
			if(isFile) {
				var type='DOC';
				if(type){
					var url='../oscarMDS/FileLabs.do';
					var data='method=fileLabAjax&flaggedLabId='+docId+'&labType='+type;

	                jQuery.ajax({
		                type: "POST",
		                url:  url,
		                data: data,
		                success: function (transport) {
						    updateDocStatusInQueue(docId);
						    jQuery('#labdoc_'+docId).hide('fade'); // jQueryUI dependency
						    if (_in_window) {
							    close = window.opener.openNext(docId);
							    if (close == "close" ) { window.close(); }
							    window.opener.updateCountTotal(0);
							    //window.opener.hideLab('labdoc_'+docId); //this will add acknowledged class
							    self.opener.removeReport(docId);  //removeReport unless you want a Filed report to mix with acknowledged
						    }
						    else {
							    refreshCategoryList();
							    fakeScroll();
						    }
                    	},
		                error: function(jqXHR, err, exception) {
			                console.log(jqXHR.status);
		                }
	                });
				}
			}
		}
	}
}

function refileDoc(id) {
    var queueId=document.getElementById('queueList_'+id).options[document.getElementById('queueList_'+id).selectedIndex].value;
    var url=contextpath +"/dms/ManageDocument.do";
    var data='method=refileDocumentAjax&documentId='+id+"&queueId="+queueId;

    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
            fileDoc(id);
        }
    });
 }

function addDocToList(provNo, provName, docId) {
	var bdoc = document.createElement('a');
	bdoc.setAttribute("onclick", "removeProv(this);");
	bdoc.setAttribute("style", "cursor: pointer;");
	bdoc.appendChild(document.createTextNode(" -remove- "));
	//console.log("--");
	var adoc = document.createElement('div');
	adoc.appendChild(document.createTextNode(provName));
	//console.log("--==");
	var idoc = document.createElement('input');
	idoc.setAttribute("type", "hidden");
	idoc.setAttribute("name", "flagproviders");
	idoc.setAttribute("value", provNo);

	adoc.appendChild(idoc);

	adoc.appendChild(bdoc);
	var providerList = document.getElementById('providerList' + docId);
	providerList.appendChild(adoc);
}

function removeLink(docType, docId, providerNo, e) {
	var url = "../dms/ManageDocument.do";
	var data = 'method=removeLinkFromDocument&docType=' + docType + '&docId=' + docId + '&providerNo=' + providerNo;

    jQuery.ajax({
        type: "POST",
        url:  url,
        data: data,
        success: function (transport) {
            updateDocLabData(docId);
        }
    });

	e.parentNode.remove(e);
}

function replaceQueryString(url,param,value) {
    var re = new RegExp("([?|&])" + param + "=.*?(&|$)","i");
    if (url.match(re))
        return url.replace(re,'$1' + param + "=" + value + '$2');
    else
        return url + '&' + param + "=" + value;
}

var CATEGORY_ALL = 1,
CATEGORY_DOCUMENTS = 2,
CATEGORY_HL7 = 3,
CATEGORY_NORMAL = 4,
CATEGORY_ABNORMAL = 5,
CATEGORY_PATIENT = 6,
CATEGORY_PATIENT_SUB = 7,
CATEGORY_HRM = 8,
CATEGORY_TYPE_DOC = 'DOC',
CATEGORY_TYPE_HL7 = 'HL7';

function reloadChangeView() {
    resetCurrentFirstDocLab();

    switch (selected_category) {
	case CATEGORY_ALL:
		showAllDocLabs();
		un_bold(document.getElementById('totalAll'))
		break;
	case CATEGORY_DOCUMENTS:
		showCategory('DOC');
		un_bold(document.getElementById('totalDocs'));
		break;
	case CATEGORY_HL7:
		showCategory('HL7');
		un_bold(document.getElementById('totalHL7s'));
		break;
	case CATEGORY_NORMAL:
		showAb_Normal('normal');
		un_bold(document.getElementById('totalNormals'));
		break;
	case CATEGORY_ABNORMAL:
		showAb_Normal('abnormal');
		un_bold(document.getElementById('totalAbnormals'));
		break;
	case CATEGORY_PATIENT:
		showThisPatientDocs(selected_category_patient);
		un_bold(document.getElementById('patient'+selected_category_patient+'all'));
		break;
    case CATEGORY_PATIENT_SUB:
    	showSubType(selected_category_patient,selected_category_type);
    	showhideSubCat('plus',selected_category_patient);
    	switch (selected_category_type) {
	    	case CATEGORY_TYPE_DOC:
				un_bold(document.getElementById('patient'+selected_category_patient+'docs'));
				break;
	    	case CATEGORY_TYPE_HL7:
				un_bold(document.getElementById('patient'+selected_category_patient+'hl7s'));
				break;
    	}
    	break;
    }
}

function inSummaryView() {
	return document.getElementById('summaryView').getStyle('display')!='none';
}

function refreshView() {
	if (inSummaryView()) {
		location.reload();
	}
	else {
		var cat     = selected_category;
		var patId   = selected_category_patient;
		var catType = selected_category_type;
		var preview = inSummaryView() ? "0" : "1";
		var search  = location.search;
		search = replaceQueryString(search,"selectedCategory",        cat);
		search = replaceQueryString(search,"selectedCategoryPatient", patId);
		search = replaceQueryString(search,"selectedCategoryType",    catType);
		search = replaceQueryString(search,"inPreview",               preview);
		location.search = search;
	}
}

function getWidth() {
    var myWidth = 0;
    if( typeof( window.innerWidth ) == 'number' ) {
        //Non-IE
        myWidth = window.innerWidth;
    } else if( document.documentElement &&  document.documentElement.clientWidth  ) {
        //IE 6+ in 'standards compliant mode'
        myWidth = document.documentElement.clientWidth;
    } else if( document.body && document.body.clientHeight  ) {
        //IE 4 compatible
        myWidth = document.body.clientWidth;
    }
    return myWidth;
}


function getHeight() {
    var myHeight = 0;
    if( typeof( window.innerHeight ) == 'number' ) {
        //Non-IE
        myHeight = window.innerHeight;
    } else if( document.documentElement && document.documentElement.clientHeight  ) {
        //IE 6+ in 'standards compliant mode'
        myHeight = document.documentElement.clientHeight;
    } else if( document.body && (document.body.clientHeight ) ) {
        //IE 4 compatible
        myHeight = document.body.clientHeight;
    }
    return myHeight;
}

function showPDF(docid,cp) {

    var height=700;
    if(getHeight()>750) {
        height=getHeight()-50;
    }

    var width=700;
    if(getWidth()>1350)
    {
        width=getWidth()-650;
    }

    var url=cp+'/dms/ManageDocument.do?method=display&doc_no='+docid+'&rand='+Math.random()+'#view=fitV&page=1';

    document.getElementById('docDispPDF_'+docid).innerHTML='<object width="'+(width)+'" height="'+(height)+'" type="application/pdf" data="'+url+'" id="docPDF_'+docid+'"></object>';
}

function showPageImg(docid,pn,cp){
    var displayDocumentAs=document.getElementById('displayDocumentAs_'+docid).value;
    if(displayDocumentAs=="PDF") {
        showPDF(docid,cp);
    }
    else
    {
        if(docid&&pn&&cp){
            var e=document.getElementById('docImg_'+docid);
            var url=cp+'/dms/ManageDocument.do?method=viewDocPage&doc_no='+docid+'&curPage='+pn;
            e.setAttribute('src',url);
        }
    }
}

function nextPage(docid,cp){
	var curPage=document.getElementById('curPage_'+docid).value;
	var totalPage=document.getElementById('totalPage_'+docid).value;
	curPage++;
	if(curPage>totalPage){
		curPage=totalPage;
		hideNext(docid);
		showPrev(docid);
	}
	document.getElementById('curPage_'+docid).value=curPage;
	document.getElementById('viewedPage_'+docid).innerHTML = curPage;

        showPageImg(docid,curPage,cp);
        if(curPage+1>totalPage){
            hideNext(docid);
            showPrev(docid);
        } else{
            showNext(docid);
            showPrev(docid);
        }
}
function prevPage(docid,cp){
     var curPage=document.getElementById('curPage_'+docid).value;
    curPage--;
    if(curPage<1){
        curPage=1;
        hidePrev(docid);
        showNext(docid);
    }
    document.getElementById('curPage_'+docid).value=curPage;
    document.getElementById('viewedPage_'+docid).innerHTML = curPage;

        showPageImg(docid,curPage,cp);
       if(curPage==1){
           hidePrev(docid);
           showNext(docid);
        }else{
            showPrev(docid);
            showNext(docid);
        }

}
function firstPage(docid,cp){
   document.getElementById('curPage_'+docid).value=1;
   document.getElementById('viewedPage_'+docid).innerHTML = 1;
    showPageImg(docid,1,cp);
    hidePrev(docid);
    showNext(docid);
}
function lastPage(docid,cp){
    var totalPage=document.getElementById('totalPage_'+docid).value;

    document.getElementById('curPage_'+docid).value=totalPage;
    document.getElementById('viewedPage_'+docid).innerHTML = totalPage;
    showPageImg(docid,totalPage,cp);
    hideNext(docid);
    showPrev(docid);
}
function hidePrev(docid){
    //disable previous link
    document.getElementById("prevP_"+docid).style.display = 'none';
    document.getElementById("firstP_"+docid).style.display = 'none';
    document.getElementById("prevP2_"+docid).style.display = 'none';
    document.getElementById("firstP2_"+docid).style.display = 'none';

    //$("prevP_"+docid).setStyle({display:'none'});
    //$("firstP_"+docid).setStyle({display:'none'});
    //$("prevP2_"+docid).setStyle({display:'none'});
    //$("firstP2_"+docid).setStyle({display:'none'});
}
function hideNext(docid){
    //disable next link
    document.getElementById("nextP_"+docid).style.display = 'none';
    document.getElementById("lastP_"+docid).style.display = 'none';
    document.getElementById("nextP2_"+docid).style.display = 'none';
    document.getElementById("lastP2_"+docid).style.display = 'none';

    //$("nextP_"+docid).setStyle({display:'none'});
    //$("lastP_"+docid).setStyle({display:'none'});
    //$("nextP2_"+docid).setStyle({display:'none'});
    //$("lastP2_"+docid).setStyle({display:'none'});

}
function showPrev(docid){
    //disable previous link
    document.getElementById("prevP_"+docid).style.display = '';
    document.getElementById("firstP_"+docid).style.display = '';
    document.getElementById("prevP2_"+docid).style.display = '';
    document.getElementById("firstP2_"+docid).style.display = '';

    //$("prevP_"+docid).setStyle({display:'inline'});
    //$("firstP_"+docid).setStyle({display:'inline'});
    //$("prevP2_"+docid).setStyle({display:'inline'});
    //$("firstP2_"+docid).setStyle({display:'inline'});

}
function showNext(docid){

    //disable next link
    document.getElementById("nextP_"+docid).style.display = '';
    document.getElementById("lastP_"+docid).style.display = '';
    document.getElementById("nextP2_"+docid).style.display = '';
    document.getElementById("lastP2_"+docid).style.display = '';

    //$("nextP_"+docid).setStyle({display:'inline'});
    //$("lastP_"+docid).setStyle({display:'inline'});
    //$("nextP2_"+docid).setStyle({display:'inline'});
    //$("lastP2_"+docid).setStyle({display:'inline'});

}

function addDocComment(docId, providerNo, sync) {

	var ret = true;
    var comment = "";
    var text = jQuery("#comment_"+docId + "_" + providerNo);
    if( text.length > 0 ) {
        comment = jQuery("#comment_"+docId + "_" + providerNo).html();
        if( comment == null || comment == "no comment" ) {
        	comment = "";
        }
    console.log("existing comment is:"+comment);
    }
    var commentVal = prompt("Please enter a comment (max. 255 characters)", comment);

    if( commentVal == null ) {
    	ret = false;
    }
    else if( commentVal != null && commentVal.length > 0 )
    	jQuery("#" + "comment_" + docId).val(commentVal);
    else
    	jQuery("#" + "comment_" + docId).val(comment);

    if( ret ) {

    	jQuery("#" + "status_" + docId).val('N');
    	var url=contextpath+"/oscarMDS/UpdateStatus.do";
    	var formid = "acknowledgeForm_" + docId;
    	var data=jQuery("#" + formid).serialize();
    	data += "&method=addComment";

	    jQuery.ajax({
		    type: "POST",
		    url:  url,
		    data: data,
		    success: function (json) {
			    if(json!=null ){
        		    var date = json.date;
        			jQuery("#" + "timestamp_"+docId+"_"+providerNo).html(date);
        		}
				jQuery("#" + "status_"+docId).val("A");
				jQuery("#" + "comment_"+docId+"_"+providerNo).html(jQuery("#" + "comment_"+docId).val());
				jQuery("#" + "comment_"+docId).html("");
              }
        });

    }
}

function getDocComment(docId, providerNo, inQueueB) {

	var ret = true;
    var comment = "";
    var text = jQuery("#comment_"+docId + "_" + providerNo);
    if( text.length > 0 ) {
        comment = jQuery("#comment_"+docId + "_" + providerNo).html();
        if( comment == null || comment == "no comment" ) {
        	comment = "";
        }
    }
    var commentVal = prompt("Please enter a comment (max. 255 characters)", comment);

    if( commentVal == null ) {
    	ret = false;
    }
    else if( commentVal != null && commentVal.length > 0 )
    	jQuery("#" + "comment_" + docId).val(commentVal);
    else
    	jQuery("#" + "comment_" + docId).val(comment);

   if(ret) {
	   updateStatus("acknowledgeForm_" + docId ,inQueueB);
   }

}