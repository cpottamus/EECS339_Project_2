$(document).ready(function() {
	$('#loginBtn').click(function() {
		$('#loginForm').submit();
	});
	
	$('#logoutBtn').click(function() {
		$('#logoutForm').submit();
	});
	
	$('#toRegisterBtn').click(function(event) {
		event.preventDefault();
		$('#toRegisterForm').submit();
	});
	
	$('#depositBtn').click(function() {
		var s = $('#moo option:selected').text();
		var cow = $("<input>").attr("type", "hidden").attr("name", "otherAcct").val(s);
		var input = $("<input>").attr("type", "hidden").attr("name", "type").val("deposit");
		$('#cashAcctMovements').append($(input));
		$('#cashAcctMovements').append($(cow));
		$('#cashAcctMovements').submit();
	});
	$('#withdrawBtn').click(function() {
		var s = $('#moo option:selected').text();
		var cow = $("<input>").attr("type", "hidden").attr("name", "otherAcct").val(s);
		var input = $("<input>").attr("type", "hidden").attr("name", "type").val("withdraw");
		$('#cashAcctMovements').append($(input));
		$('#cashAcctMovements').append($(cow));
		$('#cashAcctMovements').submit();
	});
	
	$('#viewListOfStocksBtn').click(function() {
		$('#viewStockListForm').submit();
	});
	
	$('.headerRow').click(function() {
		$(this).next().toggleClass('hide');
	});
	
	$('#buyStockBtn').click(function() {
		var input = $("<input>").attr("type", "hidden").attr("name", "type").val("buy");
		$('#buyOrSellStockForm').append($(input));
		$('#buyOrSellStockForm').submit();
	});
	$('#sellStockBtn').click(function() {
		var input = $("<input>").attr("type", "hidden").attr("name", "type").val("sell");
		$('#buyOrSellStockForm').append($(input));
		$('#buyOrSellStockForm').submit();
	});
});

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
	
}
