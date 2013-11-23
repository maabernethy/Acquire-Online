# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $("a[data-background-color]").click (event) ->
    event.preventDefault()

    $.getJSON(window.location.pathname+'.json').then((game) ->
      if game.hello
        console.log('Hello')
    )
