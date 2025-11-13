/*

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

*/
angular.module("dhdrServices", [])
	.service("dhdrService", function ($http,$q,$log) {
		return {
		apiPath:'../ws/rs',
		configHeaders: {headers: {"Content-Type": "application/json","Accept":"application/json"}},
		configHeadersWithCache: {headers: {"Content-Type": "application/json","Accept":"application/json"},cache: true},
	      
		searchByDemographicNo: function (demographicNo) {
        	var deferred = $q.defer();
        	$http({
                url: this.apiPath+'/dhdr/searchByDemographicNo?demographicNo='+demographicNo,
                method: "GET",
                headers: this.configHeaders,
              }).then(function(response){
            	  deferred.resolve(response.data);
                },function (data, status, headers) {
                	deferred.reject("An error occured while getting phr content");
                });
           return deferred.promise;
        },
        searchByDemographicNo2: function (demographicNo,searchConfig) {
        	var deferred = $q.defer();
        	$http({
                url: this.apiPath+'/dhdr/searchByDemographicNo2?demographicNo='+demographicNo,
                method: "POST",
                data: searchConfig,
                headers: this.configHeaders,
              }).then(function(response){
            	  deferred.resolve(response.data);
                },function (data, status, headers) {
                	deferred.reject("An error occured while getting phr content");
                });
           return deferred.promise;
        },
        getConsentOveride: function (demographicNo) {
        	var deferred = $q.defer();
        	$http({
                url: this.apiPath+'/dhdr/getConsentOveride?demographicNo='+demographicNo,
                method: "GET",
                headers: this.configHeaders,
              }).then(function(response){
            	  deferred.resolve(response);
                },function (data, status, headers) {
                	console.log("data error ",data);
                	deferred.reject("An error occured check log for additional details");
                });
           return deferred.promise;
        },
        logConsentOveride: function (demographicNo,uniqueToken,dataReceived) {
        	var deferred = $q.defer();
        	$http({
                url: this.apiPath+'/dhdr/logConsentOveride/'+demographicNo+'/'+uniqueToken,
                method: "POST",
                data: dataReceived,
                headers: this.configHeaders,
              }).then(function(response){
            	  deferred.resolve(response);
                },function (data, status, headers) {
                	console.log("data error ",data);
                	deferred.reject("An error occured check log for additional details");
                });
           return deferred.promise;
        },
        logConsentOverrideCancelRefuse: function (demographicNo,dataReceived) {
        	var deferred = $q.defer();
        	$http({
                url: this.apiPath+'/dhdr/logConsentOverrideCancelRefuse/'+demographicNo,
                method: "POST",
                data: dataReceived,
                headers: this.configHeaders,
              }).then(function(response){
            	  deferred.resolve(response);
                },function (data, status, headers) {
                	console.log("data error ",data);
                	deferred.reject("An error occured check log for additional details");
                });
           return deferred.promise;
        },
        getGatewayLogs: function(){
           	var deferred = $q.defer();
           	 $http.get(this.apiPath+'/dhdr/getGatewayLogs',this.configHeaders).then(function(response){
               	console.log("returned from /PHRAbilities",response.data);
               	deferred.resolve(response);
               },function(data, status, headers){
               	console.log("error initializing phr",data, status, headers);
               	deferred.reject("An error occured while trying to initialize k2a");
               });
        
             return deferred.promise;
        },        
        getPreviousGatewayLogs: function(){
           	var deferred = $q.defer();
           	 $http.get(this.apiPath+'/dhdr/getPreviousGatewayLogs',this.configHeaders).then(function(response){
               	console.log("returned from /PHRAbilities",response.data);
               	deferred.resolve(response);
               },function(data, status, headers){
               	console.log("error initializing phr",data, status, headers);
               	deferred.reject("An error occured while trying to initialize k2a");
               });
        
             return deferred.promise;
        },
        getAllGatewayLogs: function(){
           	var deferred = $q.defer();
          	 $http.get(this.apiPath+'/dhdr/getAllGatewayLogs',this.configHeaders).then(function(response){
              	console.log("returned from /PHRAbilities",response.data);
              	deferred.resolve(response);
              },function(data, status, headers){
              	console.log("error initializing phr",data, status, headers);
              	deferred.reject("An error occured while trying to initialize k2a");
              });
       
            return deferred.promise;
       },
       getGatewayLogsByExternalSystem: function(systemType){
          	var deferred = $q.defer();
         	 $http.get(this.apiPath+'/dhdr/getGatewayLogsByExternalSystem/'+systemType,this.configHeaders).then(function(response){
             	console.log("returned from /getGatewayLogsByExternalSystem",response.data);
             	deferred.resolve(response);
             },function(data, status, headers){
             	console.log("error getGatewayLogsByExternalSystem phr",data, status, headers);
             	deferred.reject("An error occured while trying to initialize k2a");
             });
      
           return deferred.promise;
      },
        createUAO: function(id,obj){
            var deferred = $q.defer();
            $http.post(this.apiPath+'/dhdr/createUAO/'+id,obj,this.configHeaders).then(function(data){
                    deferred.resolve(data.data);
            },function(){
              deferred.reject("An error occured while trying to /resources/setExportAsSent/"+id);
            });
            return deferred.promise;    
        },
        getUAOForProvider: function(prov){
           	var deferred = $q.defer();
           	 $http.get(this.apiPath+'/dhdr/UAO/list/'+prov,this.configHeaders).then(function(response){
               	console.log("returned from /getUAOForProvider",response.data);
               	deferred.resolve(response);
               },function(data, status, headers){
               	console.log("error initializing phr",data, status, headers);
               	deferred.reject("An error occured while trying to initialize k2a");
               });
        
             return deferred.promise;
        },
        archiveUAO: function(id,provider,obj){
            var deferred = $q.defer();
            $http.post(this.apiPath+'/dhdr/archiveUAO/'+provider+'/'+id,obj,this.configHeaders).then(function(data){
                    deferred.resolve(data.data);
            },function(){
              deferred.reject("An error occured while trying to /resources/setExportAsSent/"+id);
            });
            return deferred.promise;    
        },
        getTokenExpireTime: function(){
           	var deferred = $q.defer();
           	 $http.get(this.apiPath+'/dhdr/getTokenExpireTime/',this.configHeaders).then(function(response){
               	console.log("returned from /getTokenExpireTime",response.data);
               	deferred.resolve(response);
               },function(data, status, headers){
               	console.log("error initializing phr",data, status, headers);
               	deferred.reject("An error occured while trying to initialize k2a");
               });
        
             return deferred.promise;
        },
        muteDisclaimer: function(dType){
	        	var deferred = $q.defer();
	        	$http({
	                url: this.apiPath+'/dhdr/muteDisclaimer/'+dType,
	                method: "GET",
	                headers: this.configHeaders,
	              }).then(function(response){
	            	  deferred.resolve(response);
	                },function (data, status, headers) {
	                	console.log("data error ",data);
	                	deferred.reject("An error occured check log for additional details");
	                });
	           return deferred.promise;
        },
        showDisclaimer: function(dType){
	        	var deferred = $q.defer();
	        	$http({
	                url: this.apiPath+'/dhdr/showDisclaimer/'+dType,
	                method: "GET",
	                headers: this.configHeaders,
	              }).then(function(response){
	            	  deferred.resolve(response);
	                },function (data, status, headers) {
	                	console.log("data error ",data);
	                	deferred.reject("An error occured check log for additional details");
	                });
	           return deferred.promise;
        }
       
    };
});

