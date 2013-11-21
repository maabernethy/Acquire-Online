# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $("a[data-background-color]").click (event) ->
    event.preventDefault()

    $.getJSON(window.location.pathname).then((game) ->
      id = game.id
      console.log(id)
    )
