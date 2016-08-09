$(function () {
  $("[class='switch-checkbox']").bootstrapSwitch();

  $('input[class="switch-checkbox"]').on('switchChange.bootstrapSwitch', function(event, state) {
    var url = $(this).attr('url') + state;
    var method = $(this).attr('method');

    $.ajax({
      url: url,
      type: method,
      dataType: 'script'
    });
  });

  $("[class='switch-checkbox-schedule']").bootstrapSwitch();

  $('input[class="switch-checkbox-schedule"]').on('switchChange.bootstrapSwitch', function(event, state) {
    var url = $(this).attr('url');
    var method = $(this).attr('method');

    if(state){
      url += $(this).attr('value');
    }

    var callback = function(data) {
      showError($.parseJSON(data.responseText).errors);
    }
    $.ajax({
      url: url,
      type: method,
      error: callback,
      dataType: 'json'
    });
  });
});
