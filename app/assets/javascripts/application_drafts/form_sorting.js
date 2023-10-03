$(function() {
  $('.sortable').sortable({
    stop: function() {
      reAttribute();
    }
  });

  $('#add-field-button').on('click', function(event) {
    event.preventDefault();
    const newField = $('#hidden-field-container').find('.field-row').clone(true);
    newField.appendTo('#fields-container');
    reAttribute();
    $('.sortable').sortable('refresh');
  });

  $(document).on('click', '.remove-field-button', function(event) {
    event.preventDefault();
    $(this).parents('.row.field-row').remove();
    reAttribute();
  });
});

function reAttribute() {
  $('#fields-container').find('.row.field-row').each(function(index) {
    let currentRow = $(this)
    let selectors = {};
    selectors['number'] = '.number input'
    selectors['prompt'] = '.prompt textarea'
    selectors['data_type'] = '.data-type select'
    selectors['required'] = '.field-required input'
    for(const fieldType in selectors) {
      let field = currentRow.find(selectors[fieldType]);
      if(fieldType == 'number') field.val(index + 1);
      field.attr('name', newName(fieldType, index));
      field.attr('id', newID(fieldType, index))
    }
  });
}

function newName(fieldType, index){
  return 'draft[questions_attributes][' + index + '][' + fieldType + ']';
}

function newID(fieldType, index){
  return 'draft_questions_attributes_' + index + '_' + fieldType
}
