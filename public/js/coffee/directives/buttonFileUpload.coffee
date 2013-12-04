angular.module("Museum.directives").directive "buttonFileUpload", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    # upload = $("##{attr[selector]}")

    elem.click (e) ->
      e.preventDefault()
      elem = $ @
      parent = elem.parents('#drop_down, #museum_edit_dropdown')
      parent.find(':file').click()
