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
//= require jquery.mobile.custom.min
//= require waypoints/jquery.waypoints
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require cocoon
//= require bootstrap
//= require Chart
//= require osem
//= require osem-dashboard
//= require ahoy
//= require jquery-smooth-scroll
//= require trianglify
//= require tinycolor
//= require bootstrap-markdown
//= require to-markdown
//= require markdown
//= require momentjs
//= require leaflet
//= require holderjs
//= require bootstrap-datetimepicker
//= require osem-datepickers
//= require osem-datatables
//= require osem-tickets
//= require bootstrap-switch
//= require osem-switch
//= require osem-bootstrap
//= require osem-commercials
//= require unobtrusive_flash
//= require unobtrusive_flash_bootstrap

$(document).ready(function() {
    $('a[disabled=disabled]').click(function(event){
        return false;
    });

    $('body').smoothScroll({
        delegateSelector: 'a.smoothscroll'
    });
});
