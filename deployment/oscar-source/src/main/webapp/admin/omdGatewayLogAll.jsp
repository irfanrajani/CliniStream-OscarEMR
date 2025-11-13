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
</head>

<body vlink="#0000FF" class="BodyStyle">
	<div ng-controller="consentConfig">
		<div class="page-header">
			<h4>Gateway Interactions Log</h4>
		</div>
		
		
		<div class="row">
			<div class="col-xs-3">
				<div class="list-group">
						  <a ng-click="openLog(logDetail)" class="list-group-item" ng-class="itemActive(logDetail.id)" data-ng-repeat="logDetail in logDetails | limitTo:loadedSurveillanceConfigsQuantity" >
						  	
						  	<h4 class="list-group-item-heading">
						  		<span ng-if="logDetail.success" style="color:green" class="glyphicon glyphicon-ok " aria-hidden="true"></span> 
						  		{{logDetail.transactionType}}
						  	</h4>
							 <p class="list-group-item-text">Started: {{logDetail.started | date:'medium'}}</p>
							 
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
		var app = angular.module("consentConfig", ['surveillanceServices','providerServices','dhdrServices']);
		
		app.controller("consentConfig", function($scope,surveillanceService,providerService,dhdrService) {
		
			$scope.logDetails = [];
			$scope.currentLogDetail = {};
			$scope.expireTimes = [];
			
	    		getAllLogs = function(){
	    			dhdrService.getAllGatewayLogs().then(function(data){
	    				console.log("data",data);
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