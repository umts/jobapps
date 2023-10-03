$(document).ready(function(){
  // you must set a dateFormatter for datetimepicker to use or
  // you'll get an error
  $.datetimepicker.setDateFormatter('moment');

  $('.datepicker').datetimepicker({
    timepicker: false,
    format: 'MM/DD/YYYY'
  });

  $('.datetimepicker').datetimepicker({
    format: 'dddd, MMMM D, YYYY, h:mm a',
    step: 15
  });
});
