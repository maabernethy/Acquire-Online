# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $('a.cell').click (event) ->
    event.preventDefault()
    id = $(this).data('id')
    console.log(id)

    inHand = (id, tiles) ->
      if id in tiles
        console.log('yes')
      else
        console.log('no')

    $.getJSON(window.location.pathname+'.json').then((game) ->
      if game.isCurrentPlayersTurn
        console.log('yes')
      tiles = game.playerHand
      console.log(tiles)
      inHand(id, tiles)
    )
