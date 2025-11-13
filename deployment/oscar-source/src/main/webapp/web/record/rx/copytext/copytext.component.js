const CopytextComponent = {
  bindings: {
	  close: '&',
	  dismiss: '&',
	  resolve: '<',
  },
  templateUrl: '../web/record/rx/copytext/copytext.template.jsp',
  controller: ['$stateParams','$state','$uibModal','$log','rxService','$http',function($stateParams,$state,$uibModal,$log,rxService,$http) {
	  
  	copyComp = this;
  	
  	copyComp.$onInit = function(){
 		console.log("oninit copytext component",this,$stateParams);
		
  		$http.get("../oscarConsultationRequest/consultationClinicalData.do?method=fetchMedications&demographicNo="+$stateParams.demographicNo).then(function(response) {
  			console.log("copyTextLines",response);
  			copyComp.text = response.data.note;
  			
    	    });

 	}

  	copyComp.copy = function () {
  		var copyText = document.getElementById("copyTextAreaComponent");  		
  		copyText.select();
  	  	document.execCommand("copy");
    };

    copyComp.cancel = function () {
    		console.log("cancel");
    		copyComp.dismiss({$value: 'cancel'});
 	};
 	
 	} 
  ]
};
