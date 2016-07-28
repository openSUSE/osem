var conference; // Should be initialize in Schedule.loadEvents
var schedule_id; // Should be initialize in Schedule.loadEvents

var Schedule = {
  loadEvents: function(conference_param, schedule_id_param) {
    conference = conference_param;
    schedule_id = schedule_id_param;
    var url = '/admin/conference/' + conference + '/program/events';
    var callback = function(data) {
        $.each(data, function(key, val) {
            Schedule.newEvent(val);
        });
    };
    $.getJSON(url, callback);
  },
  newEvent: function(vars) {
    var height = (vars["length"] / 15 * 58) - 23; // this height fits the room cells
    var lines = Math.floor((height - 7) / 23); // subtracting the padding before calculate the number of lines
    var newEvent = $('<div class="schedule-event">'
      + '<div class="schedule-event-text" style="-webkit-line-clamp: '+ lines + '; height: ' + (lines * 23) + 'px;">'
      + '<span onclick="Schedule.remove(\'event-' + vars["guid"] + '\', \'' + conference +'\');" class="schedule-event-delete-button">X</span>'
      + vars["title"] + '</div></div>');
    newEvent.attr("id", "event-" + vars["guid"]);
    newEvent.attr("guid", vars["guid"]);
    newEvent.css("height", height);
    newEvent.css('background-color',vars["track_color"]);
    newEvent.css('color',vars["track_text_color"]);
    var date = "none";
    var room = "none"
    var time = "none";
    for (i = 0; i < vars["event_schedules"].length; i++) {
      event_schedule = vars["event_schedules"][i];
      if(event_schedule["schedule_id"] == schedule_id){
        room = event_schedule["room_guid"];
        var d = new Date(event_schedule["start_time"]);
        date =  d.getUTCFullYear() + "-"
            + ('0' + (d.getUTCMonth() +1)).slice(-2) + '-'
            + ('0' + d.getUTCDate()).slice(-2);
        minutes = d.getUTCMinutes();
        time = d.getUTCHours() + ':' + (minutes == 0 ? '00' : minutes);
        console.log("date: " + d);
        newEvent.attr("room", room);
        newEvent.attr("date", date);
        newEvent.attr("hour", time);
      }
    }
    newEvent.draggable({
      snap: '.schedule-room-slot',
      revertDuration: 200,
      revert: function (event, ui) {
          console.log(event.attr);
          return !event;
      },
      stop: function(event, ui) {
          this._originalPosition = this._originalPosition || ui.originalPosition;
          ui.helper.animate( this._originalPosition );
      },
      opacity: 0.7,
      snapMode: "inner",
      zIndex: 2
    });
    if (date == "none" || room == "none") {
      newEvent.find(".schedule-event-delete-button").hide();
      $('.unscheduled-events').append(newEvent);
    } else {
      var element = "[date='" + date +"'][hour='" + time + "'][room-guid='" + room + "']";
      $(element).append(newEvent);
    }
  },
  remove: function(element) {
    var e =  $("#" + element);
    var unscheduled = $(".unscheduled-events");

    var url = '/admin/conference/' + conference + '/schedule/' + schedule_id;
    var params = {
      event: e.attr("guid"),
      room: "none",
      date: "none",
      time: "none",
      schedule: schedule_id
    };
    var callback = function(data) {
      console.log(data);
      e.appendTo(unscheduled);
      e.find(".schedule-event-delete-button").hide();
    }
    $.ajax({
      url: url,
      type: 'PUT',
      data: params,
      success: callback,
      dataType : 'json'
    });
  },
  save: function (event_id, room_id, date, time) {
    var url = '/admin/conference/' + conference + '/schedule/' + schedule_id;;
    var params = {
      event: event_id,
      room: room_id,
      date: date,
      time: time,
      schedule: schedule_id
    };
    var callback = function(data) {
      console.log(data);
      $("#event-" + event_id).find(".schedule-event-delete-button").show();
    }
    $.ajax({
      url: url,
      type: 'PUT',
      data: params,
      success: callback,
      dataType : 'json'
    });
  }
};

$(document).ready( function() {
  $('.schedule-room-slot').droppable({
    accept: '.schedule-event',
    tolerance: "pointer",
    drop: function(event, ui) {
        $(ui.draggable).appendTo(this);
        var myId = $(ui.draggable).attr("guid");
        var myRoom = $(this).attr("room-guid")
        var myDate = $(this).attr("date");
        var myTime = $(this).attr("hour");
        $(ui.draggable).css("left", 0);
        $(ui.draggable).css("top", 0);
        $(this).css("background-color", "#ffffff");
        Schedule.save(myId, myRoom, myDate, myTime);
    },
    over: function(event, ui) {
      $(this).css("background-color", "#009ED8");
    },
    out: function(event, ui) {
      $(this).css("background-color", "#ffffff");
      }
  });
});
