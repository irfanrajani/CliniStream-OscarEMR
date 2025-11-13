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

<html ng-app="consentConfig">
<head>
	<title>Gateway Log</title>
	<link href="<%=request.getContextPath() %>/library/bootstrap/3.0.0/css/bootstrap.css" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath() %>/css/font-awesome.min.css">
	<script type="text/javascript" src="<%=request.getContextPath() %>/library/angular.min.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/surveillanceServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/providerServices.js"></script>	
	<script src="<%=request.getContextPath() %>/web/common/dhdrServices.js"></script>
	<script src="<%=request.getContextPath() %>/web/common/demographicServices.js"></script>	
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="consentConfig">
		<div class="page-header">
			<h4>Consent Unblock Log</h4>
		</div>
		
		<div class="row">
			<div class="col-xs-12">
				<form class="form-horizontal">
					  <div class="form-group">
					    <label for="inputEmail3" class="col-sm-2 control-label">Last name</label>
					    <div class="col-sm-10">
					      <input ng-model="searchtxt.demographic.lastName" type="text" placeholder="type to filter" class="form-control" />
					    </div>
					  </div>
					  <div class="form-group">
					    <label for="inputEmail3" class="col-sm-2 control-label">HIN</label>
					    <div class="col-sm-10">
					      <input ng-model="searchtxt.demographic.hin" type="text" placeholder="type to filter" class="form-control"/>
					    </div>
					  </div>
				 </form>
				
				
				
				<table class="table table-bordered">
					<tr>
						<th>Date</th>
						<th>Provider</th>
						<th>Demographic #</th>
						<th>Demographic Name</th>
						<th>Demographic HIN</th>
						<th>Unblock Status</th>
						<%--
						Date and time the request was made to override a patient consent unblock
First and Last Name of the EMR user who requested the temporary consent unblock
Unique ID of the patient related to the transaction
Patient First and Last Name
Patient Health Card Number
 --%>
					</tr>
					<tr ng-repeat="logc in logComboArr | filter : searchtxt">
						<td>{{logc.launch.started | date:'medium'}}</td>
						<td>{{getProviderName(logc.launch.initiatingProviderNo)}}</td>
						<td>{{logc.launch.demographicNo}}</td>
						<td>{{logc.demographic.lastName+", "+ logc.demographic.firstName}}</td>
						<td>{{logc.demographic.hin}}</td>
						<td>{{logc.callbackStatus}}</td>
					</tr>
				</table>
			</div>
		</div>
		
		<div class="row" ng-show="detailedLog">
			<div class="col-xs-3">
				<div class="list-group">
						  <a ng-click="openLog(logDetail)" class="list-group-item" ng-class="itemActive(logDetail.id)" data-ng-repeat="logDetail in logDetails | limitTo:loadedSurveillanceConfigsQuantity" >
						  	
						  	<h4 class="list-group-item-heading">
						  		<%--span ng-if="logDetail.success" style="color:green" class="glyphicon glyphicon-ok " aria-hidden="true"></span  --%> 
						  		{{logDetail.transactionType}}
						  	</h4>
							 <p class="list-group-item-text">Started: {{logDetail.started | date:'medium'}}</p>
							 <p class="list-group-item-text">Provider: {{getProviderName(logDetail.initiatingProviderNo)}}</p>
							 <p class="list-group-item-text">Patient: {{getDemo(logDetail.demographicNo)}}</p>
						  </a>
				</div>
			</div>
			<div class="col-xs-9">
				<div>
				    <h4>{{currentLogDetail.transactionType}} <small>Started:{{currentLogDetail.started | date:'medium'}}  - Ended: {{currentLogDetail.ended | date:'medium'}} Duration: {{currentLogDetail.ended - currentLogDetail.started}}  Result Code:({{currentLogDetail.resultCode}})</small>  </h4>
					
					<div ng-show="angular.isDefined(currentLogDetail.errorJson) && angular.isDefined(currentLogDetail.errorJson.errorCodes)">
						<h3>Error</h3>
						<pre ng-show="angular.isDefined(currentLogDetail.errorJson) && angular.isDefined(currentLogDetail.errorJson.errorCodes)">Error Codes: {{printCodes(currentLogDetail.errorJson.errorCodes)}}</pre>
					</div>
					<div ng-show="currentLogDetail.error">
						<h3>Error</h3>
						<pre>{{currentLogDetail.error}}</pre>
					</div>
					<div ng-show="angular.isDefined(currentLogDetail.errorJson) && angular.isDefined(currentLogDetail.reason)">
						<h3>Error Message </h3>
						<textarea class="form-control" rows="13">{{currentLogDetail.errorJson.reason.message}}</textarea>
						<h3>Stack Trace </h3>
						<textarea class="form-control" rows="13">{{currentLogDetail.errorJson.reason.stack}}</textarea>
					</div>
					<div ng-show="currentLogDetail.dataSentJson">
						<h3>Data Sent</h3>
						<pre>{{currentLogDetail.dataSentJson | json}}</pre>
					</div>
					
					<div ng-show="currentLogDetail.dataRecievedJson">
						<h3>Data Recieved</h3>
						<pre>{{currentLogDetail.dataRecievedJson | json}}</pre>
					</div>
					
					<div ng-show="angular.isDefined(currentLogDetail.errorJson)">
						<h3>Full Error </h3>
						<pre>{{currentLogDetail.errorJson | json}}</pre>
					</div>
					<div>
						<h3>Full Log</h3>
						<pre>{{currentLogDetail | json}}</pre>
					</div>
				</div>
			</div>
	 	</div>
	 	
	</div>
	
	<script>
		var app = angular.module("consentConfig", ['surveillanceServices','providerServices','dhdrServices','demographicServices']);
		
		app.controller("consentConfig", function($scope,surveillanceService,providerService,dhdrService,demographicService) {
		
			$scope.searchtxt = {};
			$scope.logDetails = [];
			$scope.currentLogDetail = {};
			$scope.expireTimes = [];
			activeProvidersHash = {};
			demoHash = {};
			$scope.logCombo = {}; 
			$scope.detailedLog = false;
			$scope.logComboArr = [];
			
	    		getAllLogs = function(){
	    			dhdrService.getGatewayLogsByExternalSystem('PCOI').then(function(data){
	    				console.log("data",data);
	    				
	    				<%--  Filter all unique patient names in the logs that will display.  --%> 
	    				angular.forEach(data.data,function(log){
 						if(log.demographicNo != null) {
		    					demoNo = demoHash[log.demographicNo];
		    					console.log("log.demographicNo",log.demographicNo,demoNo);
		    					if(demoNo == null){
		    						demoHash[log.demographicNo] = {};
		    						demoHash[log.demographicNo].demographicNo = log.demographicNo;
		    					}
		    					
	    					}
	    				});
	    				
	    				
	    				<%-- Now create a hash of those patients --%>
	    				angular.forEach(demoHash,function(demoNo){
	    					console.log("demoNo",demoNo);
						demographicService.getDemographic(demoNo.demographicNo).then(function(response){
    							demoHash[response.demographicNo] = response;
    						},function(reason){
    							alert(reason);
    						});
		    			});
	    				
	    				angular.forEach(data.data,function(log){
	    					console.log("lig",log.xCorrelationId);	
	    					if(log.xCorrelationId != null){
	    						fullLog = $scope.logCombo[log.xCorrelationId];
	    						if(fullLog == null){
	    							var fullLog = {};
	    							fullLog.callbackStatus = "N/A";
	    							$scope.logCombo[log.xCorrelationId] = fullLog;
	    							demographicService.getDemographic(log.demographicNo).then(function(response){
	    								fullLog.demographic = response;
	        						},function(reason){
	        							alert(reason);
	        						});
	    						}
	    						if(log.transactionType === 'CALLBACK MESSAGE'){
	    							fullLog.callback = log;
	    							
	    							try{
	    								console.log("fullLog.callback",fullLog.callback);
	    								callBackjson = JSON.parse(fullLog.callback.dataRecieved);
	    								if(angular.isDefined(callBackjson.successes) && callBackjson.successes.length >0){
	    									fullLog.callbackStatus = "Success";
	    								}else{
	    									fullLog.callbackStatus = "Cancelled";
	    								}
	    								console.log("callbackjson",callBackjson);
	    							}catch(e){
	    								console.log("ERR",e);
	    							}
	    						}else if(log.transactionType === 'consentViewletLaunch'){
	    							fullLog.launch = log;
	    						}
	    						
	    					}
	    				});
	    				
	    				angular.forEach($scope.logCombo,function(log){
	    					$scope.logComboArr.push(log);	
	    				});
	    				
		    			$scope.logDetails = data.data;
		   
				});
	    		};
	    		
	    		getPreviousGatewayLogs = function(){
	    			dhdrService.getPreviousGatewayLogs().then(function(data){
	    				console.log("data",data);
		    			$scope.logDetails = data.data;
		   
				});
	    		};
	    		
	    		
	    		$scope.itemActive = function(id){
	    			if($scope.currentLogDetail.id === id){
	    				return "active";
	    			}
	    			return "";
	    		}
	    		
	    		getTokenExpireTime = function(){
	    			dhdrService.getTokenExpireTime().then(function(data){
	    				console.log("data",data);
	    				$scope.expireTimes = data.data;
		   
				});
	    		};
	    		
	    		
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
	    		
	    		$scope.getProviderName = function(providerNumber){
	    			provider = activeProvidersHash[providerNumber];
	    			if(provider == null){ return providerNumber+" N/A inactive"}
	    			return provider.lastName+", "+provider.firstName +" ("+provider.practitionerNo+")";
	    		}
	    		
	    		
	    		$scope.getDemo = function(demoNo){
					return demoHash[demoNo].lastName+", "+ demoHash[demoNo].firstName+" (HIN: "+demoHash[demoNo].hin+")";
				};
	    		
	    		getAllLogs();
	    		getTokenExpireTime();
	    		$scope.openLog = function(logDetail){
	    			console.log("setting to current ",logDetail);
	    			$scope.currentLogDetail = logDetail;
	    			$scope.currentLogDetail.errorJson = JSON.parse(logDetail.error);
	    			$scope.currentLogDetail.dataSentJson = JSON.parse(logDetail.dataSent);
	    			$scope.currentLogDetail.dataRecievedJson = JSON.parse(logDetail.dataRecieved);
	    			console.log("currentLogDetail.errorJson.errorCodes",$scope.currentLogDetail.errorJson.errorCodes);
	    		}
	    		
	    		$scope.loadPreviousGatewayLogs = function(){
	    			getPreviousGatewayLogs();
	    		}
	    		
	    		$scope.printCodes = function(arr){
	    			var retString = "";
	    			for(a in arr){
	    				retString = retString + arr[a] +",";
	    			}
	    			return retString.slice(0, -1); ;
	    		}
	    		
	    					
		});
	
	</script>
	</body>
</html>	    			