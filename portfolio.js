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
		var input = $("<input>").attr("type", "hidden").attr("name", "type").val("deposit");
		$('#cashAcctMovements').append($(input));
		$('#cashAcctMovements').submit();
	});
	$('#withdrawBtn').click(function() {
		var input = $("<input>").attr("type", "hidden").attr("name", "type").val("withdraw");
		$('#cashAcctMovements').append($(input));
		$('#cashAcctMovements').submit();
	});
	
	$('#viewListOfStocksBtn').click(function() {
		$('#viewStockListForm').submit();
	});
	
	$('.headerRow').click(function() {
		$(this).next().toggleClass('hide');
	});
});
