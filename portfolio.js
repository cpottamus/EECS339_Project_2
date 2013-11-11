$(document).ready(function() {
	$('#loginBtn').click(function() {
		$('#loginForm').submit();
	});
	
	$('#logoutBtn').click(function() {
		$('#logoutForm').submit();
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
});
