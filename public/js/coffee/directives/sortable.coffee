angular.module("Museum.directives").directive 'sortable', ($http, errorProcessing, imageMappingHelpers, $i18next) ->
  restrict: 'A'
  scope:
    images: "=sortable"
    lang: "=lang"
  link: (scope, element, attrs) ->
    element  = $ element
    backend  = scope.$parent.backend_url || scope.$parent.$parent.backend_url
    element.disableSelection()
    console.log scope.lang
    element.sortable
      placeholder: "ui-state-highlight"
      tolerance: 'pointer'
      helper: 'clone'
      cancel: ".timestamp, .upload_item"
      items: "li:not(.timestamp):not(.upload_item)"
      # revert: true
      scroll: false
      delay: 100
      start: (event, ui) ->
        ui.item.data 'start', ui.item.index()
        ui.helper.addClass 'dragged'
        element.parents('.description').find('.timline_container').addClass('highlite')
      stop: ( event, ui ) ->
        elements = element.find('li')
        start    = ui.item.data('start')
        end      = ui.item.index()
        scope.images.splice(end, 0, scope.images.splice(start, 1)[0])
        element.parents('.description').find('.timline_container').removeClass('highlite')
        if scope.images[end].image.order isnt end
          orders = {}
          for image, index in scope.images
            image.image.order = index
            orders[image.image._id] = index
          imageMappingHelpers.update_images scope.images[0].image.parent, orders, backend
          scope.$apply()
