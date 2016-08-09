
$(document).ready(function() {

	$('#validate-form').validate({    
    rules: {
        'user[email]': {
            required: true,
            email: true
        },
        'user[name]': {
            minlength: 3,
            maxlength: 64,
            required: true
        }
    },
    highlight: function(element) {
        $(element).closest('.form-group').removeClass('has-success').addClass('has-error');
    },
    unhighlight: function(element) {
        $(element).closest('.form-group').removeClass('has-error').addClass('has-success');
    },
    errorElement: 'span',
        errorClass: 'help-block',
        errorPlacement: function(error, element) {
            if(element.length) {
                error.insertAfter(element);
            } else {
            error.insertAfter(element);
            }
        }
    });
    
    
	$("#validate-form").submit(function( event ) {
		$('.alert').hide();
	 
		// Stop form from submitting normally
		event.preventDefault();
    
    	var settingsForm = $(this);
    	if (!settingsForm.valid()) {
    		return false;
    	}
    	
		$.post(settingsForm.attr('action'), settingsForm.serialize())
		.done(function(){
			$('.alert').show();
		});
	});
  

});
