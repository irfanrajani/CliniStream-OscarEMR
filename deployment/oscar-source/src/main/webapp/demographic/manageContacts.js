var $isNewContact = false;

var $displayEditModal = true;

var $personalRoles = [
    {key: 'Mother', description: 'Mother'},
    {key: 'Father', description: 'Father'},
    {key: 'Parent', description: 'Parent'},
    {key: 'Wife', description: 'Wife'},
    {key: 'Husband', description: 'Husband'},
    {key: 'Partner', description: 'Partner'},
    {key: 'Son', description: 'Son'},
    {key: 'Daughter', description: 'Daughter'},
    {key: 'Brother', description: 'Brother'},
    {key: 'Sister', description: 'Sister'},
    {key: 'Aunt', description: 'Aunt'},
    {key: 'Uncle', description: 'Uncle'},
    {key: 'GrandFather', description: 'GrandFather'},
    {key: 'GrandMother', description: 'GrandMother'},
    {key: 'Guardian', description: 'Guardian'},
    {key: 'Foster Parent', description: 'Foster Parent'},
    {key: 'Next of Kin', description: 'Next of Kin'},
    {key: 'Administrative Staff', description: 'Administrative Staff'},
    {key: 'Care Giver', description: 'Care Giver'},
    {key: 'Power of Attorney', description: 'Power of Attorney'},
    {key: 'Insurance', description: 'Insurance'},
    {key: 'Guarantor', description: 'Guarantor'},
    {key: 'Other', description: 'Other'}
];

var $professionalRoles = [
    {key: 'Family Doctor', description: 'Family Doctor'},
    {key: 'Specialist', description: 'Specialist'},
    {key: 'Other', description: 'Other'},
    {key: 'Dietician', description: 'Dietitian'}//key originally spelt incorrect in OSCAR
];

var $returnMessage = "";

function addContact() {
    $.ajax({
        url: '../demographic/newContact.jsp?search=&id=',
        async: false,
        success: function(data) {
            $("#contactContainer").html(data);
            $('#contactView').modal('show');
        }
    });

    return false;
}

function buildContactRoles(category) {
    var contactRoles = $("#contact_role");
    var roles = category === 'professional' ? $professionalRoles : $personalRoles;
    roles.sort((a,b) => (a.description > b.description) ? 1 : ((b.description > a.description) ? -1 : 0));

    contactRoles.empty();

    $.each(roles, function(i) {
        contactRoles.append($("<option></option>").attr("value", roles[i].key).text(roles[i].description));
    });
}

function checkContactMethodField(field) {
    var valid = true;
    var fieldElement = $('#contact_'+field);

    if (fieldElement.val().trim() && ($('#contact_typeSelect').val() === 'external' || $('#contactType').text() === 'External')) {
        if (field === 'phone' || field === 'cell' || field === 'work') {
            valid = validatePhoneNumber(fieldElement.val());

            if (valid) {
                fieldElement.parent().removeClass('has-error');
                if (!$('#contact_phone').parent().hasClass('has-error') && !$('#contact_cell').parent().hasClass('has-error') && !$('#contact_work').parent().hasClass('has-error')) {
                    $('#phoneError').hide();
                }
            } else {
                fieldElement.parent().addClass('has-error');
                $('#phoneError').show();
            }
        } else if (field === 'email') {
            valid = validateEmail(fieldElement.val());

            if (valid) {
                fieldElement.parent().removeClass('has-error');
                $('#emailError').hide();
            } else {
                fieldElement.parent().addClass('has-error');
                $('#emailError').show();
            }
        }
    }

    return valid;
}

function contactSearch(url) {
    var results = [];
    $.ajax({
        url: url,
        async: false,
        success: function(data) {

            if (data.results) {
                if(data.results instanceof Array) {
                    for (var i = 0;  i < data.results.length;  i++) {
                        var tmp = data.results[i];
                        var contact = {
                            name: tmp.lastName + ", " + tmp.firstName
                        };

                        results.push(contact);
                    }
                } else {
                    results.push(data.results);
                }
            }
        }
    });
    return results;
}

function deleteContact(id) {
    if (confirm("Are you sure you wish to fully delete this contact? \n" +
            "If you wish it inactivate this contact instead, click Cancel, and edit the contact's status by clicking View.")) {
        $.ajax({
            url:'../demographic/Contact.do',
            async:false,
            data: {method: "removeContact", contactId: id},
            success:function(data) {
                $('#contact_'+id).hide();
                self.opener.refresh();
            }
        });
    } else {
        return false;
    }
}

function displayName(){
    var formattedName = $('#contact_contactName').val();
    var lastName = formattedName.indexOf(",") !== -1 ? formattedName.split(",")[0] : formattedName;
    var firstName = formattedName.indexOf(",") !== -1 && formattedName.split(",").length > 1 ? formattedName.split(",")[1] : "";

    $('#last_name').val(lastName);
    $('#first_name').val(firstName);
}

function editName() {
    var lastName =  $('#last_name').val();
    var firstName =  $('#first_name').val();
    var type = $('#contact_typeSelect').val();

    if (type === 'external') {
        $('#contact_contactName').val(lastName + ", " + firstName);
    } else if ($('#contact_contactId').val()) {
        displayName();
    }
}

function isPersonalOtherContact() {
    return $('#contact_category').val() === 'personal' && $('#contact_role').val() === 'Other';
}

function isValid() {
    var valid = true;
    $returnMessage = "";

    if (!$('#contact_contactName').val() || $('#contact_contactName').val().trim().length <= 0) {
        $returnMessage += "Missing contact name \n";
        valid = false;
    }

    if (isExistingContact($('#contact_contactId').val()) && $isNewContact) {
        $returnMessage += "Contact already exits for this demographic \n";
        valid = false;
    }

    return valid;
}

function popup(height, width, url, windowName){
    if (!windowName) {
        windowName = "manageContacts";
    }
    
    if (windowName === "demographic" || windowName === "encounter") {
        $displayEditModal = false;
    }

    return popupWindow(height, width, 0, 0, url, windowName)
}

function popupWindow(height, width, top, left, url, windowName){
    if (typeof popupWindow.winRefs == 'undefined') {
        popupWindow.winRefs = {};
    }
    if (typeof popupWindow.winRefs[windowName] == 'undefined' || popupWindow.winRefs[windowName].closed ) {
        windowprops = "height="+height+",width="+width+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=" + top + ",left=" + left;
        popupWindow.winRefs[windowName]=window.open(url, windowName, windowprops);
    }
    else {
        popupWindow.winRefs[windowName].location.href = url;
        popupWindow.winRefs[windowName].resizeTo(width,height);
        popupWindow.winRefs[windowName].focus();
    }

    return popupWindow.winRefs[windowName];
}

function saveContact(isNewContact) {
    $isNewContact = isNewContact !== null ? isNewContact : false;
    var valid = isValid();
    if (!valid) {
        alert($returnMessage);
    }
    return valid;
}

function searchContacts() {
    var category = $('input[type=radio][name=contact_category]:checked').val();
    var type = $('#contact_typeSelect').val();
    var keyword = $('#last_name').val();

    if ($('#first_name').val().trim() && $('#last_name').val().indexOf(",") === -1) {
        keyword += ", " + $('#first_name').val().trim();
    }

    var url = null;
    var columns = {
        contactId: '',
        firstName: 'firstName',
        lastName: 'lastName'
    };

    if (category === 'personal' && type === 'internal') {
        url = '../demographic/demographicsearch2apptresults.jsp?search_mode=search_name&formName=contactForm&keyword=' + keyword;
    } else if (category === 'personal' && type === 'external') {
        url = '../demographic/contactSearch.jsp?form=contactForm&list=personal&keyword=' + keyword;
    } else if (category === 'professional' && type === 'internal') {
        url = '../provider/receptionistfindprovider.jsp?custom=true&providername=' + keyword + '&form=contactForm';
        columns.contactId = 'providerNo';
    } else if (category === 'professional' && type === 'specialist') {
        url = '../demographic/professionalSpecialistSearch.jsp?form=contactForm&keyword=' + keyword + '&submit=Search';
    } else if (category === 'professional' && type === 'external') {
        url = '../demographic/procontactSearch.jsp?form=contactForm&submit=Search&keyword=' + keyword;
    }

    if (url) {
        popup(700, 960, url, 'demographic_search');
    }
}

function setBestContactMethod(contactMethod) {
    $('#contactMethods li.list-group-item.active').removeClass('active');
    $('#contactMethods input[required="required"]').removeAttr('required');

    if (contactMethod) {
        $('#contact_'+contactMethod).parent().addClass('active');
        $('#contact_'+contactMethod).attr('required', 'required');
    } else {
        $('input[type=radio][name=contact_bestContact]:checked').parent().removeClass('active');
        $('input[type=radio][name=contact_bestContact]:checked').prop('checked', false);
    }
}

function setConsent() {
    var noConsent = $('#contact_consentToContact').val() === "0";

    if (noConsent) {
        $('#bestContact').hide();
    } else {
        $('#bestContact').show();
    }
}

function setContactCategoryType(category, typeSelect) {
    $('#contact_contactId').val('');
    $('#contact_contactName').val('');
    $('#last_name').val('');
    $('#first_name').val('');
    $('#phoneError').hide();
    $('#emailError').hide();
    $('#contactMethods input[required="required"]').removeAttr('required');
    $('#contactMethods li.list-group-item.has-error').removeClass('has-error');


    if (!category) {
        category = $('input[type=radio][name=contact_category]:checked').val();
    }

    if (!typeSelect) {
        typeSelect = $("#contact_typeSelect").val();
    }

    buildContactRoles(category);

    var type = $("#contact_type");

    if (category === 'personal' && typeSelect === 'internal') {
        type.val('1');
    } else if (category === 'professional' && typeSelect === 'internal') {
        type.val('0');
    } else if (category === 'professional' && typeSelect === 'specialist') {
        type.val('3');
    } else if (typeSelect === 'external') {
        type.val('2');
    }


    if (category === 'personal') {
        $('#ecSdm').show();
        $("#contact_typeSelect option[value=specialist]").hide();
        $('#health_care').hide();
        $('#health_care_team').attr('checked', false);
    } else {
        $('#ecSdm').hide();
        $("#contact_typeSelect option[value=specialist]").show();
        if ($independentHealthCareTeam) {
            $('#health_care').show();
        }
        
        $('#health_care_team').attr('checked', true);
    }

    if (typeSelect === 'external') {
        $('#contact_phone').val('').removeAttr('disabled');
        $('#contact_cell').val('').removeAttr('disabled');
        $('#contact_work').val('').removeAttr('disabled');
        $('#contact_work_extension').val('').removeAttr('disabled');
        $('#contact_email').val('').removeAttr('disabled');
    } else {
        $('#contact_phone').val('').attr('disabled', 'disabled');
        $('#contact_cell').val('').attr('disabled', 'disabled');
        $('#contact_work').val('').attr('disabled', 'disabled');
        $('#contact_work_extension').val('').attr('disabled', 'disabled');
        $('#contact_email').val('').attr('disabled', 'disabled');
    }
}

function setContactView(id) {
    var contact = contacts && contacts.length > 0 ? $.grep(contacts, function(e){ return e.id === id; })[0] : null;

    if (contact && contact.category && $displayEditModal) {
        var searchVal = "";

        if (!id){
            searchVal = "Search";
            id = '';
        }

        $.ajax({
            url: '../demographic/editContact.jsp?search=' + searchVal + '&id=' + id + "&type=" + contact.type,
            async: false,
            success: function(data) {
                $("#contactContainer").html(data);
                setValues(contact);
                $('#contactView').modal('show');
            }
        });
    }

    $displayEditModal = true;
}

function setValues(contact) {
    buildContactRoles(contact.category);
    var contactRole = matchContactRole(contact.category, contact.role);
    $('#contact_id').val(contact.id);
    $('#contact_contactName').val(contact.contactName);
    $('#contactName').text(contact.contactName);
    $('#contact_role').val(contactRole);
    $('#contact_consentToContact').val(contact.consentToContact ? '1' : '0');
    $('#contact_active').val(contact.active ? '1' : '0');
    $('#contact_contactId').val(contact.contactId);
    $('#contact_type').val(contact.type);
    $('#contact_category').val(contact.category);
    $('#contact_note').val(contact.note ? contact.note : '');


    if (contact.bestContact) {
        $('input[type=radio][name=contact_bestContact]').filter('[value="' + contact.bestContact + '"]').attr('checked', true);
        setBestContactMethod(contact.bestContact);
    }


    if (contact.details) {
        var notSet = 'Not Set';
        if (contact.type === 2) {
            notSet = '';
            $('#contact_phone').removeAttr('disabled');
            $('#contact_cell').removeAttr('disabled');
            $('#contact_work').removeAttr('disabled');
            $('#contact_work_extension').removeAttr('disabled');
            $('#contact_email').removeAttr('disabled');
        }
        $('#contact_phone').val(contact.details.residencePhone ? contact.details.residencePhone : notSet);
        $('#contact_cell').val(contact.details.cellPhone ? contact.details.cellPhone : notSet);
        $('#contact_work').val(contact.details.workPhone ? contact.details.workPhone : notSet);
        $('#contact_work_extension').val(contact.details.workPhoneExtension ? contact.details.workPhoneExtension : notSet);
        $('#contact_email').val(contact.details.email ? contact.details.email : notSet);
    }

    $('#contactType').text(contact.type === 2 ? 'External' : 'Internal');
    if (contact.category === 'personal') {
        $('#contactCategory').text('Personal');
        $('#ecSdm').show();
        $('#contact_sdm').val(contact.sdm ? contact.sdm : '');
        $('#contact_ec').val(contact.ec ? contact.ec : '');
        $('#health_care').hide();
        $('#health_care_team').attr('checked', false);
    } else if (contact.category === 'professional') {
        $('#contactCategory').text('Professional');
        if (contact.type === 3) {
            $('#contactType').text('Professional Specialist');
        }
        
        if ($independentHealthCareTeam) {
            $('#health_care').show();
        }
        $('#health_care_team').attr('checked', contact.healthCareTeam);
    }

    setConsent();
}

/**
 * Matches the contact's role by converting it and the keys in the array to lowercase and comparing them.
 * This is necessary because if the role was imported and not capitalized, it may not match up with the correct patient role
 * 
 * category - The category the contact falls under, either Personal or Professional
 * role - The contact's stored role
 */
function matchContactRole(category, role) {
    var listToSearch = [];
    var roleDescription;
    
    if (category === 'personal') {
        listToSearch = $personalRoles;
    } else if (category === 'professional') {
        listToSearch = $professionalRoles;
    }
    
    var matchedRole = listToSearch.find(r => r.key.toLowerCase() === role.toLowerCase());
    
    if (!matchedRole) {
        roleDescription = "Other";
        $('#contact_role_other').show();
        if (role && role.trim()) {
            $('#contact_role_other').val(role.trim());
        }
    } else {
        roleDescription = matchedRole.description;
    }
    
    return roleDescription;
}

function updateList(listType) {

    var current = $('#contactListNav li.active')[0];

    if (current && !current.getAttribute('id').startsWith(listType)){
        current.removeAttribute('class');
        $('#contactListNav li#' + listType + 'Contacts').addClass('active');
        $("#list").val(listType);
        document.contactList.submit();
    }
}

function updateSort(column) {
    var sortColumn =$("#sortColumn").val();
    var sortOrder = $("#sortOrder").val();

    if(sortColumn !== column) {
        sortColumn = column;
        sortOrder = 'asc';
    } else {
        if(sortOrder === 'asc') {
            sortOrder = 'desc';
        } else {
            sortOrder='asc';
        }
    }

    $("#sortColumn").val(sortColumn);
    $("#sortOrder").val(sortOrder);

    document.contactList.submit();
}

function isExistingContact(id) {
    var contactExists = false;
    $.ajax({
        url:'../demographic/Contact.do',
        async:false,
        data: {method: "doesContactExist", demographicNo: $('#demographicNo').val(), contactId: id},
        success:function(data) {
            contactExists = data.contactExists;
        }
    });

    return contactExists;
}

function validateEmail(email) {
    var validEmail = true;
    var validEmailPattern = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$/;

    if (email && email.trim()) {
        validEmail = email.match(validEmailPattern);
    }

    return validEmail;
}

function validatePhoneNumber(phoneNumber) {
    var validPhone = true;
    var validPhoneNumberPattern = /^\s*(?:\+?(\d{1,3}))?[-.]{0,1}[(]{0,1}(\d{3})[)]{0,1}[-.]{0,1}(\d{3})[-. ]{0,1}(\d{4})$/;
    if (phoneNumber && phoneNumber.trim()) {
        validPhone = phoneNumber.match(validPhoneNumberPattern);
    }

    return validPhone;
}