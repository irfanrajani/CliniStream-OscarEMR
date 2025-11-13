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

var jqplotOptions;
var jqplotOptionsBar;

var placeHolderCount = 0;
var indicatorPanels = [];

$(document).ready( function() {
	
	jqplotOptions = {		
			title: ' ',
			seriesDefaults: {
				shadow: false, 
				renderer: $.jqplot.PieRenderer, 
				rendererOptions: { 
					startAngle: 180, 
					sliceMargin: 4, 
					showDataLabels: true,
					dataLabels: 'value',
					dataLabelThreshold: 0
				}
			},
			grid: {
			    drawGridLines: false,        	// wether to draw lines across the grid or not.
			        gridLineColor: '#cccccc',   // CSS color spec of the grid lines.
			        background: 'white',      	// CSS color spec for background color of grid.
			        borderColor: 'white',     	// CSS color spec for border around grid.
			        borderWidth: 0,           	// pixel width of border around grid.
			        shadow: false,              // draw a shadow for grid.
			        shadowAngle: 0,            	// angle of the shadow.  Clockwise from x axis.
			        shadowOffset: 0,          	// offset from the line of the shadow.
			        shadowWidth: 0,             // width of the stroke for the shadow.
			        shadowDepth: 0
			},
			legend: { show:true, location: 's' }
			
		};
	
	jqplotOptionsBar = {		
			title: ' ',
			seriesDefaults: {
				renderer: $.jqplot.BarRenderer, 
				 pointLabels: { show: false }, 
			     showLabel: true,
			     rendererOptions: { varyBarColor : true },
				
			},
			legend: {
				 show: true,
		            placement: 'outsideGrid',
		            location: 's',
		          //  labels: ticks
	        },
			highlighter:{
		        show:true,
		        tooltipContentEditor:tooltipContentEditor
		    },
	        axesDefaults: {
	        	showLabel:false,
	        	 showTickMarks:false,
	        	 showTicks:false,
	        	 show:false,
	        	 showTicks: false
	        },
			 axes: {
				 xaxis: {
	                    renderer: $.jqplot.CategoryAxisRenderer,
	                    showLabel:false,
	                    show:false
	                },
	                yaxis : {
	                	showLabel:true,
	   	        	 showTickMarks:false,
	   	        	 showTicks:true,
	   	        	 min:0
	                }
	            },
	            
		};
	
	function tooltipContentEditor(str, seriesIndex, pointIndex, plot) {
	    // display series_label, x-axis_tick, y-axis value
		//console.log(JSON.stringify(plot.data[seriesIndex][pointIndex]));
		//return plot.series[seriesIndex]["label"] + ", " + plot.data[seriesIndex][pointIndex];
		return plot.data[seriesIndex][pointIndex][0];
	}
	
	// get the drill down page
	$(".indicatorWrapper").on('click', ".indicatorDrilldownBtn", function(event) {
    	event.preventDefault();
    	var url = "/web/dashboard/display/DrilldownDisplay.do";
    	var data = new Object();
    	data.indicatorTemplateId = (this.id).split("_")[1];
    	data.method = (this.id).split("_")[0];  

    	sendData(url, data, null);
    });

	$(".indicatorWrapper").on("click", ".indicatorGraph", function(event) {
		event.preventDefault();
		var url = "/web/dashboard/display/DrilldownDisplay.do";
		var data = new Object();
		data.indicatorTemplateId = (this.id).split("_")[1];
		data.method = "getDrilldown";

		sendData(url, data, null);
	});

	// get the dashboard manager page
	$(".dashboardManagerBtn").on('click', function(event) {
    	event.preventDefault();
    	var url = "/web/dashboard/admin/DashboardManager.do";
    	var data = "dashboardId=" + this.id; 
    	sendData(url, data, null);
    });
	
	// reload this dashboard with fresh data.
	$(".reloadDashboardBtn").on('click', function(event) {
    	event.preventDefault();
    	var url = "/web/dashboard/display/DashboardDisplay.do";
    	var data = new Object();
    	data.dashboardId = (this.id).split("_")[1];
    	data.method = (this.id).split("_")[0]; 
    	
    	sendData(url, data, null);
    });
	
	$(".indicatorWrapper").each(function(){	
		var data = new Object();
		data.method = "getIndicator";
		data.indicatorId = this.id.split("_")[1];

		sendData("/web/dashboard/display/DisplayIndicator.do", data, this.id.split("_")[0]);
	});
	
	$(".indicatorWrapper").on('click', ".reloadIndicatorBtn", function(event) {
    	event.preventDefault();
    	
    	$("#indicatorId_" + this.id.split("_")[1]).html("<div><span class=\"glyphicon glyphicon-refresh glyphicon-refresh-animate\"></span>Loading...</div>");
    	
    	var data = new Object();
		data.method = "getIndicator";
		data.indicatorId = this.id.split("_")[1];

		sendData("/web/dashboard/display/DisplayIndicator.do", data, "indicatorId");
    });
	
	$(".indicatorWrapper").on('click', ".disableReloadIndicatorBtn", function(event) {
    	event.preventDefault();
    	
    	
    	var hasClass = $("#indicatorId_" +  this.id.split("_")[1]).hasClass('disableRefresh');
    	if(!hasClass) {
    		$("#indicatorId_" +  this.id.split("_")[1]).addClass('disableRefresh');
    		$("#disableReloadIndicator_" + this.id.split("_")[1]).css('color','red');
    	} else {
    		$("#indicatorId_" +  this.id.split("_")[1]).removeClass('disableRefresh');
    		$("#disableReloadIndicator_" + this.id.split("_")[1]).css('color','rgb(42, 100, 150)');
    		
    	}
    });
	
	
	placeHolderCount = $(".indicatorWrapper").length;

	
	
	$(".indicatorWrapper").on("click", ".indicatorTrendBtn", function(event) {
		event.preventDefault();
		console.log('trend going modal '  + (this.id).split("_")[1]);
		
		window.open('indicatorTrend.jsp?providerNo=' + $("#providerNo").val() + "&indicatorTemplateId=" + (this.id).split("_")[1],'trending','toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=900px,height=500px');
		
	});

	
	
})

// build Indicator panel with Pie chart.
function buildIndicatorPanel( html, target, id ) {
	
	let indicatorGraph;
	
	if ( indicatorGraph ) {
		indicatorGraph.destroy();
	}
	
	let panel = $( "#" + target + "_" + id ).html( html ); //.append("<h3>" +id+ "</h3>");
	let data = "[" + panel.find( "#graphPlots_" + id ).val() + "]";
	data = data.replace(/'/g, '"');
	data = JSON.parse( data )
	
	let labels = "[" + panel.find( "#graphLabels_" + id ).val() + "]";
	labels = labels.replace(/'/g, '"');
	labels = JSON.parse( labels )
	
	
	let graphType = panel.find( "#graphType_" + id ).val();
	
	console.log('plot data = ' + "[" + panel.find( "#graphPlots_" + id ).val() + "]");
	if(graphType === 'bar') {
		//need to massage the data variable
		//var data =  [[['% Smokers',1.0],['% Not documented',0.0],['% Non-smokers',1.0]],[],[]];
		//var data =  [[1.0,0.0,1.0],[],[]];
		
		var newData = [];
		
		var ticks = [];
		var d1 = data[0];
		for(var x=0;x<d1.length;x++) {
			console.log('element ' + x + ' -> ' + d1[x]);
			ticks[x] = d1[x][0];
			newData[x] = d1[x][1];
		}
		
		var newData2 = [];
		newData2[0] = newData;
		for(var x=0;x<d1.length-1;x++) {
			newData2[x+1] = [];
		}
		
		jqplotOptionsBar.series = [];
		jqplotOptionsBar.series[0] = {};
		for(var x=0;x<d1.length;x++) {
			jqplotOptionsBar.series[x+1] =  {renderer: $.jqplot.LineRenderer};
		}
		jqplotOptionsBar.legend.labels = ticks;
		
		
		indicatorGraph = $.jqplot ( 'graphContainer_' + id, newData2, jqplotOptionsBar ).replot();
	} else if(graphType === 'pie') {
		indicatorGraph = $.jqplot ( 'graphContainer_' + id, data, jqplotOptions ).replot();
	} else if(graphType === 'table') {
		var tableHtml = '<table class="table">';
		var d1 = data[0];
		for(var x=0;x<d1.length;x++) {
			tableHtml += "<tr><td>"+d1[x][0]+"</td><td>"+d1[x][1]+"</td></tr>";
		}
		tableHtml += "</table>";
		$('#graphContainer_' + id).html(tableHtml);
		console.log('table rendering not yet implemented');
	} else if(graphType === 'stacked') {
		console.log('stacked bar graph type not yet implemented');
	}
	
	window.onresize = function(event) {
		indicatorGraph.replot();
	}
	
	var name = panel.find( ".indicatorHeading div" ).text();
	
	var paneldata = [ name, id, data ];
	
	if( paneldata ) {
		indicatorPanels.push( paneldata );
	}

	if( indicatorPanels.length === placeHolderCount ) {

		let panelList;
		
		for(let i = 0; i < indicatorPanels.length; i++ ) {
			let ipanel = indicatorPanels[i];
			let name, id, data;

			if( ipanel ) {
				name = ipanel[0].trim();
				id = ipanel[1];
				data = ipanel[2];
				panelList += ( "NAME " + name + ", ID " + id + "\n " + "  DATA " + data + "\n" ); 
			}

		}		
		return panelList;
	} 
}

function sendData(path, param, target) {
	$.ajax({
		url: ctx + path,
	    type: 'POST',
	    data: param,
	  	dataType: 'html',
	    success: function(data) {	    	
	    	if( target === "indicatorId") {
	    		var panelList = buildIndicatorPanel( data, target, param.indicatorId );
	    		if( panelList ) {
	    			console.log( panelList );
	    		}
	    	} else {
		    	document.open();
		    	document.write(data);
		    	document.close();	    		
	    	}
	    }
	});
}

function setupRefreshIndicators(numMinutes) {
	//will need to eventual exclude some of them.
	console.log('setting up refresh of indicators every ' + numMinutes + " minutes.");
	setInterval(function(){
		refreshIndicators();
	},numMinutes*60*1000);
	
}

function refreshIndicators() {
	console.log('refreshing indicators ' + new Date().toString());
	//loop through all indicators...is it disabled?..refresh it
	$(".indicatorWrapper").each(function(){	
		var hasClass = $("#indicatorId_" +  this.id.split("_")[1]).hasClass('disableRefresh');
		if(hasClass) {
			//console.log('skipping' + this.id + " because it's refresh is disabled");
			return;
		}
		//console.log('refreshing indicator' + this.id);
		var data = new Object();
		data.method = "getIndicator";
		data.indicatorId = this.id.split("_")[1];

		sendData("/web/dashboard/display/DisplayIndicator.do", data, "indicatorId");
	});
	
}
