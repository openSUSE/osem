$(function () {
  $("[class='switch-checkbox']").bootstrapSwitch();

  $('input[class="switch-checkbox"]').on('switchChange.bootstrapSwitch', function(event, state) {
      console.log(event);
      console.log(state);
    var url = $(this).attr('url') + state;
    var method = $(this).attr('method');

    $.ajax({
      url: url,
      type: method,
      dataType: 'script'
    });
  });



});
