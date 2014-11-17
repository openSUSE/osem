$(function () {
  $(document).ready(function() {
    var t = new Trianglify({cellsize: 100, x_gradient: triangle_colors });
    var pattern = t.generate(document.body.clientWidth, ($( "#splash-banner" ).height() + 200 ));
    $('#splash-banner').css('background-image', pattern.dataUrl);
  });
});