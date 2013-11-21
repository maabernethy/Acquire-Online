# $ ->
  # $(".board").click ->
      # $(this).css "background", "yellow"

$ ->
  $("a[data-background-color]").click (event) ->
    event.preventdDefault()
    backgroundColor = $(this).data("background-color")
    paintIt(this, backgroundColor)

    $.getJSON("/games_controller/show").then((data) ->
      id = data.id
      console.log(id)
    )

  paintIt = (element, backgroundColor, textColor) ->
    element.style.backgroundColor = backgroundColor

