$(document).ready(function() {

	create_graph();

	$('#submit').click(function() {

		var input = $("<input>").attr("type", "hidden").attr("name", "range").val("update");
		$('#updatePredictionRange').append($(input));
		$('#updatePredictionRange').submit();
	});


	//If it's updates (when prediction is clicked), rerun the perl information, pass up and replot
	//if this doesnt work, just set a HUGE static number for the SQL statement, and append as selected in JS

});

function create_graph(){
	var datac = parse_table($('#cowmoo').text());
	var ctx = $("#myChart").get(0).getContext("2d");
	var data = {
	labels : datac.xhist,//Delete
	datasets : [
		{
			fillColor : "rgba(220,220,220,0.5)",
			strokeColor : "rgba(220,220,220,1)",
			pointColor : "rgba(220,220,220,1)",
			pointStrokeColor : "#fff",
			data : datac.yhist//[65,59,90,81,56,55,40]//Replace with data.yhist;
		 }//,
		// {
		// 	fillColor : "rgba(151,187,205,0.5)",
		// 	strokeColor : "rgba(151,187,205,1)",
		// 	pointColor : "rgba(151,187,205,1)",
		// 	pointStrokeColor : "#fff",
		// 	data : datac.yfut//[28,48,40,19,96,27,100]//Replace with data.yfut;
		// }
	]
};
var options = {
				
	//Boolean - If we show the scale above the chart data			
	scaleOverlay : false,
	
	//Boolean - If we want to override with a hard coded scale
	scaleOverride : false,
	
	//** Required if scaleOverride is true **
	//Number - The number of steps in a hard coded scale
	scaleSteps : null,
	//Number - The value jump in the hard coded scale
	scaleStepWidth : null,
	//Number - The scale starting value
	scaleStartValue : null,

	//String - Colour of the scale line	
	scaleLineColor : "rgba(0,0,0,.1)",
	
	//Number - Pixel width of the scale line	
	scaleLineWidth : 1,

	//Boolean - Whether to show labels on the scale	
	scaleShowLabels : true,
	
	//Interpolated JS string - can access value
	scaleLabel : "<%=value%>",
	
	//String - Scale label font declaration for the scale label
	scaleFontFamily : "'Arial'",
	
	//Number - Scale label font size in pixels	
	scaleFontSize : 12,
	
	//String - Scale label font weight style	
	scaleFontStyle : "normal",
	
	//String - Scale label font colour	
	scaleFontColor : "#666",	
	
	///Boolean - Whether grid lines are shown across the chart
	scaleShowGridLines : true,
	
	//String - Colour of the grid lines
	scaleGridLineColor : "rgba(0,0,0,.05)",
	
	//Number - Width of the grid lines
	scaleGridLineWidth : 1,	
	
	//Boolean - Whether the line is curved between points
	bezierCurve : true,
	
	//Boolean - Whether to show a dot for each point
	pointDot : true,
	
	//Number - Radius of each point dot in pixels
	pointDotRadius : 3,
	
	//Number - Pixel width of point dot stroke
	pointDotStrokeWidth : 1,
	
	//Boolean - Whether to show a stroke for datasets
	datasetStroke : true,
	
	//Number - Pixel width of dataset stroke
	datasetStrokeWidth : 2,
	
	//Boolean - Whether to fill the dataset with a colour
	datasetFill : true,
	
	//Boolean - Whether to animate the chart
	animation : false,

	//Number - Number of animation steps
	animationSteps : 60,
	
	//String - Animation easing effect
	animationEasing : "easeOutQuart",

	//Function - Fires when the animation is complete
	onAnimationComplete : null
	
};
	var theChart = new Chart(ctx).Line(data,options);
}
	


function parse_table(text) {
	
	var rows = text.split('\n');
	
	len_ = rows.length;
	
	x_vals_history = [];
	y_vals_history = [];
	x_vals_future = [];
	y_vals_future = [];
	
	for (r in rows) {
			curRow = rows[r];
			elems = curRow.split('\t');
			if (Number(elems[1]) == 0) {
				x_vals_future.push(Number(elems[0]));
				y_vals_future.push(Number(elems[2]));
			} else {
				x_vals_history.push(Number(elems[0]));
				y_vals_history.push(Number(elems[1]));
			}
	}
	x_vals_history.pop();
	y_vals_history.pop();
	
	return {
		xhist: x_vals_history,
		yhist: y_vals_history,
		xfut: x_vals_future,
		yfut: y_vals_future

	};
}