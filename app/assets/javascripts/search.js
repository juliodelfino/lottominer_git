
$(document).ready(function() {
  
    //Number Search START   
    $('#add-result-to-user-num-btn').click(function(){
        var num_id = selected_num_link.attr('id').replace('result-', '');
        var ajaxReq = $.post( "/dashboard/ajax_copy_result_to_user_number", 
            { lotto_result_id: num_id } )
            .done(function(){
                $('#notif').show();
                //window.location.reload();
            });
    });
    
    var num_search_ctx_menu = $('#num-search-context-menu');
    
/*  $('#search-num-box').on('input', function(){
        $('#results').load('/dashboard/search_number?q=' + $(this).val(), initNumSearchMenu);
    });
*/
    function initNumSearchMenu() {
        
        $('#load-icon').hide();
        $(".lotto-num-menu").click(function(){
            
            if (selected_num_link == null || $(this).attr('id') != selected_num_link.attr('id')) {

                selected_num_link = $(this);
                //move context menu just next to the selected link, not put inside it
                $(this).after(num_search_ctx_menu.detach());
            }
        });
    }
    
    initMultipleValueInputField('#search-num-multi-input', function(text){
        
        $('#results').after(num_search_ctx_menu);
        $('#load-icon').show();
        $('#results').load('/dashboard/search_number?q=' + text, initNumSearchMenu);
    });
    
    
    
    function initMultipleValueInputField(inputId, onChange) {
        
        $(inputId).on('click', function(){
            $(this).find('input:text').focus();
        });
        $(inputId + ' ul input:text').on('input propertychange', function(){
            $(this).siblings('span.input_hidden').text($(this).val());
            var inputWidth = $(this).siblings('span.input_hidden').width();
            $(this).width(inputWidth + 5);
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
    
    function invokeOnChange(inputId, onChange) {
        var txt = '';
        //join all boxed inputs into one text, separated by dashes
        $(inputId + ' ul li div').each(function(){txt += $(this).html() + "-";});
        if (onChange != null) {
            onChange(txt);
        }
    }
    
});
