$(function() {
  $('.sortable').sortable({
    stop: function() {
      reAttribute();
    },
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
    $(event.target).parents('.row.field-row').remove();
    reAttribute();
  });
});

function reAttribute() {
  $('#fields-container').find('.row.field-row').each(function(index, element) {
    const currentRow = $(element);
    const number = currentRow.find('.number input');

    number.val(index + 1).attr({'name': newName('number', index), 'id': newID('number', index)});
    currentRow.find('.prompt textarea').attr({'name': newName('prompt', index), 'id': newID('prompt', index)});
    currentRow.find('.data-type select').attr({'name': newName('data_type', index), 'id': newID('data_type', index)});
    currentRow.find('.field-required input').attr({'name': newName('required', index), 'id': newID('required', index)});
  });
}

function newName(fieldType, index) {
  return 'draft[questions_attributes][' + index + '][' + fieldType + ']';
}

function newID(fieldType, index) {
  return 'draft_questions_attributes_' + index + '_' + fieldType;
}
