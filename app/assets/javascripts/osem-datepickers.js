// get current_date
var today = new Date().toISOString().slice(0, 10);
$(function () {
  $("#registration-arrival-datepicker").datetimepicker({
      pickTime: true,
      useCurrent: false,
      minuteStepping: 15,
      sideBySide: true,
      format: "YYYY-MM-DD HH:mm",
      // current_date <= arrival_date <= end_date
      maxDate : $("#registration-arrival-datepicker").attr('end_date'),
      minDate : today,
      defaultDate :   $("#registration-arrival-datepicker").attr('start_date'),
  });
  $("#registration-departure-datepicker").datetimepicker({
      pickTime: true,
      useCurrent: false,
      minuteStepping: 15,
      sideBySide: true,
      format: "YYYY-MM-DD HH:mm",
      // departure_date > start_date
      minDate : $("#registration-arrival-datepicker").attr('start_date'),
      defaultDate :   $("#registration-arrival-datepicker").attr('end_date'),
  });

  $("#registration-arrival-datepicker").on("dp.change",function (e) {
    //   $('#registration-departure-datepicker').data("DateTimePicker").setDate(e.date);
    // console.log(new Date(e.date).getTime() ,new Date($("#registration-arrival-datepicker").attr('start_date')).getTime())

    // departure_date > start_date,arrival_date
    if ((new Date(e.date).getTime()) > (new Date($("#registration-arrival-datepicker").attr('start_date')).getTime())){
            // console.log (e.date, "arrival")
          $('#registration-departure-datepicker').data("DateTimePicker").setMinDate(e.date);
    }
    else{
        //   console.log ($("#registration-arrival-datepicker").attr('start_date'),"start_date")
        $('#registration-departure-datepicker').data("DateTimePicker").setMinDate($("#registration-arrival-datepicker").attr('start_date'));
    }

  });
  
  $("#conference-end-datepicker").on("dp.change",function (e) {
      $('#registration-arrival-datepicker').data("DateTimePicker").setMaxDate(e.date);
  });


  const $datetimepickers = $("#conference-start-datepicker, #conference-end-datepicker, #registration-period-start-datepicker, #registration-period-end-datepicker");

  $datetimepickers.datetimepicker({
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
