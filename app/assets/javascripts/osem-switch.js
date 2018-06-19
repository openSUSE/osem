function checkboxSwitch(selector){
  $(selector).bootstrapSwitch(

  );

  $(selector).on('switchChange.bootstrapSwitch', function(event, state) {
    var url = $(this).attr('url') + state;
    var method = $(this).attr('method') || 'patch';

    $.ajax({
      url: url,
      type: method,
      dataType: 'script'
    });
  });
}

$(function () {
  $.fn.bootstrapSwitch.defaults.onColor = 'success';
  $.fn.bootstrapSwitch.defaults.offColor = 'warning';
  $.fn.bootstrapSwitch.defaults.onText = 'Yes';
  $.fn.bootstrapSwitch.defaults.offText = 'No';
  $.fn.bootstrapSwitch.defaults.size = 'small';


  checkboxSwitch("[class='switch-checkbox']");

  $("[class='switch-checkbox-schedule']").bootstrapSwitch();

  $('input[class="switch-checkbox-schedule"]').on('switchChange.bootstrapSwitch', function(event, state) {
    var url = $(this).attr('url');
    var method = $(this).attr('method') || 'patch';

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
