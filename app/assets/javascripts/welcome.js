$(document).ready(function() {

	var lottoDate = $("#datepicker").datepicker({
      showOn: "button",
      buttonImage: "assets/images/calendar.gif",
      buttonImageOnly: true,
      buttonText: "Select date",
      dateFormat: 'yymmdd',
      defaultDate: getParameterByName('date') != null ? getParameterByName('date') : new Date(),
      onSelect: function(date) {
      	window.location = '?date=' + date;
      }
    });
});
