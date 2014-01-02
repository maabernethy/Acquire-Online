$ ->
  # $('a.change_cell').bind("ajax:success", (event, data, status, xhr) ->
  #   console.log(data)
  #   $("#response1").text(data.legal)
  #   if data.legal
  #     color = data.color
  #     $(this).parent().css "background", color
  #     list = ""
  #     for tile in data.new_tiles
  #       list =  list + "<li>" + tile + "</li>"
  #     console.log(list)
  #     $('.hand').html(list)
  #     for tile in data.other_tiles if data.other_tiles?
  #       id_string = "'#" + tile + "'"
  #       $(id_string).css "background", color
  #   )
  $('a.load_div').bind("ajax:success", (event, data, status, xhr) ->
    console.log(data)
    game = data.game
    console.log(game.bank)
    game.bank = 200
    console.log(game.bank)
    game.save
  )