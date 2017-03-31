$(document).ready ->
  $ ->
    users = $("#promote-search").data("users")
    $("#promote-search").autocomplete source: users
    return
  return