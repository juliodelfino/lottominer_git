$(document).ready(function() {

	var lottoDate = $("#datepicker").datepicker({
      showOn: "button",
      buttonImage: "assets/images/calendar.gif",
      buttonImageOnly: true,
      buttonText: "Select date",
      dateFormat: 'yymmdd',
      defaultDate: getParameterByName('date') != null ? getParameterByName('date') : new Date(),
      onSelect: function(date) {
      	$("#dynamic-content").load('/welcome/ajax_results?date=' + date);
      }
    });
    
    $('#left-arrow').click(function(){
    	var prevDate = $('#prev-date').val();
      	$("#dynamic-content").load('/welcome/ajax_results?date=' + prevDate);
      	lottoDate.datepicker('option','defaultDate', prevDate);
    });
    
    $('#right-arrow').click(function(){
    	var nextDate = $('#next-date').val();
      	$("#dynamic-content").load('/welcome/ajax_results?date=' + nextDate);
      	lottoDate.datepicker('option','defaultDate', nextDate);
    });
});
