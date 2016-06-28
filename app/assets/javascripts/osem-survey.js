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
});
