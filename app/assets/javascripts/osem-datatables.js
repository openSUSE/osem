$(function () {
  $(document).ready(function() {
    $('.datatable').DataTable({
      // ajax: ...,
      autoWidth: false,
      pagingType: 'full_numbers',
      "lengthMenu": [[25, 50, 100, -1], [25, 50, 100, "All"]]
    });
  });
});


