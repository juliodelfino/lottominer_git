$(document).ready(function() {

	var table = $('#admin_tbl').DataTable({
		ajax : "/admin/ajax_get_results",
		columns : [{
			data : 0
		}, {
			data : 1
		}, {
			data : 2
		}, {
			data : 3
		}, {
			data : 4
		}, {
			data : null,
			defaultContent : '<a href="" class="row_delete">Delete</a>'
		}]
	});

	table.on('click', 'a.row_delete', function(e) {
		e.preventDefault();
		rowData = table.row($(this).closest('tr')).data();
		row_delete(rowData[0]);
	});

	$('<button id="refresh">Refresh</button>').appendTo('div.dataTables_filter');

	$('#refresh').click(function() {
		table.ajax.reload();
	});

	function row_delete(id) {
		$.ajax({
			url : "/admin/ajax_delete_row?id="+id
		}).done(function(data) {
			table.ajax.reload();
		});
	}
});
