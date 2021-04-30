$( document ).ready(function() {
    let calendarEl = document.getElementById('vert-schedule-full-calendar');
    if (!calendarEl) return; //check that we need a vertical schedule
    let fullcalData = $('#fullcalendar');

    var calendar = new FullCalendar.Calendar(calendarEl, {
      schedulerLicenseKey: fullcalData.data('schedulerLicenseKey'),
      nowIndicator: true,
      now: fullcalData.data('now'),
      expandRows: true,
      allDaySlot: false,
      slotMinTime: fullcalData.data('startHour') + ':00:00',
      slotMaxTime: fullcalData.data('endHour') + ':00:00',
      validRange: {
        start: fullcalData.data('startDate'),
        end: fullcalData.data('endDate')
      },
      timeZone: fullcalData.data('timezone'),
      initialDate: fullcalData.data('day'),
      initialView: 'resourceTimeGridDay',
      resources: fullcalData.data('rooms'),
      events: fullcalData.data('events')
    });

    calendar.render();
});
