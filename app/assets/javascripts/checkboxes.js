$(function() {
  const mousedownOn = {
    id: '',
    checkState: false,
  };

  $('.calendar').mouseup(function() {
    mousedownOn.id = '';
  });

  $('.hours_checkbox input[type="checkbox"]')
      .mousedown(function(event) {
        const target = $(event.target);
        mousedownOn.id = target.attr('id');
        mousedownOn.checkState = target.prop('checked');
        target.prop('checked', !target.prop('checked'));
      })
      .mouseenter(function(event) {
        const target = $(event.target);

        if (mousedownOn.id != '' && mousedownOn.id != target.attr('id')) {
          target.prop('checked', !mousedownOn.checkState);
        }
      })
      .click(function(event) {
        event.preventDefault();
        return false;
      });
});
