var url; // Should be initialize in Schedule.initialize
var schedule_id; // Should be initialize in Schedule.initialize

var events_to_save = {};
var events_to_remove = {};

function showMessage(message, type){
  // Delete other messages before showing the new one
  $('.unobtrusive-flash-container').empty();
  UnobtrusiveFlash.showFlashMessage(message, {type: type});
}

var Schedule = {
  initialize: function(url_param, schedule_id_param) {
    url = url_param;
    schedule_id = schedule_id_param;
  },
  remove: function(element) {
    var e =  $("#" + element);
    var event_id = e.attr("event_id");
    if(e.attr("event_schedule_id")!= null){
      events_to_remove[event_id] = {
        event: e,
        previous_parent: e.parent()
      };
    }
    delete events_to_save[event_id];
    var unscheduled = $(".unscheduled-events");
    e.appendTo(unscheduled);
    e.find(".schedule-event-delete-button").hide();
  },
  add: function (previous_parent, new_parent, event) {
    var params = {
      previous_parent: previous_parent,
      new_parent: new_parent,
      event: event
    }
    var event_id = event.attr("event_id");
    events_to_save[event_id] = params;
    delete events_to_remove[event_id];
    event.appendTo(new_parent);
    $("#event-" + event_id).find(".schedule-event-delete-button").show();
  },
  saveEvents: function () {
    var errors = '';
    for (var key in events_to_save){
      var event = events_to_save[key]['event'];
      var event_schedule_id = event.attr("event_schedule_id");
      var new_parent = events_to_save[key]['new_parent'];
      var my_url = url;
      var type = 'POST';
      var params = { event_schedule: {
        room_id: new_parent.attr("room_id"),
        start_time: (new_parent.attr("date") + ' ' + new_parent.attr("hour"))
      }};
      if(event_schedule_id != null){
        type = 'PUT';
        my_url += ('/' + event_schedule_id);
      }
      else{
        params['event_schedule']['event_id'] = event.attr("event_id");
        params['event_schedule']['schedule_id'] = schedule_id;
      }
      var success_callback_save = function(data) {
        console.log(data);
        event.attr("event_schedule_id", data.event_schedule_id);
        }
      var error_callback_save = function(data) {
        console.log(data);
        errors += $.parseJSON(data.responseText).errors;
        event.appendTo(events_to_save[key]['previous_parent']);
        if(parent.hasClass('unscheduled-events'))
          event.find(".schedule-event-delete-button").hide();
      }
      $.ajax({
        async: false,
        url: my_url,
        type: type,
        data: params,
        success: success_callback_save,
        error: error_callback_save,
        dataType : 'json'
      });
    }
    for (var key in events_to_remove){
      var event = events_to_remove[key]['event'];
      var success_callback_remove = function(data) {
        console.log(data);
        event.attr("event_schedule_id", null);
      }
      var error_callback_remove = function(data) {
        console.log(data);
        errors += $.parseJSON(data.responseText).errors;
        events_to_remove[key]['previous_parent'].append(event);
        if(!parent.hasClass('unscheduled-events'))
          event.find(".schedule-event-delete-button").show();
      }
      $.ajax({
        async: false,
        url: url + '/' + event.attr("event_schedule_id"),
        type: 'DELETE',
        success: success_callback_remove,
        error: error_callback_remove,
        dataType : 'json'
      });
    }
    events_to_remove = {};
    events_to_save = {};
    if(errors == '')
      showMessage('Schedule correctly saved', 'notice');
    else
      showMessage(errors, 'error');
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

  $('.schedule-save').on('click', function(e) {
    Schedule.saveEvents();
  });
});

function eventClicked(e, element){
  var url = $(element).data('url');
  if(e.ctrlKey)
    window.open(url,'_blank');
  else
    window.location = url;
}

/* Links inside event-panel (to make ctrl + click work for these links):
 = link_to text, '#', onClick: 'insideLinkClicked();', 'data-url' => url
*/
function insideLinkClicked(event){
  // stops the click from propagating
  if (!event) // for IE
    var event = window.event;
  event.cancelBubble = true;
  if (event.stopPropagation) event.stopPropagation();

  var url = $(event.target).data('url');
  if(event.ctrlKey)
    window.open(url,'_blank');
  else
    window.location = url;
}
