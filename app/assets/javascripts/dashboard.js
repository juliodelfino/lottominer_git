
$(document).ready(function() {

	dialog = $( "#add_number_form" ).dialog({
      autoOpen: false,
      height: 300,
      width: 350,
      modal: true,
      buttons: {
        "Add": function(){
          dialog.dialog( "close" );
        },
        Cancel: function() {
          dialog.dialog( "close" );
        }
      },
      open: function() {
        $(this).load('/dashboard/get_add_number_form');
      },
      close: function() {
      }
    });
    
	$('#add_number_btn').click(function() {
		dialog.dialog( "open" );
	});

});
