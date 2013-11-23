# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $("a[data-background-color]").click (event) ->
    event.preventDefault()
    console.log('yo')

    $.getJSON(window.location.pathname+'.json').then((game) ->
      console.log(game.isCurrentPlayersTurn)
    )
