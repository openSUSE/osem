$( document ).ready(function() {

  $('.osem-register button.show-or-hide-password').click(function() {
    const is_locked = $(this).data('lock');
    $(this).data('lock', !is_locked);
    $(this).parents('.osem-register').find('input').attr('type', is_locked ? 'text' : 'password');
    if (is_locked) {
      $(this).find('.show-password').hide();
      $(this).find('.hide-password').show();
    } else {
      $(this).find('.show-password').show();
      $(this).find('.hide-password').hide();
    }
  } );
} );
