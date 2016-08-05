var url; // Should be initialize in Schedule.initialize
var schedule_id; // Should be initialize in Schedule.initialize

function showError(error){
  // Delete other error messages before showing the new one
  $('.unobtrusive-flash-container').empty();
  UnobtrusiveFlash.showFlashMessage(error, {type: 'error'});
}

var Schedule = {
  initialize: function(url_param, schedule_id_param) {
    url = url_param;
    schedule_id = schedule_id_param;
  },
  remove: function(element) {
    var e =  $("#" + element);
    var event_schedule_id = e.attr("event_schedule_id");
    if(event_schedule_id != null){
      var my_url = url + '/' + event_schedule_id;
      var callback = function(data) {
        console.log(data);
        if(data.status == 'ok'){
          e.attr("event_schedule_id", null);
          e.appendTo($(".unscheduled-events"));
          e.find(".schedule-event-delete-button").hide();
        }
        else{
          showError(data.status);
        }
      }
      $.ajax({
        url: my_url,
        type: 'DELETE',
        success: callback,
        dataType : 'json'
      });
    }
    else{
      showError("The event couldn't be unscheduled");
    }
  },
  add: function (previous_parent, new_parent, event) {
    var event_schedule_id = event.attr("event_schedule_id");
    var my_url = url;
    var type = 'POST';
    if(event_schedule_id != null){
      type = 'PUT';
      my_url += ('/' + event_schedule_id);
    }
    var params = { event_schedule: {
      event_id: event.attr("event_id"),
      schedule_id: schedule_id,
      room_id: new_parent.attr("room_id"),
      start_time: (new_parent.attr("date") + ' ' + new_parent.attr("hour"))
    }};
    var callback = function(data) {
      console.log(data);
      if(data.status == 'ok'){
        event.appendTo(new_parent);
        event.attr("event_schedule_id", data.event_schedule_id);
        event.find(".schedule-event-delete-button").show();
      }
      else{
        event.appendTo(previous_parent);
        showError("The event couldn't been scheduled");
      }
    }
    $.ajax({
      url: my_url,
      type: type,
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
        $(ui.draggable).css("left", 0);
        $(ui.draggable).css("top", 0);
        $(this).css("background-color", "#ffffff");
        Schedule.add($(ui.draggable).parent(), $(this), $(ui.draggable));
    },
    over: function(event, ui) {
      $(this).css("background-color", "#009ED8");
    },
    out: function(event, ui) {
      $(this).css("background-color", "#ffffff");
      }
  });
});
