-- final patch OSCAR 15 sql  May 14, 2018
-- contains both patch and the earlier patch1
-- this is an amalgamation of updates 
-- written so that they can be re-run on a patched database without error
-- read carefully as there are comments and optional sections

-- patch1 sql July 5, 2017

CREATE TABLE IF NOT EXISTS `indicatorTemplate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dashboardId` int(11),
  `name` varchar(255),
  `category` varchar(255),
  `subCategory` varchar(255),
  `framework` varchar(255),
  `frameworkVersion` date,
  `definition` tinytext,
  `notes` tinytext,
  `template` mediumtext,
  `active` bit(1),
  `locked` bit(1),
  PRIMARY KEY (`id`)
);

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `CreateIndex` $$
CREATE PROCEDURE `CreateIndex`
(
    given_database VARCHAR(64),
    given_table    VARCHAR(64),
    given_unique   VARCHAR(64),
    given_index    VARCHAR(64),
    given_columns  VARCHAR(64)

)
theStart:BEGIN

    DECLARE TableIsThere INTEGER;
    DECLARE IndexIsThere INTEGER;

    SELECT COUNT(1) INTO TableIsThere
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE table_schema = given_database
    AND   table_name   = given_table;

    IF TableIsThere = 0 THEN
        SELECT CONCAT(given_database,'.',given_table, 
	' does not exist.  Unable to add ', given_index) CreateIndexMessage;
	LEAVE theStart;
    ELSE

	    SELECT COUNT(1) INTO IndexIsThere
	    FROM INFORMATION_SCHEMA.STATISTICS
	    WHERE table_schema = given_database
	    AND   table_name   = given_table
	    AND   index_name   = given_index;

	    IF IndexIsThere = 0 THEN
		SET @sqlstmt = CONCAT('CREATE ',given_unique,' INDEX ',given_index,' ON ',
		given_database,'.',given_table,' (',given_columns,')');
		PREPARE st FROM @sqlstmt;
		EXECUTE st;
		DEALLOCATE PREPARE st;
	    ELSE
		SELECT CONCAT('Index ',given_index,' Already Exists ON Table ',
		given_database,'.',given_table) CreateIndexMessage;
	    END IF;

	END IF;

END $$

DELIMITER ;

-- INSERT DEFERED INDICES from the following updates


-- phc hack
UPDATE `oscar_15`.`eform` SET `file_name` = 'rtl.html' WHERE `form_name` = 'Rich Text Letter' AND `file_name` IS NULL;
UPDATE `oscar_15`.`eform` SET `file_name` = '' WHERE `file_name` IS NULL;

-- from update 2014 02 1 warped forward to 2014

UPDATE `eform` 
SET `form_date`= '2014-12-30', `status`= '1', `form_html`= '\n<html><head>\r\n<meta http-equiv="content-type" content="text/html; charset=UTF-8">\r\n\r\n<title>Rich Text Letter</title>\r\n<style type="text/css">\r\n.butn {width: 140px;}\r\n</style>\r\n\r\n<style type="text/css" media="print">\r\n.DoNotPrint {display: none;}\r\n\r\n</style>\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}jquery/jquery-1.4.2.js"></script>\r\n\r\n<script language="javascript">\r\nvar needToConfirm = false;\r\n\r\n//keypress events trigger dirty flag for the iFrame and the subject line\r\ndocument.onkeyup=setDirtyFlag\r\n\r\n\r\nfunction setDirtyFlag() {\r\n	needToConfirm = true; \r\n}\r\n\r\nfunction releaseDirtyFlag() {\r\n	needToConfirm = false; //Call this function if dosent requires an alert.\r\n	//this could be called when save button is clicked\r\n}\r\n\r\n\r\nwindow.onbeforeunload = confirmExit;\r\n\r\nfunction confirmExit() {\r\n	if (needToConfirm){\r\n	return "You have attempted to leave this page. If you have made any changes without clicking the Submit button, your changes will be lost. Are you sure you want to exit this page?";\r\n	}\r\n}\r\n\r\n\r\nvar loads=true;\r\n\r\nfunction maximize() {\r\n	window.resizeTo(1030, 865) ;\r\n	loads=false;\r\n}\r\n\r\nfunction saveRTL() {\r\n	needToConfirm=false;\r\n	var theRTL=editControlContents(''edit'');\r\n	var myNewString = theRTL.replace(/"/g, ''&quot;'');\r\n	document.getElementById(''Letter'').value=myNewString.replace(/''/g, "&#39;");\r\n}\r\n</script>\r\n\r\n<!-- START OF EDITCONTROL CODE --> \r\n\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}eforms/editControl.js"></script>\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}eforms/APCache.js"></script>\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}eforms/imageControl.js"></script>\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}eforms/faxControl.js"></script>\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}eforms/signatureControl.jsp"></script>\r\n<script language="javascript" type="text/javascript" src="${oscar_javascript_path}eforms/printControl.js"></script>\r\n\r\n<script language="javascript">\r\n	//put any of the optional configuration variables that you want here\r\n	cfg_width = ''840''; //editor control width in pixels\r\n	cfg_height = ''520''; //editor control height in pixels\r\n	cfg_editorname = ''edit''; //the handle for the editor                  \r\n	cfg_isrc = ''../eform/displayImage.do?imagefile=''; //location of the button icon files\r\n	cfg_filesrc = ''../eform/displayImage.do?imagefile=''; //location of the html files\r\n	cfg_template = ''blank.rtl''; //default style and content template\r\n	cfg_formattemplate = ''<option value=""> loading... </option></select>'';\r\n	//cfg_layout = ''[all]'';             //adjust the format of the buttons here\r\n	//cfg_layout = ''<table style="background-color:ccccff; width:840px"><tr id=control1><td>[bold][italic][underlined][strike][subscript][superscript]|[left][center][full][right]|[unordered][ordered][rule]|[undo][redo]|[indent][outdent][select-all][clean]|[table]</td></tr><tr id=control2><td>[select-block][select-face][select-size][select-template]|[image][clock][date][spell][help]</td></tr></table>[edit-area]'';\r\n	cfg_layout = ''<table style="background-color:ccccff; width:840px"><tr id=control1><td align=center>[bold][italic][underlined][strike][subscript][superscript]|[left][center][full][right]|[unordered][ordered][rule]|[undo][redo]|[indent][outdent][select-all][clean]|[table]\\[text-colour][hilight]</td></tr><tr id=control2><td align=center>[select-block][select-face][select-size][select-template]|[image][link]|[clock][date][spell][cut][copy][paste][help]</td></tr></table>[edit-area]'';\r\n	insertEditControl(); // Initialise the edit control and sets it at this point in the webpage\r\n\r\n	\r\n	function gup(name, url)\r\n	{\r\n		if (url == null) { url = window.location.href; }\r\n		name = name.replace(/[\\[]/,"\\\\\\[").replace(/[\\]]/,"\\\\\\]");\r\n		var regexS = "[\\\\?&]"+name+"=([^&#]*)";\r\n		var regex = new RegExp(regexS);\r\n		var results = regex.exec(url);\r\n		if (results == null) { return ""; }\r\n		else { return results[1]; }\r\n	}\r\n	var demographicNo ="";\r\n\r\n	jQuery(document).ready(function(){\r\n		demographicNo = gup("demographic_no");\r\n		if (demographicNo == "") { demographicNo = gup("efmdemographic_no", jQuery("form").attr(''action'')); }\r\n		if (typeof signatureControl != "undefined") {\r\n			signatureControl.initialize({\r\n				sigHTML:"../signature_pad/tabletSignature.jsp?inWindow=true&saveToDB=true&demographicNo=",\r\n				demographicNo:demographicNo,\r\n				refreshImage: function (e) {\r\n					var html = "<img src=''"+e.storedImageUrl+"&r="+ Math.floor(Math.random()*1001) +"''></img>";\r\n					doHtml(html);		\r\n				},\r\n				signatureInput: "#signatureInput"	\r\n			});\r\n		}		\r\n	});\r\n		\r\n	var cache = createCache({\r\n		defaultCacheResponseHandler: function(type) {\r\n			if (checkKeyResponse(type)) {\r\n				doHtml(cache.get(type));\r\n			}			\r\n			\r\n		},\r\n		cacheResponseErrorHandler: function(xhr, error) {\r\n			alert("Please contact an administrator, an error has occurred.");			\r\n			\r\n		}\r\n	});	\r\n	\r\n	function checkKeyResponse(response) {		\r\n		if (cache.isEmpty(response)) {\r\n			alert("The requested value has no content.");\r\n			return false;\r\n		}\r\n		return true;\r\n	}\r\n	\r\n	function printKey (key) {\r\n		var value = cache.lookup(key); \r\n		if (value != null && checkKeyResponse(key)) { doHtml(cache.get(key)); } 		  \r\n	}\r\n	\r\n	function submitFaxButton() {\r\n		document.getElementById(''faxEForm'').value=true;\r\n		saveRTL();\r\n		setTimeout(''document.RichTextLetter.submit()'',1000);\r\n	}\r\n	\r\n	cache.addMapping({\r\n		name: "_SocialFamilyHistory",\r\n		values: ["social_family_history"],\r\n		storeInCacheHandler: function(key,value) {\r\n			cache.put(this.name, cache.get("social_family_history").replace(/(<br>)+/g,"<br>"));\r\n		},\r\n		cacheResponseHandler:function () {\r\n			if (checkKeyResponse(this.name)) {				\r\n				doHtml(cache.get(this.name));\r\n			}	\r\n		}\r\n	});\r\n	\r\n	\r\n	cache.addMapping({name: "template", cacheResponseHandler: populateTemplate});	\r\n	\r\n	cache.addMapping({\r\n		name: "_ClosingSalutation", \r\n		values: ["provider_name_first_init"],	\r\n		storeInCacheHandler: function (key,value) {\r\n			if (!cache.isEmpty("provider_name_first_init")) {\r\n				cache.put(this.name, "<p>Yours Sincerely<p>&nbsp;<p>" + cache.get("provider_name_first_init") + ", MD");\r\n			}\r\n		},\r\n		cacheResponseHandler:function () {\r\n			if (checkKeyResponse(this.name)) {				\r\n				doHtml(cache.get(this.name));\r\n			}	\r\n		}\r\n	});\r\n	\r\n	cache.addMapping({\r\n		name: "_ReferringBlock", \r\n		values: ["referral_name", "referral_address", "referral_phone", "referral_fax"], 	\r\n		storeInCacheHandler: function (key, value) {\r\n			var text = \r\n				(!cache.isEmpty("referral_name") ? cache.get("referral_name") + "<br>" : "") \r\n			  + (!cache.isEmpty("referral_address") ? cache.get("referral_address") + "<br>" : "")\r\n			  + (!cache.isEmpty("referral_phone") ? "Tel: " + cache.get("referral_phone") + "<br>" : "")\r\n			  + (!cache.isEmpty("referral_fax") ? "Fax: " + cache.get("referral_fax") + "<br>" : "");\r\n			if (text == "") {\r\n				text = \r\n					(!cache.isEmpty("bc_referral_name") ? cache.get("bc_referral_name") + "<br>" : "") \r\n				  + (!cache.isEmpty("bc_referral_address") ? cache.get("bc_referral_address") + "<br>" : "")\r\n				  + (!cache.isEmpty("bc_referral_phone") ? "Tel: " + cache.get("bc_referral_phone") + "<br>" : "")\r\n				  + (!cache.isEmpty("bc_referral_fax") ? "Fax: " + cache.get("bc_referral_fax") + "<br>" : "");\r\n			}						 \r\n			cache.put(this.name, text)\r\n		},\r\n		cacheResponseHandler: function () {\r\n			if (checkKeyResponse(this.name)) {\r\n				doHtml(cache.get(this.name));\r\n			}\r\n		}\r\n	});\r\n	\r\n	cache.addMapping({\r\n		name: "letterhead", \r\n		values: ["clinic_name", "clinic_fax", "clinic_phone", "clinic_addressLineFull", "doctor", "doctor_contact_phone", "doctor_contact_fax", "doctor_contact_addr"], \r\n		storeInCacheHandler: function (key, value) {\r\n			var text = genericLetterhead();\r\n			cache.put("letterhead", text);\r\n		},\r\n		cacheResponseHandler: function () {\r\n			if (checkKeyResponse(this.name)) {\r\n				doHtml(cache.get(this.name));\r\n			}\r\n		}\r\n	});\r\n	\r\n	cache.addMapping({\r\n		name: "referral_nameL", \r\n		values: ["referral_name"], \r\n		storeInCacheHandler: function(_key,_val) { \r\n		if (!cache.isEmpty("referral_name")) {\r\n				var mySplitResult =  cache.get("referral_name").toString().split(",");\r\n				cache.put("referral_nameL", mySplitResult[0]);\r\n			} \r\n		}\r\n	});\r\n\r\n	cache.addMapping({\r\n		name: "medical_historyS", \r\n		values: ["medical_history"], \r\n		storeInCacheHandler: function(_key,_val) { \r\n		if (!cache.isEmpty("medical_history")) {\r\n				var mySplitResult =  cache.get("medical_history").toString().split("]]-----");\r\n				cache.put("medical_historyS", mySplitResult.pop());\r\n			} \r\n		}\r\n	});\r\n\r\n	cache.addMapping({\r\n		name: "stamp", \r\n		values: ["stamp_name", "doctor"], \r\n		storeInCacheHandler: function(_key,_val) { \r\n				var imgsrc=pickStamp();\r\n				cache.put("stamp",imgsrc);\r\n		}\r\n	});\r\n\r\n	\r\n	cache.addMapping({\r\n		name: "complexAge", \r\n		values: ["complexAge"], \r\n		cacheResponseHandler: function() {\r\n			if (cache.isEmpty("complexAge")) { \r\n				printKey("age"); \r\n			}\r\n			else {\r\n				if (checkKeyResponse(this.name)) {\r\n					doHtml(cache.get(this.name));\r\n				}\r\n			}\r\n		}\r\n	});\r\n	\r\n	// Setting up many to one mapping for derived gender keys.\r\n	var genderKeys = ["he_she", "his_her", "gender"];	\r\n	var genderIndex;\r\n	for (genderIndex in genderKeys) {\r\n		cache.addMapping({ name: genderKeys[genderIndex], values: ["sex"]});\r\n	}\r\n	cache.addMapping({name: "sex", values: ["sex"], storeInCacheHandler: populateGenderInfo});\r\n	\r\n	function isGenderLookup(key) {\r\n		var y;\r\n		for (y in genderKeys) { if (genderKeys[y] == key) { return true; } }\r\n		return false;\r\n	}\r\n	\r\n	function populateGenderInfo(key, val){\r\n		if (val == ''F'') {\r\n			cache.put("sex", "F");\r\n			cache.put("he_she", "she");\r\n			cache.put("his_her", "her");\r\n			cache.put("gender", "female");				\r\n		}\r\n		else {\r\n			cache.put("sex", "M");\r\n			cache.put("he_she", "he");\r\n			cache.put("his_her", "his");\r\n			cache.put("gender", "male");				\r\n		}\r\n	}\r\n	\r\n	function Start() {\r\n		\r\n			$.ajax({\r\n				url : "efmformrtl_templates.jsp",\r\n				success : function(data) {\r\n					$("#template").html(data);\r\n					loadDefaultTemplate();\r\n				}\r\n			});\r\n	\r\n			$(".cacheInit").each(function() { \r\n				cache.put($(this).attr(''name''), $(this).val());\r\n				$(this).remove();				\r\n			});\r\n			\r\n			// set eventlistener for the iframe to flag changes in the text displayed \r\n			var agent = navigator.userAgent.toLowerCase(); //for non IE browsers\r\n			if ((agent.indexOf("msie") == -1) || (agent.indexOf("opera") != -1)) {\r\n				document.getElementById(cfg_editorname).contentWindow\r\n						.addEventListener(''keypress'', setDirtyFlag, true);\r\n			}\r\n				\r\n			// set the HTML contents of this edit control from the value saved in Oscar (if any)\r\n			var contents = document.getElementById(''Letter'').value\r\n			if (contents.length == 0) {\r\n				parseTemplate();\r\n			} else {\r\n				seteditControlContents(cfg_editorname, contents);\r\n				document.getElementById(cfg_editorname).contentWindow.document.designMode = ''on'';\r\n			}\r\n			maximize();\r\n	}\r\n\r\n	function htmlLine(text) {\r\n		return text.replace(/\\r?\\n/g,"<br>");\r\n	}\r\n\r\n	function genericLetterhead() {\r\n		// set the HTML contents of the letterhead\r\n		var address = ''<table border=0><tbody><tr><td><font size=6>''\r\n				+ cache.get(''clinic_name'')\r\n				+ ''</font></td></tr><tr><td><font size=2>''\r\n				+ cache.get(''doctor_contact_addr'')\r\n				+ '' Fax: '' + cache.get(''doctor_contact_fax'')\r\n				+ '' Phone: '' + cache.get(''doctor_contact_phone'')\r\n				+ ''</font><hr></td></tr></tbody></table><br>'';\r\n		if ( (cache.get(''clinic_name'').toLowerCase()).indexOf(''amily health team'',0)>-1){\r\n		address=fhtLetterhead(); }\r\n		if ( (cache.get(''clinic_name'').toLowerCase()).indexOf(''fht'',0)>-1){\r\n		address=fhtLetterhead(); }\r\n		return address;\r\n	}\r\n\r\n	function fhtLetterhead() {\r\n		// set the HTML contents of the letterhead using FHT colours\r\n		var address = cache.get(''clinic_addressLineFull'')\r\n				+ ''<br>Fax:'' + cache.get(''clinic_fax'')\r\n				+ '' Phone:'' + cache.get(''clinic_phone'');\r\n		if (cache.contains("doctor")) {\r\n			var str = cache.get(''doctor'');\r\n			var res = str.split(", "); //last, first\r\n			if (cache.get(''doctor'').indexOf(''zapski'') > 0) {\r\n			address = ''293 Meridian Avenue, Haileybury, ON P0J 1K0<br> Tel 705-672-2442&nbsp;&nbsp; Fax 866-945-5725'';\r\n			}\r\n			if (cache.get(''doctor'').indexOf(''lokodan'') > 0) {\r\n			address = ''PO Box 1178, Haileybury, ON P0J 1K0<br> Tel 705-672-3371&nbsp;&nbsp; Fax 866-945-5725'';\r\n			}\r\n			if (cache.get(''doctor'').indexOf(''hurman'') > 0) {\r\n			address = ''494 Ferguson, Haileybury, ON P0J 1K0<br> Tel 705-672-3371&nbsp;&nbsp; Fax 866-945-5725'';\r\n			}\r\n		}\r\n		address = ''<table style=\\''text-align: right;\\'' border=\\''0\\''><tbody><tr class=\\''t71\\'' style=\\''font-style: italic;\\''><td><font size=\\''+2\\''>''\r\n				+ cache.get(''clinic_name'')\r\n				+ ''</font> <hr class=\\''b212\\''></td> </tr> <tr class=\\''t71\\''> <td><font size=\\''+1\\''>''\r\n				+  res[1] + " " + res[0] + ''</font></td> </tr> <tr class=\\''b212\\''> <td><small>''\r\n				+ address + ''</small></td> </tr> </tbody> </table>'';\r\n		return address;\r\n	}\r\n\r\n	function pickStamp() {\r\n		// set the HTML contents of the signature stamp\r\n		var mystamp =''<img src="../eform/displayImage.do?imagefile=stamp.png">'';\r\n		if (cache.contains("doctor")) {\r\n			if (cache.get(''doctor'').indexOf(''zapski'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=PHC.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''doctor'').indexOf(''hurman'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=MCH.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''doctor'').indexOf(''mith'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=PJS.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''doctor'').indexOf(''loko'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=FAO.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''doctor'').indexOf(''urrie'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=LNC.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''doctor'').indexOf(''esilets'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=SAD.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''doctor'').indexOf(''lgadi'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=KME.png" width="200" height="100" />'';\r\n				}\r\n			\r\n		}\r\n		if (cache.contains("current_user")) {\r\nalert ("current_user found")\r\n			if (cache.get(''current_user'').indexOf(''lgadi'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=KME.png" width="200" height="100" />'';\r\n				}\r\n			if (cache.get(''current_user'').indexOf(''sworth'') > 0) {\r\n				mystamp = ''<img src="../eform/displayImage.do?imagefile=KME.png" width="200" height="100" />'';\r\n				}\r\n		}\r\n		return mystamp;\r\n	}\r\n	var formIsRTL = true;\r\n\r\n</script>\r\n<!-- END OF EDITCONTROL CODE -->\r\n</head><body bgcolor="FFFFFF" onload="Start();">\r\n<form method="post" action="" name="RichTextLetter" ><textarea name="Letter" id="Letter" style="width:600px; display: none;"></textarea>\r\n\r\n<div class="DoNotPrint" id="control3" style="position:absolute; top:20px; left: 860px;">\r\n\r\n<!-- Letter Head -->\r\n<input type="button" class="butn" name="AddLetterhead" id="AddLetterhead" value="Letterhead" onclick="printKey(''letterhead'');">\r\n<br>\r\n\r\n<!-- Referring Block -->\r\n<input type="button" class="butn" name="AddReferral" id="AddReferral" value="Referring Block" onclick="printKey(''_ReferringBlock'');">\r\n<br>\r\n\r\n<!-- Patient Block -->\r\n<input type="button" class="butn" name="AddLabel" id="AddLabel" value="Patient Block" onclick="printKey(''label'');">\r\n<br>\r\n<br> \r\n\r\n<!-- Social History -->\r\n<input type="button" class="butn" name="AddSocialFamilyHistory" value="Social History" onclick="var hist=''_SocialFamilyHistory'';printKey(hist);">\r\n<br>\r\n\r\n<!--  Medical History -->\r\n<input type="button"  class="butn" name="AddMedicalHistory" value="Medical History" width=30 onclick="var hist=''medical_historyS'';printKey(hist);">\r\n<br>\r\n\r\n<!--  Ongoing Concerns -->\r\n<input type="button" class="butn" name="AddOngoingConcerns" value="Ongoing Concerns" onclick="var hist=''ongoingconcerns''; printKey(hist);">\r\n<br>\r\n\r\n<!-- Reminders -->\r\n<input type="button" class="butn" name="AddReminders" value="Reminders"\r\n	onclick="var hist=''reminders''; printKey(hist);">\r\n<br>\r\n\r\n<!-- Allergies -->\r\n<input type="button" class="butn" name="Allergies" id="Allergies" value="Allergies" onclick="printKey(''allergies_des'');">\r\n<br>\r\n\r\n<!-- Prescriptions -->\r\n<input type="button" class="butn" name="Medlist" id="Medlist" value="Prescriptions"	onclick="printKey(''druglist_trade'');">\r\n<br>\r\n\r\n<!-- Other Medications -->\r\n<input type="button" class="butn" name="OtherMedicationsHistory" value="Other Medications" onclick="printKey(''other_medications_history''); ">\r\n\r\n<br>\r\n\r\n<!-- Risk Factors -->\r\n<input type="button" class="butn" name="RiskFactors" value="Risk Factors" onclick="printKey(''riskfactors''); ">\r\n<br>\r\n\r\n<!-- Family History -->\r\n<input type="button" class="butn" name="FamilyHistory" value="Family History" onclick="printKey(''family_history''); ">\r\n<br>\r\n<br>\r\n\r\n<!-- Patient Name --> \r\n<input type="button" class="butn" name="Patient" value="Patient Name" onclick="printKey(''first_last_name'');">\r\n<br>\r\n\r\n<!-- Patient Age -->\r\n<input type="button" class="butn" name="PatientAge" value="Patient Age" onclick="var hist=''ageComplex''; printKey(hist);">\r\n\r\n<br>\r\n\r\n<!-- Patient Label -->\r\n<input type="button" class="butn" name="label" value="Patient Label" onclick="hist=''label'';printKey(hist);">\r\n<br>\r\n\r\n<input type="button" class="butn" name="PatientSex" value="Patient Gender" onclick="printKey(''gender'');">\r\n<br>\r\n<br>\r\n\r\n<!-- Closing Salutation -->\r\n<input type="button" class="butn" name="Closing" value="Closing Salutation" onclick="printKey(''_ClosingSalutation'');">\r\n<br>\r\n\r\n<!-- Signature Stamp -->\r\n<input type="button" class="butn" name="stamp" value="Stamp" onclick="printKey(''stamp'');">\r\n<br>\r\n<!--  Current User -->\r\n<input type="button" class="butn" name="User" value="Current User" onclick="var hist=''current_user''; printKey(hist);">\r\n<br>\r\n\r\n<!-- Attending Doctor -->\r\n<input type="button" class="butn" name="Doctor" value="Doctor (MRP)" onclick="var hist=''doctor''; printKey(hist);">\r\n<br>\r\n<br>\r\n\r\n</div>\r\n\r\n\r\n<div class="DoNotPrint" >\r\n<input onclick="viewsource(this.checked)" type="checkbox">\r\nHTML Source\r\n<input onclick="usecss(this.checked)" type="checkbox">\r\nUse CSS	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Subject: <input name="subject" id="subject" size="40" type="text">		 \r\n\r\n<table><tr id=sig>\r\n<td> <div id="signatureInput">&nbsp;</div></td>\r\n<td> <div id="faxControl">&nbsp;</div></td>\r\n</tr></table>\r\n \r\n \r\n<input value="Submit" name="SubmitButton" type="submit" onclick="saveRTL();  document.RichTextLetter.submit()">\r\n<input value="Print" name="PrintSaveButton" type="button" onclick="document.getElementById(''edit'').contentWindow.print();saveRTL();  setTimeout(''document.RichTextLetter.submit()'',1000);">\r\n<input value="Reset" name="ResetButton" type="reset">\r\n<input value="Print" name="PrintButton" type="button" onclick="document.getElementById(''edit'').contentWindow.print();">\r\n\r\n\r\n    	</div>\r\n\r\n</form>\r\n\r\n</body></html>'
WHERE `form_name` IN ('letter', 'Rich Text Letter')
AND `form_date`IN ('2010-05-02','2012-06-01','2014-02-01') ;

-- from update-2014-02-12.sql --
ALTER TABLE `secRole` ADD UNIQUE INDEX `secRoleTemp`(`role_name`, `description`);
INSERT INTO `secRole` (`role_name`, `description`) VALUES('midwife', 'midwife') ON DUPLICATE KEY UPDATE `role_name`='midwife';
ALTER TABLE `secRole` DROP INDEX `secRoleTemp`;


-- from update-2016-02-23.sql --
ALTER TABLE `appointmentArchive` MODIFY notes varchar( 255 );


-- from update-2016-02-16.sql --
insert into `secObjectName` (`objectName`) values ('_phr') ON DUPLICATE KEY UPDATE objectName='_phr' ;

DELIMITER $$

DROP PROCEDURE IF EXISTS DropIndex $$
CREATE PROCEDURE DropIndex(
    given_database VARCHAR(64),
    given_table    VARCHAR(64),
    given_index    VARCHAR(64)
)
theStart:BEGIN

    DECLARE TableIsThere INTEGER;
    DECLARE IndexIsThere INTEGER;

    SELECT COUNT(1) INTO TableIsThere
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE table_schema = given_database
    AND   table_name   = given_table;

    IF TableIsThere = 0 THEN
        SELECT CONCAT(given_database,'.',given_table, 
	' does not exist.  Unable to drop ', given_index) DropIndexMessage;
	LEAVE theStart;
        ELSE

	    SELECT COUNT(1) INTO IndexIsThere
	    FROM INFORMATION_SCHEMA.STATISTICS
	    WHERE table_schema = given_database
	    AND   table_name   = given_table
	    AND   index_name   = given_index;

	    IF IndexIsThere <> 0 THEN
		SET @sqlstmt = CONCAT('DROP INDEX ',given_index,' ON ',
		given_database,'.',given_table);
		PREPARE st FROM @sqlstmt;
		EXECUTE st;
		DEALLOCATE PREPARE st;
	    ELSE
		SELECT CONCAT('Index ',given_index,' Does not exist ON Table ',
		given_database,'.',given_table) DropIndexMessage;
	    END IF;

	END IF;

END $$

DELIMITER ;

CALL DropIndex('oscar_15','secObjPrivilege','role_objectNameTemp');

ALTER TABLE `secObjPrivilege` ADD UNIQUE INDEX `role_objectNameTemp`(`roleUserGroup`,`objectName`);
insert into `secObjPrivilege` values('doctor','_phr','x',0,'999998')ON DUPLICATE KEY UPDATE objectName='_phr' ;
insert into `secObjPrivilege` values('nurse','_phr','x',0,'999998')ON DUPLICATE KEY UPDATE objectName='_phr' ;
-- from update-2016-07-12.sql part revoked 
-- insert into `secObjPrivilege` values('admin', '_dashboardManager', 'x', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_dashboardManager' ;
-- insert into `secObjPrivilege` values('admin', '_dashboardDisplay', 'x', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_dashboardDisplay' ;
-- insert into `secObjPrivilege` values('admin', '_dashboardDrilldown', 'x', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_dashboardDrilldown' ;


CALL DropIndex('oscar_15','secObjPrivilege','role_objectNameTemp');


-- from update 2016-06-06.sql

CREATE TABLE IF NOT EXISTS `oscar_msg_type` (
    `type` int(10),
    `description` varchar(255),
    PRIMARY KEY(`type`)
);

-- phc hacks again
-- missed tables somehow

DELIMITER $$

DROP PROCEDURE IF EXISTS patch_database $$
CREATE PROCEDURE patch_database()
BEGIN

-- rename a table safely
-- IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
--        AND TABLE_NAME='my_old_table_name') ) THEN
--    RENAME TABLE 
--        my_old_table_name TO my_new_table_name,
-- END IF;

-- add a column safely
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='description' AND TABLE_NAME='HRMDocument') ) THEN
    ALTER TABLE `HRMDocument` ADD `description` varchar(255);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='vacancyName' AND TABLE_NAME='vacancy') ) THEN
    ALTER TABLE `vacancy` ADD `vacancyName` VARCHAR( 255 ) NOT NULL AFTER `id` ;
END IF;
-- from update 2016-02-19.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='lastUpdateDate' AND TABLE_NAME='consultationRequests') ) THEN
    ALTER TABLE `consultationRequests` ADD `lastUpdateDate` datetime not null;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='eformId' AND TABLE_NAME='professionalSpecialists') ) THEN
    ALTER TABLE `professionalSpecialists` add `eformId` INT(10);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='fdid' AND TABLE_NAME='consultationRequests') ) THEN
    ALTER TABLE `consultationRequests` ADD `fdid` INT(10);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='source' AND TABLE_NAME='consultationRequests') ) THEN
    ALTER TABLE `consultationRequests` ADD `source` VARCHAR(50);
END IF;
-- from update 2016-06-06.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='type' AND TABLE_NAME='messagetbl') ) THEN
    ALTER TABLE `messagetbl` ADD `type` INT(10);
    UPDATE `messagetbl` SET `type` = 2 WHERE `type` IS NULL;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='type_link' AND TABLE_NAME='messagetbl') ) THEN
    ALTER TABLE `messagetbl` ADD `type_link` VARCHAR(2048);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='id' AND TABLE_NAME='msgDemoMap') ) THEN
    ALTER TABLE `msgDemoMap` DROP primary key;
    ALTER TABLE `msgDemoMap` ADD `id` INT(11) auto_increment primary key;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='supervisor' AND TABLE_NAME='provider') ) THEN
    ALTER TABLE `provider` ADD `supervisor` VARCHAR(6);
END IF;
IF NOT EXISTS( (SELECT * FROM `oscar_msg_type` WHERE 
        `type` = '1') ) THEN
    INSERT INTO `oscar_msg_type` VALUES (1,'OSCAR Resident Review');
END IF;
IF NOT EXISTS( (SELECT * FROM `oscar_msg_type` WHERE 
        `type` = '2') ) THEN
    INSERT INTO `oscar_msg_type` VALUES (2,'General');
END IF;
IF NOT EXISTS( (SELECT * FROM `OscarJobType` WHERE 
        `name` = 'OSCAR MSG REVIEW') ) THEN
    INSERT INTO `OscarJobType` VALUES (null,'OSCAR MSG REVIEW','Sends OSCAR Messages to Residents Supervisors when charts need to be reviewed','org.oscarehr.jobs.OscarMsgReviewSender',0,now());
END IF;
IF NOT EXISTS( (SELECT * FROM `OscarJob` WHERE 
        `name` = 'OSCAR Message Review') ) THEN
    INSERT INTO `OscarJob` VALUES (null,'OSCAR Message Review','',(SELECT id FROM OscarJobType WHERE name = 'OSCAR MSG REVIEW') ,'0 0/30 * * * *','999998',0,now());
END IF;

-- from update 2015-12-07.sql (sic)
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='appointmentInstructions' AND TABLE_NAME='consultationRequests') ) THEN
    ALTER TABLE `consultationRequests` ADD `appointmentInstructions` varchar(256) AFTER `urgency`;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='listTitle' AND TABLE_NAME='LookupList') ) THEN
    ALTER TABLE `LookupList` ADD `listTitle`  varchar(50) AFTER `name` ;
END IF;
IF NOT EXISTS( (SELECT * FROM `LookupList` WHERE 
        `name` = 'consultApptInst') ) THEN
    INSERT INTO `LookupList` ( `listTitle` , `name` , `description`, `categoryId`, `active`, `createdBy`, `dateCreated` )
VALUES ('Consultation Request Appointment Instructions List', 'consultApptInst', 'Select list for the consultation appointment instruction select list', NULL , '1', 'oscar', NOW( ));
END IF;
IF NOT EXISTS( (SELECT * FROM `LookupListItem` WHERE 
        `label` = 'Please reply to sending facility by fax or phone with appointment') ) THEN
    INSERT INTO `LookupListItem` ( lookupListId, value, label, displayOrder, active, createdBy, dateCreated ) (
SELECT id, UUID( ) , 'Please reply to sending facility by fax or phone with appointment', '1', '1', 'oscar', NOW( )
FROM `LookupList`
WHERE `name` = "consultApptInst");
END IF;

-- from update-2017-01-31.sql
IF NOT EXISTS( (SELECT * FROM `OscarJobType` WHERE 
        `name` = 'OSCAR ON CALL CLINIC') ) THEN
    INSERT INTO `OscarJobType` VALUES (null,'OSCAR ON CALL CLINIC', 'Notifies MRP if patient seen during on-call clinic','org.oscarehr.jobs.OscarOnCallClinic',false,now());
END IF;
IF NOT EXISTS( (SELECT * FROM `OscarJob` WHERE 
        `name` = 'OSCAR On-Call Clinic') ) THEN
    INSERT INTO `OscarJob` VALUES (null,'OSCAR On-Call Clinic','',(SELECT id FROM OscarJobType WHERE name = 'OSCAR ON CALL CLINIC'),'0 0 4 * * *','999998',false,now());
END IF;
IF NOT EXISTS( (SELECT * FROM `scheduletemplate` WHERE 
        `name` = 'P:OnCallClinic') ) THEN
    INSERT INTO `scheduletemplate` VALUES('Public','P:OnCallClinic','Weekends/Holidays','________________________________________CCCCCCCCCCCCCCCC________________________________________');
END IF;
IF NOT EXISTS( (SELECT * FROM `scheduletemplatecode` WHERE 
        `description` = 'On Call Clinic') ) THEN
    INSERT INTO `scheduletemplatecode` (id,code,description,duration,color,confirm,bookinglimit) VALUES(null,'C','On Call Clinic','15','green','Onc',1);
END IF;




-- from update 2016-06-12.sql
IF NOT EXISTS( (SELECT * FROM `icd9` WHERE 
        icd9.icd9 = '780.93') ) THEN
    INSERT INTO icd9 (`icd9`, `description`) VALUES ('780.93','MEMORY LOSS');
END IF;
-- from update 2016-07-11.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='passwordUpdateDate' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `passwordUpdateDate` DATETIME;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='pinUpdateDate' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `pinUpdateDate` DATETIME;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='lastUpdateUser' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `lastUpdateUser` VARCHAR(20);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='lastUpdateDate' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `lastUpdateDate` TIMESTAMP;
END IF;
-- from update 2016-08-30.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='category_id' AND TABLE_NAME='tickler') ) THEN
    ALTER TABLE `tickler` ADD `category_id` int(11);
END IF;
-- from update 2016-12-02.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='shared' AND TABLE_NAME='indicatorTemplate') ) THEN
    ALTER TABLE `indicatorTemplate` ADD `shared` tinyint(1);
END IF;
-- from update 2017-03-09.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='short_term' AND TABLE_NAME='drugs') ) THEN
    ALTER TABLE `drugs` ADD `short_term` boolean after `long_term`;
END IF;


END $$

CALL patch_database() $$

DELIMITER ;



CREATE TABLE IF NOT EXISTS `ichppccode` (
  `ichppccode` varchar(10) NOT NULL,
  `diagnostic_code` varchar(10) default NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY (`ichppccode`)
) ;

-- from update 2016-07-11.sql
alter table security modify password varchar(255);
alter table security modify pin varchar(255);

CREATE TABLE IF NOT EXISTS `SecurityArchive` (
 `id` int(11) NOT NULL auto_increment,
  security_no int(6) NOT NULL,
  user_name varchar(30) NOT NULL,
  password varchar(255) NOT NULL,
  provider_no varchar(6) default NULL,
  pin varchar(255),
  b_ExpireSet int(1),
  date_ExpireDate date,
  b_LocalLockSet int(1),
  b_RemoteLockSet int(1),
  forcePasswordReset tinyint(1),
  passwordUpdateDate datetime,
  pinUpdateDate datetime,
  lastUpdateUser varchar(20),
  lastUpdateDate timestamp,
 PRIMARY KEY  (`id`)
);

-- DESTRUCTIVE optionally run the following to clean out incomplete and duplicate pharmacies in the schema
-- DELETE FROM pharmacyInfo WHERE pharmacyInfo.fax = '';
-- DELETE pharmacyInfo FROM pharmacyInfo INNER JOIN (SELECT max( recordID ) AS lastId, name FROM pharmacyInfo GROUP BY ID HAVING count( * ) >1)duplic ON duplic.ID = pharmacyInfo.ID WHERE pharmacyInfo.recordID < duplic.lastId;

-- from update 2016-06-06.sql
CALL CreateIndex('oscar_15', 'msgDemoMap','', 'demoMap_messageID_demographic_no', 'messageID, demographic_no');


CALL CreateIndex('oscar_15', 'billing_on_cheader1', '', 'dem_stat_date_Index', 'demographic_no, status,billing_date');
CALL CreateIndex('oscar_15', 'casemgmt_tmpsave', '', 'provider_demoIndex', 'provider_no(4),demographic_no');
CALL CreateIndex('oscar_15', 'casemgmt_note_link', '', 'note_idIndex', 'note_id');
CALL CreateIndex('oscar_15', 'casemgmt_note_ext', '', 'note_idIndex', 'note_id');
CALL CreateIndex('oscar_15', 'consultationRequests', '', 'demographicNoIndex', 'demographicNo');
CALL CreateIndex('oscar_15', 'demographic', '','demo_last_first_hin_sex_Index', 'demographic_no, last_name, first_name, hin, sex');
CALL CreateIndex('oscar_15', 'drugs','', 'special_instructionIndex', 'special_instruction(5)');
CALL CreateIndex('oscar_15', 'drugs', '','demo_script_pos_rxdate_Index', 'demographic_no, script_no, position, rx_date, drugid');
CALL CreateIndex('oscar_15', 'dxresearch', '','demographic_noIndex', 'demographic_no');
CALL CreateIndex('oscar_15', 'eChart','', 'demographicNoIdIndex', 'demographicNo,eChartId');
CALL CreateIndex('oscar_15', 'eform_data', '','patient_independentIndex', 'patient_independent');
CALL CreateIndex('oscar_15', 'eform_data','', 'dem_inde_stat_date_time_Index', 'demographic_no,patient_independent,status,form_date,form_time');
CALL CreateIndex('oscar_15', 'eform_values','', 'fdidIndex', 'fdid');
CALL CreateIndex('oscar_15', 'facility_message', '','facility_idIndex', 'facility_id');
CALL CreateIndex('oscar_15', 'formLabReq10','', 'demographic_noIndex', 'demographic_no');
CALL CreateIndex('oscar_15', 'formONAREnhanced','', 'demographic_noIndex', 'demographic_no');
CALL CreateIndex('oscar_15', 'formONAREnhancedRecord','', 'demographic_noIndex', 'demographic_no');
CALL CreateIndex('oscar_15', 'formONAREnhancedRecordExt1','', 'idIndex', 'ID');
CALL CreateIndex('oscar_15', 'formONAREnhancedRecordExt2','', 'idIndex', 'ID');
CALL CreateIndex('oscar_15', 'formRourke2009', '','demographic_noIndex', 'demographic_no');
CALL CreateIndex('oscar_15', 'icd9','','icd9Index','icd9');
CALL CreateIndex('oscar_15', 'messagetbl','','id_by_subject_Index','messageid,sentby,thesubject');
CALL CreateIndex('oscar_15', 'property', '','provider_noIndex', 'provider_no');
CALL CreateIndex('oscar_15', 'property','', 'nameIndex', 'name(20)');
CALL CreateIndex('oscar_15', 'secObjPrivilege','', 'objectNameIndex', 'objectName');
CALL CreateIndex('oscar_15', 'tickler','', 'statusIndex', 'status');
CALL CreateIndex('oscar_15', 'queue_document_link','', 'id_que_doc_status_Index','id, queue_id, document_id, status');
CALL CreateIndex('oscar_15', 'tickler','', 'demo_status_dateIndex', 'demographic_no,status,service_date');

--  April 25th, 2016 
CALL CreateIndex('oscar_15', 'log','', 'provider_noIndex', 'provider_no');
CALL CreateIndex('oscar_15', 'fileUploadCheck', '','md5Index', 'md5sum(10)');
CALL CreateIndex('oscar_15', 'radetail','', 'providerohip_noIndex', 'providerohip_no');
CALL CreateIndex('oscar_15', 'raheader','', 'datesIndex', 'paymentdate,readdate');
CALL CreateIndex('oscar_15', 'drugs','', 'regionalIndex', 'regional_identifier(20)');
CALL CreateIndex('oscar_15', 'billactivity','', 'date_status_Index', 'updatedatetime,status');
CALL CreateIndex('oscar_15', 'document','', 'status_type_Index', 'status,doctype');


-- end April 25

INSERT INTO ichppccode VALUES ('000','831','Dislocated Shoulder') ON DUPLICATE KEY UPDATE description='Dislocated Shoulder' ;
INSERT INTO ichppccode VALUES ('204','669','Complicated Delivery') ON DUPLICATE KEY UPDATE description='Complicated Delivery';
INSERT INTO ichppccode VALUES ('288','781','Pain Or Stiffness In Joint') ON DUPLICATE KEY UPDATE description='Pain Or Stiffness In Joint';
INSERT INTO ichppccode VALUES ('053','269','Feeding Problem Baby Or Elderly') ON DUPLICATE KEY UPDATE description='Feeding Problem Baby Or Elderly';
INSERT INTO ichppccode VALUES ('235','739','Cervical Spine Syndromes') ON DUPLICATE KEY UPDATE description='Cervical Spine Syndromes';
INSERT INTO ichppccode VALUES ('376','629','Non-Specific Abnormal Pap Smear') ON DUPLICATE KEY UPDATE description='Non-Specific Abnormal Pap Smear';
INSERT INTO ichppccode VALUES ('246','739','Other Musculoskel, Connectiv Diseas (DDD)') ON DUPLICATE KEY UPDATE description='Other Musculoskel, Connectiv Diseas (DDD)';
INSERT INTO ichppccode VALUES ('105','389','Deafness, Partial or Complete/ Hearing problem') ON DUPLICATE KEY UPDATE description='Deafness, Partial or Complete/ Hearing problem';
INSERT INTO ichppccode VALUES ('231','715','Arthritis NEC/Diff Conn Tiss Dis,polymyalgia rheumatica, PMR') ON DUPLICATE KEY UPDATE description='Arthritis NEC/Diff Conn Tiss Dis,polymyalgia rheumatica, PMR';
INSERT INTO ichppccode VALUES ('026','112','Moniliasis, Urogenital, Proven') ON DUPLICATE KEY UPDATE description='Moniliasis, Urogenital, Proven';
INSERT INTO ichppccode VALUES ('363.2','909','Elder abuse') ON DUPLICATE KEY UPDATE description='Elder abuse';
INSERT INTO ichppccode VALUES ('006','033','Whooping Cough') ON DUPLICATE KEY UPDATE description='Whooping Cough';
INSERT INTO ichppccode VALUES ('109','410','Acute MI') ON DUPLICATE KEY UPDATE description='Acute MI';
INSERT INTO ichppccode VALUES ('251','743','Blocked Tear Duct') ON DUPLICATE KEY UPDATE description='Blocked Tear Duct';
INSERT INTO ichppccode VALUES ('303','807','Fractured Ribs') ON DUPLICATE KEY UPDATE description='Fractured Ribs';
INSERT INTO ichppccode VALUES ('330','930','Foreign Body In Eye') ON DUPLICATE KEY UPDATE description='Foreign Body In Eye';
INSERT INTO ichppccode VALUES ('293','799','Weight Loss') ON DUPLICATE KEY UPDATE description='Weight Loss';
INSERT INTO ichppccode VALUES ('329','930','Foreign Body In Tissues') ON DUPLICATE KEY UPDATE description='Foreign Body In Tissues';
INSERT INTO ichppccode VALUES ('277','289','Hepatomegaly/Splenomegaly') ON DUPLICATE KEY UPDATE description='Hepatomegaly/Splenomegaly';
INSERT INTO ichppccode VALUES ('099','379','Other Eye Diseases, Vision Problem') ON DUPLICATE KEY UPDATE description='Other Eye Diseases, Vision Problem';
INSERT INTO ichppccode VALUES ('147','519','Other Respiratory, Atelectasis') ON DUPLICATE KEY UPDATE description='Other Respiratory, Atelectasis';
INSERT INTO ichppccode VALUES ('083.3','304','Prescription drug dependence') ON DUPLICATE KEY UPDATE description='Prescription drug dependence';
INSERT INTO ichppccode VALUES ('194','629','Other disorders of female genital organs') ON DUPLICATE KEY UPDATE description='Other disorders of female genital organs';
INSERT INTO ichppccode VALUES ('110','413','Acute coronary insufficiency, Angina Pectoris(CAD, Ischemic Heart)/IHD') ON DUPLICATE KEY UPDATE description='Acute coronary insufficiency, Angina Pectoris(CAD, Ischemic Heart)/IHD';
INSERT INTO ichppccode VALUES ('202.2','644','Preterm Labour') ON DUPLICATE KEY UPDATE description='Preterm Labour';
INSERT INTO ichppccode VALUES ('334','977','Overdose, Poisoning, Accidental Ingestion') ON DUPLICATE KEY UPDATE description='Overdose, Poisoning, Accidental Ingestion';
INSERT INTO ichppccode VALUES ('016','072','Mumps') ON DUPLICATE KEY UPDATE description='Mumps';
INSERT INTO ichppccode VALUES ('142','491','Chronic Bronchitis') ON DUPLICATE KEY UPDATE description='Chronic Bronchitis';
INSERT INTO ichppccode VALUES ('157','553','Other Hernias') ON DUPLICATE KEY UPDATE description='Other Hernias';
INSERT INTO ichppccode VALUES ('184','752','Cervical Hyperplasia') ON DUPLICATE KEY UPDATE description='Cervical Hyperplasia';
INSERT INTO ichppccode VALUES ('115','427','Ectopic Beats, All Types') ON DUPLICATE KEY UPDATE description='Ectopic Beats, All Types';
INSERT INTO ichppccode VALUES ('149.1','529','Thrush') ON DUPLICATE KEY UPDATE description='Thrush';
INSERT INTO ichppccode VALUES ('043','218','Fibroids, Benign Neoplasm Uterus') ON DUPLICATE KEY UPDATE description='Fibroids, Benign Neoplasm Uterus';
INSERT INTO ichppccode VALUES ('001','002','Typhoid & Paratyphoid Fevers') ON DUPLICATE KEY UPDATE description='Typhoid & Paratyphoid Fevers';
INSERT INTO ichppccode VALUES ('340','896','Prophylactic Immunization') ON DUPLICATE KEY UPDATE description='Prophylactic Immunization';
INSERT INTO ichppccode VALUES ('335','989','Adverse Effects Of Other Chemicals') ON DUPLICATE KEY UPDATE description='Adverse Effects Of Other Chemicals';
INSERT INTO ichppccode VALUES ('146','680','Boil In Nose') ON DUPLICATE KEY UPDATE description='Boil In Nose';
INSERT INTO ichppccode VALUES ('339','136','Contact/Carrier, Infec/Parasit Disease') ON DUPLICATE KEY UPDATE description='Contact/Carrier, Infec/Parasit Disease';
INSERT INTO ichppccode VALUES ('058','280','Iron Deficiency Anemia') ON DUPLICATE KEY UPDATE description='Iron Deficiency Anemia';
INSERT INTO ichppccode VALUES ('111','429','Disease Heart Valve Non-Rheum,NOS,NYD') ON DUPLICATE KEY UPDATE description='Disease Heart Valve Non-Rheum,NOS,NYD';
INSERT INTO ichppccode VALUES ('053.1','269','Feeding Problem Baby') ON DUPLICATE KEY UPDATE description='Feeding Problem Baby';
INSERT INTO ichppccode VALUES ('012','055','Measles') ON DUPLICATE KEY UPDATE description='Measles';
INSERT INTO ichppccode VALUES ('312','718','Acute Damage Knee Meniscus') ON DUPLICATE KEY UPDATE description='Acute Damage Knee Meniscus';
INSERT INTO ichppccode VALUES ('073.2','300','Obsessive-compulsive disorder') ON DUPLICATE KEY UPDATE description='Obsessive-compulsive disorder';
INSERT INTO ichppccode VALUES ('074.1','315','Learning disorder') ON DUPLICATE KEY UPDATE description='Learning disorder';
INSERT INTO ichppccode VALUES ('363.3','909','Child abuse') ON DUPLICATE KEY UPDATE description='Child abuse';
INSERT INTO ichppccode VALUES ('348','799','Letter, Forms, Prescription WO Exam') ON DUPLICATE KEY UPDATE description='Letter, Forms, Prescription WO Exam';
INSERT INTO ichppccode VALUES ('054','274','Gout') ON DUPLICATE KEY UPDATE description='Gout';
INSERT INTO ichppccode VALUES ('249','608','Undescended Testicle') ON DUPLICATE KEY UPDATE description='Undescended Testicle';
INSERT INTO ichppccode VALUES ('070.2','300','Panic Disorder') ON DUPLICATE KEY UPDATE description='Panic Disorder';
INSERT INTO ichppccode VALUES ('273','787','(DO NOT USE) Anorexia') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Anorexia';
INSERT INTO ichppccode VALUES ('200','635','Therapeutic Abortion') ON DUPLICATE KEY UPDATE description='Therapeutic Abortion';
INSERT INTO ichppccode VALUES ('213','691','Eczema And Allergic Dermatitis') ON DUPLICATE KEY UPDATE description='Eczema And Allergic Dermatitis';
INSERT INTO ichppccode VALUES ('354','799','Advice & Health Instruction') ON DUPLICATE KEY UPDATE description='Advice & Health Instruction';
INSERT INTO ichppccode VALUES ('190','626','Excessive Menstruation') ON DUPLICATE KEY UPDATE description='Excessive Menstruation';
INSERT INTO ichppccode VALUES ('189','626','Amenorrhea, Absent, Scanty, Rare Menstruation') ON DUPLICATE KEY UPDATE description='Amenorrhea, Absent, Scanty, Rare Menstruation';
INSERT INTO ichppccode VALUES ('338.1','917','CPX/Physical, Annual Health Adult/Teen, Well Visit') ON DUPLICATE KEY UPDATE description='CPX/Physical, Annual Health Adult/Teen, Well Visit';
INSERT INTO ichppccode VALUES ('204.4','653','Cephalo-pelvic disproportion') ON DUPLICATE KEY UPDATE description='Cephalo-pelvic disproportion';
INSERT INTO ichppccode VALUES ('204.11','645','Post Dates') ON DUPLICATE KEY UPDATE description='Post Dates';
INSERT INTO ichppccode VALUES ('332.1','959','Motor Vehicle Accident, MVA') ON DUPLICATE KEY UPDATE description='Motor Vehicle Accident, MVA';
INSERT INTO ichppccode VALUES ('002','009','Diarrhea/Presumed Infect.Intest Disease') ON DUPLICATE KEY UPDATE description='Diarrhea/Presumed Infect.Intest Disease';
INSERT INTO ichppccode VALUES ('015','070','Infectious Hepatitis') ON DUPLICATE KEY UPDATE description='Infectious Hepatitis';
INSERT INTO ichppccode VALUES ('156','552','Hiatus/Diaphragmatic Hernia') ON DUPLICATE KEY UPDATE description='Hiatus/Diaphragmatic Hernia';
INSERT INTO ichppccode VALUES ('218','698','Pruritis And Related Conditions') ON DUPLICATE KEY UPDATE description='Pruritis And Related Conditions';
INSERT INTO ichppccode VALUES ('120','401','Hypertension - Uncomplicated (HTN)') ON DUPLICATE KEY UPDATE description='Hypertension - Uncomplicated (HTN)';
INSERT INTO ichppccode VALUES ('119','796','Elevated Blood Pressure (BP)') ON DUPLICATE KEY UPDATE description='Elevated Blood Pressure (BP)';
INSERT INTO ichppccode VALUES ('067','295','Schizophrenia') ON DUPLICATE KEY UPDATE description='Schizophrenia';
INSERT INTO ichppccode VALUES ('057','259','AIDS,HIV,Other Endocr,Nutritn,Metabol Disord,Jaundice,Dehydration,immunity disorders') ON DUPLICATE KEY UPDATE description='AIDS,HIV,Other Endocr,Nutritn,Metabol Disord,Jaundice,Dehydration,immunity disorders';
INSERT INTO ichppccode VALUES ('094','367','Myopia,Astigmatism,Other Refrac Disease') ON DUPLICATE KEY UPDATE description='Myopia,Astigmatism,Other Refrac Disease';
INSERT INTO ichppccode VALUES ('038','201','Hodgkins Disease,Lymphoma,Leukemia') ON DUPLICATE KEY UPDATE description='Hodgkins Disease,Lymphoma,Leukemia';
INSERT INTO ichppccode VALUES ('104','386','Labyrinthitis, Meniere&#146;s Disease') ON DUPLICATE KEY UPDATE description='Labyrinthitis, Meniere&#146;s Disease';
INSERT INTO ichppccode VALUES ('245','735','Hammer Toe') ON DUPLICATE KEY UPDATE description='Hammer Toe';
INSERT INTO ichppccode VALUES ('297','797','Senility Without Psychosis') ON DUPLICATE KEY UPDATE description='Senility Without Psychosis';
INSERT INTO ichppccode VALUES ('307','815','Fractured Metacarpals') ON DUPLICATE KEY UPDATE description='Fractured Metacarpals';
INSERT INTO ichppccode VALUES ('350','650','Diagnosing Pregnancy') ON DUPLICATE KEY UPDATE description='Diagnosing Pregnancy';
INSERT INTO ichppccode VALUES ('349','799','Referral WO Exam Or Interview') ON DUPLICATE KEY UPDATE description='Referral WO Exam Or Interview';
INSERT INTO ichppccode VALUES ('021','136','Malaria') ON DUPLICATE KEY UPDATE description='Malaria';
INSERT INTO ichppccode VALUES ('162','565','Anal Fissure/Fistula/Abscess') ON DUPLICATE KEY UPDATE description='Anal Fissure/Fistula/Abscess';
INSERT INTO ichppccode VALUES ('082.1','304','Smokestop') ON DUPLICATE KEY UPDATE description='Smokestop';
INSERT INTO ichppccode VALUES ('353.1','609','Circumcision') ON DUPLICATE KEY UPDATE description='Circumcision';
INSERT INTO ichppccode VALUES ('338','650','Well baby, Newborn care, Postnatal care, Postpartum care') ON DUPLICATE KEY UPDATE description='Well baby, Newborn care, Postnatal care, Postpartum care';
INSERT INTO ichppccode VALUES ('198','646','Urinary Infection, Pregnancy & Postpartum') ON DUPLICATE KEY UPDATE description='Urinary Infection, Pregnancy & Postpartum';
INSERT INTO ichppccode VALUES ('074.2','315','Attention deficit disorder, ADD, ADHD') ON DUPLICATE KEY UPDATE description='Attention deficit disorder, ADD, ADHD';
INSERT INTO ichppccode VALUES ('017','075','Infectious Mononucleosis') ON DUPLICATE KEY UPDATE description='Infectious Mononucleosis';
INSERT INTO ichppccode VALUES ('027','131','Trichomonas, Urogenital, Proven') ON DUPLICATE KEY UPDATE description='Trichomonas, Urogenital, Proven';
INSERT INTO ichppccode VALUES ('262','785','Chest Pain') ON DUPLICATE KEY UPDATE description='Chest Pain';
INSERT INTO ichppccode VALUES ('116','785','Heart Murmur NEC, NYD') ON DUPLICATE KEY UPDATE description='Heart Murmur NEC, NYD';
INSERT INTO ichppccode VALUES ('219','700','Corns, Calluses') ON DUPLICATE KEY UPDATE description='Corns, Calluses';
INSERT INTO ichppccode VALUES ('220','706','Sebaceous Cyst') ON DUPLICATE KEY UPDATE description='Sebaceous Cyst';
INSERT INTO ichppccode VALUES ('121','402','Hypertension - Target Organ Invl (HTN)') ON DUPLICATE KEY UPDATE description='Hypertension - Target Organ Invl (HTN)';
INSERT INTO ichppccode VALUES ('167','579','Other Digestive Sys. Dis. NEC, Dysphagia') ON DUPLICATE KEY UPDATE description='Other Digestive Sys. Dis. NEC, Dysphagia';
INSERT INTO ichppccode VALUES ('068','296','(DO NOT USE) Manic Depressive Psychosis') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Manic Depressive Psychosis';
INSERT INTO ichppccode VALUES ('163','564','Proctitis, Rectal & Anal Pain NOS') ON DUPLICATE KEY UPDATE description='Proctitis, Rectal & Anal Pain NOS';
INSERT INTO ichppccode VALUES ('252','759','Congenital Anomalies, hip diplasia') ON DUPLICATE KEY UPDATE description='Congenital Anomalies, hip diplasia';
INSERT INTO ichppccode VALUES ('064','288','Abnormal White Cell Count') ON DUPLICATE KEY UPDATE description='Abnormal White Cell Count';
INSERT INTO ichppccode VALUES ('153','536','Other Stomach & Duoden Disease/Disorder') ON DUPLICATE KEY UPDATE description='Other Stomach & Duoden Disease/Disorder';
INSERT INTO ichppccode VALUES ('317','845','Sprain/Strain Ankle, Foot, Toes') ON DUPLICATE KEY UPDATE description='Sprain/Strain Ankle, Foot, Toes';
INSERT INTO ichppccode VALUES ('215','691','Diaper Rash') ON DUPLICATE KEY UPDATE description='Diaper Rash';
INSERT INTO ichppccode VALUES ('022','097','Syphilis, All Sites And Stages') ON DUPLICATE KEY UPDATE description='Syphilis, All Sites And Stages';
INSERT INTO ichppccode VALUES ('125','440','Arteriosclerosis, Atherosclerosis') ON DUPLICATE KEY UPDATE description='Arteriosclerosis, Atherosclerosis';
INSERT INTO ichppccode VALUES ('318','845','Sprain/Strain Foot, Toes') ON DUPLICATE KEY UPDATE description='Sprain/Strain Foot, Toes';
INSERT INTO ichppccode VALUES ('266','785','Enlarged Lymph Nodes, Not Infected') ON DUPLICATE KEY UPDATE description='Enlarged Lymph Nodes, Not Infected';
INSERT INTO ichppccode VALUES ('149.2','529','Sore Throat') ON DUPLICATE KEY UPDATE description='Sore Throat';
INSERT INTO ichppccode VALUES ('369','909','(DO NOT USE) Other Problems Of Social Adjustment') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Other Problems Of Social Adjustment';
INSERT INTO ichppccode VALUES ('370','906','Legal Problem') ON DUPLICATE KEY UPDATE description='Legal Problem';
INSERT INTO ichppccode VALUES ('197.1','640','Bleeding, threatened abortion, hemorrhage in early pregnancy') ON DUPLICATE KEY UPDATE description='Bleeding, threatened abortion, hemorrhage in early pregnancy';
INSERT INTO ichppccode VALUES ('294.1','315','Developmental delay') ON DUPLICATE KEY UPDATE description='Developmental delay';
INSERT INTO ichppccode VALUES ('053.2','269','Elderly Feeding Problem') ON DUPLICATE KEY UPDATE description='Elderly Feeding Problem';
INSERT INTO ichppccode VALUES ('202.3','644','Post-term Labour') ON DUPLICATE KEY UPDATE description='Post-term Labour';
INSERT INTO ichppccode VALUES ('209','683','Lymphadenitis, Acute') ON DUPLICATE KEY UPDATE description='Lymphadenitis, Acute';
INSERT INTO ichppccode VALUES ('210','684','Impetigo') ON DUPLICATE KEY UPDATE description='Impetigo';
INSERT INTO ichppccode VALUES ('298','791','Abnormal Urine Test NEC') ON DUPLICATE KEY UPDATE description='Abnormal Urine Test NEC';
INSERT INTO ichppccode VALUES ('308','816','Fractured Phalanges - Foot/Hand') ON DUPLICATE KEY UPDATE description='Fractured Phalanges - Foot/Hand';
INSERT INTO ichppccode VALUES ('313','839','Other Dislocations') ON DUPLICATE KEY UPDATE description='Other Dislocations';
INSERT INTO ichppccode VALUES ('131','447','Postural Hypotension') ON DUPLICATE KEY UPDATE description='Postural Hypotension';
INSERT INTO ichppccode VALUES ('351','799','Prenatal Care') ON DUPLICATE KEY UPDATE description='Prenatal Care';
INSERT INTO ichppccode VALUES ('078','313','(DO NOT USE) Behaviour Disorders, Child/Adolesce, ADD, ADHD') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Behaviour Disorders, Child/Adolesce, ADD, ADHD';
INSERT INTO ichppccode VALUES ('172','597','Urethritis') ON DUPLICATE KEY UPDATE description='Urethritis';
INSERT INTO ichppccode VALUES ('068.1','296','Bi-polar/bipolar affective disorder') ON DUPLICATE KEY UPDATE description='Bi-polar/bipolar affective disorder';
INSERT INTO ichppccode VALUES ('323','879','Laceration/Open Wound/Traum Amputat/Needlestick injury') ON DUPLICATE KEY UPDATE description='Laceration/Open Wound/Traum Amputat/Needlestick injury';
INSERT INTO ichppccode VALUES ('355','799','Problems External To Patient') ON DUPLICATE KEY UPDATE description='Problems External To Patient';
INSERT INTO ichppccode VALUES ('135','463','Tonsilitis And Quinsy') ON DUPLICATE KEY UPDATE description='Tonsilitis And Quinsy';
INSERT INTO ichppccode VALUES ('032','151','Malig Neopl G.I. Tract, Colon Cancer') ON DUPLICATE KEY UPDATE description='Malig Neopl G.I. Tract, Colon Cancer';
INSERT INTO ichppccode VALUES ('086.1','301','Self esteem problem') ON DUPLICATE KEY UPDATE description='Self esteem problem';
INSERT INTO ichppccode VALUES ('074','315','(DO NOT USE) Specified Delays In Development') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Specified Delays In Development';
INSERT INTO ichppccode VALUES ('036','180','Malig Neoplasm Female Genital Tract') ON DUPLICATE KEY UPDATE description='Malig Neoplasm Female Genital Tract';
INSERT INTO ichppccode VALUES ('256','780','Vertigo & Giddiness, Dizzy') ON DUPLICATE KEY UPDATE description='Vertigo & Giddiness, Dizzy';
INSERT INTO ichppccode VALUES ('359','898','(DO NOT USE) Marital/Relationship Problem') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Marital/Relationship Problem';
INSERT INTO ichppccode VALUES ('360','899','(DO NOT USE) Parent/Child Problem, Child Abuse') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Parent/Child Problem, Child Abuse';
INSERT INTO ichppccode VALUES ('224','706','Acne, Sebaceous Cyst') ON DUPLICATE KEY UPDATE description='Acne, Sebaceous Cyst';
INSERT INTO ichppccode VALUES ('077.3','309','Adolescent adjustment') ON DUPLICATE KEY UPDATE description='Adolescent adjustment';
INSERT INTO ichppccode VALUES ('194.1','640','Bleeding, threatened abor., hemorrhage in early pregnacy') ON DUPLICATE KEY UPDATE description='Bleeding, threatened abor., hemorrhage in early pregnacy';
INSERT INTO ichppccode VALUES ('078.2','313','Discipline, Temper Tantrums, Conduct Disorder') ON DUPLICATE KEY UPDATE description='Discipline, Temper Tantrums, Conduct Disorder';
INSERT INTO ichppccode VALUES ('199','642','Pre-eclampsia, eclampsia, toxaemia, Gestational Hypertension, Toxemias of Pregnancy & Puerperium') ON DUPLICATE KEY UPDATE description='Pre-eclampsia, eclampsia, toxaemia, Gestational Hypertension, Toxemias of Pregnancy & Puerperium';
INSERT INTO ichppccode VALUES ('204.5','660','Obstructed labour') ON DUPLICATE KEY UPDATE description='Obstructed labour';
INSERT INTO ichppccode VALUES ('080.1','303','Alcohol Abuse') ON DUPLICATE KEY UPDATE description='Alcohol Abuse';
INSERT INTO ichppccode VALUES ('204.1','651','Multiple Pregnancy') ON DUPLICATE KEY UPDATE description='Multiple Pregnancy';
INSERT INTO ichppccode VALUES ('354.1','895','Sexual Health') ON DUPLICATE KEY UPDATE description='Sexual Health';
INSERT INTO ichppccode VALUES ('204.9','656','Decreased fetal movement') ON DUPLICATE KEY UPDATE description='Decreased fetal movement';
INSERT INTO ichppccode VALUES ('168','580','Glumerulonephritis, Acute & Chronic') ON DUPLICATE KEY UPDATE description='Glumerulonephritis, Acute & Chronic';
INSERT INTO ichppccode VALUES ('042','217','Benign Neoplasm Breast') ON DUPLICATE KEY UPDATE description='Benign Neoplasm Breast';
INSERT INTO ichppccode VALUES ('286','781','Leg Pain') ON DUPLICATE KEY UPDATE description='Leg Pain';
INSERT INTO ichppccode VALUES ('221','703','Ingrown Toenail/Nail Diseases/Paronychia') ON DUPLICATE KEY UPDATE description='Ingrown Toenail/Nail Diseases/Paronychia';
INSERT INTO ichppccode VALUES ('070.1','300','Post-traumatic stress disorder') ON DUPLICATE KEY UPDATE description='Post-traumatic stress disorder';
INSERT INTO ichppccode VALUES ('132','459','Other Periph. Vessel Dis, Aneurysm, CVD') ON DUPLICATE KEY UPDATE description='Other Periph. Vessel Dis, Aneurysm, CVD';
INSERT INTO ichppccode VALUES ('084','301','Personality Disorders') ON DUPLICATE KEY UPDATE description='Personality Disorders';
INSERT INTO ichppccode VALUES ('069','298','(DO NOT USE) Psychosis, Other/NOS Excl Alcoholic') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Psychosis, Other/NOS Excl Alcoholic';
INSERT INTO ichppccode VALUES ('070','300','Anxiety') ON DUPLICATE KEY UPDATE description='Anxiety';
INSERT INTO ichppccode VALUES ('079','302','Sexual Dysfunction') ON DUPLICATE KEY UPDATE description='Sexual Dysfunction';
INSERT INTO ichppccode VALUES ('080','303','Alcoholism & Alcohol Problem') ON DUPLICATE KEY UPDATE description='Alcoholism & Alcohol Problem';
INSERT INTO ichppccode VALUES ('234','781','Muscle Pain/Myalgia/Fibromyalgia') ON DUPLICATE KEY UPDATE description='Muscle Pain/Myalgia/Fibromyalgia';
INSERT INTO ichppccode VALUES ('375','790','Hematological Abnormality NEC') ON DUPLICATE KEY UPDATE description='Hematological Abnormality NEC';
INSERT INTO ichppccode VALUES ('361','900','(DO NOT USE) Aged Parent Or In-Law Problem') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Aged Parent Or In-Law Problem';
INSERT INTO ichppccode VALUES ('136','474','Chronic Infection Tonsils/Adenoids') ON DUPLICATE KEY UPDATE description='Chronic Infection Tonsils/Adenoids';
INSERT INTO ichppccode VALUES ('187','627','Menopausal Symptoms/Menopause,post menopausal bleeding') ON DUPLICATE KEY UPDATE description='Menopausal Symptoms/Menopause,post menopausal bleeding';
INSERT INTO ichppccode VALUES ('033','162','Malignant Neopl Respiratory Tract, lung cancer') ON DUPLICATE KEY UPDATE description='Malignant Neopl Respiratory Tract, lung cancer';
INSERT INTO ichppccode VALUES ('319','847','Sprain/Strain Neck, Low Back,Coccyx') ON DUPLICATE KEY UPDATE description='Sprain/Strain Neck, Low Back,Coccyx';
INSERT INTO ichppccode VALUES ('037','188','Malig Neop Urinary & Male Genital') ON DUPLICATE KEY UPDATE description='Malig Neop Urinary & Male Genital';
INSERT INTO ichppccode VALUES ('178','604','Orchitis & Epididymitis') ON DUPLICATE KEY UPDATE description='Orchitis & Epididymitis';
INSERT INTO ichppccode VALUES ('320','847','Sprain/Strain Vertebral Excl Neck') ON DUPLICATE KEY UPDATE description='Sprain/Strain Vertebral Excl Neck';
INSERT INTO ichppccode VALUES ('037.1','185','Prostate cancer') ON DUPLICATE KEY UPDATE description='Prostate cancer';
INSERT INTO ichppccode VALUES ('075','307','Sleep Disorders, Insomnia') ON DUPLICATE KEY UPDATE description='Sleep Disorders, Insomnia';
INSERT INTO ichppccode VALUES ('333','959','Other Injuries & Trauma, Fall, Soft Tissue Injury') ON DUPLICATE KEY UPDATE description='Other Injuries & Trauma, Fall, Soft Tissue Injury';
INSERT INTO ichppccode VALUES ('314','840','Sprain/Strain Shoulder And Arm') ON DUPLICATE KEY UPDATE description='Sprain/Strain Shoulder And Arm';
INSERT INTO ichppccode VALUES ('356','897','Financial Stress') ON DUPLICATE KEY UPDATE description='Financial Stress';
INSERT INTO ichppccode VALUES ('183','615','PID, Pelvic Inflammatory Disease, Acute Or Chronic Endometritis (PID)') ON DUPLICATE KEY UPDATE description='PID, Pelvic Inflammatory Disease, Acute Or Chronic Endometritis (PID)';
INSERT INTO ichppccode VALUES ('204.6','662','Prolonged labour') ON DUPLICATE KEY UPDATE description='Prolonged labour';
INSERT INTO ichppccode VALUES ('078.3','313','Behaviour Problem, Conduct Disorder') ON DUPLICATE KEY UPDATE description='Behaviour Problem, Conduct Disorder';
INSERT INTO ichppccode VALUES ('052','269','Avitamin & Nutritional Disorder NEC') ON DUPLICATE KEY UPDATE description='Avitamin & Nutritional Disorder NEC';
INSERT INTO ichppccode VALUES ('365','903','Illegitimacy') ON DUPLICATE KEY UPDATE description='Illegitimacy';
INSERT INTO ichppccode VALUES ('141','511','Pleurisy All Types Excl Tuberculosis') ON DUPLICATE KEY UPDATE description='Pleurisy All Types Excl Tuberculosis';
INSERT INTO ichppccode VALUES ('173','593','Orthostatic Albuminuria') ON DUPLICATE KEY UPDATE description='Orthostatic Albuminuria';
INSERT INTO ichppccode VALUES ('366','904','(DO NOT USE) Social Maladjustment') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Social Maladjustment';
INSERT INTO ichppccode VALUES ('276','787','Hematemesis/Melena') ON DUPLICATE KEY UPDATE description='Hematemesis/Melena';
INSERT INTO ichppccode VALUES ('225','707','Chronic Skin Ulcer') ON DUPLICATE KEY UPDATE description='Chronic Skin Ulcer';
INSERT INTO ichppccode VALUES ('240','737','Scoliosis, Kyphosis, Lordosis') ON DUPLICATE KEY UPDATE description='Scoliosis, Kyphosis, Lordosis';
INSERT INTO ichppccode VALUES ('369.1','909','Other social problem') ON DUPLICATE KEY UPDATE description='Other social problem';
INSERT INTO ichppccode VALUES ('239','724','Lumbar Strain, Sciatica, back pain with radiation') ON DUPLICATE KEY UPDATE description='Lumbar Strain, Sciatica, back pain with radiation';
INSERT INTO ichppccode VALUES ('088','332','Parkinsonism') ON DUPLICATE KEY UPDATE description='Parkinsonism';
INSERT INTO ichppccode VALUES ('177','603','Hydrocele') ON DUPLICATE KEY UPDATE description='Hydrocele';
INSERT INTO ichppccode VALUES ('229','715','Osteoarthritis & Allied Conditions') ON DUPLICATE KEY UPDATE description='Osteoarthritis & Allied Conditions';
INSERT INTO ichppccode VALUES ('230','716','Traumatic Arthritis') ON DUPLICATE KEY UPDATE description='Traumatic Arthritis';
INSERT INTO ichppccode VALUES ('267','786','Epistaxis') ON DUPLICATE KEY UPDATE description='Epistaxis';
INSERT INTO ichppccode VALUES ('371','909','Problems NEC In Codes 008- To V629') ON DUPLICATE KEY UPDATE description='Problems NEC In Codes 008- To V629';
INSERT INTO ichppccode VALUES ('126','447','Other Disorders Of Arteries/claudication') ON DUPLICATE KEY UPDATE description='Other Disorders Of Arteries/claudication';
INSERT INTO ichppccode VALUES ('005','511','Pleural Effusion NOS') ON DUPLICATE KEY UPDATE description='Pleural Effusion NOS';
INSERT INTO ichppccode VALUES ('328','949','Burns & Scalds - All Degrees') ON DUPLICATE KEY UPDATE description='Burns & Scalds - All Degrees';
INSERT INTO ichppccode VALUES ('999','','Other') ON DUPLICATE KEY UPDATE description='Other';
INSERT INTO ichppccode VALUES ('197.2','640','Antepartum bleeding') ON DUPLICATE KEY UPDATE description='Antepartum bleeding';
INSERT INTO ichppccode VALUES ('041','216','Mole, Pigmented Nevus') ON DUPLICATE KEY UPDATE description='Mole, Pigmented Nevus';
INSERT INTO ichppccode VALUES ('083','304','Drug Addiction, Dependence') ON DUPLICATE KEY UPDATE description='Drug Addiction, Dependence';
INSERT INTO ichppccode VALUES ('130','455','Hemorrhoids') ON DUPLICATE KEY UPDATE description='Hemorrhoids';
INSERT INTO ichppccode VALUES ('134','461','Sinusitis, Acute & Chronic') ON DUPLICATE KEY UPDATE description='Sinusitis, Acute & Chronic';
INSERT INTO ichppccode VALUES ('217','696','Psoriasis') ON DUPLICATE KEY UPDATE description='Psoriasis';
INSERT INTO ichppccode VALUES ('374','625','Non-Psych Vaginismus & Dyspareunia') ON DUPLICATE KEY UPDATE description='Non-Psych Vaginismus & Dyspareunia';
INSERT INTO ichppccode VALUES ('275','787','Heartburn/dyspepsia') ON DUPLICATE KEY UPDATE description='Heartburn/dyspepsia';
INSERT INTO ichppccode VALUES ('082','304','Tobacco Abuse/Smoking Cessation') ON DUPLICATE KEY UPDATE description='Tobacco Abuse/Smoking Cessation';
INSERT INTO ichppccode VALUES ('182','611','Other Breast Diseases(gynecomastia)') ON DUPLICATE KEY UPDATE description='Other Breast Diseases(gynecomastia)';
INSERT INTO ichppccode VALUES ('363','909','(DO NOT USE) Other Family Problems') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Other Family Problems';
INSERT INTO ichppccode VALUES ('066','290','Dementia/organic psychosis') ON DUPLICATE KEY UPDATE description='Dementia/organic psychosis';
INSERT INTO ichppccode VALUES ('364','902','Education Problem') ON DUPLICATE KEY UPDATE description='Education Problem';
INSERT INTO ichppccode VALUES ('259','300','Disturbance Of Sensation/Numbness') ON DUPLICATE KEY UPDATE description='Disturbance Of Sensation/Numbness';
INSERT INTO ichppccode VALUES ('233','727','Other Bursitis & Synovitis, Tendonitis') ON DUPLICATE KEY UPDATE description='Other Bursitis & Synovitis, Tendonitis';
INSERT INTO ichppccode VALUES ('129','454','Varicose Veins - Legs, venous stasis') ON DUPLICATE KEY UPDATE description='Varicose Veins - Legs, venous stasis';
INSERT INTO ichppccode VALUES ('176','601','Prostatitis & Seminal Vesiculitis') ON DUPLICATE KEY UPDATE description='Prostatitis & Seminal Vesiculitis';
INSERT INTO ichppccode VALUES ('279','787','Abdominal Pain') ON DUPLICATE KEY UPDATE description='Abdominal Pain';
INSERT INTO ichppccode VALUES ('316','844','Sprain/Strain Knee, Leg') ON DUPLICATE KEY UPDATE description='Sprain/Strain Knee, Leg';
INSERT INTO ichppccode VALUES ('280','786','Dysuria') ON DUPLICATE KEY UPDATE description='Dysuria';
INSERT INTO ichppccode VALUES ('327','919','Bruise, Contusion, Crushing') ON DUPLICATE KEY UPDATE description='Bruise, Contusion, Crushing';
INSERT INTO ichppccode VALUES ('118','429','Other Heart Diseases NEC,cardiomyopathy') ON DUPLICATE KEY UPDATE description='Other Heart Diseases NEC,cardiomyopathy';
INSERT INTO ichppccode VALUES ('004','010','TB skin test conv.Tuberculosis infection, primary') ON DUPLICATE KEY UPDATE description='TB skin test conv.Tuberculosis infection, primary';
INSERT INTO ichppccode VALUES ('181','610','Chronic cystic breast disease, fibrocystic breast disease, cyst breast benign') ON DUPLICATE KEY UPDATE description='Chronic cystic breast disease, fibrocystic breast disease, cyst breast benign';
INSERT INTO ichppccode VALUES ('186','618','Cystocele,Rectocele,Uterine Prolapse') ON DUPLICATE KEY UPDATE description='Cystocele,Rectocele,Uterine Prolapse';
INSERT INTO ichppccode VALUES ('223','799','Pompholyx & Sweat Gland Disease NEC') ON DUPLICATE KEY UPDATE description='Pompholyx & Sweat Gland Disease NEC';
INSERT INTO ichppccode VALUES ('029','132','Lice, Head Or Body, Pediculosis') ON DUPLICATE KEY UPDATE description='Lice, Head Or Body, Pediculosis';
INSERT INTO ichppccode VALUES ('030','133','Scabies & Other Acariasis') ON DUPLICATE KEY UPDATE description='Scabies & Other Acariasis';
INSERT INTO ichppccode VALUES ('144','493','Asthma') ON DUPLICATE KEY UPDATE description='Asthma';
INSERT INTO ichppccode VALUES ('311','829','Other Fractures') ON DUPLICATE KEY UPDATE description='Other Fractures';
INSERT INTO ichppccode VALUES ('326','919','Abrasion, Scratch, Blister') ON DUPLICATE KEY UPDATE description='Abrasion, Scratch, Blister';
INSERT INTO ichppccode VALUES ('353','799','Med/Surg Procedure WO Diagnosis') ON DUPLICATE KEY UPDATE description='Med/Surg Procedure WO Diagnosis';
INSERT INTO ichppccode VALUES ('128','451','Phlebitis, Thrombophlebitis (DVT)') ON DUPLICATE KEY UPDATE description='Phlebitis, Thrombophlebitis (DVT)';
INSERT INTO ichppccode VALUES ('171','592','Urinary Calculus/ kidney stone') ON DUPLICATE KEY UPDATE description='Urinary Calculus/ kidney stone';
INSERT INTO ichppccode VALUES ('322','850','Head injury, concussion, intracranial injury') ON DUPLICATE KEY UPDATE description='Head injury, concussion, intracranial injury';
INSERT INTO ichppccode VALUES ('212','690','Seborrhoeic Dermatitis') ON DUPLICATE KEY UPDATE description='Seborrhoeic Dermatitis';
INSERT INTO ichppccode VALUES ('368','909','Phase-Of-Life Problem NEC') ON DUPLICATE KEY UPDATE description='Phase-Of-Life Problem NEC';
INSERT INTO ichppccode VALUES ('238','781','Back Pain (backache)W/O Radiation') ON DUPLICATE KEY UPDATE description='Back Pain (backache)W/O Radiation';
INSERT INTO ichppccode VALUES ('072','300','Depression') ON DUPLICATE KEY UPDATE description='Depression';
INSERT INTO ichppccode VALUES ('204.3','652','Unusual position of fetus, malpresentation') ON DUPLICATE KEY UPDATE description='Unusual position of fetus, malpresentation';
INSERT INTO ichppccode VALUES ('093','373','Stye, Chalazion') ON DUPLICATE KEY UPDATE description='Stye, Chalazion';
INSERT INTO ichppccode VALUES ('197','641','Abruptio Placenta, Placenta Praevia') ON DUPLICATE KEY UPDATE description='Abruptio Placenta, Placenta Praevia';
INSERT INTO ichppccode VALUES ('244','718','Chronic Internal Knee Derangement') ON DUPLICATE KEY UPDATE description='Chronic Internal Knee Derangement';
INSERT INTO ichppccode VALUES ('248','754','Congenital Anomalies Of Lower Limb') ON DUPLICATE KEY UPDATE description='Congenital Anomalies Of Lower Limb';
INSERT INTO ichppccode VALUES ('103','381','Eustachian Block Or Catarrh') ON DUPLICATE KEY UPDATE description='Eustachian Block Or Catarrh';
INSERT INTO ichppccode VALUES ('025','112','Moniliasis Excl Urogenital') ON DUPLICATE KEY UPDATE description='Moniliasis Excl Urogenital';
INSERT INTO ichppccode VALUES ('347','895','General Contraceptive Guidance') ON DUPLICATE KEY UPDATE description='General Contraceptive Guidance';
INSERT INTO ichppccode VALUES ('056','272','Lipid Metabolism Disorders/Hypercholesterolemia/Hyperlipidemia') ON DUPLICATE KEY UPDATE description='Lipid Metabolism Disorders/Hypercholesterolemia/Hyperlipidemia';
INSERT INTO ichppccode VALUES ('084.1','301','(DO NOT USE) Substance/alcohol abuse, not tobacco') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Substance/alcohol abuse, not tobacco';
INSERT INTO ichppccode VALUES ('207','680','Boil/Cellulitis Incl Finger/Toe/Paronychia') ON DUPLICATE KEY UPDATE description='Boil/Cellulitis Incl Finger/Toe/Paronychia';
INSERT INTO ichppccode VALUES ('145','477','Hay Fever, allergic rhinitis, allergies') ON DUPLICATE KEY UPDATE description='Hay Fever, allergic rhinitis, allergies';
INSERT INTO ichppccode VALUES ('046','239','Neoplasm Nyd As Benign Or Malignant') ON DUPLICATE KEY UPDATE description='Neoplasm Nyd As Benign Or Malignant';
INSERT INTO ichppccode VALUES ('124','436','CVA, Stroke') ON DUPLICATE KEY UPDATE description='CVA, Stroke';
INSERT INTO ichppccode VALUES ('161','564','Constipation') ON DUPLICATE KEY UPDATE description='Constipation';
INSERT INTO ichppccode VALUES ('291','780','Fever - Undetermined Cause') ON DUPLICATE KEY UPDATE description='Fever - Undetermined Cause';
INSERT INTO ichppccode VALUES ('301','802','Skull/Facial Fractures') ON DUPLICATE KEY UPDATE description='Skull/Facial Fractures';
INSERT INTO ichppccode VALUES ('343','895','Sterilization, Male/Female') ON DUPLICATE KEY UPDATE description='Sterilization, Male/Female';
INSERT INTO ichppccode VALUES ('265','785','Edema') ON DUPLICATE KEY UPDATE description='Edema';
INSERT INTO ichppccode VALUES ('149','529','Glossitis/Mouth Disease') ON DUPLICATE KEY UPDATE description='Glossitis/Mouth Disease';
INSERT INTO ichppccode VALUES ('150','530','Esophageal Disorder(GERD/esophagitis),Reflux') ON DUPLICATE KEY UPDATE description='Esophageal Disorder(GERD/esophagitis),Reflux';
INSERT INTO ichppccode VALUES ('363.5','901','Sibling Rivalry') ON DUPLICATE KEY UPDATE description='Sibling Rivalry';
INSERT INTO ichppccode VALUES ('083.2','304','Legal Drug Addiction, Dependence') ON DUPLICATE KEY UPDATE description='Legal Drug Addiction, Dependence';
INSERT INTO ichppccode VALUES ('337','994','Adverse Effects Of Physical Factors') ON DUPLICATE KEY UPDATE description='Legal Drug Addiction, Dependence';
INSERT INTO ichppccode VALUES ('014','057','Viral Xanthems') ON DUPLICATE KEY UPDATE description='Viral Xanthems';
INSERT INTO ichppccode VALUES ('155','550','Inguinal Hernia W/WO Obstruction') ON DUPLICATE KEY UPDATE description='Inguinal Hernia W/WO Obstruction';
INSERT INTO ichppccode VALUES ('073.1','300','Phobia') ON DUPLICATE KEY UPDATE description='Phobia';
INSERT INTO ichppccode VALUES ('078.1','313','Behavioural problem/conduct disorder') ON DUPLICATE KEY UPDATE description='Behavioural problem/conduct disorder';
INSERT INTO ichppccode VALUES ('363.1','909','Family Violence') ON DUPLICATE KEY UPDATE description='Family Violence';
INSERT INTO ichppccode VALUES ('607','180','(DO NOT USE) Other Male Genital Organ Diseases') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Other Male Genital Organ Diseases';
INSERT INTO ichppccode VALUES ('031','136','Sepsis/Other Infect/Parasutic Diseases NEC/STD/fungus/coxsackie') ON DUPLICATE KEY UPDATE description='Sepsis/Other Infect/Parasutic Diseases NEC/STD/fungus/coxsackie';
INSERT INTO ichppccode VALUES ('071','300','Hysterical & Hypochondriac Disorder') ON DUPLICATE KEY UPDATE description='Hysterical & Hypochondriac Disorder';
INSERT INTO ichppccode VALUES ('013','056','Rubella') ON DUPLICATE KEY UPDATE description='Rubella';
INSERT INTO ichppccode VALUES ('039','199','Other Malignant Neoplasms NEC') ON DUPLICATE KEY UPDATE description='Other Malignant Neoplasms NEC';
INSERT INTO ichppccode VALUES ('040','214','Lipoma, Any Site') ON DUPLICATE KEY UPDATE description='Lipoma, Any Site';
INSERT INTO ichppccode VALUES ('055','278','Obesity') ON DUPLICATE KEY UPDATE description='Obesity';
INSERT INTO ichppccode VALUES ('097','365','Glaucoma') ON DUPLICATE KEY UPDATE description='Glaucoma';
INSERT INTO ichppccode VALUES ('158','562','Diverticular Disease Of Intestine') ON DUPLICATE KEY UPDATE description='Diverticular Disease Of Intestine';
INSERT INTO ichppccode VALUES ('195','628','Female Infertility') ON DUPLICATE KEY UPDATE description='Female Infertility';
INSERT INTO ichppccode VALUES ('205','675','Mastitis & Lactation Disorders') ON DUPLICATE KEY UPDATE description='Mastitis & Lactation Disorders';
INSERT INTO ichppccode VALUES ('378','998','Other Adverse Effects NEC') ON DUPLICATE KEY UPDATE description='Other Adverse Effects NEC';
INSERT INTO ichppccode VALUES ('362.1','901','Couple problem') ON DUPLICATE KEY UPDATE description='Couple problem';
INSERT INTO ichppccode VALUES ('318.1','845','Heel pain, plantar fasciitis') ON DUPLICATE KEY UPDATE description='Heel pain, plantar fasciitis';
INSERT INTO ichppccode VALUES ('222','704','Alopecia,folliculitis') ON DUPLICATE KEY UPDATE description='Alopecia,folliculitis';
INSERT INTO ichppccode VALUES ('107','388','Tinnitus/Ear Pain/Otalgia') ON DUPLICATE KEY UPDATE description='Tinnitus/Ear Pain/Otalgia';
INSERT INTO ichppccode VALUES ('341','799','Observ/Care Pt On Medicat (HRT, medication rev)') ON DUPLICATE KEY UPDATE description='Observ/Care Pt On Medicat (HRT, medication rev)';
INSERT INTO ichppccode VALUES ('008','045','Polio & CNS Enteroviral Diseases') ON DUPLICATE KEY UPDATE description='Polio & CNS Enteroviral Diseases';
INSERT INTO ichppccode VALUES ('138','466','Bronchitis & Bronchiolitis, Acute') ON DUPLICATE KEY UPDATE description='Bronchitis & Bronchiolitis, Acute';
INSERT INTO ichppccode VALUES ('304','810','Fractured Clavicle') ON DUPLICATE KEY UPDATE description='Fractured Clavicle';
INSERT INTO ichppccode VALUES ('294','783','Lack Of Expected Physiolog Develop') ON DUPLICATE KEY UPDATE description='Lack Of Expected Physiolog Develop';
INSERT INTO ichppccode VALUES ('346','895','Other Contraceptive Methods(IUD)') ON DUPLICATE KEY UPDATE description='Other Contraceptive Methods(IUD)';
INSERT INTO ichppccode VALUES ('024','117','Dermatophytosis & Dermatomycosis, fungal infection/Tinea') ON DUPLICATE KEY UPDATE description='Dermatophytosis & Dermatomycosis, fungal infection/Tinea';
INSERT INTO ichppccode VALUES ('123','435','Transient Cerebral Ischemia/TIA') ON DUPLICATE KEY UPDATE description='Transient Cerebral Ischemia/TIA';
INSERT INTO ichppccode VALUES ('050.1','251','Glucose Intolerance') ON DUPLICATE KEY UPDATE description='Glucose Intolerance';
INSERT INTO ichppccode VALUES ('363.4','899','Family of Origin Issues') ON DUPLICATE KEY UPDATE description='Family of Origin Issues';
INSERT INTO ichppccode VALUES ('360.3','899','Adult Child of Alcoholic') ON DUPLICATE KEY UPDATE description='Adult Child of Alcoholic';
INSERT INTO ichppccode VALUES ('083.1','304','Illegal Drug Addiction, Dependence') ON DUPLICATE KEY UPDATE description='Illegal Drug Addiction, Dependence';
INSERT INTO ichppccode VALUES ('258','780','Headache Except Tension And Migraine') ON DUPLICATE KEY UPDATE description='Headache Except Tension And Migraine';
INSERT INTO ichppccode VALUES ('247','746','Congenital Anomaly Heart & Circulation') ON DUPLICATE KEY UPDATE description='Congenital Anomaly Heart & Circulation';
INSERT INTO ichppccode VALUES ('336','998','Surgery & Medical Care Complication') ON DUPLICATE KEY UPDATE description='Surgery & Medical Care Complication';
INSERT INTO ichppccode VALUES ('102','381','Acute & Chronic Serous Otitis Media') ON DUPLICATE KEY UPDATE description='Acute & Chronic Serous Otitis Media';
INSERT INTO ichppccode VALUES ('096','366','Cataract') ON DUPLICATE KEY UPDATE description='Cataract';
INSERT INTO ichppccode VALUES ('106','388','Wax In Ear') ON DUPLICATE KEY UPDATE description='Wax In Ear';
INSERT INTO ichppccode VALUES ('092','372','Conjunctivitis & Ophthalmia') ON DUPLICATE KEY UPDATE description='Conjunctivitis & Ophthalmia';
INSERT INTO ichppccode VALUES ('289','781','Swelling Or Effusion Of Joint') ON DUPLICATE KEY UPDATE description='Swelling Or Effusion Of Joint';
INSERT INTO ichppccode VALUES ('300','788','Sign, Symptom, Ill Defined Cond NEC') ON DUPLICATE KEY UPDATE description='Sign, Symptom, Ill Defined Cond NEC';
INSERT INTO ichppccode VALUES ('290','780','Excessive Sweating, Night Sweats') ON DUPLICATE KEY UPDATE description='Excessive Sweating, Night Sweats';
INSERT INTO ichppccode VALUES ('003','349','Other Diseases Of CNS (CP), Neuralgia') ON DUPLICATE KEY UPDATE description='Other Diseases Of CNS (CP), Neuralgia';
INSERT INTO ichppccode VALUES ('367.1','905','Unemployment/Work stress') ON DUPLICATE KEY UPDATE description='Unemployment/Work stress';
INSERT INTO ichppccode VALUES ('034','173','Malig Neo Skin/Subcutaneous Tissue') ON DUPLICATE KEY UPDATE description='Malig Neo Skin/Subcutaneous Tissue';
INSERT INTO ichppccode VALUES ('175','600','Benign Prostatic Hypertrophy/BPH') ON DUPLICATE KEY UPDATE description='Benign Prostatic Hypertrophy/BPH';
INSERT INTO ichppccode VALUES ('072.1','300','Dysthymia') ON DUPLICATE KEY UPDATE description='Dysthymia';
INSERT INTO ichppccode VALUES ('076','307','Tension Headaches') ON DUPLICATE KEY UPDATE description='Tension Headaches';
INSERT INTO ichppccode VALUES ('112','428','Congestive Heart Failure (CHF)') ON DUPLICATE KEY UPDATE description='Congestive Heart Failure (CHF)';
INSERT INTO ichppccode VALUES ('191','625','Dysmenorrhea') ON DUPLICATE KEY UPDATE description='Dysmenorrhea';
INSERT INTO ichppccode VALUES ('243','733','Osteoporosis') ON DUPLICATE KEY UPDATE description='Osteoporosis';
INSERT INTO ichppccode VALUES ('060','282','Hereditary Hemolytic Anemias') ON DUPLICATE KEY UPDATE description='Hereditary Hemolytic Anemias';
INSERT INTO ichppccode VALUES ('148','521','Dental Disorders') ON DUPLICATE KEY UPDATE description='Dental Disorders';
INSERT INTO ichppccode VALUES ('342','799','Observ/Care Other Hi Risk Patient') ON DUPLICATE KEY UPDATE description='Observ/Care Other Hi Risk Patient';
INSERT INTO ichppccode VALUES ('059','281','Pernicious & Other Deficienc Anemia (B12 deficiency)') ON DUPLICATE KEY UPDATE description='Pernicious & Other Deficienc Anemia (B12 deficiency)';
INSERT INTO ichppccode VALUES ('053.3','269','Breast Feeding Difficulties') ON DUPLICATE KEY UPDATE description='Breast Feeding Difficulties';
INSERT INTO ichppccode VALUES ('201','634','Complete/Incomplete Abortion, Miscarriage') ON DUPLICATE KEY UPDATE description='Complete/Incomplete Abortion, Miscarriage';
INSERT INTO ichppccode VALUES ('154','540','Appendicitis, All Types') ON DUPLICATE KEY UPDATE description='Appendicitis, All Types';
INSERT INTO ichppccode VALUES ('196','633','Ectopic Pregnancy') ON DUPLICATE KEY UPDATE description='Ectopic Pregnancy';
INSERT INTO ichppccode VALUES ('206','669','Other Complication Of Puerperium') ON DUPLICATE KEY UPDATE description='Other Complication Of Puerperium';
INSERT INTO ichppccode VALUES ('299','796','Other Unexplained Abnormal Results') ON DUPLICATE KEY UPDATE description='Other Unexplained Abnormal Results';
INSERT INTO ichppccode VALUES ('309','821','Fractured Femur') ON DUPLICATE KEY UPDATE description='Fractured Femur';
INSERT INTO ichppccode VALUES ('310','823','Fractured Tibia/Fibula') ON DUPLICATE KEY UPDATE description='Fractured Tibia/Fibula';
INSERT INTO ichppccode VALUES ('377','977','Allergy To Medications') ON DUPLICATE KEY UPDATE description='Allergy To Medications';
INSERT INTO ichppccode VALUES ('263','786','Palpitations') ON DUPLICATE KEY UPDATE description='Palpitations';
INSERT INTO ichppccode VALUES ('077.1','309','Grief reaction/bereavement') ON DUPLICATE KEY UPDATE description='Grief reaction/bereavement';
INSERT INTO ichppccode VALUES ('362','901','Separation/divorce') ON DUPLICATE KEY UPDATE description='Separation/divorce';
INSERT INTO ichppccode VALUES ('325','989','Insect Bites / Bee Stings') ON DUPLICATE KEY UPDATE description='Insect Bites / Bee Stings';
INSERT INTO ichppccode VALUES ('257','799','Disturbance Of Speech, hoarseness') ON DUPLICATE KEY UPDATE description='Disturbance Of Speech, hoarseness';
INSERT INTO ichppccode VALUES ('278','787','Flatulence, Bloating, Eructation') ON DUPLICATE KEY UPDATE description='Flatulence, Bloating, Eructation';
INSERT INTO ichppccode VALUES ('242','732','Osteochondritis') ON DUPLICATE KEY UPDATE description='Osteochondritis';
INSERT INTO ichppccode VALUES ('295','780','Fatigue, Malaise, Tiredness') ON DUPLICATE KEY UPDATE description='Fatigue, Malaise, Tiredness';
INSERT INTO ichppccode VALUES ('305','812','Fractured Humerus') ON DUPLICATE KEY UPDATE description='Fractured Humerus';
INSERT INTO ichppccode VALUES ('086.2','307','Eating disorder') ON DUPLICATE KEY UPDATE description='Eating disorder';
INSERT INTO ichppccode VALUES ('281.1','788','Toilet Training Problems') ON DUPLICATE KEY UPDATE description='Toilet Training Problems';
INSERT INTO ichppccode VALUES ('169','590','Pyelonephritis & Pyelitis,Acute/Chronic') ON DUPLICATE KEY UPDATE description='Pyelonephritis & Pyelitis,Acute/Chronic';
INSERT INTO ichppccode VALUES ('044','228','Hemangioma & Lymphangioma') ON DUPLICATE KEY UPDATE description='Hemangioma & Lymphangioma';
INSERT INTO ichppccode VALUES ('143','492','Emphysema & COPD') ON DUPLICATE KEY UPDATE description='Emphysema & COPD';
INSERT INTO ichppccode VALUES ('321','848','Other Sprains And Strains') ON DUPLICATE KEY UPDATE description='Other Sprains And Strains';
INSERT INTO ichppccode VALUES ('232','739','Shoulder Syndromes') ON DUPLICATE KEY UPDATE description='Shoulder Syndromes';
INSERT INTO ichppccode VALUES ('081','291','Acute Alcoholic Intoxication') ON DUPLICATE KEY UPDATE description='Acute Alcoholic Intoxication';
INSERT INTO ichppccode VALUES ('170','595','Cystitis & UTI (Urinary Tract Infection)') ON DUPLICATE KEY UPDATE description='Cystitis & UTI (Urinary Tract Infection)';
INSERT INTO ichppccode VALUES ('028','127','Oxyuriasis, Pinworms, Helminthiasis') ON DUPLICATE KEY UPDATE description='Oxyuriasis, Pinworms, Helminthiasis';
INSERT INTO ichppccode VALUES ('065','289','Blood/Blood Forming Organ Disor NEC') ON DUPLICATE KEY UPDATE description='Blood/Blood Forming Organ Disor NEC';
INSERT INTO ichppccode VALUES ('117','429','Pulmonary Heart Disease') ON DUPLICATE KEY UPDATE description='Pulmonary Heart Disease';
INSERT INTO ichppccode VALUES ('159','787','Irritable Bowel Syndrome IBS /Intest Disor NEC') ON DUPLICATE KEY UPDATE description='Irritable Bowel Syndrome IBS /Intest Disor NEC';
INSERT INTO ichppccode VALUES ('160','556','Ulcerative Colitis, Crohn&#146;s, Inflammatory Bowel') ON DUPLICATE KEY UPDATE description='Ulcerative Colitis, Crohn&#146;s, Inflammatory Bowel';
INSERT INTO ichppccode VALUES ('185','616','Vaginitis NOS, Vulvitis, Yeast Vaginitis') ON DUPLICATE KEY UPDATE description='Vaginitis NOS, Vulvitis, Yeast Vaginitis';
INSERT INTO ichppccode VALUES ('352','799','Postnatal Care/Postpartum Care') ON DUPLICATE KEY UPDATE description='Postnatal Care/Postpartum Care';
INSERT INTO ichppccode VALUES ('366.1','904','Cultural adjustment') ON DUPLICATE KEY UPDATE description='Cultural adjustment';
INSERT INTO ichppccode VALUES ('315','842','Sprain/Strain Wrist, Hand, Fingers') ON DUPLICATE KEY UPDATE description='Sprain/Strain Wrist, Hand, Fingers';
INSERT INTO ichppccode VALUES ('237','715','Osteoarthritis Of Spine') ON DUPLICATE KEY UPDATE description='Osteoarthritis Of Spine';
INSERT INTO ichppccode VALUES ('061','285','Anemia, Other/Unspecified') ON DUPLICATE KEY UPDATE description='Anemia, Other/Unspecified';
INSERT INTO ichppccode VALUES ('018','372','Viral Conjunctivitis') ON DUPLICATE KEY UPDATE description='Viral Conjunctivitis';
INSERT INTO ichppccode VALUES ('211','686','Pyoderma,Pyogenic Granuloma') ON DUPLICATE KEY UPDATE description='Pyoderma,Pyogenic Granuloma';
INSERT INTO ichppccode VALUES ('253','763','All Perinatal Conditions') ON DUPLICATE KEY UPDATE description='All Perinatal Conditions';
INSERT INTO ichppccode VALUES ('086','298','Other Psychiatric Disorder') ON DUPLICATE KEY UPDATE description='Other Psychiatric Disorder';
INSERT INTO ichppccode VALUES ('049','244','Hypothyroidism, Myxedema, Cretinism') ON DUPLICATE KEY UPDATE description='Hypothyroidism, Myxedema, Cretinism';
INSERT INTO ichppccode VALUES ('023','098','Gonococcal Infections') ON DUPLICATE KEY UPDATE description='Gonococcal Infections';
INSERT INTO ichppccode VALUES ('127','415','Pulmonary Embolism & Infarction') ON DUPLICATE KEY UPDATE description='Pulmonary Embolism & Infarction';
INSERT INTO ichppccode VALUES ('164','569','Rectal Bleeding') ON DUPLICATE KEY UPDATE description='Rectal Bleeding';
INSERT INTO ichppccode VALUES ('373','599','Hematuria NOS') ON DUPLICATE KEY UPDATE description='Hematuria NOS';
INSERT INTO ichppccode VALUES ('179','605','Phimosis & Paraphimosis') ON DUPLICATE KEY UPDATE description='Phimosis & Paraphimosis';
INSERT INTO ichppccode VALUES ('268','786','Hemoptysis') ON DUPLICATE KEY UPDATE description='Hemoptysis';
INSERT INTO ichppccode VALUES ('180','608','Other Male Genital Organ Diseases') ON DUPLICATE KEY UPDATE description='Other Male Genital Organ Diseases';
INSERT INTO ichppccode VALUES ('216','696','Pityriasis Rosea') ON DUPLICATE KEY UPDATE description='Pityriasis Rosea';
INSERT INTO ichppccode VALUES ('331','930','Foreign Body Entering Thru Orifice') ON DUPLICATE KEY UPDATE description='Foreign Body Entering Thru Orifice';
INSERT INTO ichppccode VALUES ('086.3','301','Sexual identity problem') ON DUPLICATE KEY UPDATE description='Sexual identity problem';
INSERT INTO ichppccode VALUES ('357','909','Housing/Placement Problem') ON DUPLICATE KEY UPDATE description='Housing/Placement Problem';
INSERT INTO ichppccode VALUES ('050','250','Diabetes Mellitus, NIDDM, IDDM') ON DUPLICATE KEY UPDATE description='Diabetes Mellitus, NIDDM, IDDM';
INSERT INTO ichppccode VALUES ('007','034','Strep Throat, Scarlet Fever, Erysipelas') ON DUPLICATE KEY UPDATE description='Strep Throat, Scarlet Fever, Erysipelas';
INSERT INTO ichppccode VALUES ('367','905','(DO NOT USE) Occupational Problems') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Occupational Problems';
INSERT INTO ichppccode VALUES ('226','708','Allergic Urticaria, hives') ON DUPLICATE KEY UPDATE description='Allergic Urticaria, hives';
INSERT INTO ichppccode VALUES ('338.2','917','Well child 2-15 years') ON DUPLICATE KEY UPDATE description='Well child 2-15 years';
INSERT INTO ichppccode VALUES ('204.2','656','Small/Large for Dates') ON DUPLICATE KEY UPDATE description='Small/Large for Dates';
INSERT INTO ichppccode VALUES ('204.7','664','Perineal lacerations') ON DUPLICATE KEY UPDATE description='Perineal lacerations';
INSERT INTO ichppccode VALUES ('274','643','Nausea and/or vomiting, hyperemesis gravidarum') ON DUPLICATE KEY UPDATE description='Nausea and/or vomiting, hyperemesis gravidarum';
INSERT INTO ichppccode VALUES ('133','460','Common Cold, Acute URI, Pharyngitis, URTI') ON DUPLICATE KEY UPDATE description='Common Cold, Acute URI, Pharyngitis, URTI';
INSERT INTO ichppccode VALUES ('202.4','645','Prolonged pregnancy') ON DUPLICATE KEY UPDATE description='Prolonged pregnancy';
INSERT INTO ichppccode VALUES ('011','054','Herpes Simplex, All Sites') ON DUPLICATE KEY UPDATE description='Herpes Simplex, All Sites';
INSERT INTO ichppccode VALUES ('372','099','Non-Specific Urethritis') ON DUPLICATE KEY UPDATE description='Non-Specific Urethritis';
INSERT INTO ichppccode VALUES ('345','895','Intrauterine Devices') ON DUPLICATE KEY UPDATE description='Intrauterine Devices';
INSERT INTO ichppccode VALUES ('035','174','Malignant Neoplasm Breast') ON DUPLICATE KEY UPDATE description='Malignant Neoplasm Breast';
INSERT INTO ichppccode VALUES ('140','486','Pneumonia') ON DUPLICATE KEY UPDATE description='Pneumonia';
INSERT INTO ichppccode VALUES ('139','487','Influenza') ON DUPLICATE KEY UPDATE description='Influenza';
INSERT INTO ichppccode VALUES ('051','790','Abnormal Unexplained Biochem Test') ON DUPLICATE KEY UPDATE description='Abnormal Unexplained Biochem Test';
INSERT INTO ichppccode VALUES ('332','959','Late Effect Of Trauma') ON DUPLICATE KEY UPDATE description='Late Effect Of Trauma';
INSERT INTO ichppccode VALUES ('358','909','Caregiver Stress') ON DUPLICATE KEY UPDATE description='Caregiver Stress';
INSERT INTO ichppccode VALUES ('152','531','Other Peptic Ulcer, H Pylori, PUD') ON DUPLICATE KEY UPDATE description='Other Peptic Ulcer, H Pylori, PUD';
INSERT INTO ichppccode VALUES ('165','571','Cirrhosis & Other Liver Diseases') ON DUPLICATE KEY UPDATE description='Cirrhosis & Other Liver Diseases';
INSERT INTO ichppccode VALUES ('228','714','Rheumatoid Arthritis, Still&#146;s Disease, Polymyalgia Rheumatica') ON DUPLICATE KEY UPDATE description='Rheumatoid Arthritis, Still&#146;s Disease, Polymyalgia Rheumatica';
INSERT INTO ichppccode VALUES ('264','780','Syncope, Faint, Blackout') ON DUPLICATE KEY UPDATE description='Syncope, Faint, Blackout';
INSERT INTO ichppccode VALUES ('201.1','656','Decreased Fetal Movement, Fetal Distress') ON DUPLICATE KEY UPDATE description='Decreased Fetal Movement, Fetal Distress';
INSERT INTO ichppccode VALUES ('086.4','299','Autism') ON DUPLICATE KEY UPDATE description='Autism';
INSERT INTO ichppccode VALUES ('204.8','666','Postpartum Hemorrhage, PPH') ON DUPLICATE KEY UPDATE description='Postpartum Hemorrhage, PPH';
INSERT INTO ichppccode VALUES ('214','692','Contact Dermatitis') ON DUPLICATE KEY UPDATE description='Contact Dermatitis';
INSERT INTO ichppccode VALUES ('063','289','Lymphadenitis, Chronic/Nonspecific') ON DUPLICATE KEY UPDATE description='Lymphadenitis, Chronic/Nonspecific';
INSERT INTO ichppccode VALUES ('254','780','Convulsions') ON DUPLICATE KEY UPDATE description='Convulsions';
INSERT INTO ichppccode VALUES ('270','786','Cough') ON DUPLICATE KEY UPDATE description='Cough';
INSERT INTO ichppccode VALUES ('306','813','Fractured Radius/Ulna') ON DUPLICATE KEY UPDATE description='Fractured Radius/Ulna';
INSERT INTO ichppccode VALUES ('296','229','Mass & Localized Swelling NOS/NYD') ON DUPLICATE KEY UPDATE description='Mass & Localized Swelling NOS/NYD';
INSERT INTO ichppccode VALUES ('227','709','Other Skin/Subcutaneous Tiss Diseas (Actinic Keratosis)') ON DUPLICATE KEY UPDATE description='Other Skin/Subcutaneous Tiss Diseas (Actinic Keratosis)';
INSERT INTO ichppccode VALUES ('269','786','Dyspnea/SOB') ON DUPLICATE KEY UPDATE description='Dyspnea/SOB';
INSERT INTO ichppccode VALUES ('089','345','Epilepsy/Seizure, All Types') ON DUPLICATE KEY UPDATE description='Epilepsy/Seizure, All Types';
INSERT INTO ichppccode VALUES ('090','346','Migraine Headaches') ON DUPLICATE KEY UPDATE description='Migraine Headaches';
INSERT INTO ichppccode VALUES ('283','788','Frequency Of Urination') ON DUPLICATE KEY UPDATE description='Frequency Of Urination';
INSERT INTO ichppccode VALUES ('241','727','Ganglion Of Joint & Tendon') ON DUPLICATE KEY UPDATE description='Ganglion Of Joint & Tendon';
INSERT INTO ichppccode VALUES ('100','380','Otitis Externa/OE') ON DUPLICATE KEY UPDATE description='Otitis Externa/OE';
INSERT INTO ichppccode VALUES ('047','240','Nontoxic Goiter & Nodule') ON DUPLICATE KEY UPDATE description='Nontoxic Goiter & Nodule';
INSERT INTO ichppccode VALUES ('188','625','Premenstrual Tension Syndrome (PMS)') ON DUPLICATE KEY UPDATE description='Premenstrual Tension Syndrome (PMS)';
INSERT INTO ichppccode VALUES ('045','229','Other Benign Neoplasms NEC') ON DUPLICATE KEY UPDATE description='Other Benign Neoplasms NEC';
INSERT INTO ichppccode VALUES ('087','340','Multiple Sclerosis/MS') ON DUPLICATE KEY UPDATE description='Multiple Sclerosis/MS';
INSERT INTO ichppccode VALUES ('020.1','799','Sexually transmitted disease, STD') ON DUPLICATE KEY UPDATE description='Sexually transmitted disease, STD';
INSERT INTO ichppccode VALUES ('110.1','412','Post MI, Old Myocardial infarction, chronic coronary artery disease') ON DUPLICATE KEY UPDATE description='Post MI, Old Myocardial infarction, chronic coronary artery disease';
INSERT INTO ichppccode VALUES ('204.10','658','Premature rupture of membranes/PROM') ON DUPLICATE KEY UPDATE description='Premature rupture of membranes/PROM';
INSERT INTO ichppccode VALUES ('101','382','Acute Otitis Media/OM') ON DUPLICATE KEY UPDATE description='Acute Otitis Media/OM';
INSERT INTO ichppccode VALUES ('048','242','Thyrotoxicosis W/WO Goiter,Hyperthyroidism') ON DUPLICATE KEY UPDATE description='Thyrotoxicosis W/WO Goiter,Hyperthyroidism';
INSERT INTO ichppccode VALUES ('091','343','Other Neurological Disorders/Carpal Tunnel Syndrome/Trigeminal Neuralgia') ON DUPLICATE KEY UPDATE description='Other Neurological Disorders/Carpal Tunnel Syndrome/Trigeminal Neuralgia';
INSERT INTO ichppccode VALUES ('062','286','Purpura,Hemorrhage & Coagulation Defect') ON DUPLICATE KEY UPDATE description='Purpura,Hemorrhage & Coagulation Defect';
INSERT INTO ichppccode VALUES ('202','646','Other Complications Of Pregnancy') ON DUPLICATE KEY UPDATE description='Other Complications Of Pregnancy';
INSERT INTO ichppccode VALUES ('281','788','Enuresis, Incontinence') ON DUPLICATE KEY UPDATE description='Enuresis, Incontinence';
INSERT INTO ichppccode VALUES ('166','575','Cholecystitis/Gallbladder Disease') ON DUPLICATE KEY UPDATE description='Cholecystitis/Gallbladder Disease';
INSERT INTO ichppccode VALUES ('077','309','(DO NOT USE) Adjustment Reaction, grief') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Adjustment Reaction, grief';
INSERT INTO ichppccode VALUES ('071.1','300','Somatoform/psychosomatic disturbance') ON DUPLICATE KEY UPDATE description='Somatoform/psychosomatic disturbance';
INSERT INTO ichppccode VALUES ('137','464','Laryngitis&Tracheitis, Acute, Croup') ON DUPLICATE KEY UPDATE description='Laryngitis&Tracheitis, Acute, Croup';
INSERT INTO ichppccode VALUES ('009','052','Chickenpox') ON DUPLICATE KEY UPDATE description='Chickenpox';
INSERT INTO ichppccode VALUES ('174','598','Other Urinary System Diseases NEC/ RENAL FAILURE') ON DUPLICATE KEY UPDATE description='Other Urinary System Diseases NEC/ RENAL FAILURE';
INSERT INTO ichppccode VALUES ('085','319','(DO NOT USE) Mental Retardation') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Mental Retardation';
INSERT INTO ichppccode VALUES ('019','078','Warts, All Sites') ON DUPLICATE KEY UPDATE description='Warts, All Sites';
INSERT INTO ichppccode VALUES ('020','079','Viral Infection NOS') ON DUPLICATE KEY UPDATE description='Viral Infection NOS';
INSERT INTO ichppccode VALUES ('098','369','Blindness') ON DUPLICATE KEY UPDATE description='Blindness';
INSERT INTO ichppccode VALUES ('108','390','Rheumatic Fever/Heart Disease') ON DUPLICATE KEY UPDATE description='Rheumatic Fever/Heart Disease';
INSERT INTO ichppccode VALUES ('010','053','Herpes Zoster, Shingles') ON DUPLICATE KEY UPDATE description='Herpes Zoster, Shingles';
INSERT INTO ichppccode VALUES ('202.1','644','False Labour, Threatened Labour') ON DUPLICATE KEY UPDATE description='False Labour, Threatened Labour';
INSERT INTO ichppccode VALUES ('114','427','Paroxysmal Tachycardia') ON DUPLICATE KEY UPDATE description='Paroxysmal Tachycardia';
INSERT INTO ichppccode VALUES ('255','781','Abnormal Involuntary Movement(tremor)') ON DUPLICATE KEY UPDATE description='Abnormal Involuntary Movement(tremor)';
INSERT INTO ichppccode VALUES ('113','427','Atrial Fibrillation or Flutter') ON DUPLICATE KEY UPDATE description='Atrial Fibrillation or Flutter';
INSERT INTO ichppccode VALUES ('151','532','Duodenal Ulcer/Gastritis/Gastroenteritis') ON DUPLICATE KEY UPDATE description='Duodenal Ulcer/Gastritis/Gastroenteritis';
INSERT INTO ichppccode VALUES ('344','895','Contraceptive Advice, Family Plan,contraception/BCP') ON DUPLICATE KEY UPDATE description='Contraceptive Advice, Family Plan,contraception/BCP';
INSERT INTO ichppccode VALUES ('193','626','Disorders Of Menstruation, DUB') ON DUPLICATE KEY UPDATE description='Disorders Of Menstruation, DUB';
INSERT INTO ichppccode VALUES ('085.1','319','Developmental delay') ON DUPLICATE KEY UPDATE description='Developmental delay';
INSERT INTO ichppccode VALUES ('302','805','Fracture Vertebral Column') ON DUPLICATE KEY UPDATE description='Fracture Vertebral Column';
INSERT INTO ichppccode VALUES ('292','691','Rash & Other Non Specific Skin Eruption') ON DUPLICATE KEY UPDATE description='Rash & Other Non Specific Skin Eruption';
INSERT INTO ichppccode VALUES ('360.1','899','Parent/child problem') ON DUPLICATE KEY UPDATE description='Parent/child problem';
INSERT INTO ichppccode VALUES ('073','300','(DO NOT USE) Neurosis, Other/Unspecified') ON DUPLICATE KEY UPDATE description='(DO NOT USE) Neurosis, Other/Unspecified';
INSERT INTO ichppccode VALUES ('077.2','309','Coping with physical illness') ON DUPLICATE KEY UPDATE description='Coping with physical illness';
INSERT INTO ichppccode VALUES ('086.5','300','Self mutilation') ON DUPLICATE KEY UPDATE description='Self mutilation';
INSERT INTO ichppccode VALUES ('203','650','Uncomplicated Pregnancy, normal delivery') ON DUPLICATE KEY UPDATE description='Uncomplicated Pregnancy, normal delivery';


-- from update-2016-02-19-born.sql  if you are not using BORN these data are just going to be cluttering your dropdown
-- ALTER TABLE `consultationServices` ADD UNIQUE INDEX `serviceDescTemp`(`serviceDesc`);
--
-- INSERT INTO consultationServices VALUES (\N,'Autism Intervention Services','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Autism Intervention Services';
-- INSERT INTO consultationServices VALUES (\N,'Blind Low Vision Program','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Blind Low Vision Program';
-- INSERT INTO consultationServices VALUES (\N,'Child Care','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Child Care';
-- INSERT INTO consultationServices VALUES (\N,'Child Protection Services','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Child Protection Services';
-- INSERT INTO consultationServices VALUES (\N,'Children\'s Mental Health Services','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Children\'s Mental Health Services';
-- INSERT INTO consultationServices VALUES (\N,'Children\'s Treatment Centre','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Children\'s Treatment Centre';
-- INSERT INTO consultationServices VALUES (\N,'Community Care Access Centre','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Community Care Access Centre';
-- INSERT INTO consultationServices VALUES (\N,'Community Parks and Recreation Programs','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Community Parks and Recreation Programs';
-- INSERT INTO consultationServices VALUES (\N,'Dental Services','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Dental Services';
-- INSERT INTO consultationServices VALUES (\N,'Family Resource Programs','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Family Resource Programs';
-- INSERT INTO consultationServices VALUES (\N,'Healthy Babies Healthy Children','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Healthy Babies Healthy Children';
-- INSERT INTO consultationServices VALUES (\N,'Infant Development Program','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Infant Development Program';
-- INSERT INTO consultationServices VALUES (\N,'Infant Hearing Program','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Infant Hearing Program';
-- INSERT INTO consultationServices VALUES (\N,'Ontario Early Years Centre','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Ontario Early Years Centre';
-- INSERT INTO consultationServices VALUES (\N,'Paediatrician/Developmental Paediatrician','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Paediatrician/Developmental Paediatrician';
-- INSERT INTO consultationServices VALUES (\N,'Preschool Speech and Language Program','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Preschool Speech and Language Program';
-- INSERT INTO consultationServices VALUES (\N,'Public Health','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Public Health';
-- INSERT INTO consultationServices VALUES (\N,'Schools','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Schools';
-- INSERT INTO consultationServices VALUES (\N,'Services for Physical and Developmental Disabilities','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Services for Physical and Developmental Disabilities';
-- INSERT INTO consultationServices VALUES (\N,'Services for the Hearing Impaired','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Services for the Hearing Impaired';
-- INSERT INTO consultationServices VALUES (\N,'Services for the Visually Impaired','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Services for the Visually Impaired';
-- INSERT INTO consultationServices VALUES (\N,'Specialized Child Care Programming','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Specialized Child Care Programming';
-- INSERT INTO consultationServices VALUES (\N,'Specialized Medical Services','1') ON DUPLICATE KEY UPDATE `serviceDesc`='Specialized Medical Services';
-- 
-- ALTER TABLE `consultationServices` DROP INDEX `serviceDescTemp`;


-- patch sql  May 14, 2018
-- earlier patchwork moved into patch1.sql

-- from update-2016-03-15.sql

CREATE TABLE IF NOT EXISTS `BORNPathwayMapping` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `bornPathway` varchar(100),
  `serviceId` int(10),
  PRIMARY KEY (`id`)
);

-- from update-2016-04-25-bc.sql

CREATE TABLE IF NOT EXISTS `billingperclimit` (
  `service_code` varchar(10) NOT NULL ,
  `min` varchar(8),
  `max` varchar(8),
  `effective_date` date,
  `id` int auto_increment,
  PRIMARY KEY  (`id`)
) ;


-- from update-2016-06-06.sql

CREATE TABLE IF NOT EXISTS `resident_oscarMsg` (
    `id` int(11) auto_increment,
    `supervisor_no` varchar(6),
    `resident_no` varchar(6),
    `demographic_no` int(11),
    `appointment_no` int(11),    
    `note_id` int(10),
    `complete` int(1),
    `create_time` timestamp,
    `complete_time` timestamp,
    PRIMARY KEY(`id`),
    index note_id_idx (`note_id`)
);

-- from update-2016-03-30.sql
CREATE TABLE  IF NOT EXISTS `Consent` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `demographic_no` int(10),
  `consent_type_id` int(10),
  `explicit` tinyint(1),
  `optout` tinyint(1),
  `last_entered_by` varchar(10),
  `consent_date` datetime,
  `optout_date` datetime,
  `edit_date` datetime,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `consentType` (
  `id` int(15) NOT NULL AUTO_INCREMENT,
  `type` varchar(50),
  `name` varchar(50),
  `description` varchar(500),
  `active` tinyint(1),
  PRIMARY KEY (`id`)
);

INSERT INTO `consentType` VALUES ('1', 'integrator_patient_consent', 'Sunshiner frailty network', 'Patient Permissions for Integrator enabled sharing of: Chart notes, RXes, eforms, allergies, documents (e.g.photos) Discussed with patient (and/or their representative) and they have consented to integrator enabled sharing of their information with Sunshiners Frailty Network', '1') ON DUPLICATE KEY UPDATE `type`='integrator_patient_consent';

-- from update-2016-06-21.sql
INSERT INTO `icd9` (`icd9`, `description`) VALUES ('780.93','MEMORY LOSS') ON DUPLICATE KEY UPDATE `description`='MEMORY LOSS';

-- from update-2016-06-28.sql
ALTER TABLE `eform` MODIFY form_html mediumtext;

-- from update-2016-07-12.sql part
INSERT INTO  `secObjectName` (`objectName`) values ('_dashboardManager') ON DUPLICATE KEY UPDATE objectName='_dashboardManager' ;
INSERT INTO  `secObjectName` (`objectName`) values ('_dashboardDisplay') ON DUPLICATE KEY UPDATE objectName='_dashboardDisplay' ;
INSERT INTO  `secObjectName` (`objectName`) values ('_dashboardDrilldown') ON DUPLICATE KEY UPDATE objectName='_dashboardDrilldown' ;

-- from update-2016-07-15.sql
CREATE TABLE IF NOT EXISTS `dashboard` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255),
  `description` varchar(255),
  `creator` varchar(11),
  `edited` datetime,
  `active` bit(1),
  `locked` bit(1),
  PRIMARY KEY (`id`)
);


-- from update-2016-08-30.sql
CREATE TABLE IF NOT EXISTS `tickler_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(55),
  `description` varchar(255),
  `active` bit(1),
  PRIMARY KEY (`id`)
);

INSERT INTO `tickler_category` VALUES ('1', 'To Call In', 'Call this patient in for a follow-up visit', b'1')  ON DUPLICATE KEY UPDATE category='To Call In';
INSERT INTO `tickler_category` VALUES ('2', 'Reminder Note', 'Send a reminder note to this patient', b'1') ON DUPLICATE KEY UPDATE category='Reminder Note';
INSERT INTO `tickler_category` VALUES ('3', 'Follow-up Billing', 'Follow-up Additional Billing', b'1') ON DUPLICATE KEY UPDATE category='Follow-up Billing';

-- PHC fix no longer needed
-- UPDATE `tickler` SET `category_id` = "0" WHERE `category_id` IS NULL ;

-- PHC fix for update 2016-12-02.sql ...causes a NPE when run on a table with existing data
-- so remove any nulls there in
UPDATE `indicatorTemplate` SET `shared`="0" WHERE `shared` IS NULL;



-- from update-2017-01-25.sql
ALTER TABLE `hl7TextInfo` MODIFY report_status VARCHAR(10);

-- from update-2017-01-31.sql
-- more above
CREATE TABLE IF NOT EXISTS `onCallClinicDates` (
  `id` int(10),
  `startDate` date,
  `endDate` date,
  `name` varchar(256),
  `location` varchar(256),
  `color` varchar(7),
  PRIMARY KEY (`id`)
);

-- from update-2017-02-21.sql
ALTER TABLE `casemgmt_issue` CHANGE COLUMN demographic_no demographic_no int(11);

-- adhoc from update-2017-02-27.sql

INSERT INTO  `secObjectName` (`objectName`) VALUES ('_admin.eformreporttool') ON DUPLICATE KEY UPDATE objectName='_admin.eformreporttool' ;
INSERT INTO  `secObjectName` (`objectName`) VALUES ('_admin.eform') ON DUPLICATE KEY UPDATE objectName='_admin.eform' ;
INSERT INTO  `secObjPrivilege` VALUES('admin', '_admin.eformreporttool', 'x', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_admin.eformreporttool' ;
INSERT INTO  `secObjPrivilege` VALUES('admin', '_admin.eform', 'x', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_admin.eform' ;

-- from update-2017-06-20.sql for build 639
ALTER TABLE `log` MODIFY action varchar(100);

-- from update-2017-07-26.sql for build 656
INSERT INTO  `secObjectName` (`objectName`) VALUES  ('_newCasemgmt.photo') ON DUPLICATE KEY UPDATE objectName='_newCasemgmt.photo' ;
INSERT INTO  `secObjPrivilege` VALUES('doctor','_newCasemgmt.photo','x',0,'999998')ON DUPLICATE KEY UPDATE objectName='_newCasemgmt.photo' ;

-- from update-2017-08-01.sql for build 667
INSERT INTO  `secObjectName` (`objectName`) VALUES ('_dashboardCommonLink') ON DUPLICATE KEY UPDATE objectName='_dashboardCommonLink' ;
INSERT INTO  `secObjPrivilege` VALUES ('doctor','_dashboardCommonLink','o',0,'999998') ON DUPLICATE KEY UPDATE objectName='_dashboardCommonLink' ;
INSERT INTO  `secObjPrivilege` VALUES ('admin','_dashboardCommonLink','o',0,'999998') ON DUPLICATE KEY UPDATE objectName='_dashboardCommonLink' ;


-- circa build 680

-- from update-2017-07-20.sql, if you have a lot of data, say 3/4 million rows, this might take 15 sec

ALTER TABLE `measurementsDeleted` CHANGE COLUMN dataField dataField varchar(255);

-- update-2017-09-21.sql
--  add addkey procedure and add them for the two tables below
DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `CreateIndex` $$
CREATE PROCEDURE `CreateIndex`
(
    given_database VARCHAR(64),
    given_table    VARCHAR(64),
    given_unique   VARCHAR(64),
    given_index    VARCHAR(64),
    given_columns  VARCHAR(64)

)
theStart:BEGIN

    DECLARE TableIsThere INTEGER;
    DECLARE IndexIsThere INTEGER;

    SELECT COUNT(1) INTO TableIsThere
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE table_schema = given_database
    AND   table_name   = given_table;

    IF TableIsThere = 0 THEN
        SELECT CONCAT(given_database,'.',given_table, 
	' does not exist.  Unable to add ', given_index) CreateIndexMessage;
	LEAVE theStart;
    ELSE

	    SELECT COUNT(1) INTO IndexIsThere
	    FROM INFORMATION_SCHEMA.STATISTICS
	    WHERE table_schema = given_database
	    AND   table_name   = given_table
	    AND   index_name   = given_index;

	    IF IndexIsThere = 0 THEN
		SET @sqlstmt = CONCAT('CREATE ',given_unique,' INDEX ',given_index,' ON ',
		given_database,'.',given_table,' (',given_columns,')');
		PREPARE st FROM @sqlstmt;
		EXECUTE st;
		DEALLOCATE PREPARE st;
	    ELSE
		SELECT CONCAT('Index ',given_index,' Already Exists ON Table ',
		given_database,'.',given_table) CreateIndexMessage;
	    END IF;

	END IF;

END $$

DELIMITER ;

CALL CreateIndex('oscar_15', 'encounterForm','UNIQUE', 'form_name_idx', 'form_name');

INSERT INTO encounterForm( form_name, form_value, form_table, hidden ) VALUES ("LabReq07 eFTS", "../form/formlabreq07.jsp?labType=eFTS&demographic_no=", "", '0') ON DUPLICATE KEY UPDATE hidden='0';
INSERT INTO encounterForm( form_name, form_value, form_table, hidden ) VALUES ("LabReq10 eFTS", "../form/formlabreq10.jsp?labType=eFTS&demographic_no=", "", '0') ON DUPLICATE KEY UPDATE hidden='0';

-- add empty table as not present in BC and adding the index will break it
 
CREATE TABLE IF NOT EXISTS `frm_labreq_preset` (
  `preset_id` int(10) NOT NULL AUTO_INCREMENT,
  `lab_type` varchar(255) NOT NULL,
  `prop_name` varchar(255) NOT NULL,
  `prop_value` varchar(255) NOT NULL,
  `status` int(1) NOT NULL,
  PRIMARY KEY (`preset_id`),
  UNIQUE KEY `lab_type_prop_name_prop_value` (`lab_type`,`prop_name`,`prop_value`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

CALL CreateIndex('oscar_15', 'frm_labreq_preset','UNIQUE', 'lab_type_prop_name_prop_value', 'lab_type, prop_name, prop_value');

INSERT INTO frm_labreq_preset( lab_type, prop_name, prop_value, status ) VALUES ("eFTS", "o_otherTests1", "Enhanced First Trimester Screen", "1") ON DUPLICATE KEY UPDATE status='1';

-- update-2017-09-26.sql 

INSERT INTO  `secObjectName` (`objectName`) VALUES ('_admin.demographic') ON DUPLICATE KEY UPDATE objectName='_admin.demographic' ;
INSERT INTO  `secObjPrivilege` VALUES('admin', '_admin.demographic', 'u', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_admin.demographic' ;


-- update-2017-12-13.sql 

INSERT INTO  `secObjectName` (`objectName`) VALUES  ('_admin.auditLogPurge') ON DUPLICATE KEY UPDATE objectName='_admin.auditLogPurge' ;
INSERT INTO  `secObjPrivilege` VALUES('admin', '_admin.auditLogPurge', 'u', 0, '999998') ON DUPLICATE KEY UPDATE objectName='_admin.auditLogPurge' ;


-- from update-2016-08-30.sql
-- more below
CREATE TABLE IF NOT EXISTS `tickler_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(55),
  `description` varchar(255),
  `active` bit(1),
  PRIMARY KEY (`id`)
);

INSERT INTO `tickler_category` VALUES ('1', 'To Call In', 'Call this patient in for a follow-up visit', b'1') ON DUPLICATE KEY UPDATE category='To Call In' ;
INSERT INTO `tickler_category` VALUES ('2', 'Reminder Note', 'Send a reminder note to this patient', b'1') ON DUPLICATE KEY UPDATE category='Reminder Note' ; 
INSERT INTO `tickler_category` VALUES ('3', 'Follow-up Billing', 'Follow-up Additional Billing', b'1') ON DUPLICATE KEY UPDATE category='Follow-up Billing' ;


-- phc fudge to accomodate a missing table
CREATE TABLE  IF NOT EXISTS `ResourceStorage` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `resourceType` varchar(100),
  `resourceName` varchar(100),
  `uuid` varchar(40),
  `fileContents` mediumblob,
  `uploadDate` datetime,
  `update_date` datetime,
  `reference_date` datetime,
  `active` tinyint(1),
  PRIMARY KEY (`id`),
  KEY `ResourceStorage_resourceType_active` (`resourceType`(10),`active`),
  KEY `ResourceStorage_resourceType_uuid` (`uuid`)
);


DELIMITER $$

DROP PROCEDURE IF EXISTS patch_database $$
CREATE PROCEDURE patch_database()
BEGIN

-- rename a table safely
-- IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
--        AND TABLE_NAME='my_old_table_name') ) THEN
--    RENAME TABLE 
--        my_old_table_name TO my_new_table_name,
-- END IF;

-- add a column safely

-- from update-2018-01-15.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='practitionerNoType' AND TABLE_NAME='provider') ) THEN
    ALTER TABLE `provider` ADD `practitionerNoType` varchar(255);
    UPDATE `provider` SET `practitionerNoType` = '';
END IF;

IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='practitionerNoType' AND TABLE_NAME='providerArchive') ) THEN
    ALTER TABLE `providerArchive` ADD `practitionerNoType` varchar(255);
    UPDATE `providerArchive` SET `practitionerNoType` = '';
END IF;

IF NOT EXISTS( (SELECT * FROM `LookupList` WHERE 
        `name` = 'practitionerNoType') ) THEN
    INSERT INTO `LookupList` VALUES (\N,'practitionerNoType','Practitioner No Type List','Select list for disambiguating practitionerNo in provider record',NULL,1,'oscar',now());
    SET @lid = LAST_INSERT_ID();
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'CPSO','College of Physicians and Surgeons of Ontario',3,1,'oscar',now());
END IF;


-- from update update-2018-07-23-on.sql
IF NOT EXISTS( (SELECT * FROM `OscarJobType` WHERE 
        `name` = 'CanadianVaccineCatalogueUpdater') ) THEN
    INSERT INTO `OscarJobType` VALUES (\N,'CanadianVaccineCatalogueUpdater','Updates the local copy of the data','org.oscarehr.integration.born.CanadianVaccineCatalogueJob',1,now()),(\N,'BORN FHIR','','org.oscarehr.integration.born.BORNFhirJob',1,now());
END IF;

IF NOT EXISTS( (SELECT * FROM `OscarJob` WHERE 
        `name` = 'CanadianVaccineCatalogueUpdater') ) THEN
    INSERT INTO `OscarJob` VALUES (\N,'CanadianVaccineCatalogueUpdater','Updates the CVC data',(select id from OscarJobType where name='CanadianVaccineCatalogueUpdater'),'0 * 0 * * *','999998',1,now()),(\N,'BORN FHIR','',(select id from OscarJobType where name='BORN FHIR'),'0 * * * * *','999998',1,now());
END IF;


-- from update-2018-01-19.sql  Add PHU field to master demographic 
IF NOT EXISTS( (SELECT * FROM `LookupList` WHERE 
        `name` = 'phu') ) THEN
    INSERT INTO `LookupList` VALUES (\N,'phu','Public Health Units','Public Health Units - needed for DHIR submissions',NULL,1,'oscar',now());
    SET @lid = LAST_INSERT_ID();
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'6','Grey Bruce Health Unit',1,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'9','Huron County Health Unit',2,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'11','Oxford County Public Health',3,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'12','Simcoe Muskoka District Health Unit',4,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'13','Hastings and Prince Edward Counties Health Unit',5,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'14','Peel Public Health',6,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'15','Brant County Health Unit',7,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'16','Leeds, Grenville and Lanark District Health Unit',8,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'17','Chatham-Kent Public Health Unit',9,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'18','Eastern Ontario Health Unit',10,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'19','Wellington-Dufferin-Guelph Public Health',11,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'20','Hamilton Public Health services',12,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'21','Northwestern Health Unit',13,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'22','Kingston, Frontenac and Lennox & Addington Public Health',14,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'23','Middlesex-London Health Unit',15,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'24','Timiskaming Health Unit',16,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'25','York Region Public Health services',17,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'26','North Bay Parry Sound District Health Unit',18,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'27','Halton Region Health Department',19,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'28','Ottawa Public Health',20,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'29','Renfrew County and District Health Unit',21,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'30','Peterborough Country-City Health Unit',22,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'31','Lambton Public Health',23,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'32','Haliburton, Kawartha, Pine Ridge District Health Unit',24,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'33','Algoma Public Health Unit',25,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'34','Haldimand-Norfolk Health Unit',26,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'35','Elgin-St. Thomas Health Unit',27,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'36','Perth District Health Unit',28,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'40','Sudbury and District Health Unit',29,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'41','Niagara Region Public Health Unit',30,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'46','Thunder Bay District Health Unit',31,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'54','Porcupine Health Unit',32,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'55','Toronto Public Health',33,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'56','Region of Waterloo, Public Health',34,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'57','Durham Region Health Department',35,1,'oscar',now());
    INSERT INTO `LookupListItem` VALUES (\N,@lid,'58','Windsor-Essex County Health Unit',36,1,'oscar',now());
END IF;

-- from update-2016-08-30.sql


IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='category_id' AND TABLE_NAME='tickler') ) THEN
    ALTER TABLE `tickler` ADD `category_id` int(11);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='oneIdKey' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `oneIdKey` varchar(255);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='oneIdEmail' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `oneIdEmail` varchar(255);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='delegateOneIdEmail' AND TABLE_NAME='security') ) THEN
    ALTER TABLE `security` ADD `delegateOneIdEmail` varchar(255);
END IF;

-- from update-2018-01-31.sql  Changes for Dashboard Phase II 
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='metricSetName' AND TABLE_NAME='indicatorTemplate') ) THEN
    ALTER TABLE `indicatorTemplate` ADD `metricSetName` varchar(255);
END IF;
	
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='metricLabel' AND TABLE_NAME='indicatorTemplate') ) THEN
    ALTER TABLE `indicatorTemplate` ADD `metricLabel` varchar(255);
END IF;
	
-- from update-2018-01-08.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='snomedId' AND TABLE_NAME='preventions') ) THEN
    ALTER TABLE `preventions` ADD `snomedId` varchar(255);
END IF;

-- From update-2018-05-06.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='deleted' AND TABLE_NAME='Consent') ) THEN
    ALTER TABLE `Consent` ADD `deleted` tinyint(1);
END IF;

-- From update-2017-10-24.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='update_date' AND TABLE_NAME='ResourceStorage') ) THEN
    ALTER TABLE `ResourceStorage` ADD `update_date` datetime;
END IF;

IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='reference_date' AND TABLE_NAME='ResourceStorage') ) THEN
    ALTER TABLE `ResourceStorage` ADD `reference_date` datetime;
END IF;

IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='period' AND TABLE_NAME='surveyData') ) THEN
    ALTER TABLE `surveyData` ADD `period` int(10);
END IF;

IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='randomness' AND TABLE_NAME='surveyData') ) THEN
    ALTER TABLE `surveyData` ADD `randomness` int(10);
END IF;

IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='version' AND TABLE_NAME='surveyData') ) THEN
    ALTER TABLE `surveyData` ADD `version` int(10);
END IF;

-- from update-2018-05-31.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='providerNo' AND TABLE_NAME='view') ) THEN
    ALTER TABLE `view` ADD `providerNo` varchar(6);
END IF;

-- From update update-2018-07-23.sql DHIRSubmission
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='demographicNo' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `demographicNo` int;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='type' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `type` varchar(20);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='httpCode' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `httpCode` varchar(20);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='httpResult' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `httpResult` mediumtext;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='httpHeaders' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `httpHeaders` text;
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='hialTransactionId' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `hialTransactionId` varchar(255);
END IF;
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='contentLocation' AND TABLE_NAME='BornTransmissionLog') ) THEN
    ALTER TABLE `BornTransmissionLog` ADD `contentLocation` varchar(255);
END IF;
-- From update update-2018-10-02.sql
IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND COLUMN_NAME='config' AND TABLE_NAME='OscarJob') ) THEN
    ALTER TABLE `OscarJob` ADD `config` text;
END IF;



-- bc patch billingmaster is a table that is only in BC builds --
IF EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
       AND TABLE_NAME='billingmaster') ) THEN
-- update-2018-03-23-bc.sql
        CALL CreateIndex('oscar_15', 'LookupListItem', 'UNIQUE', 'value_idx', 'value');
        INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CPSBC','College of Physicians and Surgeons of British Columbia',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CPSBC';
        INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CNPBC','College of Naturopathic Physicians of BC',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CNPBC';
        INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CRNBC','College of Registered Nurses of BC',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CRNBC';
        INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CPBC','College of Psychologists BC',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CPBC';
        INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CMBC','College of Midwives of BC',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CMBC';

-- update-2018-08-01-bc.sql --
        CREATE TABLE `tmp_bm_nos` (id int(10));
        INSERT INTO `tmp_bm_nos` SELECT billingmaster_no FROM billingmaster bm,billing b WHERE bm.billing_no = b.billing_no and bm.billingstatus='S' and b.billingtype='Pri';
        UPDATE billingmaster SET billingstatus='A' WHERE billingmaster_no in (select id from tmp_bm_nos);
        DROP TABLE `tmp_bm_nos`;
END IF;


END $$

DELIMITER ;

CALL patch_database();



-- update-2018-02-13.sql Add new granular schedule-management role object: 
INSERT INTO `secObjectName` (`objectName`, `description`, `orgapplicable`) VALUES ('_admin.schedule.curprovider_only','allow provider with non-admin role to create schedule templates and assign to themselves', 0) ON DUPLICATE KEY UPDATE objectName='_admin.schedule.curprovider_only' ;


-- from update-2018-01-08.sql
CREATE TABLE IF NOT EXISTS `CVCMedication` (
  `id` int(11) NOT NULL auto_increment,
  `versionId` integer,
  `din` integer,
  `dinDisplayName` varchar(255),
  `snomedCode` varchar(255),
  `snomedDisplay` varchar(255),
  `status` varchar(40),
  `isBrand` tinyint(1),
  `manufacturerId` integer,
  `manufacturerDisplay` varchar(255),
  PRIMARY KEY  (`id`)
);

CREATE TABLE IF NOT EXISTS `CVCMedicationGTIN` (
  `id` int(11) NOT NULL auto_increment,
  `cvcMedicationId` integer NOT NULL,
  `gtin` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
);

CREATE TABLE IF NOT EXISTS `CVCMedicationLotNumber` (
  `id` int(11) NOT NULL auto_increment,
  `cvcMedicationId` integer NOT NULL,
  `lotNumber` varchar(255) NOT NULL,
  `expiryDate` date,
  PRIMARY KEY  (`id`)
);

CREATE TABLE IF NOT EXISTS `CVCImmunization` (
  `id` int(11) NOT NULL auto_increment,
  `versionId` integer,
  `snomedConceptId` varchar(255),
  `displayName` varchar(255),
  `picklistName` varchar(255),
  `generic` tinyint(1),
  `prevalence` int,
  `parentConceptId` varchar(255),
  `ispa` tinyint(1),
  PRIMARY KEY  (`id`)
);

ALTER TABLE `preventions` MODIFY `prevention_type` varchar(255);


CREATE TABLE IF NOT EXISTS `CVCMapping` (
   `id` int(10) NOT NULL auto_increment,
   `oscarName` varchar(255),
   `cvcSnomedId` varchar(255),
   `preferCVC` tinyint(1),
  PRIMARY KEY (`id`)
);

-- From update-2017-04-04.sql (sic)

CREATE TABLE IF NOT EXISTS `IntegratorFileLog` (
    `id` int(11) auto_increment,
    `filename` varchar(255),
    `checksum` varchar(255),
    `lastDateUpdated` datetime,
    `currentDate` datetime,
    `integratorStatus` varchar(100),
    `dateCreated` timestamp,
    PRIMARY KEY(`id`)
);

CALL CreateIndex('oscar_15', 'measurements', '', 'measurement_integrator', 'demographicNo,dateEntered');
CALL CreateIndex('oscar_15', 'dxresearch', '', 'dxresearch_integrator', 'demographic_no,update_date');


-- From update update-2018-04-16.sql
ALTER TABLE `billing` modify `status` varchar(1) DEFAULT NULL;

-- From update-2018-05-06.sql
UPDATE `Consent` SET `deleted` = 0 WHERE `deleted` IS NULL;
UPDATE `Consent` SET `deleted` = 1, `optout` = 1 WHERE `optout` IS NULL;

-- From update-2017-10-24.sql fixed typos for table name
CALL CreateIndex('oscar_15', 'ResourceStorage','UNIQUE', 'ResourceStorage_resourceType_uuid', 'uuid');
ALTER TABLE `surveyData` MODIFY `surveyId` varchar(40);
CREATE TABLE IF NOT EXISTS `SurveillanceData` (
        `id` int(10)  NOT NULL auto_increment primary key,
        `surveyId` varchar(50),
        `data` mediumblob,
        `createDate` datetime,
        `lastUpdateDate` datetime,
        `transmissionDate` datetime,
        `sent` boolean
);

-- x update-2018-04-01.sql
-- x update-2018-05-31.sql
-- x update-2018-06-01.sql
-- x update-2018-06-03.sql
-- x update-2018-07-03.sql

-- From update update-2018-07-23.sql DHIRSubmission also above

CREATE TABLE IF NOT EXISTS DHIRSubmissionLog (
    id int(11) auto_increment,
    demographicNo int,
    preventionId int,
    submitterProviderNo varchar(255),
    status varchar(255),
    dateCreated datetime,
    transactionId varchar(100),
    bundleId varchar(255),
    response mediumtext,
    contentLocation varchar(255),
    clientRequestId varchar(100),
    clientResponseId varchar(100),
    PRIMARY KEY(id)
);

ALTER TABLE BornTransmissionLog MODIFY filename varchar(100);

-- From update update-2018-07-23-on.sql CanadianVaccineCatalogueUpdater


CALL CreateIndex('oscar_15', 'consentType', 'UNIQUE', 'type_idx', 'type');

INSERT INTO `consentType`(`type`, `name`, `description`, `active`) VALUES ('dhir_non_ispa_consent','DHIR non-ISPA Vaccines','Patient consents to submitting immunization data not covered by ISPA to DHIR',1) ON DUPLICATE KEY UPDATE type='dhir_non_ispa_consent';
INSERT INTO `consentType`(`type`, `name`, `description`, `active`) VALUES ('dhir_ispa_consent','DHIR ISPA Vaccines','Patient consents to submitting immunization data covered by ISPA to DHIR',1) ON DUPLICATE KEY UPDATE type='dhir_ispa_consent';



DELETE FROM LookupListItem where value='CNO' AND lookupListId = (select id from LookupList where name = 'practitionerNoType');

CALL CreateIndex('oscar_15', 'LookupListItem', 'UNIQUE', 'value_idx', 'value');

INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'OCP','Ontario College of Pharmacists (OCP)',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='OCP';
INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CNORNP','RNP - College of Nurses of Ontario (CNO)',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CNORNP';
INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CNORN','RN - College of Nurses of Ontario  (CNO)',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CNORN';
INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CNORPN','RPN - College of Nurses of Ontario  (CNO)',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CNORPN';
INSERT INTO `LookupListItem` VALUES (\N,(select id from LookupList where name = 'practitionerNoType'),'CMO','College of Midwives of Ontario',3,1,'oscar',now()) ON DUPLICATE KEY UPDATE value='CMO';

-- for update-2018-10-02.sql see procedure above

-- for update-2018-11-11.sql 
INSERT INTO `secObjectName` (`objectName`, `description`, `orgapplicable`) VALUES ('_dashboardChgUser','security object for changing dashboard user', 0) ON DUPLICATE KEY UPDATE objectName='_dashboardChgUser' ;



