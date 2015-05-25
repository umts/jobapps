$(document).ready ->
  $('.datepicker').datepicker
    changeMonth: true
    changeYear:  true
    yearRange:   'c-5:c+5'

  $('.datetimepicker').datetimepicker
    formatTime: 'g:i a'
    step:       15
  return
