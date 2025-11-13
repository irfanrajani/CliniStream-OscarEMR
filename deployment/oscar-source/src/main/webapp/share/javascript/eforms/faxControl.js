if (typeof jQuery == "undefined") { alert("The faxControl library requires jQuery. Please ensure that it is loaded first"); }

var faxControlPlaceholder = "<br/>Fax Recipients:<br/><div id='faxForm'>Loading fax options..</div>";
var faxControlFaxButton     = "<span>&nbsp;</span><input value='Fax' name='FaxButton' id='fax_button' disabled type='button' onclick='paste2Note();submitFaxButtonAjax(false)'>";
var faxControlFaxSaveButton = "<span>&nbsp;</span><input value='Submit & Fax' name='FaxSaveButton' id='faxSave_button' disabled type='button' onclick='paste2Note();submitFaxButtonAjax(true)'>";
var faxControlMemoryInput = "<input value='false' name='faxEForm' id='faxEForm' type='hidden' />";	
var faxControl = {
	initialize: function () {
		var placeholder = jQuery("#faxControl");
		if (placeholder == null || placeholder.length == 0) { 
			if (jQuery(".DoNotPrint").length > 0) { 
				placeholder = jQuery("<div id='faxControl'>&nbsp;</div>");
				jQuery(".DoNotPrint").append(placeholder);				
			}
			else {
				alert("Missing placeholder please ensure a div with the id faxControl or a div with class DoNotPrint exists on the page."); 
				return;
			}
		}
		
		var demoNo ="";			
		demoNo = getSearchValue("demographic_no");
		if (demoNo == "") { demoNo = getSearchValue("efmdemographic_no", jQuery("form").attr('action')); }
		placeholder.html(faxControlPlaceholder);
		
		$.ajax({
			url:"../eform/efmformfax_form.jsp",
			data:"demographicNo=" + demoNo,
			success: function(data) {
				
				if (data == null || data.trim() == "") {
					placeholder.html("");
					console.log("Error loading fax control, please contact an administrator.");
				}
				else { 
					placeholder.html(data);					
					var buttonLocation = jQuery("input[name='SubmitButton']");
					if (buttonLocation.length != 0) { 
						buttonLocation = jQuery(buttonLocation[buttonLocation.length -1]);
						jQuery(faxControlFaxButton).insertAfter(buttonLocation);
						jQuery(faxControlFaxSaveButton).insertAfter(buttonLocation);
						jQuery(faxControlMemoryInput).insertAfter(buttonLocation);
					}
					else {
						buttonLocation = jQuery(".DoNotPrint");
						if (buttonLocation == null || buttonLocation.length == 0) {			
							buttonLocation = jQuery(jQuery("form")[0]);
						}
						if (buttonLocation != null) {
							buttonLocation.append(jQuery(faxControlFaxButton));
							buttonLocation.append(jQuery(faxControlFaxSaveButton));
							buttonLocation.append(jQuery(faxControlMemoryInput));
						}
					}
					if (buttonLocation == null) { alert("Unable to find form or save button please check this is a proper eform."); return; }					
					
					updateFaxButton();
				}
			}
		});
	}		
};

jQuery(document).ready(function() {
	faxControl.initialize();
});


function paste2Note(){
	try{
                if(pasteFaxNote == 0)
                        return;
                var demoNo = getSearchValue("demographic_no");
                if (demoNo == "") { demoNo = getSearchValue("efmdemographic_no", jQuery("form").attr('action')); }
                var faxName = "";
                var faxNo = "";

                for(var i = 0;i < $("#faxRecipients li").length;i ++){
                        var num = 0;
                        if($("#faxRecipients li")[i].innerHTML.indexOf("<b>,") > 0){
                                num = $("#faxRecipients li")[i].innerHTML.indexOf("<b>,");
                                var toName = $("#faxRecipients li")[i].innerHTML.substring(0, num);
                                var toFaxNo = jQuery("input[name='faxRecipients']")[i].value;
                                if(toName != toFaxNo){
                                        if(i == 0){
                                                faxName = toName;
                                        }else{
                                                faxName = faxName + "," + toName;
                                        }
                                }
                        }
                }

                for(var i = 0;i < jQuery("input[name='faxRecipients']").length;i ++){
                        if(i == 0){
                                faxNo = jQuery("input[name='faxRecipients']")[i].value;
                        }else{
                                faxNo = faxNo + ", " + jQuery("input[name='faxRecipients']")[i].value;
                        }
                }
                var text ="[Faxed eform " + setEformName + " to " + faxName.trim() + " Fax#: " + faxNo + " by " + setProviderName + ", " + currentTimeStamp + "]"+"\n";
                var noteEditor = "noteEditor"+demoNo;
			//console.log(text); 

                if( window.parent.opener.document.forms["caseManagementEntryForm"] != undefined ) {
                window.parent.opener.pasteToEncounterNote(text);
              }else if( window.parent.opener.document.encForm != undefined ){
                window.parent.opener.document.encForm.enTextarea.value = window.parent.opener.document.encForm.enTextarea.value + text;
              }else if( window.parent.opener.document.getElementById(noteEditor) != undefined ){
                window.parent.opener.document.getElementById(noteEditor).value = window.parent.opener.document.getElementById(noteEditor).value + text;
              }else if(window.parent.opener.parent.opener.document.forms["caseManagementEntryForm"] != undefined){
                  window.parent.opener.parent.opener.pasteToEncounterNote(text);
              }else if( window.parent.opener.parent.opener.document.encForm != undefined ){
                window.parent.opener.parent.opener.document.encForm.enTextarea.value = window.parent.opener.parent.opener.document.encForm.enTextarea.value + text;
              }else if( window.parent.opener.parent.opener.document.getElementById(noteEditor) != undefined ){
                window.parent.opener.parent.opener.document.getElementById(noteEditor).value = window.parent.opener.parent.opener.document.getElementById(noteEditor).value + text;
              }
        }catch (e){
              console.log("ERROR: could not paste to EMR");
              //alert ("ERROR: could not paste to EMR");
        }
}




function getSearchValue(name, url)
{
	if (url == null) { url = window.location.href; }
	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regexS = "[\\?&]"+name+"=([^&#]*)";
	var regex = new RegExp(regexS);
	var results = regex.exec(url);
	if (results == null) { return ""; }
	else { return results[1]; }
}

function AddOtherFaxProvider() {
	var selected = jQuery("#otherFaxSelect option:selected"); 
	_AddOtherFax(selected.text(),selected.val());
}
function AddOtherFax() {
	var number = document.getElementById("otherFaxInput").value.trim();
	if (checkPhone(number)) {
		_AddOtherFax(number,number);
	}
	else {
		alert("The fax number you entered is invalid.");
	}
}
 
function _AddOtherFax(name, number) {
	//if (name == "" || number == "") { alert("Invalid recipient"); return; }
	var remove = "<a href='javascript:void(0);' onclick='removeRecipient(this)'>remove</a>";
	var html = "<li>"+name+"<b>, Fax No: </b>"+number+ " " +remove+"<input type='hidden' name='faxRecipients' value='"+number+"'></input></li>";
	jQuery("#faxRecipients").append(jQuery(html));
	updateFaxButton();
}

function checkPhone(str) 
{
	var phone =  /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/;
	if (str.match(phone)) {
   		return true;
 	} else {
 		return false;
 	}
}

function removeRecipient(element) { 
	var el = jQuery(element);
	if (el) { el.parent().remove(); updateFaxButton(); }
	else { alert("Unable to remove recipient."); }	
}

function updateFaxButton() {
	var disabled = !hasFaxNumber();
	document.getElementById("fax_button").disabled = disabled;
	document.getElementById("faxSave_button").disabled = disabled;
}

function hasFaxNumber() {
	return jQuery("#faxRecipients").children().length > 0; 
}

function submitFaxButtonAjax(save) {
	var ticklerFlag = $("#tickler_send_to");
    if (ticklerFlag.length >0) { 
        $.when(setTickler()).then(function( data, textStatus, jqXHR ) {
            console.log("faxControl.js reports tickler "+textStatus);
            if ( jqXHR.status != 200 ){ alert("ERROR ("+jqXHR.status+") automatic tickler FAILED to be set");}
            finishFax(save);
        });
    } else {
        finishFax(save);
    }
}

function finishFax(save) {
	document.getElementById('faxEForm').value=true;
	var saveHolder = jQuery("#saveHolder");
	if (saveHolder == null || saveHolder.length == 0) {
		jQuery("form").append("<input id='saveHolder' type='hidden' name='skipSave' value='"+!save+"' >");
	}
	saveHolder = jQuery("#saveHolder");
	saveHolder.val(!save);
	needToConfirm=false;
	if (document.getElementById('Letter') == null) {
		jQuery("form").trigger('submit');
	}
	else {
		var form = $("form[name='RichTextLetter']");
		form.attr("target", "_blank");
		document.getElementById('Letter').value=editControlContents('edit');
		
		$.ajax({
			 type: "POST",  
			 url: form.attr("action"),  
			 data: form.serialize(),  
			 success: function() {  
			    alert("Fax sent successfully");
			    if (save) { window.close(); }
			 },
			 error: function() {
				 alert("An error occured while attempting to send your fax, please contact an administrator.");
			 } 
		});
	}
	document.getElementById('faxEForm').value=false;
}