var conference_id; // Should be initialize in Schedule.initialize
var schedule_id; // Should be initialize in Schedule.initialize

var events_to_create = {};
var events_to_update = {};
var events_to_remove = {};

function showMessage(message, type){
  // Delete other messages before showing the new one
  $('.unobtrusive-flash-container').empty();
  UnobtrusiveFlash.showFlashMessage(message, {type: type});
}

var Schedule = {
  initialize: function(conference_id_param, schedule_id_param) {
    conference_id = conference_id_param;
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
    var event_id = e.attr("event_id");
    var event_schedule_id = e.attr("event_schedule_id");
    if(event_schedule_id != null){
      events_to_remove[event_id] = event_schedule_id;
    }
    delete events_to_create[event_id];
    delete events_to_update[event_id];
    Schedule.validateCells(e.parent(), e.attr("length"));
    var unscheduled = $(".unscheduled-events");
    e.appendTo(unscheduled);
    e.find(".schedule-event-delete-button").hide();
  },
  add: function (new_parent, event) {
    var event_id = event.attr("event_id");
    var event_schedule_id = event.attr("event_schedule_id");
    var room_id = new_parent.attr("room_id");
    var start_time = (new_parent.attr("date") + ' ' + new_parent.attr("hour"));
    if(event_schedule_id != null){
      var params = {};
      params[event_schedule_id] = {
        room_id: room_id,
        start_time: start_time
      };
      events_to_update[event_id] = params;
      delete events_to_create[event_id];
    }
    else{
      events_to_create[event_id] = {
        room_id: room_id,
        start_time: start_time,
        event_id: event_id,
        schedule_id: schedule_id
      };
      delete events_to_update[event_id];
    }
    delete events_to_remove[event_id];
    Schedule.invalidateCells(event, event.attr("length"));
    event.appendTo(new_parent);
    $("#event-" + event_id).find(".schedule-event-delete-button").show();
  },
  saveEvents: function () {
    var errors = '';
    var with_errors = false;
    var error_callback = function(data) {
      try{
        errors += $.parseJSON(data.responseText).errors;
        with_errors = true;
      }catch(e){
        with_errors = true;
      }
    }
    if(!jQuery.isEmptyObject(events_to_create)){
      $.ajax({
        async: false,
        url: ("/admin/conferences/" + conference_id + "/bulk_create"),
        type: 'POST',
        data: { event_schedules: events_to_create },
        error: error_callback,
        dataType : 'json'
      });
    }
    if(!jQuery.isEmptyObject(events_to_update)){
      $.ajax({
        async: false,
        url: ("/admin/conferences/" + conference_id + "/bulk_update"),
        type: 'POST',
        data: { event_schedules: events_to_update },
        error: error_callback,
        dataType : 'json'
      });
    }
    if(!jQuery.isEmptyObject(events_to_remove)){
      $.ajax({
        async: false,
        url: ("/admin/conferences/" + conference_id + "/bulk_destroy"),
        type: 'POST',
        data: { event_schedules: events_to_remove },
        error: error_callback,
        dataType : 'json'
      });
    }
    var url = (window.location.href).substring(0, window.location.href.indexOf('?'));
    if(with_errors){
      var msg = "Some events couldn't be scheduled"
      if(errors != ''){
        msg += (": " + errors);
      }
      window.location.href = (url + "?flash=" + msg + "&type=error");
    } else {
      window.location.href = (url + "?flash=Schedule correctly saved&type=notice");
    }
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
      var free = true;
      var i = 0;
      var elem = $(this);
      while(free && i < dropElem.attr("length")){
        if(elem.hasClass('with-event'))
          free = false;
        elem = elem.next();
        i++;
      }
      return free;
    },
    drop: function(event, ui) {
        $(ui.draggable).css("left", 0);
        $(ui.draggable).css("top", 0);
        $(this).css("background-color", "#ffffff");
        Schedule.add($(this), $(ui.draggable));
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
