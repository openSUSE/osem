var conference; // Should be initialize in Schedule.initialize
var schedule_id; // Should be initialize in Schedule.initialize

var Schedule = {
  initialize: function(conference_param, schedule_id_param) {
    conference = conference_param;
    schedule_id = schedule_id_param;
  },
  remove: function(element) {
    var e =  $("#" + element);
    var event_schedule_id = e.attr("event_schedule_id");
    if(event_schedule_id != null){
      var url = '/admin/conference/' + conference + '/event_schedule/' + event_schedule_id;
      var params = {
        event: e.attr("guid"),
        schedule: schedule_id
      };
      var callback = function(data) {
        console.log(data);
        e.attr("event_schedule_id", null);
      }
      $.ajax({
        url: url,
        type: 'DELETE',
        data: params,
        success: callback,
        dataType : 'json'
      });
    }
    var unscheduled = $(".unscheduled-events");
    e.appendTo(unscheduled);
    e.find(".schedule-event-delete-button").hide();
  },
  add: function (event_id, room_id, date, time, event_schedule_id) {
    var url = '/admin/conference/' + conference + '/event_schedule';
    var type = 'POST'
    if(event_schedule_id != null){
      type = 'PUT';
      url += ('/' + event_schedule_id);
    }
    var params = {
      event: event_id,
      schedule: schedule_id,
      room: room_id,
      date: date,
      time: time,
      schedule: schedule_id
    };
    var callback = function(data) {
      console.log(data);
      var e =  $("#event-" + event_id);
      e.attr("event_schedule_id", data.event_schedule_id);
      e.find(".schedule-event-delete-button").show();
    }
    $.ajax({
      url: url,
      type: type,
      data: params,
      success: callback,
      dataType : 'json'
    });
  }
};

$(document).ready( function() {
  // hide the remove button for unshceduled events
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
        var myEventSchedule = $(ui.draggable).attr("event_schedule_id");
        $(ui.draggable).css("left", 0);
        $(ui.draggable).css("top", 0);
        $(this).css("background-color", "#ffffff");
        Schedule.add(myId, myRoom, myDate, myTime, myEventSchedule);
    },
    over: function(event, ui) {
      $(this).css("background-color", "#009ED8");
    },
    out: function(event, ui) {
      $(this).css("background-color", "#ffffff");
      }
  });
});
