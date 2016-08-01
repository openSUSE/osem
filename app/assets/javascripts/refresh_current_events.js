$(document).ready(function() {
  // will call refreshCurrentEvents every 15 minutes
  setInterval(refreshCurrentEvents,900000);

  // Only show the first child of tweet and sponsor containers on page load
  $('#tweet-container').children().hide();
  $('#tweet-container').children().eq(0).show();
  $('#sponsor-container').children().hide();
  $('#sponsor-container').children().eq(0).show();

  setInterval(function(){ cycleVisibleElement($('#tweet-container'))}, 5000)
  setInterval(function(){ cycleVisibleElement($('#sponsor-container'))}, 10000)
});

// Makes an ajax call for fresh data
function refreshCurrentEvents(){
  $.ajax({
    url: "conference_wide_screen.js"
  });
};

// Cycle through children in a container and toggles visibility
function cycleVisibleElement(container){
  var childrens = $(container).children();
  for(var i = 0; i < childrens.length; i++ ){
      if(childrens.eq(i).is(":visible")){
        childrens.eq(i).hide();
        childrens.eq(++i % childrens.length).show();
        return
      }
  }
};
