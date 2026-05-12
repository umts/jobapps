$(function() {
  $('form').on('change', '#application_submission_date_for_later', function(event) {
    $('#notification').toggle($(event.target).val().length > 0);
  });
});
