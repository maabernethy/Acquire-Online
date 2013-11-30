# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $('a.change_cell').bind("ajax:success", (event, data, status, xhr) ->
      $(this).parent().css "background", "blue"
      $("#response1").text(data.new_tiles)
      $("#response2").text(data.legal)
      console.log(data)
    )

  # $('a.change_cell').each (index, cell) ->
  #   cell.bind("ajax:success", (event, data, status, xhr) ->
  #     $(this).parent().css "background", "blue"
  #     console.log(data)
  #   )

    # $.getJSON(window.location.pathname+'.json').then((game) ->
      # if game.isCurrentPlayersTurn
        # console.log('yes')
      # console.log(game.test)
    # )
