$(function() {
  $('.selectpicker').on('changed.bs.select', function (e, clickedIndex) {
    $('.kinds').addClass('hidden');
    var selected = $('.selectpicker').find('option:selected').val();
    $('.' + selected).removeClass('hidden');

    if (selected == 'choice') {
      $('.survey-possible-answers').removeClass('hidden');
    }
    else
    {
      $('.survey-possible-answers').addClass('hidden');
    }
  });
  $('#survey_question_title').on('keyup', function(){
    $('#survey_question_preview #title').text($(this).val())
  });

  function render_possible_answers_preview() {
    var options_html = '';
    var options_array = $('#survey_question_possible_answers').val().split(',');
    var input_type = ($('#survey_question_min_choices').val() == 1 &&
                      $('#survey_question_max_choices').val() == 1) ? 'radio' : 'checkbox';
    $.each(options_array, function(index, option) {
      options_html += '<input type="' + input_type + '" name="preview_option"/>  ' + option.trim() + '<br/>';
    });
    $('#survey_question_preview .choice').html(options_html)
  };

  $('#survey_question_possible_answers').on('keyup', render_possible_answers_preview);
  $('#survey_question_min_choices').on('change', render_possible_answers_preview);
  $('#survey_question_max_choices').on('change', render_possible_answers_preview);
});
