//navlist
jQuery(document).ready(function(){
	var hide_ConReport = jQuery("#mainScript").attr('hide_ConReport') == "true";
	if (!hide_ConReport) {
		jQuery("<li><a href=\"#\" onclick=\"popupOscarRx(625,1024,'../eyeform/ConsultationReportList.do\');\" title\"View Consultation Reports\">ConReport</a></li>").insertAfter("#con");
	}
});
