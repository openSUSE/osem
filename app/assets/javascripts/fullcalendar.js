$( document ).ready(function() {
    let calendarEl = document.getElementById('vert-schedule-full-calendar');
    if (!calendarEl) return; //check that we need a vertical schedule
    let fullcalData = $('#fullcalendar');

    var calendar = new FullCalendar.Calendar(calendarEl, {
      expandRows: true,
      allDaySlot: false,
      slotMinTime: fullcalData.data('startHour') + ':00:00',
      slotMaxTime: fullcalData.data('endHour') + ':00:00',
      timeZone: 'UTC', // TODO: Events are stored in conference's timezone implicitly (UTC+0) in the database 
      initialDate: fullcalData.data('day'),
      initialView: 'resourceTimeGridDay',
      resources: fullcalData.data('rooms'),
      events: fullcalData.data('events')
    });

    calendar.render();
});
