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

<html ng-app="surveillanceConfig">
<head>
	<title>DX Registry Bulk Add</title>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/angular.min.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/diseaseRegistryServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/demographicServices.js"></script>	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="surveillanceConfig">
		<div class="page-header">
			<h4>DX Registry Bulk Add</h4>
		</div>
		<div class="row">
		 	<div class="col-xs-3">
		 		<span ng-hide="selectedDx.description" >1. Select a diagnostic code to bulk added to patients.</span>
			 	<h3 ng-show="selectedDx.description"  style="margin-top:0px">{{selectedDx.description}}({{selectedDx.codingSystem}}:{{selectedDx.code}})</h3>
			 	<span ng-show="selectedDx.description" >2. To add this diagnostic code to the patient's Disease Registry add the patient's demographic number in the text area below.<br>One Demographic Number per line.  <br>E.G.</span>
			 	<pre ng-show="selectedDx.description" >453345333
3453455553
344422333</pre>
				<button ng-show="selectedDx.description" ng-click="parseForDemos()" class="btn btn-primary btn-block" style="margin-bottom:3px;">Add Dx Code to Patients</button>
			 	
			 	<div ng-show="showDxSelection">
				 	<div class="panel panel-default" ng-repeat="list in quickLists">
		  				<div class="panel-heading">{{list.label}}</div>
						<div class="panel-body" style="padding:0px;">
						    <div class="list-group">
							  <a ng-click="dxSelected(item);" class="list-group-item" ng-repeat="item in list.dxList">{{item.description}} ({{item.codingSystem}}:{{item.code}}) </a>
							</div>
						</div>
					</div>	
				</div>
				<div ng-show="showDemographicTextBox">
			 		<textarea ng-model="textToParse" class="form-control" rows="30"></textarea>	
			 		
			 	</div>
		  		
		 	</div>
		 	
		 	<div class="col-xs-8" >
		 	
		 	<h4>Processed List</h4>
	 	
		 		<table class="table  table-striped"> 
		 			<thead> 
		 				<tr> 
		 					<th>#</th> 
		 					<th>Demographic #</th> 
		 					<th>Valid Patient</th>
		 					<th>Has Dx</th>
		 					<th>Dx Added</th> 
						</tr> 
					</thead> 
		 			<tbody> 
		 				<tr ng-repeat="demo in demoList"> 
		 					<th scope="row">{{demo.idx}}</th> 
		 					<td>{{demo.no}}</td> 
		 					<td>{{demo.valid}}</td>
		 					<td>{{demo.alreadyHasDx}}</td>
		 					<td>{{demo.dxAdded}}</td> 
		 				</tr> 
		 			</tbody> 
		 		</table>
		 		

		 	</div>
	 	</div>
	 	
	 	
		
	</div>
	
	<script>
		var app = angular.module("surveillanceConfig", ['diseaseRegistryServices','demographicServices']);
		
		app.controller("surveillanceConfig", function($scope,$http,diseaseRegistryServices,demographicService) {
		
			$scope.demoList = [];
			
			$scope.quickLists = [];
			$scope.showDxSelection = true;
			$scope.showDemographicTextBox = false;
			$scope.selectedDx = {};
			$scope.selectedIssue = {};
			
			$scope.dxSelected = function(item){
				$scope.selectedDx = item;
				$scope.selectedIssue.type = item.codingSystem;
				$scope.selectedIssue.code = item.code;
				$scope.showDxSelection = false;
				$scope.showDemographicTextBox = true;
			}
			
			getQuickLists = function(){
				
				diseaseRegistryServices.getQuickLists().then(function(data){
	    				$scope.quickLists = data;
	    			
				});
			};
			getQuickLists();
			processDemo = function(item, index) {
				console.log("processDemo",item,index);
				
				
				if(item.trim().length != 0){
					var demo = {};
					demo.idx = index;
					demo.no = item;
					//Valid Patient?
					demo.valid = false;
					demographicService.getDemographic(demo.no).then(function(data){
						if(angular.isDefined(data.demographicNo)){
							demo.valid = true;
							//Has Dx Already?
							demo.alreadyHasDx = false;
							demo.dxAdded = false;
							$http.get('../ws/rs/dxRegisty/getDiseaseRegistry?demographicNo='+demo.no).then(function (response){
            						console.log("getDiseaseRegistry",response.data);
            						for(i=0; i < response.data.length; i++){
            							console.log("for loop",response.data[i]);
            							var x = response.data[i];
            							if(x.codingSystem === $scope.selectedDx.codingSystem && x.dxresearchCode === $scope.selectedDx.code){
          								  demo.alreadyHasDx = true;
          							  }
            						}
            						for (x in response.data) {
            							console.log("X",x);
            							console.log("x.codingSystem = "+x.codingSystem+" $scope.selectedDx.codingSystem "+$scope.selectedDx.codingSystem+" && x.dxresearchCode "+x.dxresearchCode+" $scope.selectedDx.code"+$scope.selectedDx.code );
            							  if(x.codingSystem === $scope.selectedDx.codingSystem && x.dxresearchCode === $scope.selectedDx.code){
            								  demo.alreadyHasDx = true;
            							  }
            						} 
            						if(!demo.alreadyHasDx){
            							console.log("going to add ",$scope.selectedDx,demo);
            							diseaseRegistryServices.addToDxRegistry(demo.no,$scope.selectedIssue).then(function(data){
            								demo.dxAdded = true;	
            							});
            						}
            						
            						
          					});
									
							
						}
							
						console.log("getDemographic",data);
					});
					
							
					//Added?
					$scope.demoList.push(demo);
				}
			}
			
			$scope.parseForDemos = function(){
				$scope.demoList = [];
				if(!confirm("Press OK to add dx code: "+$scope.selectedDx.codingSystem+":"+$scope.selectedDx.code+" to these patients:\n\n"+$scope.textToParse)){
					return;	
				}
				splitlines = $scope.textToParse.split(/\n/);
				splitlines.forEach(processDemo);
			}
		  


			
			
		
			
		});
	
	</script>
	</body>
</html>	    			