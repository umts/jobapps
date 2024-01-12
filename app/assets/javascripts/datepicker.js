$(function() {
  // you must set a dateFormatter for datetimepicker to use or
  // you'll get an error
  $.datetimepicker.setDateFormatter('moment');

  $('.datetimepicker').datetimepicker({
    format: 'dddd, MMMM D, YYYY, h:mm a',
    step: 15
  });
});
