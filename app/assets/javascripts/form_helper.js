$(document).ready(function() {
  $("[required]").each(function(index, element){
    var label = $("label[for='" + $(element).attr('id') + "']");
    label.addClass('required');
  });
});
