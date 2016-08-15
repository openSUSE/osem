$(document).ready(function() {
    $('.show-changeset').click(function(){
        if ($(this).text() == 'View Changes'){
            $(this).text('Hide Changes');
        }else {
            $(this).text('View Changes');
        }
        $('#changeset-' + this.id).toggle();
    });
});
