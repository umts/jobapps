$(function() {
  const mousedownOn = {
    id: '',
    checkState: false,
  };

  $('.calendar').on('mouseup', function() {
    mousedownOn.id = '';
  });

  $('.hours-checkbox input[type="checkbox"]')
      .on('mousedown', function(event) {
        const target = $(event.target);
        mousedownOn.id = target.attr('id');
        mousedownOn.checkState = target.prop('checked');
        target.prop('checked', !target.prop('checked'));
      })
      .on('mouseenter', function(event) {
        const target = $(event.target);

        if (mousedownOn.id != '' && mousedownOn.id != target.attr('id')) {
          target.prop('checked', !mousedownOn.checkState);
        }
      })
      .on('click', function(event) {
        event.preventDefault();
        return false;
      });
});
