$(function () {
  $("#registration-arrival-datepicker").datetimepicker({
      pickTime: true,
      useCurrent: false,
      minuteStepping: 15,
      sideBySide: true,
      format: "YYYY-MM-DD HH:mm"
  });
  $("#registration-departure-datepicker").datetimepicker({
      pickTime: true,
      useCurrent: false,
      minuteStepping: 15,
      sideBySide: true,
      format: "YYYY-MM-DD HH:mm"
  });
  $("#registration-arrival-datepicker").on("dp.change",function (e) {
      console.log (e.date)
      $('#registration-departure-datepicker').data("DateTimePicker").setDate(e.date);
      $('#registration-departure-datepicker').data("DateTimePicker").setMinDate(e.date);
  });
  $("#conference-end-datepicker").on("dp.change",function (e) {
      $('#registration-arrival-datepicker').data("DateTimePicker").setMaxDate(e.date);
  });


  $("#conference-start-datepicker").datetimepicker({
      pickTime: false,
      useCurrent: false,
      format: "YYYY-MM-DD"
  });
  $("#conference-end-datepicker").datetimepicker({
      pickTime: false,
      useCurrent: false,
      format: "YYYY-MM-DD"
  });
  $("#conference-start-datepicker").on("dp.change",function (e) {
      console.log (e.date)
      $('#conference-end-datepicker').data("DateTimePicker").setDate(e.date);
      $('#conference-end-datepicker').data("DateTimePicker").setMinDate(e.date);
  });
  $("#conference-end-datepicker").on("dp.change",function (e) {
      $('#conference-start-datepicker').data("DateTimePicker").setMaxDate(e.date);
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
  $("#registration-period-start-datepicker").on("dp.change",function (e) {
      console.log (e.date)
      $('#registration-period-end-datepicker').data("DateTimePicker").setDate(e.date);
      $('#registration-period-end-datepicker').data("DateTimePicker").setMinDate(e.date);
  });
  $("#registration-period-end-datepicker").on("dp.change",function (e) {
      $('#registration-period-start-datepicker').data("DateTimePicker").setMaxDate(e.date);
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
