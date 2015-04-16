$(function() {
  // add a hash to the URL when the user clicks on a tab
  $('a[data-toggle="tab"]').on('click', function(e) {
    history.pushState(null, null, $(this).attr('href'));
  });
  // navigate to a tab when the history changes
  window.addEventListener("popstate", function(e) {
    var activeTab = $('a[href="' + location.hash + '"]');
    if (activeTab.length) {
      activeTab.tab('show');
    } else {
      $('.nav-tabs a').first().tab('show');
    }
  });
});

$(function() {
    var hash = window.location.hash;
    hash && $('ul.nav a[href="' + hash + '"]').tab('show');
});

$(function () {
  $('[data-toggle="popover"]').popover({html: true})
});
