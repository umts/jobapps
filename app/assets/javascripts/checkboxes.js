var mousedownOn = {
  id: '',
  checkState: false
};

$(".calendar").mouseup(function() {
  mousedownOn.id = '';
});

$('.hours_checkbox input[type="checkbox"]')
    .mousedown(function() {
      var $this = $(this);
      mousedownOn.id = $this.attr('id');
      mousedownOn.checkState = $this.prop('checked');
      $this.prop('checked',!$this.prop('checked'));
  })
  .mouseenter(function() {
      var $this = $(this);

      if (mousedownOn.id != '' && mousedownOn.id != $this.attr('id')){
          $this.prop('checked',!mousedownOn.checkState);
      }
  })
  .click(function(e) {
      e.preventDefault();
      return false;
  });

//javascript source comes from http://jsfiddle.net/ebStc/7/
