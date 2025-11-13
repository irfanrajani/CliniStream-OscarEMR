const RxPrintComponent = {
  bindings: {
	  close: '&',
	  dismiss: '&',
	  resolve: '<',
  },
  templateUrl: '../web/record/rx/print/print.template.jsp',
  controller: ['$stateParams','$state','$uibModal','$log','rxService','$http',function($stateParams,$state,$uibModal,$log,rxService,$http) {
	  
	/*
	 Options on the print page:
	 -Print PDF with drop box for size.  //look at ViewScript2.jsp
	 -Print
	 -Print & Paste into EMR
	 -Create New Rx
	 
	  Add additional notes to rx  (Add to Rx)
	  
	  Signature spot.
	  
	 */  
	  
  	rxPrint = this;
  	
  	rxPrint.print = function(){
  		printIframe();
  	}
  	
  	signatureHandler = function(e) {
		var browserName=navigator.appName; 
		if (browserName=="Microsoft Internet Explorer"){
			try{ 
				iframe = document.getElementById('preview'); 
				iframe.contentWindow.document.signatureHandler(e);  
			}catch(e){ 
				window.print(); 
			} 
		}else{
			preview.signatureHandler(e);
		}	
	}
  	
  	rxPrint.printPasteToChartNote = function(){
  		 try{
  		      text =""; // "****<%=oscar.oscarProvider.data.ProviderData.getProviderName(bean.getProviderNo())%>********************************************************************************";
  		      //console.log("1");
  		      //text = text.substring(0, 82) + "\n";
  		      if (document.all){
  		         text += document.getElementById("preview").contentWindow.document.getElementById("rx_no_newlines").value;
  		      } else {
  		         text += document.getElementById("preview").contentWindow.document.getElementById("rx_no_newlines").value + "\n";
  		      }
  		      //console.log("2");
  		      text+=document.getElementById('additionalNotes').value+"\n";
  		      //text += "**********************************************************************************\n";
  		      //oscarLog(text);

  		      //we support pasting into orig encounter and new casemanagement
  		      demographicNo = $stateParams.demographicNo;
  		      noteEditor = "noteEditor"+demographicNo;
  		      if( window.parent.opener.document.forms["caseManagementEntryForm"] != undefined ) {
  		          //oscarLog("3");
  		        window.parent.opener.pasteToEncounterNote(text);
  		      }else if( window.parent.opener.document.encForm != undefined ){
  		          //oscarLog("4");
  		        window.parent.opener.document.encForm.enTextarea.value = window.parent.opener.document.encForm.enTextarea.value + text;
  		      }else if( window.parent.opener.document.getElementById(noteEditor) != undefined ){
  		    	window.parent.opener.document.getElementById(noteEditor).value = window.parent.opener.document.getElementById(noteEditor).value + text; 
  		      }
  		      
  		   }catch (e){
  		      alert ("ERROR: could not paste to EMR");
  		      console.log(e,e);
  		   }
  		   
  		   printIframe();
  		
  	}
  	
  	rxPrint.$onInit = function(){
 		console.log("oninit print component",this);

 		rxPrint.printId = this.resolve.scriptId;
 		rxPrint.pharamacyId = this.resolve.pharamacyId;
 		rxPrint.scriptURL = "../web/record/rx/print/PrintView.jsp?scriptId="+rxPrint.printId+"&rePrint=false&pharmacyId="+rxPrint.pharamacyId;
 		rxService.recordPrescriptionPrint(rxPrint.printId);
 	}
 	
 	
  	rxPrint.ok = function () {
  		console.log("ok");
  		rxPrint.close({$value: 'hi'});
    };

    rxPrint.cancel = function () {
    		console.log("cancel");
    		rxPrint.dismiss({$value: 'cancel'});
 	};
 	
 	rxPrint.defaultPageOption = "PageSize.A4";
 	rxPrint.pdfPageOptions = [{label:"A4 page", code:"PageSize.A4"},{label:"A6 page", code:"PageSize.A6"},{label:"Letter page", code:"PageSize.Letter"}];
 	
 	rxPrint.printPDF = function(pageOpt = null) {
 		if(angular.isDefined(this.resolve.reprint) && this.resolve.reprint){
 			onPrint2("rePrint", this.resolve.scriptId,pageOpt);
 		}else{
 			onPrint2("print", this.resolve.scriptId,pageOpt);
 		}
 	   
 	}
 	
 	rxPrint.addNotes = function(){
	    var url = "../oscarRx/AddRxComment.jsp";
	    var ran_number=Math.round(Math.random()*1000000);
	    var comment = encodeURIComponent(document.getElementById('additionalNotes').value);
	    var params = "scriptNo="+this.resolve.scriptId+"&comment="+comment+"&rand="+ran_number;  //]
	    $http.get(url+"?"+params).then(function(response) {
	      console.log(response);
	    });
	    //new Ajax.Request(url, {method: 'post',parameters:params}); 
	    document.getElementById("preview").contentWindow.document.getElementById('additNotes').innerHTML =  document.getElementById('additionalNotes').value.replace(/\n/g, "<br>");
	    document.getElementById("preview").contentWindow.document.getElementsByName('additNotes')[0].value=  document.getElementById('additionalNotes').value.replace(/\n/g, "\r\n");
 	
 		
 	}
 		
 	function onPrint2(method, scriptId,rxPageSize) {
 			
 			var useSC=false;
 	        var scAddress="";
 	        if(rxPageSize == null){
 	        		rxPageSize = rxPrint.defaultPageOption;
 	        }

 	  /*<% if(vecAddressName != null) {
 	    %>
 	        useSC=true;
 	   <%      for(int i=0; i<vecAddressName.size(); i++) {%>
 		    if(document.getElementById("addressSel").value=="<%=i%>") {
 	    	       scAddress="<%=vecAddress.get(i)%>";
 	            }
 	<%       }
 	      }%>
 			*/
 	       
 	       
 	              var action="../../../../form/createcustomedpdf?__title=Rx&__method=" +  method+"&useSC="+useSC+"&scAddress="+scAddress+"&rxPageSize="+rxPageSize+"&scriptId="+scriptId;
 	            document.getElementById("preview").contentWindow.document.getElementById("preview2Form").action = action;
 	            document.getElementById("preview").contentWindow.document.getElementById("preview2Form").target="_blank";
 	            document.getElementById("preview").contentWindow.document.getElementById("preview2Form").submit();
 	       return true;
 	   }
 	
 	
 	function printIframe(){
 	   var browserName=navigator.appName; 
 	   if (browserName=="Microsoft Internet Explorer"){
 	      try{ 
 		     iframe = document.getElementById('preview'); 
 		     iframe.contentWindow.document.execCommand('print', false, null); 
 		  }catch(e){ 
 		     window.print(); 
 		  } 
 	   }else{
          preview.focus();
 		  preview.print();
 	   }	
    }
 	
 	
 	
 	
 	} 
  ]
};





  