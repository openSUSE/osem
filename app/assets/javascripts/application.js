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
//= require toastr_rails
//= require jquery_ujs
//= require jquery.mobile.custom.min
//= require jquery.ui.draggable
//= require jquery.ui.droppable
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
//= require osem-schedule
//= require osem-switch
//= require osem-bootstrap
//= require osem-revisionhistory
//= require osem-commercials
//= require unobtrusive_flash
//= require unobtrusive_flash_bootstrap
//= require countable

$(document).ready(function() {
	$('a[disabled=disabled]').click(function(event){
		return false;
	});

	toastr.options = {
		'closeButton': false,
		'debug': false,
		'newestOnTop': false,
		'progressBar': true,
		'positionClass': 'toast-top-center',
		'preventDuplicates': true,
		'onclick': null,
		'showDuration': '300',
		'hideDuration': '100',
		'timeOut': '5000',
		'extendedTimeOut': '1000',
		'showEasing': 'swing',
		'hideEasing': 'linear',
		'showMethod': 'fadeIn',
		'hideMethod': 'fadeOut'
	};
	$('body').smoothScroll({
		delegateSelector: 'a.smoothscroll'
	});
});
