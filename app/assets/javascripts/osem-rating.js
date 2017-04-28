$( document ).ready(function() {
      $(".disabled-rate .star").each(function(){
          $(this).raty('readOnly', true);
      });
});