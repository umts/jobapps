$(function() {
  $('form').on('change', '#application_submission_date_for_later', function() {
    $('#notification').toggle($(this).val().length > 0);
  });
});
