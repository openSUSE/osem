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
       format: "YYYY-MM-DD"
   });

   $("#conference-end-datepicker").datetimepicker({
       useCurrent: false,
       format: "YYYY-MM-DD"
   });

   // start_registration <= end_registration <= end_conference
   var end_conference = $('form').data('end-conference');

   $('#registration-period-start-datepicker').datetimepicker({
       format: 'YYYY-MM-DD',
       maxDate : end_conference
   });

   $('#registration-period-end-datepicker').datetimepicker({
       format: 'YYYY-MM-DD',
       maxDate : end_conference
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

  $("#registration-period-start-datepicker").on("dp.change",function (e) {
      $('#registration-period-end-datepicker').data("DateTimePicker").minDate(e.date);
      if (!$('#registration-period-end-datepicker').val()) {
         $('#registration-period-end-datepicker').data("DateTimePicker").date(e.date);
      }
  });
  $("#registration-period-end-datepicker").on("dp.change",function (e) {
      $('#registration-period-start-datepicker').data("DateTimePicker").maxDate(e.date);
  });
} );
