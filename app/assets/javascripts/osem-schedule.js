var conference; // Should be initialize in Schedule.initialize
var schedule_id; // Should be initialize in Schedule.initialize

var Schedule = {
  initialize: function(conference_param, schedule_id_param) {
    conference = conference_param;
    schedule_id = schedule_id_param;
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
  add: function (event_id, room_id, date, time) {
    var url = '/admin/conference/' + conference + '/schedule/' + schedule_id;
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
  // hide the remove button for unscheduled events
  $('.unscheduled-events .schedule-event-delete-button').hide();

  // set events as draggable
  $('.schedule-event').draggable({
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

  // set room cells as droppable
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
        Schedule.add(myId, myRoom, myDate, myTime);
    },
    over: function(event, ui) {
      $(this).css("background-color", "#009ED8");
    },
    out: function(event, ui) {
      $(this).css("background-color", "#ffffff");
      }
  });
});
