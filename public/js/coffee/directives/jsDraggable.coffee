angular.module("Museum.directives").directive 'jsDraggable', ($rootScope, $i18next, imageMappingHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element

    weight_calc = imageMappingHelpers.weight_calc

    element.draggable
      axis: "x"
      containment: "parent"
      cursor: "pointer"
      start: (event, ui) ->
        image = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        image.dragging = true
      drag: (event, ui) ->
        current_time = imageMappingHelpers.calc_timestamp(ui, false)
        image        = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        if image?
          if image.mappings[$rootScope.lang].timestamp isnt current_time
            image.mappings[$rootScope.lang].timestamp = current_time
        true
      stop: ( event, ui ) ->
        console.log 'drag_stop'
        current_time   = imageMappingHelpers.calc_timestamp(ui, false)
        image          = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        image.dragging = false
        scope.$parent.set_hover( image, false )
        if image?
          if image.mappings[$rootScope.lang].timestamp isnt current_time
            image.mappings[$rootScope.lang].timestamp = current_time

        scope.$parent.container.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)

        orders = {}
        for item, index in scope.$parent.container.images
          item.image.order = index
          orders[item.image._id] = index
          if item.image._id is image.image._id
            imageMappingHelpers.update_image item, scope.$parent.$parent.backend_url

        imageMappingHelpers.update_images image.image.parent, orders, scope.$parent.$parent.backend_url

        scope.$parent.$parent.$digest()
        event.stopPropagation()
