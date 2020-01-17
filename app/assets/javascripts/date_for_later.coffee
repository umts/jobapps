$(document).ready ->
  $('form').on 'change', '#date_for_later', ->
    $('#notification').toggle $(this).val().length > 0
