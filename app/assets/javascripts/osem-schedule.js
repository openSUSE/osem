var conference; // Should be initialize in Schedule.initialize
var schedule_id; // Should be initialize in Schedule.initialize

var events_to_save = {};
var events_to_remove = {};

var Schedule = {
  initialize: function(conference_param, schedule_id_param) {
    conference = conference_param;
    schedule_id = schedule_id_param;
  },
  invalidateCells: function(element, length) {
    for (i = 0; i < length; i++) {
      element.addClass('with-event');
      element = element.next();
    }
  },
  validateCells: function(element, length) {
    for (i = 0; i < length; i++) {
      element.removeClass('with-event');
      element = element.next();
    }
  },
  remove: function(element) {
    var e =  $("#" + element);
    var event_schedule_id = e.attr("event_schedule_id");
    var event_id = e.attr("guid");
    if(event_schedule_id != null){
      events_to_remove[event_id] = { event_schedule_id: event_schedule_id };
    }
    delete events_to_save[event_id];
    var unscheduled = $(".unscheduled-events");
    Schedule.validateCells(e.parent(), e.attr("length"));
    e.appendTo(unscheduled);
    e.find(".schedule-event-delete-button").hide();
  },
  add: function (event_id, room_id, date, time, event_schedule_id) {
    var params = {
      event: event_id,
      schedule: schedule_id,
      room: room_id,
      date: date,
      time: time,
      event_schedule_id: event_schedule_id
    };
    events_to_save[event_id] = params;
    delete events_to_remove[event_id];
    $("#event-" + event_id).find(".schedule-event-delete-button").show();
  },
  saveEvents: function () {
    var callback_save = function(data) {
      console.log(data);
      $("#event-" + data.event).attr("event_schedule_id", data.event_schedule_id);
    }
    var callback_remove = function(data) {
      console.log(data);
      $("#event-" + data.event).attr("event_schedule_id", null);
    }
    for (var key in events_to_save){
      var type = 'POST';
      var url = '/admin/conference/' + conference + '/event_schedule';
      var event_schedule_id = events_to_save[key].event_schedule_id;
      if(event_schedule_id != null){
        type = 'PUT';
        url += ('/' + event_schedule_id);
      }
      $.ajax({
        url: url,
        type: type,
        data: events_to_save[key],
        success: callback_save,
        dataType : 'json'
      });
    }
    for (var key in events_to_remove){
      $.ajax({
        url: '/admin/conference/' + conference + '/event_schedule/' + events_to_remove[key].event_schedule_id,
        type: 'DELETE',
        success: callback_remove,
        dataType : 'json'
      });
    }
    alert('Schedule correctly saved');
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
      var dropable = $(this).parent();
      if(!dropable.hasClass('unscheduled-events')){
        Schedule.invalidateCells(dropable, $(this).attr("length"));
      }
      return !event;
    },
    start: function(event, ui) {
      var dropable = $(this).parent();
      if(!dropable.hasClass('unscheduled-events')){
        Schedule.validateCells(dropable, $(this).attr("length"));
      }
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
    accept: function(dropElem){
      return !$(this).hasClass('with-event');
    },
    drop: function(event, ui) {
        var myId = $(ui.draggable).attr("guid");
        var myLength = $(ui.draggable).attr("length");
        var myRoom = $(this).attr("room-guid")
        var myDate = $(this).attr("date");
        var myTime = $(this).attr("hour");
        var myEventSchedule = $(ui.draggable).attr("event_schedule_id");
        $(ui.draggable).css("left", 0);
        $(ui.draggable).css("top", 0);
        $(this).css("background-color", "#ffffff");
        Schedule.add(myId, myRoom, myDate, myTime, myEventSchedule);
        Schedule.invalidateCells($(this), myLength);
        $(ui.draggable).appendTo(this);
    },
    over: function(event, ui) {
      $(this).css("background-color", "#009ED8");
    },
    out: function(event, ui) {
      $(this).css("background-color", "#ffffff");
      }
  });

  $('.schedule-save').on('click', function(e) {
    Schedule.saveEvents();
  });
});
