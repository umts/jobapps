$(document).ready ->
  $('form').on 'change', '#application_submission_date_for_later', ->
    $('#notification').toggle $(this).val().length > 0
