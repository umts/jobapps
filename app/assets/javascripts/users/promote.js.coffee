$(document).ready ->
  $('.promote-table').on 'change', '#select-all', ->
    if $(this).is(':checked')
      $('.promote-select').prop 'checked', true
    else
      $('.promote-select').prop 'checked', false
    return
  $('.promote-table').on 'change', '.promote-select', ->
    if $('.promote-select:checked').length == 0
      $('#select-all').prop 'checked', false
    else if $('.promote-select:checked').length == $('.promote-table').find('tbody > tr').length
      $('#select-all').prop 'checked', true
    return
  return