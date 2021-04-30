$( document ).ready(function() {
    let calendarEl = document.getElementById('vert-schedule-full-calendar');
    if (!calendarEl) return; //check that we need a vertical schedule
    let fullcalData = $('#fullcalendar');

    var calendar = new FullCalendar.Calendar(calendarEl, {
      allDaySlot: false,
      timeZone: 'UTC', // TODO: Events are stored in conference's timezone implicitly (UTC+0) in the database 
      initialDate: fullcalData.data('day'),
      initialView: 'resourceTimeGridDay',
      resources: fullcalData.data('rooms'),
      events: fullcalData.data('events')
    });

    calendar.render();
});
