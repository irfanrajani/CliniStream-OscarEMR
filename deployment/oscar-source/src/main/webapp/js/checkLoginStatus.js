//requires jquery to have been imported first

function startCheckLoginStatus(baseURL) {
	setInterval(function(){checkLoginStatus(baseURL)},5000);
}

function checkLoginStatus(baseURL) {
	jQuery.ajax({
			url:baseURL + "/ws/rs/status/checkIfAuthed", 
			dataType:"json",
			statusCode: {
				    401: function() {
				      console.log( "logged out..closing window" );
				      window.close();
				    }
			}
	});
}