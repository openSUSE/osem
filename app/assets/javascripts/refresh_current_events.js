$(document).ready(function() {
  // will call refreshCurrentEvents every 15 minutes
  setInterval(refreshCurrentEvents, 900000)
  // To cycle through tweets
  var tweets = $('div[id^="tweet"]').hide();
  var i = 0;

  (function cycle() {
    tweets.eq(i).show(0)
                .delay(5000)
                .hide(0, cycle);
    i = ++i % tweets.length;
  })();

  });

function refreshCurrentEvents(){
  $.ajax({
    url: "conference_wide_screen.js"
  });
};
