$(function () {
  $("#registration-arrival-datepicker").datetimepicker({
      pickTime: true,
      format: "YYYY-MM-DD hh:mm"
  });
  $("#registration-departure-datepicker").datetimepicker({
      pickTime: true,
      format: "YYYY-MM-DD hh:mm"
  });
  $("#conference-start-datepicker").datetimepicker({
      pickTime: false,
      format: "YYYY-MM-DD"
  });
  $("#conference-end-datepicker").datetimepicker({
      pickTime: false,
      format: "YYYY-MM-DD"
  });
  $("#registration-period-start-datepicker").datetimepicker({
      format: "YYYY-MM-DD",
      pickTime: false,
      pickSeconds: false
  });
  $("#registration-period-end-datepicker").datetimepicker({
      format: "YYYY-MM-DD",
      pickTime: false,
      pickSeconds: false
  });
  $(".target-due-date-datepicker").datetimepicker({
      pickTime: false,
      format: "YYYY-MM-DD"
  });
  /* Appends the datetimepicker to new injected nested target fields. */
  $('a:contains("Add target")').click(function () {
      setTimeout(function () {
          $('.target-due-date-datepicker').not('.hasDatepicker').datetimepicker({
              pickTime: false,
              format: "YYYY-MM-DD"
          });
      },
      5)
  });
} );
