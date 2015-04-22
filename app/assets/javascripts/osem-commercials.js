$(function () {
  $(document).ready(function() {
    $("#commercial_url").bind('paste keyup', function() {
      clearTimeout($(this).data('timeout'));

      $(this).data('timeout', setTimeout(function () {
        var url = $('#new_commercial').attr('action');
        url = url + '/render_commercial'
        $.ajax({
          method: 'GET',
          url: url,
          data: { url: $('#commercial_url').val() },
          error: function(xhr, status, error) {
            $('#commercial_submit_action').prop('disabled', true);
            $('#resource-content').hide();
            $('#resource-placeholder').show();
            $('#commercial_error').hide();
            $('#commercial_url_input').addClass('has-error error');
            $('<span id="commercial_error" class="help-block">' + xhr.responseText + '</span>').insertAfter('#commercial_url');
          },
          success: function(msg) {
            $('#commercial_submit_action').prop('disabled', false);
            $('#commercial_url_input').removeClass('has-error error');
            $('#commercial_error').hide();
            $('#resource-placeholder').hide();
            $('#resource-content').html(msg).show();
          }
        })
      }, 200)
      );
    });
  });
});
