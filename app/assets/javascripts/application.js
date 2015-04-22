// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require waypoints
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require cocoon
//= require bootstrap
//= require Chart
//= require d3
//= require osem
//= require dashboard
//= require ahoy
//= require smoothscroll
//= require trianglify.min
//= require tinycolor
//= require bootstrap-markdown
//= require to-markdown
//= require markdown
//= require moment
//= require leaflet
//= require bootstrap-datetimepicker
//= require osem-datepickers
//= require osem-datatables
//= require osem-tickets
//= require bootstrap-switch
//= require osem-switch
//= require osem-bootstrap
//= require osem-commercials

$(document).ready(function() {
    $('a[disabled=disabled]').click(function(event){
        return false;
    });
});
