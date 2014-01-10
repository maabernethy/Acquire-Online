$ ->
  $('a.change_cell').bind("ajax:success", (event, data, status, xhr) ->
    if data.form?
      identifier = data.form
      $(identifier).css "visibility", 'visible'
    console.log(data)
    $("#response1").text(data.legal)
    if data.legal
      color = data.color
      $(this).parent().css "background", color
      list = ""
      for tile in data.new_tiles
        list =  list + "<li>" + tile + "</li>"
      console.log(list)
      $('.hand').html(list)
      if data.other_tiles?
        for tile in data.other_tiles
          id_string = "'#" + tile + "'"
          $(id_string).css "background", color
  )
