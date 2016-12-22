$(document).ready ->
  $('form').on 'change', '#date_for_later', ->
    $('#notification').toggleClass 'hidden', $(this).val().length > 0
