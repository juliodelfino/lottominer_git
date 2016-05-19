
$(document).ready(function() {

	var add_number_form_loaded = false;
	var selected_user_num;
	dialog = $( "#add_number_form" ).dialog({
      autoOpen: false,
      height: 300,
      width: 300,
      modal: true,
      buttons: [{
        text: "Add",
        'class' : 'btn btn-primary',
        click: function(){
          var ajaxReq = $.post( "/dashboard/ajax_add_number", 
          	{ game_id: $('#game_id').val(), numbers: $('#numbers').val() } )
          	.done(function(){
          		window.location.reload();
          	});
          
          dialog.dialog( "close" );
        }},
        { text: "Cancel",
          'class': 'btn',
          click: function() {
          dialog.dialog( "close" );
        }
      }],
      close: function() {
      }
    });
    
	$('#add_number_btn').click(function() {
		
		if (!add_number_form_loaded) {
			var url = '/dashboard/get_add_number_form';
			$('#form-content').load(url, function(){	
				dialog.dialog( "open" );
			});
			
			add_number_form_loaded = true;
		} else {		
			dialog.dialog( "open" );
		}
	});
	
	initUserNumMenu();
	
	$('#remove-num-btn').click(function(){
		var num_id = selected_num_link.attr('id').replace('usernum-', '');
		var ajaxReq = $.post( "/dashboard/ajax_remove_number", 
          	{ id: num_id } )
          	.done(function(){
          		window.location.reload();
          	});
	});
		
	$('#add-result-to-user-num-btn').click(function(){
		var num_id = selected_num_link.attr('id').replace('result-', '');
		var ajaxReq = $.post( "/dashboard/ajax_copy_result_to_user_number", 
          	{ lotto_result_id: num_id } )
          	.done(function(){
          		window.location.reload();
          	});
	});
	
	var user_num_ctx_menu = $('#user-num-context-menu');
	var selected_num_link = null;
	function initUserNumMenu() {
		$(".user-num-menu").click(function(){

			if (selected_num_link == null || $(this).attr('id') != selected_num_link.attr('id')) {

				selected_num_link = $(this);
				//move context menu just next to the selected link, not put inside it
				$(this).after(user_num_ctx_menu.detach());
			}
		});
	}
	
	
	var num_search_ctx_menu = $('#num-search-context-menu');
	
	$('#search-num-box').on('input', function(){
		$('#results').load('/dashboard/search_number?token=' + $(this).val(), initNumSearchMenu);
	});
	
	function initNumSearchMenu() {
		$(".lotto-num-menu").click(function(){
			
			if (selected_num_link == null || $(this).attr('id') != selected_num_link.attr('id')) {

				selected_num_link = $(this);
				//move context menu just next to the selected link, not put inside it
				$(this).after(num_search_ctx_menu.detach());
			}
		});
	}

});
