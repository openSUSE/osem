$(function () {
  $(document).ready(function() {
    $('.datatable').DataTable({
      // ajax: ...,
      stateSave: true,
      autoWidth: false,
      pagingType: 'full_numbers',
      "lengthMenu": [[25, 50, 100, -1], [25, 50, 100, "All"]]
    });

    $('#versionstable').DataTable({
      pagingType: 'full_numbers',
      order: [[ 0, 'desc' ]]
    });
  });
});


