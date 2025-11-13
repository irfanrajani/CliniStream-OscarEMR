/*
 * On page load, this script registers an event listener for the "submit" event on the
 * HTML form with ID "providerForm" that validates form numeric field values for the form.
 *
 * Validated Form Id
 *  - providerForm
 *
 * Validated values
 *  - numericFormField - numeric text input field
 *
 * Updated HTML elements
 *  - errorMessage - set it's CSS display property to "block"
 */

window.onload = function() {

	// register event listener
    if (document.getElementById("providerForm")) {

	    document.getElementById("providerForm").onsubmit = function(e) {
		    // get form element value in a safe manner
		    var formFieldElements = document.querySelectorAll('[id^="numericFormField"]');
            for (var i = 0; i < formFieldElements.length; i++ ) {

                var formFieldElement = formFieldElements[i];
		        if (!formFieldElement) {
                    console.log("no element");
			        return;
		        }

		        var value = formFieldElement.value;
		        if (!value) {
                    console.log("no value");
			        return;
		        }

		        // trim
		        value = value.replace(/^\s+|\s+$/, "");

		        // validate
		        var hasNonDigits = /\D+/.test(value);
		        var isGreaterThanZero = parseInt(value) > 0;
		        var isValid = !hasNonDigits && isGreaterThanZero;
		        if (!isValid) {

		            // show error message
		            var errorMessageElement = document.getElementById("errorMessage");
		            if (errorMessageElement) {
			            errorMessageElement.style.display = "block";
		            }

		            // highlight error
		            formFieldElement.focus();
		            formFieldElement.style.borderColor = "red";

		            // cancel form submission
		            return false;

		        }
            }
            return;
	    };
    };
};