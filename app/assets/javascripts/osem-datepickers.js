// get current_date
var today = new Date().toISOString().slice(0, 10);
$(function () {
  $("input[id^='datetimepicker']").datetimepicker({
    useCurrent: false,
    sideBySide: true,
    format: 'YYYY-MM-DD HH:mm'
  });

  $('.datetimepicker').datetimepicker({
    useCurrent: false,
    sideBySide: true,
    format: 'YYYY-MM-DD HH:mm'
  });

   $("#conference-start-datepicker").datetimepicker({
       useCurrent: false,
       ignoreReadonly: true,
       format: "YYYY-MM-DD",
   });

   $("#conference-end-datepicker").datetimepicker({
       useCurrent: false,
       ignoreReadonly: true,
       format: "YYYY-MM-DD"
   });

  $("#conference-start-datepicker").on("dp.change",function (e) {
      $('#conference-end-datepicker').data("DateTimePicker").minDate(e.date);
      if (!$('#conference-end-datepicker').val()) {
         $('#conference-end-datepicker').data("DateTimePicker").date(e.date);
      }
  });

  $("#conference-start-datepicker").change(function (e) {
      $('#conference-start-datepicker').val()?$('#conference-end-datepicker').data("DateTimePicker").minDate(e.date):$('#conference-end-datepicker').data("DateTimePicker").minDate(null);
  });

  $("#conference-end-datepicker").on("dp.change",function (e) {
      $('#conference-start-datepicker').data("DateTimePicker").maxDate(e.date);
  });

  $("#conference-end-datepicker").change(function (e) {
      $('#conference-end-datepicker').val()?$('#conference-start-datepicker').data("DateTimePicker").maxDate(e.date):$('#conference-start-datepicker').data("DateTimePicker").maxDate(null);
  });

} );
