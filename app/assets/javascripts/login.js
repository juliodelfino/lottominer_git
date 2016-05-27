$(document).ready(function() {

	$('#user-register-form').validate({
		rules : {
			'user[email]' : {
				required : true,
				email : true
			},
			'user[name]' : {
				minlength : 3,
				maxlength : 64,
				required : true
			}
		},
		highlight : function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
		},
		unhighlight : function(element) {
			$(element).closest('.form-group').removeClass('has-error').addClass('has-success');
		},
		errorElement : 'span',
		errorClass : 'help-block',
		errorPlacement : function(error, element) {
			if (element.length) {
				error.insertAfter(element);
			} else {
				error.insertAfter(element);
			}
		}
	});

});
