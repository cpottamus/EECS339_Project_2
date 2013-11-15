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
	new Chart(ctx).Line(data,options);
	var data = {
	labels : ["January","February","March","April","May","June","July"],//Delete
	datasets : [
		{
			fillColor : "rgba(220,220,220,0.5)",
			strokeColor : "rgba(220,220,220,1)",
			pointColor : "rgba(220,220,220,1)",
			pointStrokeColor : "#fff",
			data : datac.yhist//[65,59,90,81,56,55,40]//Replace with data.yhist;
		},
		{
			fillColor : "rgba(151,187,205,0.5)",
			strokeColor : "rgba(151,187,205,1)",
			pointColor : "rgba(151,187,205,1)",
			pointStrokeColor : "#fff",
			data : datac.yfut//[28,48,40,19,96,27,100]//Replace with data.yfut;
		}
	]
}	
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