const RxMedrecComponent = {
  bindings: {
  },
  templateUrl: '../web/record/rx/medrec/medrec.template.jsp',
  controller: ['$stateParams','$state','$log','$timeout','measurementService','providerService','$filter','$window','$uibModal',function($stateParams,$state,$log,$timeout,measurementService,providerService,$filter,$window,$uibModal) {
  	 rxMedrecComp = this;

  
  	
  	rxMedrecComp.$onInit = function(){
  		
  		rxMedrecComp.lastMedRecDate = "N/A";
  		rxMedrecComp.providerName = null;
  		rxMedrecComp.trackingMeasurement = "MDRC";
  		rxMedrecComp.longerThanAYear = false;
  		rxMedrecComp.showAddNew = false;
  		
  		var measurementList = {}
  		measurementList.types = [rxMedrecComp.trackingMeasurement];
  		getLatestMeasurment($stateParams.demographicNo,measurementList);


 	}
  	
  	getLatestMeasurment = function(demographicNo,measurementList){
  		measurementService.getMeasurements(demographicNo,measurementList).then(
				function(d) {
					processMeasurementResponse(d);
				},
				function(errorMessage) {
					console.log("Error parsing Intruction",errorMessage);
				}
			);
  	};
  	
  	processMeasurementResponse = function(d){
  		console.log("d.measurements.length",d.measurements[rxMedrecComp.trackingMeasurement]);
  		if(d.measurements[rxMedrecComp.trackingMeasurement] == undefined){
			rxMedrecComp.longerThanAYear = true;
			return;
		}
  		
  		rxMedrecComp.lastMedRecDate = d.measurements[rxMedrecComp.trackingMeasurement][0].dateObserved;
  		rxMedrecComp.providerNo = d.measurements[rxMedrecComp.trackingMeasurement][0].providerNo;
  		providerService.getProvider(rxMedrecComp.providerNo).then(function(data){
  			console.log("get PRovidere ",data);
  			rxMedrecComp.providerName  = data.lastName+", "+data.firstName;
  		});
		now = new Date();
		if(now.getTime() - d.measurements[rxMedrecComp.trackingMeasurement][0].dateObserved    > 31557600000){
			console.log("longer than a year");
			rxMedrecComp.longerThanAYear = true;
		}
		rxMedrecComp.longerThanAYear = false; 
  	}
  	
  	rxMedrecComp.buttonStyle = function(mode){
  		if(rxMedrecComp.longerThanAYear){
  			return "btn-danger";
  		}
  		return "btn-primary";
  	}
  	
  	rxMedrecComp.showNewButton = function(){
  		console.log("rxMedrecComp.showAddNew",rxMedrecComp.showAddNew);
  		if(rxMedrecComp.showAddNew){
  			rxMedrecComp.showAddNew = false;
  		}else{
  			rxMedrecComp.showAddNew = true;
  		}
  	}
  	
  	rxMedrecComp.saveNewMedRec = function(){
  		console.log("$ctrl.newMedRec",rxMedrecComp.newMedRec);
  		measurement = {};
  		measurement.type = rxMedrecComp.trackingMeasurement;
  		measurement.dataField = "yes";
  		measurement.dateObserved = rxMedrecComp.newMedRec;
  		
  		measurementService.saveMeasurement($stateParams.demographicNo,measurement).then(
				function(d) {
					console.log("measurement ",d);
					processMeasurementResponse(d);
					rxMedrecComp.showNewButton();
					
				},
				function(errorMessage) {
					console.log("Error parsing Intruction",errorMessage);
				}
			);
  	}
  	
  
 	 	
	
 	} 
  ]
};