$(document).ready ->
  $('.phone').keydown((e) ->
    key = e.charCode or e.keyCode or 0
    phone = $(this)
      
    # Auto-format - do not expose the mask as the user begins to type

    if key != 8 and key != 9
      if phone.val().length == 4
        phone.val phone.val() + ')'
      if phone.val().length == 5
        phone.val phone.val() + ' '
      if phone.val().length == 9
        phone.val phone.val() + '-'

      # Allow numeric, tab, backspace, delete keys only
      key == 8 or key == 9 or key == 46 or key >= 48 and key <= 57 or key >= 96 and key <= 185
    
  ).bind('focus click', ->
    phone = $(this)
    if phone.val().length == 0
      phone.val '('
    else
      val = phone.val();
      phone.val('').val val 
      # ensure cursor remains at end
    return

  ).blur ->
    phone = $(this)
    if phone.val() == '('
      phone.val ''
    return
  return
