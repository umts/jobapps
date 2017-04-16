$(document).ready ->
  $('#promote-search').autocomplete source: $('#promote-search').data('users')
  return