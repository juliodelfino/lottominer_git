$(document).ready(function() {

	var lottoDate = $("#datepicker").datepicker({
      changeYear: true,
      yearRange: '2002:present',
      dateFormat: 'yymmdd',
      defaultDate: getParameterByName('date') != null ? getParameterByName('date') : new Date(),
      onSelect: function(date) {
      	queryResultsByDate(date);
      }
    });
    
    $('#cal-btn').click(function(){
    	lottoDate.datepicker('show');
    });
    
    $('#left-arrow').click(function(){
    	var prevDate = $('#prev-date').val();
      	queryResultsByDate(prevDate);
      	lottoDate.datepicker('option','defaultDate', prevDate);
    });
    
    $('#right-arrow').click(function(){
    	var nextDate = $('#next-date').val();
      	queryResultsByDate(nextDate);
      	lottoDate.datepicker('option','defaultDate', nextDate);
    });
    
    function queryResultsByDate(selectedDate) {
    	$('#load-icon').show();
      	$("#dynamic-content").load('/welcome/ajax_results?date=' + selectedDate, function() {
      		$('#load-icon').hide();
      	});
    }
});
