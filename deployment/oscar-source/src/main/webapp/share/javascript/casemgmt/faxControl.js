function addOtherFaxProvider() {
    var selected = jQuery("#otherFaxSelect option:selected");
    addRecipient(selected.text(),selected.val());
}
function addOtherFax() {
    var number = jQuery("#otherFaxInput").val();
    if (checkPhone(number)) {
        addRecipient(number,number);
    }
    else {
       alertFaxNumberRules();
    }
}

function addOtherFaxToDocument(documentId) {
    var number = jQuery("#otherFaxInput_" + documentId).val();
    if (checkPhone(number)) {
        addRecipientToDocument(number,number, documentId);
    }
    else {
        alertFaxNumberRules();
    }
}

function alertFaxNumberRules() {
    alert("The fax number you entered is invalid.\n" +
        "Try one of the following valid formats:\n" +
        "X-XXX-XXX-XXXX\n" +
        "X-XXXXXXXXXX\n" +
        "XXXX-XXX-XXXX\n" +
        "XXXXXXX-XXXX\n" +
        "XXXXXXXXXXX\n");
}

function addRecipient(name, number) {
    var remove = "<a href='javascript:void(0);' onclick='removeRecipient(this)'>remove</a>";
    var html = "<li>"+name+"<b>, Fax No: </b>"+number+ " " +remove+"<input type='hidden' name='faxRecipients' value='"+number+"'></input></li>";
    jQuery("#faxRecipients").append(jQuery(html));
    updateFaxButton();
}

function addRecipientToDocument(name, number, documentId) {
    var remove = "<a href='javascript:void(0);' onclick='removeRecipientFromDocument(this)'>remove</a>";
    var html = "<li>"+name+"<b>, Fax No: </b>"+number+ " " +remove+"<input type='hidden' name='faxRecipients' value='"+number+"'></input></li>";
    jQuery("#faxRecipients_" + documentId).append(jQuery(html));
}

function checkPhone(str) {
    var phone =  /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/
    if (str.match(phone)) {
        return true;
    } else {
        return false;
    }
}

function removeRecipient(el) {
    var el = jQuery(el);
    if (el) { el.parent().remove(); updateFaxButton(); }
    else { alert("Unable to remove recipient."); }
}

function removeRecipientFromDocument(el) {
    var el = jQuery(el);
    if (el) { el.parent().remove();}
    else { alert("Unable to remove recipient."); }
}

function hasFaxNumber() {
    return jQuery("#faxRecipients").children().length > 0;
}
function updateFaxButton() {
    var disabled = !hasFaxNumber();
    document.getElementById("fax_button").disabled = disabled;
    //document.getElementById("fax_button2").disabled = disabled;
}