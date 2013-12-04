angular.module("Museum.directives").directive 'openLightbox', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    parent   = element.parents('#drop_down, #museum_edit_dropdown')
    lightbox = parent.find('.lightbox_area')
    element.click ->
      if element.parents('li').hasClass('dragged')
        element.parents('li').removeClass('dragged')
      else
        lightbox.show()
        parent.height(lightbox.height() + 45) if lightbox.height() + 45 > parent.height()
        setTimeout ->
          $(".slider:visible .thumb.item_#{attrs.openLightbox} img").click()
        , 100
    true
