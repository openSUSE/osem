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
      var success_callback = function(data) {
        e.attr("event_schedule_id", null);
        e.appendTo($(".unscheduled-events"));
        e.find(".schedule-event-delete-button").hide();
      }
      var error_callback = function(data) {
        showError($.parseJSON(data.responseText).errors);
      }
      $.ajax({
        url: my_url,
        type: 'DELETE',
        success: success_callback,
        error: error_callback,
        dataType : 'json'
      });
    }
    else{
      showError("The event couldn't be unscheduled");
    }
  },
  add: function (previous_parent, new_parent, event) {
    event.appendTo(new_parent);
    var event_schedule_id = event.attr("event_schedule_id");
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
    var success_callback = function(data) {
      event.attr("event_schedule_id", data.event_schedule_id);
      event.find(".schedule-event-delete-button").show();
      }
    var error_callback = function(data) {
      showError($.parseJSON(data.responseText).errors);
      event.appendTo(previous_parent);
    }
    $.ajax({
      url: my_url,
      type: type,
      data: params,
      success: success_callback,
      error: error_callback,
      dataType : 'json'
    });
  }
};

$(document).ready( function() {
  // hide the remove button for unscheduled and non schedulable events
  $('.unscheduled-events .schedule-event-delete-button').hide();
  $('.non_schedulable .schedule-event-delete-button').hide();

  // set events as draggable
  $('.schedule-event').not('.non_schedulable').draggable({
    snap: '.schedule-room-slot',
    revertDuration: 200,
    revert: function (event, ui) {
        return !event;
    },
    stop: function(event, ui) {
        this._originalPosition = this._originalPosition || ui.originalPosition;
        ui.helper.animate( this._originalPosition );
    },
    opacity: 0.7,
    snapMode: "inner",
    zIndex: 2,
    scroll: true
  });

  // set room cells as droppable
  $('.schedule-room-slot').not('.non_schedulable .schedule-room-slot').droppable({
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

function eventClicked(e, element){
  if (e.target.href) {
    return;
  }
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
