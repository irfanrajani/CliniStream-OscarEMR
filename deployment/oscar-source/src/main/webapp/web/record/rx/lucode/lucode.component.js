const RxLucodeComponent = {
  bindings: {
	  med: '<' 
  },
  templateUrl: '../web/record/rx/lucode/lucode.template.jsp',
  controller: ['$stateParams','$state','$log','$timeout','rxService','providerService','$filter','$window','$uibModal',function($stateParams,$state,$log,$timeout,rxService,providerService,$filter,$window,$uibModal) {
  	 luCodeComp = this;

  	luCodeComp.codes = []; 
  	
  	luCodeComp.$onInit = function(){
  		
  		console.log("luCodeComp.$onInit",luCodeComp.med.regionalIdentifier);

  		rxService.getLUCodes(luCodeComp.med.regionalIdentifier).then(
				function(d) {
					console.log("getLUCodes",d);
					luCodeComp.codes = d.data;
				},
				function(errorMessage) {
					console.log("Error parsing Intruction",errorMessage);
				}
			);

 	}
  	
  	
  	luCodeComp.addLuCode = function(lu){
  		luCodeComp.med.instructions = luCodeComp.med.instructions+" LU Code: "+lu.useId; 
  		console.log("med "+luCodeComp.med);
  	}
  	
 	} 
  ]
};