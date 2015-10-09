$(function () {
    $(document).ready(function() {
        $('#commercial_url').focusout(function(){
            var url = $('#new_commercial').attr('action');
            url = url + '/get_html'
            $.ajax({
                method: 'GET',
                url: url,
                data: { url: $(this).val() }
            })
                .done(function( msg ) {
                    $('#resource-content').html(msg);
                });
        });
    });
});

