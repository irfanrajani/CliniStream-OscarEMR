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

<html ng-app="uaoConfig">
<head>
	<title>UAO Configuration</title>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/angular.min.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/dhdrServices.js"></script>
	<script src="<%=request.getContextPath() %>/web/common/providerServices.js"></script>	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="uaoConfig">
		<div class="page-header">
			<h4>UAO Configuration <small >(Under the Authority Of)</small></h4>
		</div>
		<div class="row">
		 	<div class="col-xs-3">
		 		
		 		
    						<div class="list-group">
						  <a ng-click="selectProvider(prov)" class="list-group-item" ng-class="itemActive(prov.providerNo)" data-ng-repeat="prov in activeProviders " >
						  	<h4 class="list-group-item-heading"> {{prov.name}}({{prov.providerNo}})</h4>
						  </a>
						</div>
    					
		  		
		 	</div>
		 	
		 	<div class="col-xs-9" ng-show="currentProviderNo != null">
		 	
		 	
		 	
		 	
		 	<h4>Current UAO's for {{getProviderName(currentProviderNo)}}</h4>

		 		
		 		<table class="table table-condensed table-striped"> 
		 			<thead> 
		 				<tr> 
		 					<th>UAO</th> 
		 					<th>Friendly Name</th> 
		 					<th>Default</th>
		 					<th>&nbsp;</th>
						</tr> 
					</thead> 
		 			<tbody> 
		 				<tr ng-repeat="uao in currentUAOs"> 
		 					<th scope="row">{{uao.name}}</th> 
		 					<td>{{uao.friendlyName}}</td> 
		 					<td>{{uao.defaultUAO}}</td>
		 					<td><a ng-click="archiveUAO(uao)">delete</a></td> 
		 				</tr> 
		 			</tbody> 
		 		</table>
		 		
			
	 		<form class="well">
	 			<h4>Add UAO</h4>
	 		  <div class="row">	
			  	<div class="form-group col-xs-6">
			    		<label for="exampleInputName2">UAO </label>
					<input type="text" class="form-control" id="exampleInputName2" placeholder="eg, 23.2232.33232.2223.332.223" ng-model="uaoName">
			  	</div>
			  </div>
			  <div class="row">	
			  	<div class="form-group col-xs-6">
			    		<label for="exampleInputEmail2">UAO Friendly name</label>
			    		<input type="text" class="form-control" id="exampleInputEmail2" placeholder="Example Clinic" ng-model="uaoFriendlyName">
			  	</div>
			  </div>
			  
			  <button type="submit" class="btn btn-default" ng-click="createUAO(currentProviderNo,uaoFriendlyName,uaoName)" >Add</button>
			  
			</form>


		 	</div>
	 	</div>
	 	
	 	
		
	</div>
	
	<script>
		var app = angular.module("uaoConfig", ['dhdrServices','providerServices']);
		
		app.controller("uaoConfig", function($scope,dhdrService,providerService) {
		
			$scope.activeProviders = [];
			activeProvidersHash = {};
			$scope.loadedSurveillanceConfigsQuantity = 10;
			
			$scope.currentSurveyActive = false;
			$scope.currentProvider = null;
			$scope.currentProviderNo = null;
			$scope.currentUAOs= [];
			
			
	    		
	    		
	    		getAllActiveProviders = function(){
	    			providerService.getAllActiveProviders().then(function(data){
		    			$scope.activeProviders = data;
		    			console.log("$scope.activeProviders",data);
		    			angular.forEach($scope.activeProviders, function(provider) {
		    				activeProvidersHash[provider.providerNo] = provider;
		    			});
		    			console.log("getAllActiveProviders", activeProvidersHash); //data);
				});
	    		};
	    		
	    		getAllActiveProviders();
	    		
	    		$scope.itemActive = function(id){
	    			if($scope.currentProviderNo === id){
	    				return "active";
	    			}
	    			return "";
	    		}
	    		
	    		$scope.selectProvider = function(prov){
	    			$scope.currentProvider = prov;
	    			$scope.currentProviderNo = prov.providerNo;
	    			loadUAOs($scope.currentProviderNo);
	    		}
	    		
	    		loadUAOs = function(id){
	    			console.log("loadUAOs",id);
	    			dhdrService.getUAOForProvider(id).then(function(data){
	    				$scope.currentUAOs = data.data;
		    			
		    			console.log("loadUAOs",$scope.currentUAOs);
				});
	    		}; 
		    
	    		
	    		
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
	    		
			$scope.createUAO = function(currentProviderNo,uaoFriendlyName,uaoName){
				console.log("createUAO",currentProviderNo,uaoFriendlyName,uaoName);
				obj = {};
				obj.uaoName = uaoName;
				obj.uaoFriendlyName = uaoFriendlyName;
				dhdrService.createUAO($scope.currentProviderNo,obj).then(function(data){
    					console.log("data coming back",data);
    					loadUAOs($scope.currentProviderNo);
				});
				
						
			};
			
			$scope.archiveUAO = function(obj){
				
				dhdrService.archiveUAO(obj.id,$scope.currentProviderNo,obj).then(function(data){
					console.log("data coming back",data);
					loadUAOs($scope.currentProviderNo);
				});
				
			};
		     
			
			
			
			
		});
	
	</script>
	</body>
</html>	    			