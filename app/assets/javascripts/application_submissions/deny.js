$(function() {
  $('form').on('change', '#application_submission_notify_of_denial', function() {
    const inform = this.checked;
    $('.rejection-message').toggle(inform);
  });
});
