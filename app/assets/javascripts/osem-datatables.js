$(function () {
  $.extend(true, $.fn.dataTable.defaults, {
    "buttons": ["csv"],
    "dom": "lBfrtip",
    "stateSave": true,
    "autoWidth": false,
    "pagingType": "full_numbers",
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
  });

  $('.datatable:not([data-source])').DataTable();

  $('.datatable').on('init.dt', function (e, settings, json) {
    var datatableApi = $(this).dataTable().api();
    // Thanks to cale_b:        https://stackoverflow.com/u/870729
    // Stack Overflow question: https://stackoverflow.com/q/5548893
    // Stack Overflow answer:   https://stackoverflow.com/a/23897722
    // Grab the datatables input box and alter how it is bound to events
    $(".dataTables_filter input")
      .unbind() // Unbind previous default bindings
      .bind("input", function(e) { // Bind our desired behavior
        // If the length is 3 or more characters, or the user pressed ENTER, search
        if(this.value.length >= 3 || e.keyCode == 13) {
          // Call the API search function
          datatableApi.search(this.value).draw();
        }
        // Ensure we clear the search if they backspace far enough
        if(this.value == "") {
          datatableApi.search("").draw();
        }
        return;
      });
  });
});

function truncatify(selector) {
  $(selector).each(function(){
    var text = $(this).text()
    $(this).html('<span data-toggle="tooltip" title="' + text + '">' + text + '</span> ')
  });
}

function iconize(selector, value, icon, title) {
	$(selector).each(function(){
		if ($(this).text() == value) {
			$(this).html("<i class='fa fa-" + icon + "' title='" + title + "'></i>");
		}
	});
}
