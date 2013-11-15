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
