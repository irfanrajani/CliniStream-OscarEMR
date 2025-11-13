<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
	boolean authed=true;
%>
<security:oscarSec roleName="<%=roleName$%>"
	objectName="_admin,_admin.misc" rights="r" reverse="<%=true%>">
	<%authed=false; %>
	<%response.sendRedirect("../securityError.jsp?type=_admin&type=_admin.misc");%>
</security:oscarSec>
<%
	if(!authed) {
		return;
	}
%>


<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>

<html ng-app="appointmentDxLinkConfig">
<head>
	<title><bean:message key="admin.admin.appointmentDxLinkConfig"/></title>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	<script src="<%=request.getContextPath() %>/js/jquery-1.12.3.js"></script>
        <script src="<%=request.getContextPath() %>/library/jquery/jquery-migrate-1.4.1.js"></script>
	<script src="<%=request.getContextPath() %>/library/bootstrap/3.0.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/angular.min.js"></script>	
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/ui-bootstrap-tpls-0.11.0.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/scheduleServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/providerServices.js"></script>	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="appointmentDxLinkConfig">
		<div class="page-header">
			
			<h4><bean:message key="admin.admin.appointmentDxLinkConfig"/></h4>
		</div>
		<div class="row">
		 	<div class="col-xs-3">
		 	
		 		<ul class="nav nav-tabs nav-justified">
  					<li role="presentation" ng-class="sideTabActive('online')"><a ng-click="setActiveSideTab('online')">Active</a></li>
  					<li role="presentation" ng-class="sideTabActive('offline')"><a ng-click="setActiveSideTab('offline')">Archived</a></li>
  					
				</ul>	
		 		<div class="tab-content">
    					<div role="tabpanel" class="tab-pane" ng-class="sideTabActive('online')" id="home">
    						<div class="list-group">
						  <a ng-if="searchConfig.active" class="list-group-item" ng-class="itemActive(searchConfig.id)" data-ng-repeat="searchConfig in appointmentDxLinkList " >  <%--| limitTo:loadedSurveillanceConfigsQuantity --%>
						  	
						  	<h4 class="list-group-item-heading">{{searchConfig.code}}</h4>
						  	 <p class="list-group-item-text">Age Range: {{searchConfig.ageRange}}  </p>  
							 <p class="list-group-item-text">Colour: {{searchConfig.colour}}  </p>
							 <p class="list-group-item-text">Message: {{searchConfig.message}}  </p>
							 <p class="list-group-item-text">Symbol: {{searchConfig.symbol}}  </p>
							 <p class="list-group-item-text">Link: {{searchConfig.link}}  </p>
							 <p class="list-group-item-text">Create :{{searchConfig.createDate | date:'medium'}}</p>
							 <br>
		  					<button ng-if="searchConfig.active" class="btn btn-default btn-sm " ng-click="disableAppointmentDxLink(searchConfig.id);$event.stopPropagation();">Disable</button>
						  </a>
						</div>
    					</div>
    					<div role="tabpanel" class="tab-pane" ng-class="sideTabActive('offline')" id="profile">
    						<div class="list-group">
						  <a ng-if="!searchConfig.active"  class="list-group-item" ng-class="itemActive(searchConfig.id)" data-ng-repeat="searchConfig in appointmentDxLinkList | limitTo:loadedSurveillanceConfigsQuantity" >
						  	
						  	<h4 class="list-group-item-heading">{{searchConfig.code}}</h4>
						  	 <p class="list-group-item-text">Age Range: {{searchConfig.ageRange}}  </p> 
							 <p class="list-group-item-text">Colour: {{searchConfig.colour}}  </p>
							 <p class="list-group-item-text">Message: {{searchConfig.message}}  </p>
							 <p class="list-group-item-text">Symbol: {{searchConfig.symbol}}  </p>
							 <p class="list-group-item-text">Link: {{searchConfig.link}}  </p>
							 <p class="list-group-item-text">Create :{{searchConfig.createDate | date:'medium'}}</p>
							 <br>
		  					<%-- button ng-if="!searchConfig.active" class="btn btn-default btn-sm" ng-click="enableSearchConfig(searchConfig.id);$event.stopPropagation();">Enable</button --%>
						  </a>
						</div>
    					</div>
  				</div>
		  		
		 	</div>
		 	<div class="col-xs-9">
		 		
		 		<div class="jumbotron">
				  <h2>Add New Dx Link</h2>				
				  <form>
		
				  
					  <div class="form-group">
					    <label for="searchNameText">Dx Code</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="dx code that will trigger showing the symbol" ng-model="new.code">
					  </div>
					  <div class="form-group">
					    <label for="searchNameText">Dx Code Type</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="code type, usually this is icd9" ng-model="new.codeType">
					  </div>
					  <div class="form-group">
					    <label for="searchNameText">Age Range</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="Can be 40-50 or >16 or <50. Leave blank if there is no age filter" ng-model="new.ageRange">
					  </div>
					  <div class="form-group">
					    <label for="searchNameText">Colour</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="colour of the symbol in the appointment screen" ng-model="new.colour">
					  </div>
					   <div class="form-group">
					    <label for="searchNameText">Message</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="What will show when a user hovers over symbol" ng-model="new.message">
					  </div>
					  <div class="form-group">
					    <label for="searchNameText">Symbol</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="The HTML Symbol that will show in appointment screen eg. &sigma;" ng-model="new.symbol">
					  </div>
					  <div class="form-group">
					    <label for="searchNameText">Link</label>
					    <input type="text" class="form-control" id="exampleInputEmail1" placeholder="If symbol should open a page" ng-model="new.link">
					  </div>
					  <button  class="btn btn-default" ng-click="addAppointmentDxLink()">Save</button>
					</form>	  
				</div>
		 		
		 	</div>
		 	
		
	 	</div>
	 	
	 	
		
	</div>

	
	
	
	
	<script>
		var app = angular.module("appointmentDxLinkConfig", ['scheduleServices']);
		
		app.controller("appointmentDxLinkConfig", function($scope,scheduleService) {
			$scope.appointmentDxLinkList = [];
			
			$scope.currentId = null;
			$scope.currentSearchConfig = null;
			
		    $scope.new = {};
	
			
			
			getAppointmentDxLinkList = function(){
				console.log("calling getAppointmentDxLinkList");
	    			scheduleService.getAppointmentDxLinkList().then(function(data){
	    			    console.log("getAppointmentDxLinkList ",data);
	    			    $scope.appointmentDxLinkList = data;
	    			    //if($scope.currentId != null && $scope.currentId != 0){
	    			    	//$scope.openSearchConfig($scope.currentId);
	    			    //}
		    			//angular.forEach($scope.activeProviders, function(provider) {
		    			//	activeProvidersHash[provider.providerNo] = provider;
		    			//});
		    			//console.log("getTypes", activeProvidersHash); //data);
				});
	    		};
	    		
	    		getAppointmentDxLinkList();	
	    		
	    		$scope.disableAppointmentDxLink = function(id){
	    			scheduleService.disableAppointmentDxLink(id).then(function(data){
	    			    console.log("disable ",data);
	    			    
	    			    getAppointmentDxLinkList();
				});
	    		}
	
	    		$scope.addAppointmentDxLink = function(){
	    			console.log("calling addAppointmentDxLink",$scope.new);
	    			scheduleService.addAppointmentDxLink($scope.new).then(function(data){
	    			    console.log("addAppointmentDxLink ",data);
	    			    getAppointmentDxLinkList();  
				});
	    		} 
	    		
	    		
	    		
			
	    		
	    		
	    		
			
			
	    		
	    		
	    		
	    		
	    		
	    	
	    		
	    		
	    		
	    		 
				
			
	    		
	    		
	    		
		    
	    		$scope.activeTab = "main";
	    		$scope.tabActive = function(tab){
	    			if(tab === $scope.activeTab){
	    				return "active";
	    			}
	    			return "";
	    		}
	    		
	    		$scope.setActiveTab = function(tab){
	    			$scope.activeTab = tab;
	    			console.log("$scope.activeTab",$scope.activeTab);
	    		}
	    		
	    		$scope.activeSideTab = "online";
	    		$scope.sideTabActive = function(tab){
	    			if(tab === $scope.activeSideTab){
	    				return "active";
	    			}
	    			return "";
	    		}
	    		
	    		$scope.setActiveSideTab = function(tab){
	    			$scope.activeSideTab = tab;
	    			console.log("$scope.activeTab",$scope.activeSideTab);
	    		}
	    		
	    		$scope.getProviderName = function(providerNumber){
	    			provider = activeProvidersHash[providerNumber];
	    			if(provider == null){ return providerNumber+" N/A inactive"}
	    			return provider.lastName+", "+provider.firstName;
	    		}
	    		
	    		$scope.getFullProviderName = function(providerNumber){
	    			provider = activeProvidersHash[providerNumber];
	    			if(provider == null){ return providerNumber+" N/A inactive"}
	    			return provider.lastName+", "+provider.firstName+" ("+provider.providerNo+")";
	    		}
	    		
	    		
		    $scope.openSearchConfig = function(searchConfig){
		    		console.log("calling open Search Config")
		    		$scope.currentId = searchConfig.id;
		    		$scope.currentApptSearch = searchConfig;
		    		scheduleService.getSearchConfig($scope.currentId).then(function(data){
	    			    console.log("openSearchConfig/getSearchConfig ",data);
	    			    $scope.currentSearchConfig = data;
	    			    	
	    			    if($scope.currentSearchConfig == null || $scope.currentSearchConfig ===""){
	    			    		console.log("was blank");
	    			    		$scope.currentSearchConfig = {};	
	    			    }
	    			    if($scope.currentSearchConfig == null){
	    			    	    console.log("$scope.currentSearchConfig was null");
	    			    		$scope.currentSearchConfig = {};	
	    			    }
	    			    console.log("AAAAA",(!angular.isDefined($scope.currentSearchConfig.bookingProviders) || $scope.currentSearchConfig.bookingProviders == null));
	    			    if(!angular.isDefined($scope.currentSearchConfig.bookingProviders) || $scope.currentSearchConfig.bookingProviders == null){
	    			    	    console.log("initializing $scope.currentSearchConfig.bookingProviders");
		    				$scope.currentSearchConfig.bookingProviders= [];
	    			    }
	    			    console.log("$scope.currentSearchConfig 1",$scope.currentSearchConfig);
	    			    if(!angular.isDefined($scope.currentSearchConfig.bookingAppointmentTypes) || $scope.currentSearchConfig.bookingAppointmentTypes == null){
		    				$scope.currentSearchConfig.bookingAppointmentTypes = [];
	    			    }
	    			    console.log("$scope.currentSearchConfig 2",$scope.currentSearchConfig);
	    			    console.log("CCCCC",(!angular.isDefined($scope.currentSearchConfig.appointmentCodeDurations) || $scope.currentSearchConfig.appointmentCodeDurations == null));
	    			    if(!angular.isDefined($scope.currentSearchConfig.appointmentCodeDurations) || $scope.currentSearchConfig.appointmentCodeDurations == null){
	    			    		console.log("initializing $scope.currentSearchConfig.appointmentCodeDurations");
		    				$scope.currentSearchConfig.appointmentCodeDurations = {};
	    			    }
	    			    console.log("$scope.currentSearchConfig 3",$scope.currentSearchConfig);
	    			    if(!angular.isDefined($scope.currentSearchConfig.openAccessList) || $scope.currentSearchConfig.openAccessList == null){
	    			    		$scope.currentSearchConfig.openAccessList = [];
	    			    }
	    			    console.log("$scope.currentSearchConfig 4",$scope.currentSearchConfig);
		
	    			    
		    			//console.log("getTypes", activeProvidersHash); //data);
				});

		    }
		    
		   
			$scope.editApptTypeForProvider = function(appt,provider,$event){
	    			
	    			//alert("SEARCH ManageProviderApptDialogCtrl in clinic app for what to pass here in. The current clinic is wrong here.");
	    		    
	    		    var modalInstance = $modal.open({
	    		      
	    		      templateUrl: 'myModalContent.html',
	    		      controller: 'ModalInstanceCtrl',
	    		      controllerAs: 'mpa',
	    		      parent: angular.element(document.body),
	    		      size: 'lg',
	    		      appendTo: $event,
	    		      resolve: {
	    		    	  	
	    		    	  		provider: function () {
	    		          		return provider;
	    		        		},
	    		        		appt: function () {
	    		          		return appt;
	    		        		},
	    		        		apptCodes: function () {
	    		          		return $scope.oscarTemplateCodes;  // apptCodes: clinic.apptCodes
		    		        	},
		    		        	appointmentCodeDurations: function(){
		    		        		return $scope.currentSearchConfig.appointmentCodeDurations;
		    		        	}
	    		      }
	    		    });

	    		    modalInstance.result.then(function (selectedItem) {
	    		      selected = selectedItem;
	    		    }, function () {
	    		      console.log('Modal dismissed at: ' + new Date());
	    		    });
	    		  };
		    
	    		  
	    		  $scope.viewProvider = function(provider,$event){
	    			  var modalInstance = $modal.open({
		    		      
		    		      templateUrl: 'providerCopy.html',
		    		      controller: 'ViewProviderDialogCtrl',
		    		      controllerAs: 'ppa',
		    		      parent: angular.element(document.body),
		    		      size: 'lg',
		    		      appendTo: $event,
		    		      resolve: {
		    		    	  	
		    		    	  		provider: function () {
		    		          		return provider;
		    		        		},
		    		        		searchConfig: function () {
		    		          		return $scope.currentSearchConfig;
		    		        		},
		    		        		providerName : function(){
		    		        			return $scope.getProviderName;
		    		        		}
		    		      }
		    		    });

		    		    modalInstance.result.then(function (selectedItem) {
		    		      selected = selectedItem;
		    		    }, function () {
		    		      console.log('Modal dismissed at: ' + new Date());
		    		    });
	    		
	    		  }
		
			
		});
		
		app.controller('ViewProviderDialogCtrl',function ViewProviderDialogCtrl($scope,$modal,$modalInstance,provider,searchConfig,providerName){
			console.log("ViewProviderDialogCtrl",provider,searchConfig);
			$scope.vp = {};
			$scope.vp.getProviderName = providerName;
			$scope.vp.clinic = searchConfig;
			$scope.vp.copyProvidersTemplate = function(providerToCopy) {
				console.log("vpd ",provider,providerToCopy);
				provider.appointmentDurations = angular.copy(providerToCopy.appointmentDurations);
				provider.appointmentTypes = angular.copy(providerToCopy.appointmentTypes);
				$modalInstance.close(providerToCopy);	
			};
			$scope.vp.listAppt = function(prov, appt){
				if(angular.isDefined(prov) && angular.isDefined(prov.appointmentTypes)) {
			
					for(var x = 0; x < prov.appointmentTypes.length; x++) {
						if(prov.appointmentTypes[x].id === appt.id) {
							return prov.appointmentTypes[x].codes.join();
						}
					}
				}
				return "";
			}
		});
		
		app.controller('ModalInstanceCtrl', function ModalInstanceCtrl($scope, $modal, $modalInstance,provider,appt,apptCodes,appointmentCodeDurations){
			console.log("ModalInstanceCtrl",provider,appt,apptCodes);
			//console.log("mdic",mpa);
			$scope.mpa = {};
			$scope.mpa.provider = provider;
			$scope.mpa.appt = appt;
			$scope.mpa.apptCodes = [];
			console.log($scope.mpa);
			
			
			///////////////
			var ctrl = this;
		      //  	ctrl.apptCodes = [];
		        	ctrl.provider = provider;
		        	apptType = null;
		        	
		        	ctrl.getProviderName = function(prov) { return mainService.getProviderName(prov) };
		        	
		        	ctrl.providerHasApptType = function(apptId) {
		        		console.log("providerHasApptType",apptId);
		        	    for (i = 0; i < provider.appointmentTypes.length; i++) {
		        	        if (provider.appointmentTypes[i].id === apptId) {
		        	            apptType = provider.appointmentTypes[i];
		        	            if (angular.isDefined(apptType.duration) && isFinite(apptType.duration) && apptType.duration > 0) {
		        	            	$scope.mpa.durationOverride = apptType.duration;
		        	            }
		        	        }
		        	    }
		        	    
		        	}
		        	ctrl.providerHasApptType(appt.id);

		        	ctrl.getApptCodes = function() {
			        	for (i = 0; i < apptCodes.length; i++) {
			        		console.log("apptCodes",apptCodes[i]);
			        	    //if (apptCodes[i].onlineBooking) {
			        	    	if(appointmentCodeDurations[apptCodes[i].code] != null){
			        	        appointment = angular.copy(apptCodes[i]);
			        	        if (apptType != null && apptType.codes.indexOf(appointment.code) >= 0) {
			        	            appointment.accepting = true;
			        	            if (apptCodes[i].duration != apptType.duration && apptType.duration != "0") {
			        	                appointment.durationOverride = apptType.duration;
			        	            }
			        	        }
			        	        $scope.mpa.apptCodes.push(appointment);
			        	    }
			        	}
		        	}
		        	ctrl.getApptCodes();
		        	console.log("mpa2",$scope.mpa);

		        	$scope.saveManageApptProvider = function() {
		        	    var onlineAcceptingAppt = [];
		        	    for (i = 0; i < $scope.mpa.apptCodes.length; i++) {
		        	        if ($scope.mpa.apptCodes[i].accepting) onlineAcceptingAppt.push($scope.mpa.apptCodes[i].code);
		        	    }

		        	    if (apptType != null && onlineAcceptingAppt.length == 0) {
		        	        var indx = provider.appointmentTypes.indexOf(apptType);
		        	        provider.appointmentTypes.splice(indx, 1);
		        	    } else if (apptType != null) {
		        	        apptType.codes = onlineAcceptingAppt;
		        	        if ($scope.mpa.durationOverride != null && $scope.mpa.durationOverride != "" && isFinite($scope.mpa.durationOverride)) {
		        	            apptType.duration = $scope.mpa.durationOverride;
		        	        } 
		        	    } else if (onlineAcceptingAppt.length > 0) {
		        	        newApptType = { 
		        	        	codes: onlineAcceptingAppt,
		        	        	id: appt.id,
		        	        	name: appt.name
		        	        };

		        	      	if ($scope.mpa.durationOverride != null && $scope.mpa.durationOverride != "" && isFinite($scope.mpa.durationOverride)) {
		        	            newApptType.duration = $scope.mpa.durationOverride;
		        	        } 
		        	        ctrl.provider.appointmentTypes.push(newApptType);
		        	    }
		        	    $modalInstance.close(ctrl.provider);	
		        	   // $mdDialog.hide();
		        	}

				$scope.cancel = function(){
					
					$modalInstance.close(false);	
				}
			
			///////////////
		      
			//mpa = sConfig;
			
		});
	
		app.filter('blankFilter', function() {
			return function(input, input2)
			{
				if(input2){
					return (input);
				} else{
					return ('Select Appt Type');
				}
			};
		});
	</script>
	</body>
</html>	    			