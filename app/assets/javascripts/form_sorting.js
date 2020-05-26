$( document ).ready( function() {
    $('.sortable').sortable({
      stop: function() {
        reAttribute();
      },
    });
  
    $('#add-new').click(function() {
      const newField = $('.hidden').find('.row.field-row').clone(true).removeClass('hidden');
      newField.appendTo('.container.sortable');
      reAttribute();
      $('.sortable').sortable('refresh');
    });
  
    $('.remove').click(function() {
      const parentField = $(this).parents('.row.field-row');
      parentField.remove();
      reAttribute(); // This one works.
    });
  
    $('.data-type select').change(function() {
      toggleFields(this);
      reAttribute();
    });
  }); // END of document.ready
  
  function takesPlaceholder(value) {
    return ['date', 'date/time', 'long-text', 'text', 'time'].includes(value);
  }
  function reAttribute() {
    $('.number input:visible').each(function(index) {
      $(this).attr('name', newName('number', index))
      $(this).attr('id', 'form_draft_fields_attributes_' + index + '_number');
      $(this).val(index + 1);
      const parentField = $(this).parents('.row.field-row');
      [
        '.prompt textarea',
        '.placeholder input',
        '.required input',
        '.data-type select',
        '.options textarea'
      ].forEach(function(className){
        let name = className.match(/.\w+/)[0].slice(1);
        if(name=='data'){
          name = 'data_type'
        }
        parentField.find(className).attr('name', newName(name, index));
        parentField.find(className).attr('id', newID(name, index));
      })
    });
  }
  function newName(fieldType, index){
    return 'form_draft[fields_attributes][' + index + '][' + fieldType + ']';
  }
  // the number of padded fields will the number of visible fields + 1,
  // which is what we want for the number of a new visible field.
  function newID(fieldType, index){
    return 'form_draft_fields_attributes_' + index + '_' + fieldType
  }
  function toggleFields(dataField) {
    const dataType = dataField.value;
    const container = $(dataField).parents('.field-row');
    togglePlaceholder(dataType, container);
    toggleOptions(dataType, container);
    toggleRequiredCheckbox(dataType, container);
  }
  function toggleOptions(dataType, container) {
    if (dataType == 'options') {
      const placeholder = 'separate options by any special character (space, comma, etc)';
      const newField = $('<textarea placeholder="' + placeholder + '" class="form-control" rows="4">');
      newField.appendTo(container.find('.options'));
    } else {
        container.find('.options').children().remove();
    }
  }
  function togglePlaceholder(dataType, container) {
    if (takesPlaceholder(dataType) == true) {
      if (container.find('.placeholder').children().length == 0) {
        const newField = $('<input class="form-control" type="text">')
        newField.appendTo(container.find('.placeholder'));
      }
    } else {
      container.find('.placeholder').children().remove();
    }
  }
  function toggleRequiredCheckbox(dataType, container){
    if (dataType == 'heading' || dataType == 'explanation') {
      container.find('.required').children().remove();
    } else {
      if (container.find('.required').children().length == 0) {
        const newField = $('<input type="checkbox">')
        newField.appendTo(container.find('.required'));
      }
    }
  }