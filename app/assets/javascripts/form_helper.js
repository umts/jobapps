$(document).ready(function() {
  $("[required]").each(function(index, element){
    var label = $("label[for='" + $(element).attr('id') + "']");
    label.addClass('required');
  });

  $('.dept-select').multipleSelect({
    width: 200,
    placeholder: 'All Departments',
    selectAll: false
  });
});
