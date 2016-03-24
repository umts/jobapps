$(document).ready ->
  $('.datepicker').datepicker
    changeMonth: true
    changeYear:  true
    yearRange:   'c-20:c+5'
    showOn: 'both'
    buttonImage: "/assets/calendar.gif"

  $('.datetimepicker').datetimepicker
    format: 'l, F j, Y g:i a'
    step:       15
  return
