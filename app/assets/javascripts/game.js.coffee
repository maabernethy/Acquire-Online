# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $('a.cell').click (event) ->
    event.preventDefault()

    $.getJSON(window.location.pathname+'.json').then((game) ->
      if game.isCurrentPlayersTurn
        console.log('yes')
      console.log(game.test)
    )
