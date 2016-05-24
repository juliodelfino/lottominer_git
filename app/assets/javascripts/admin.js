$(document).ready(function() {

    var table = null;
	initDbTable();



	$('<button id="refresh">Refresh</button>').appendTo('div.dataTables_filter');

	$('#refresh').click(function() {
		table.ajax.reload();
	});
	
	$('#table_name').change(function(){
		$('#dynamic-content').load('/admin/get_db_table?table=' + $(this).val(), function(){
			initDbTable();
		});
	});

	function row_delete(id, tblRow) {
		$.ajax({
			url : "/admin/ajax_delete_row?id="+id + "&table=" + $('#table_name').val()
		}).done(function(data) {
			//table.ajax.reload();
			tblRow.remove().draw();
		});
	}
	
	function initDbTable() {
		
		var dbtable_url = "/admin/ajax_get_results?table=" + $('#table_name').val();
	  	$.get(dbtable_url, function(result){
	  		
	  		delete_link = '<a href="" class="row_delete">Delete</a>';
	  	    result.columns.push({title: 'Actions'});
	  		for (idx in result.data) {
	  			result.data[idx].push(delete_link);
	  		}
	  		table = $('#admin_tbl').DataTable({
	  			
			//	ajax : dbtable_url,
	  			destroy: true,
				columns: result.columns,
				data: result.data
			});
			

			table.on('click', 'a.row_delete', function(e) {
				e.preventDefault();
				tblRow = table.row($(this).closest('tr'));
				rowData = tblRow.data();
				row_delete(rowData[0], tblRow);
			});
	  	});
	}
	
	$('#get-latest-btn').click(function(){
		$('#dynamic-results-content').load('/task/get_daily_results?callid=adminweb');
	});
});
