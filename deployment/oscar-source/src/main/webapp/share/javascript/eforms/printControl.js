/* printControl - Changes eform to add a server side generated PDF
 *                with print functionality intact (if print button on the form).
 */

if (typeof jQuery == "undefined") { alert("The printControl library requires jQuery v 1.7.x+. Please ensure that it is loaded first"); }

function compare(a, b) {
    if (a === b) {
       return 0;
    }
    var a_components = a.split(".");
    var b_components = b.split(".");
    var len = Math.min(a_components.length, b_components.length);

    // loop while the components are equal
    for (var i = 0; i < len; i++) {
        // A bigger than B
        if (parseInt(a_components[i]) > parseInt(b_components[i])) {
            return 1;
        }
        // B bigger than A
        if (parseInt(a_components[i]) < parseInt(b_components[i])) {
            return -1;
        }
    }

    // If one's a prefix of the other, the longer one is greater.
    if (a_components.length > b_components.length) {
        return 1;
    }
    if (a_components.length < b_components.length) {
        return -1;
    }
    // they are the same
    return 0;
}


if ( compare(jQuery.fn.jquery,'1.7.1') < 0 ) {
    alert("You have loaded jQuery version "+ jQuery.fn.jquery + " but we require at least v 1.7.1");
}

var printControl = {
	initialize: function () {

		var submit = jQuery("input[name='SubmitButton']");
		var printSave = jQuery("input[name='PrintSaveButton']");
		submit.append("<input name='pdfSaveButton' type='button'>");
		submit.append("<input name='pdfButton' type='button'>");
		var pdf = jQuery("input[name='pdfButton']");
		var pdfSave = jQuery("input[name='pdfSaveButton']");
		if (pdf.length == 0) { pdf = jQuery("input[name='pdfButton']"); }
		if (pdfSave.length == 0) { pdfSave = jQuery("input[name='pdfSaveButton']"); }

		pdf.insertAfter(submit);
		pdfSave.insertAfter(submit);

		if (pdf.length != 0) {

			pdf.off('click');
			pdf.attr("value", "PDF");
			pdf.on('click', function()  {submitPrintButton(false);});

		}
		if (pdfSave.length != 0) {

			pdfSave.off('click');
			pdfSave.attr("value", "Submit & PDF");
			pdfSave.on('click', function()  {submitPrintButton(true);});

		}
		if (printSave.length != 0) {
			printSave.attr("value", "Submit & Print");
		}

	}
};

function setFutureDate(weeks){
	var now = new Date();
	now.setDate(now.getDate() + weeks * 7);
	return (now.toISOString().substring(0,10));
}

function setTickler(){
    var today = new Date().toISOString().slice(0, 10);
    var subject=( $('#subject').val() ? $('#subject').val() : "test");
	var demographicNo = ($("#tickler_patient_id").val() ? $("#tickler_patient_id").val() : "-1"); // patient_id
    var taskAssignedTo = ($("#tickler_send_to").val() ? $("#tickler_send_to").val() : "-1"); // id from doctor_provider_no current_user_id etc
	var weeks = ($("#tickler_weeks").val() ? $("#tickler_weeks").val() : "6");
	var message = ($("#tickler_message").val() ? $("#tickler_message").val() : "Check for results of "+subject+" ordered " + today);
  	var ticklerDate = setFutureDate(weeks);
	var urgency = ($("#tickler_priority").val() ? $("#ticklerpriority").val() : "Normal"); // case sensitive, can be Low Normal High
	var ticklerToSend = {};
	ticklerToSend.demographicNo = demographicNo;
	ticklerToSend.message = message;
	ticklerToSend.taskAssignedTo = taskAssignedTo;
	ticklerToSend.serviceDate = ticklerDate;
	ticklerToSend.priority = urgency;
 	console.log("pringControl.js is setting a tickler: "+JSON.stringify(ticklerToSend));
    return $.ajax({
        type: "POST",
  		url:  '../ws/rs/tickler/add',
  		dataType:'json',
  		contentType:'application/json',
  		data: JSON.stringify(ticklerToSend)
  	});

}

function wrapsetTickler() {
$.when(setTickler()).then(function( data, textStatus, jqXHR ) {
            console.log("printControl.js1 reports tickler "+textStatus);
            if ( jqXHR.status != 200 ){ alert("ERROR ("+jqXHR.status+") automatic tickler FAILED to be set");}

        });
}

function submitPrintButton(save) {
	var ticklerFlag = $("#tickler_send_to");
    if (ticklerFlag.length >0) {
        $.when(setTickler()).then(function( data, textStatus, jqXHR ) {
            console.log("printControl.js reports tickler "+textStatus);
            if ( jqXHR.status != 200 ){ alert("ERROR ("+jqXHR.status+") automatic tickler FAILED to be set");}
            finishPdf(save);
        });
    } else {
        finishPdf(save);
    }
}

function finishPdf(save) {
	// Setting this form to print.
	var printHolder = jQuery('#printHolder');
	if (printHolder == null || printHolder.length == 0) {
		jQuery("form").append("<input id='printHolder' type='hidden' name='print' value='true' >");
	}
	printHolder = jQuery('#printHolder');
	printHolder.val("true");

	var saveHolder = jQuery("#saveHolder");
	if (saveHolder == null || saveHolder.length == 0) {
		jQuery("form").append("<input id='saveHolder' type='hidden' name='skipSave' value='"+!save+"' >");
	}
	saveHolder = jQuery("#saveHolder");
	saveHolder.val(!save);
	needToConfirm=false;

	if (document.getElementById('Letter') != null) {
		document.getElementById('Letter').value=editControlContents('edit');
	}

	jQuery("form").submit();
	if (save) { setTimeout("window.close()", 3000); }
	printHolder.val("false");
	saveHolder.val("false");

}


jQuery(document).ready(function(){printControl.initialize();});