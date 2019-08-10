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

  $("#registration-arrival-datepicker").datetimepicker({
      useCurrent: false,
      stepping: 15,
      sideBySide: true,
      format: "YYYY-MM-DD HH:mm",
      // current_date <= arrival_date <= end_date
      maxDate : $("#registration-arrival-datepicker").attr('end_date'),
      minDate : today
  });

  $("#registration-departure-datepicker").datetimepicker({
      useCurrent: false,
      stepping: 15,
      sideBySide: true,
      format: "YYYY-MM-DD HH:mm",
      // departure_date > start_date
      minDate : $("#registration-arrival-datepicker").attr('start_date')
  });

  $('#invitation-end-date').datetimepicker({
      format: 'YYYY-MM-DD',
      maxDate : $("#invitation-end-date").attr('end_date'),
      minDate : today
   }).keypress(function(event) {event.preventDefault();});

  $("#registration-arrival-datepicker").on("dp.change",function (e) {
      // departure_date > start_date,arrival_date
      if ((new Date(e.date).getTime()) > (new Date($("#registration-arrival-datepicker").attr('start_date')).getTime())){
            $('#registration-departure-datepicker').data("DateTimePicker").minDate(e.date);
      }
      else{
          $('#registration-departure-datepicker').data("DateTimePicker").minDate($("#registration-arrival-datepicker").attr('start_date'));
      }
  });

  // departure_date >= arrival_date
   $("#registration-departure-datepicker").on("dp.change",function (e) {
       $('#registration-arrival-datepicker').data("DateTimePicker").maxDate(e.date);
   });

   $("#conference-start-datepicker").datetimepicker({
       useCurrent: false,
       format: "YYYY-MM-DD",
       // conference-start-day >= Current_date
       minDate : today
   });

   $("#conference-end-datepicker").datetimepicker({
       useCurrent: false,
       format: "YYYY-MM-DD"
   });

   // today <= start_registration <= end_registration <= end_conference
   var end_conference = $('form').data('end-conference');

   $('#registration-period-start-datepicker').datetimepicker({
       format: 'YYYY-MM-DD',
       minDate : today,
       maxDate : end_conference
   });

   $('#registration-period-end-datepicker').datetimepicker({
       format: 'YYYY-MM-DD',
       minDate : today,
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
