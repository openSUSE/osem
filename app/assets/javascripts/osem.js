$(function () {
    /**
    * Update the number of words in the biography text field every time the user
    * releases a key on the keyboard
     */
    $("#user_biography").bind('keyup', function() {
        word_count(this, 'bio_length', 150);
    } );

    /**
     * Displays a modal with the questions of the registration.
     */
    $(document).ready(function(){
        $(".question-btn").click(function(){
            var id = $(this).data('id');
            $("#question-modal-body").empty();
            $("#question-modal-body").html($(".question" + id).clone().show());
            $("#question-modal-header").text('Questions for ' + $(this).data('name'));
            $('#questions').modal('show');
        });
    });

    /**
     * Toggles email template help below email body textarea field.
     */
    $(document).ready( function() {
        $(".template-help").hide();
        $(".template_help_link").click(function() {
            var id = $(this).data('name');
            $("#" + id).toggle();
        });
    });

    /**
     * Randomize order of parallel elements by shuffling the decks
     * Adapted from https://stackoverflow.com/questions/7070054
     */

    $(document).ready( function() {
        $.each($(".shuffle-deck"), function(index, deck) {
            for(var i = deck.children.length; i >= 0; i--) {
                deck.appendChild(deck.children[Math.random() * i | 0]);
            }
        });
    });

    $(".select-help-toggle").change(function () {
        var id = $(this).attr('id');
        $('.' + id).collapse('hide');

        $('#' + $(this).val() + '-help.' + id).collapse('show');
        $('#' + $(this).val() + '-instructions.' + id).collapse('show');

    });
    $('.dropdown-toggle').dropdown();

    /**
     * Adds the default template as value to the regarding email textarea field.
     */
    $(".load_template").on('click', function () {
      var subject_input_id = $(this).data('subject-input-id');
      var subject_input_text = $(this).data('subject-text');
      var body_input_id = $(this).data('body-input-id');
      var body_input_text = $(this).data('body-text');
      $('#' + subject_input_id).val(subject_input_text);
      $('#' + body_input_id).val(body_input_text);
    });

    /**
     * Toggle the required attribute on click on_send_email radio button.
     */
    $('.send_on_radio').click(function () {
        toggle_required_for_mail_subjects($(this))
    });

    /**
     * Adds required attribute to on_send_email radio button if necessary.
     */
    $('.send_on_radio').each(function () {
        toggle_required_for_mail_subjects($(this))
    });
    /**
     * Toggle the required attribute helper function.
     */
    function toggle_required_for_mail_subjects($this) {
        var name = $this.data('name');
        if ($this.is(':checked')) {
            $('#' + name).prop('required', true);
        } else {
            $('#' + name).removeAttr('required');
        }
    }

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

    $('a:contains("Add track")').click(function () {
        setTimeout(function () {
                $("div.nested-fields:last div:nth-of-type(2) input").val(get_color());
            },
            5)
    });

    $('a:contains("Add difficulty_level")').click(function () {
        setTimeout(function () {
                $("div.nested-fields:last div:nth-of-type(3) input").val(get_color());
            },
            5)
    });

    $('a:contains("Add event_type")').click(function () {
        setTimeout(function () {
                $("div.nested-fields:last div:nth-of-type(5) input").val(get_color());
            },
            5)
    });
});

function get_color() {
    var colors = ['#000000', '#0000FF', '#00FF00', '#FF0000', '#FFFF00', '#9900CC',
        '#CC0066', '#00FFFF', '#FF00FF', '#C0C0C0', '#00008B', '#FFD700',
        '#FFA500', '#FF1493', '#FF00FF', '#F0FFFF', '#EE82EE', '#D2691E',
        '#C0C0C0', '#A52A2A', '#9ACD32', '#9400D3', '#8B008B', '#8B0000',
        '#87CEEB', '#808080', '#800080', '#008B8B', '#006400'
    ];
    return colors[Math.floor(Math.random() * colors.length)];
}

function word_count(text, divId, maxcount) {
    var area = document.getElementById(text.id)

    Countable.live(area, function(counter) {
        $('#' + divId).text(counter.words);
        if (counter.words > maxcount)
            $('#' + divId).css('color', 'red');
        else
            $('#' + divId).css('color', 'black');
    });
};

function replace_defaut_submission_text(input_selector, new_text, valid_defaults) {
    let $area = $(input_selector);
    let current_text = $area.val();

    if (!current_text) {
        $area.val(new_text);
        $area.trigger('change');
        return;
    }

    valid_defaults.some(default_text => {
        if (current_text == default_text) {
            $area.val(new_text);
            $area.trigger('change');
            return true;
        }
    });
}

/* Wait for the DOM to be ready before attaching events to the elements */
$( document ).ready(function() {
    /* Set the minimum and maximum proposal abstract and submission text word length */
    $("#event_event_type_id").change(function () {
        var $selected = $("#event_event_type_id option:selected")
        var max = $selected.data("max-words");
        var min = $selected.data("min-words");

        // We replace the default text only if the current field is empty,
        // or is set to the default text of another event type.
        replace_defaut_submission_text(
            '#event_submission_text',
            $selected.data("instructions"),
            $("#event_event_type_id option").toArray().map(e => $(e).data('instructions'))
        );

        $("#abstract-maximum-word-count").text(max);
        $("#submission-maximum-word-count").text(max);
        $("#abstract-minimum-word-count").text(min);
        $("#submission-minimum-word-count").text(min);
        word_count($('#event_abstract').get(0), 'abstract-count', max);
        word_count($('#event_submission_text').get(0), 'submission-count', max);
    }).trigger('change');

    /* Count the proposal abstract length */
    $("#event_abstract").bind('change keyup paste input', function() {
        var $selected = $("#event_event_type_id option:selected")
        var max = $selected.data("max-words");
        word_count(this, 'abstract-count', max);
    } );

    /* Count the submission text length */
    $("#event_submission_text").bind('change keyup paste input', function() {
        var $selected = $("event_event_type_id option:selected")
        var max = $selected.data("max-words");
        word_count(this, 'submission-count', max);
    });

    /* Listen for reset template button, wait for confirm, and reset. */
    $('.js-resetSubmissionText').click((e) => {
        let $selected = $("#event_event_type_id option:selected");
        let $this = $(e.target);
        let affirm = confirm($this.data('confirm'));
        if (affirm) {
            let sub_text = $('#event_submission_text');
            sub_text.val($selected.data('instructions'));
            sub_text.trigger('change');
        }
    });
});

/* Commodity function for modal windows */

window.build_dialog = function(selector, content) {
  // Close it and remove content if it's already open
  $("#" + selector).modal('hide');
  $("#" + selector).remove();
  // Add new content and pops it up
  $("body").append("<div id=\"" + selector + "\" class=\"modal fade\" role=\"dialog\">\n" + content + "</div>");
  $("#" + selector).modal();
}
