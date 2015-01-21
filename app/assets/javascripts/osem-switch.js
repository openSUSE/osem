$(function () {
  $(document).ready(function() {
    $("[class='switch-checkbox']").bootstrapSwitch();

    $('input[class="switch-checkbox"]').on('switchChange.bootstrapSwitch', function(event, state) {
      url = "/admin/conference/" + this.name + "/events/" + this.value

      $.ajax({
        url: url,
        type: 'PATCH',
        data: { event: { is_highlight: state } },
        dataType: 'script'
      });
    });
  });
});
