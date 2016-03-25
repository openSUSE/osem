Array.prototype.remove = function() {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
};

Date.prototype.addDays = function(days) {
    var dat = new Date(this.valueOf())
    dat.setDate(dat.getDate() + days);
    return dat;
}

function getDates(startDate, stopDate) {
    var dateArray = new Array();
    var currentDate = startDate;
    while (currentDate <= stopDate) {
        dateArray.push(currentDate)
        currentDate = currentDate.addDays(1);
    }
    return dateArray;
}

var scheduleDayEvents = {};

var Schedule = {
    loadEvents: function(conference_id, start_date) {
        var eventDates = {};
        var url = '/admin/conference/' + conference_id + '/program/events';
        var params = { start: $('#start').text(), end: $('#end').text()};
        var callback = function(data) {
            $.each(data, function(key, val) {
                Schedule.newEvent(val, conference_id);
            });
            Schedule.changeDay(start_date);
        };
        $.getJSON(url, params, callback);
    },
    newEvent: function(vars, conference_id) {
        var newEvent = $('<div>'
            + '<div onclick="Schedule.remove(\'event-' + vars["guid"] + '\', \'' + conference_id +'\');" class="schedule-event-delete-button">X</div>'
            + '<div>' + vars["title"] + '</div></div>');
        var date = "none";
        var hour = "12";
        var minute = "0";
        console.log(vars);
        if (vars["start_time"] != null) {
            var d = new Date(vars["start_time"]);
            date =  d.getUTCFullYear() + "-"
                + ('0' + (d.getUTCMonth() +1)).slice(-2) + '-'
                + ('0' + d.getUTCDate()).slice(-2);
            hour = d.getUTCHours();
            minute = d.getUTCMinutes();
            console.log("date: " + d);
        }
        newEvent.addClass("schedule-event");
        newEvent.css('background-color',vars["track_color"]);
        newEvent.attr("id", "event-" + vars["guid"]);
        newEvent.attr("room", vars["room_guid"]);
        newEvent.attr("guid", vars["guid"]);
        newEvent.attr("length", vars["length"]);
        newEvent.attr("date", date);
        newEvent.attr("hour", hour);
        newEvent.attr("minute", minute);
        newEvent.draggable({
            snap: '.schedule-track-slot',
            revertDuration: 200,
            revert: function (event, ui) {
//                $(this).data("draggable").originalPosition = {
//                    top: 0,
//                    left: 0
//                };
                console.log(event.attr);
                return !event;
            },
            stop: function(event, ui) {
                this._originalPosition = this._originalPosition || ui.originalPosition;
                ui.helper.animate( this._originalPosition );
            },
            start: function( event, ui ) {
                $(ui.helper).height(ui.helper.attr("length") * 2 - 7);

            },
            opacity: 0.7,
            snapMode: "inner",
            zIndex: 2
        });
        if (date == "none" || vars["room_id"] == null) {
            $('#unscheduled').append(newEvent);
        } else {
            if (!scheduleDayEvents.hasOwnProperty(date)) {
                scheduleDayEvents[date] = new Array();
            }
            newEvent.height(newEvent.attr("length") * 2 - 7);
            newEvent.width(200 - 10);
            scheduleDayEvents[date].push(newEvent);
        }
    },
    remove: function(element, conference_id) {
        var e =  $("#" + element);
        var unscheduled = $("#unscheduled");

        var url = '/admin/conference/' + conference_id + '/schedule';
        var params = {
            event: e.attr("guid"),
            room: "none",
            date: "none",
            time: "none"
        };
        var callback = function(data) {
            console.log(data);
            e.height(10);
            e.width(unscheduled.width())
            e.appendTo(unscheduled);
        }
        $.ajax({
            url: url,
            type: 'PUT',
            data: params,
            success: callback,
            dataType : 'json'
        });
    },
    changeDay: function(date) {
        $(".date-selector").removeClass("active");
        $(".date-selector #" + date + "-selector").parent().addClass("active");
        $(".schedule-room-slot").attr("date", date);
        // Now clear all of the attached events
        $(".schedule-rooms-container .schedule-event").remove();
        if (scheduleDayEvents.hasOwnProperty(date)) {
            var events = scheduleDayEvents[date];
            for (var i = 0; i < events.length; i++) {
                var elem = events[i];
                elem.draggable({
                    grid: [200,31],
                    snap: '.schedule-track-slot',
                    revert: function (event, ui) {
                        $(this).data("draggable").originalPosition = {
                            top: 0,
                            left: 0
                        };
                        return !event;
                    },
                    opacity: 0.7,
                    snapMode: "inner",
                    zIndex: 2
                });

                var attachStr = "#schedule-room-" + elem.attr("room") + "-" + elem.attr("hour") + "-" + elem.attr("minute");
                $(attachStr).append(elem);
            }
        }
    },
    save: function (conference_id, event_id, room_id, date, time) {
        var url = '/admin/conference/' + conference_id + '/schedule';
        var params = {
            event: event_id,
            room: room_id,
            date: date,
            time: time
        };
        var callback = function(data) {
            console.log(data);
        }
        $.ajax({
            url: url,
            type: 'PUT',
            data: params,
            success: callback,
            dataType : 'json'
        });
    },

};
