$(document).ready(function() {
  // will call refreshCurrentEvents every 15 minutes
    setInterval(refreshCurrentEvents, 900000)
  });

function refreshCurrentEvents(){
  $.ajax({
    url: "conference_wide_screen.js"
  });
};
