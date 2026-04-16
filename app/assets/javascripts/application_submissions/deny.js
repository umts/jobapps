$(function() {
  $('form').on('change', '#application_submission_notify_of_denial', function(event) {
    const inform = $(event.target).checked;
    $('.rejection-message').toggle(inform);
  });
});
