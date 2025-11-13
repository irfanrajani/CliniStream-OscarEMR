function popupPatientRx(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '1024px';
      width       = typeof(width)     != 'undefined' ? width : '1280px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'docEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
      left = Math.floor((screen.width)/2);
    // As the browser will NOT open a window off screen 
    // hack: open a smaller window in the proper offset position
    // and then SearchDrug3.jsp can resize to proper width to extend off the screen
      windowprops = "height="+height+",width="+width+",screenX=50,screenY="+left+",left="+left+",top=50,location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,";
console.log(windowprops+"\nscreen width="+screen.width);
	  d = document.getElementById('demofind'+ docId).value; 
	  urlNew = url + d;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        popup = window.open(urlNew, windowName, windowprops);
            popup.setfocus;
      }
}

function popupPatient(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '700px';
      width       = typeof(width)     != 'undefined' ? width : '1024px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'docEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
	  d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
	  urlNew = url + d;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        return popup2(height, width, 0, 0, urlNew, windowName);
      }
}

function popupPatientTicklerPlus(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '700px';
      width       = typeof(width)     != 'undefined' ? width : '1024px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'docEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
      d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
      n = document.getElementById('demofindName' + docId).value;
      urlNew = url + "method=edit&tickler.demographic_webName=" + n + "&tickler.demographicNo=" +  d + "&docType=DOC&docId="+docId;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        return popup2(height, width, 0, 0, urlNew, windowName);
      }
}

function popupPatientTickler(height, width, url, windowName, docId, inTabs) {
      height      = typeof(height)    != 'undefined' ? height : '700px';
      width       = typeof(width)     != 'undefined' ? width : '1024px';
      url         = typeof(url)       != 'undefined' ? url : '';
      windowName  = typeof(windowName)!= 'undefined' ? windowName : 'docEdit';
      docId       = typeof(docId)     != 'undefined' ? docId : '0';
      inTabs      = typeof(inTabs)    != 'undefined' ? inTabs : false;
	  d = document.getElementById('demofind'+ docId).value; //demog  //attachedDemoNo
	  n = document.getElementById('demofindName' + docId).value;
	  urlNew = url + "demographic_no="+d+"&name="+n+"&chart_no=&bFirstDisp=false&messageID=null&remoteFacilityId=&docType=DOC&docId="+docId;
      if (inTabs) {
	        return window.open(urlNew, windowName);
        } else {
	        return popup2(height, width, 0, 0, urlNew, windowName);
      }
}

function getDocumentType() {
    return document.getElementsByName('docType')[0].value || '';
}

