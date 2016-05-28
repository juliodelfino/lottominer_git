
$(document).ready(function() {

	var add_number_form_loaded = false;
	var selected_user_num;
	var add_number_dialog = $( "#add_number_dialog" ).dialog({
      autoOpen: false,
      height: 300,
      width: 340,
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
          
          add_number_dialog.dialog( "close" );
        }},
        { text: "Cancel",
          'class': 'btn',
          click: function() {
          add_number_dialog.dialog( "close" );
        }
      }]
    });
    
	$('#add_number_btn').click(function() {
		
		if (!add_number_form_loaded) {
			var url = '/dashboard/get_add_number_form';
			$('#dialog-content').load(url, function(){
				initMultipleValueInputField('#add-number-multi-input', function(text){
					$('#numbers').val(text);
				});
				add_number_dialog.dialog( "open" );
			});
			
			add_number_form_loaded = true;
		} else {		
			add_number_dialog.dialog( "open" );
		}
	});
    
    $( "#details_dialog" ).dialog({
      autoOpen: false,
      height: +$("#details_dialog").css('height').replace('px', ''),
      width: +$("#details_dialog").css('width').replace('px', ''),
      modal: true,
      buttons: [{ text: "OK",
          'class': 'btn btn-primary',
          click: function() {
          $( "#details_dialog" ).dialog( "close" );
        }
      }]
    });
	
	$('.details-btn').click(function(){
		var numbers = selected_num_link.attr('data-numbers');
		var game_id = selected_num_link.attr('data-game-id');
		var url = '/dashboard/get_number_details';
		
			$.get( url, {game_id: game_id, numbers: numbers} )
			  .done(function( data ) {
			  	var container = $('#details-content');
			    container.empty();
			    container.append( data );
				$( "#details_dialog" ).dialog( "open" );
			  });

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
	
	
	//Number Search START	
	$('#add-result-to-user-num-btn').click(function(){
		var num_id = selected_num_link.attr('id').replace('result-', '');
		var ajaxReq = $.post( "/dashboard/ajax_copy_result_to_user_number", 
          	{ lotto_result_id: num_id } )
          	.done(function(){
          		window.location.reload();
          	});
	});
	
	var num_search_ctx_menu = $('#num-search-context-menu');
	
	$('#search-num-box').on('input', function(){
		$('#results').load('/dashboard/search_number?q=' + $(this).val(), initNumSearchMenu);
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
	
	initMultipleValueInputField('#search-num-multi-input', function(text){
		
		$('#results').load('/dashboard/search_number?q=' + text, initNumSearchMenu);
	});
	
	
	function invokeOnChange(inputId, onChange) {
		var txt = '';
		//join all boxed inputs into one text, separated by dashes
		$(inputId + ' ul li div').each(function(){txt += $(this).html() + "-";});
		if (onChange != null) {
			onChange(txt);
		}
	}
	
	
    function initMultipleValueInputField(inputId, onChange) {
    	
		$(inputId).on('click', function(){
            $(this).find('input:text').focus();
        });
        $(inputId + ' ul input:text').on('input propertychange', function(){
            $(this).siblings('span.input_hidden').text($(this).val());
            var inputWidth = $(this).siblings('span.input_hidden').width();
            $(this).width(inputWidth);
        });
        $(inputId + ' ul input:text').on('keypress', function(event){
        	
            if(event.which == 32 || event.which == 44 || event.which == 45 || event.which == 13){ //space, comma, dash, enter
                var toAppend = $(this).val();
                if(toAppend!=''){
                    $('<li><div>'+toAppend+'</div><a href="#" class="text-muted">×</a></li>').insertBefore($(this));
                    $(this).val('');
                    invokeOnChange(inputId, onChange);
                } else {
                    return false;
                }
                return false;
            } else if (event.which < 48 || event.which > 57) {
            	return false;
            } else {
            	var toAppend = $(this).val();
                if(toAppend.length >= 2){
                    $('<li><div>'+toAppend+'</div><a href="#" class="text-muted">×</a></li>').insertBefore($(this));
                    $(this).val('');
                    invokeOnChange(inputId, onChange);
                }
            }
        	
        	
        });
        $(inputId + ' ul input:text').on('keydown', function(event){
        	
 			if (event.which == 8) {
            	if ($(this).val() == "") {
		        	lastLi = $(inputId + ' ul li:last');
		            if (lastLi != null) {
		            	lastLi.detach();
                    invokeOnChange(inputId, onChange);
		            }
		        }
		        return true;
            }
           
        });
        $(document).on('click', inputId + ' ul li a', function(e){
            e.preventDefault();
            $(this).parents('li').remove();
        });
    }
});
