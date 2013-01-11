$(function() {
    $('.dropdown-toggle').dropdown();
    $("#conference-start-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-end-datepicker").datepicker("option","minDate", selected)
        }
    });
    $("#conference-end-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-start-datepicker").datepicker("option","maxDate", selected)
            $("#cfp-hard-datepicker").datepicker("option","minDate", selected)

        }
    });

    $("#cfp-hard-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-end-datepicker").datepicker("option","maxDate", selected)
            $("#conference-start-datepicker").datepicker("option","maxDate", selected)

        }
    });

    $("#conference-reg-start-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-reg-end-datepicker").datepicker("option","minDate", selected)
        }
    });
    $("#conference-reg-end-datepicker").datepicker({
        dateFormat: 'yy/mm/dd',
        numberOfMonths: 2,
        onSelect: function(selected) {
            $("#conference-reg-start-datepicker").datepicker("option","maxDate", selected)
        }
    });

    $(".comment-reply-link").click(function(){
        $(".comment-reply", $(this).parent()).toggle();
        return false;
    });

    $("#event-comment-link").click(function(){
        $("#comments-div").toggle();
        return false;
    });

    $(".comment-reply").hide();
    $(".user-details-popover").popover();
    $("#comments-div").hide();
});

function word_count(text, divId) {
    var r = 0;
    var input = text.value.replace(/\s/g,' ');
    var word_array = input.split(' ');
    for (var i=0; i < word_array.length; i++) {
        if (word_array[i].length > 0) r++;
    }

    $('#' + divId).text(r);
};
