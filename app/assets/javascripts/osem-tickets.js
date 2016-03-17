function update_price($this){
    var id = $this.data('id');

    // Calculate price for row
    var value = $this.val();
    var price = $('#price_' + id).text();
    $('#total_row_' + id).text(value * price);

    // Calculate total price
    var total = 0;
    $('.total_row').each(function( index ) {
        total += parseInt($(this).text());
    });
    $('#total_price').text(total);
}

$( document ).ready(function() {
    $('.quantity').each(function() {
        update_price($(this));
    });

    $('.quantity').change(function() {
        update_price($(this));
    });
    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    });
});
