angular.module("Museum.directives").directive 'droppable', ($http, errorProcessing, $i18next, imageMappingHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    element.droppable
      accept: '.dragable_image'
      out: ( event, ui ) ->
        element.removeClass 'can_drop'
      over: ( event, ui ) ->
        element.addClass 'can_drop'
      drop: ( event, ui ) -> 
        target_storyset = if element.hasClass 'active_exhibit'
          scope.active_exhibit
        else if element.hasClass 'current_museum'
          scope.current_museum
        element.removeClass 'can_drop'
        # sortable.sortable( "option", "disabled", true )
        # setTimeout ->
        #   sortable.sortable( "option", "disabled", false )
        #   sortable.sortable( "refresh" )
        #   sortable.sortable( "refreshPositions" )
        # , 300
        found     = false
        dropped   = ui.draggable
        droppedOn = $ @
        dropped.attr('style', '')
        seek_bar = element.find('.jp-seek-bar')
        jp_durat = element.find('.jp-duration')
        jp_play  = element.find('.jp-play')

        target_image  = target_storyset.images[dropped.data('array-index')]

        mapped_images = target_storyset.stories[scope.current_museum.language].mapped_images
        mapped_images = [] unless mapped_images?        
        mapped_images.push target_image

        target_image.mappings[dropped.data('lang')] = {}
        target_image.mappings[dropped.data('lang')].timestamp = imageMappingHelpers.calc_timestamp(ui, true)
        target_image.mappings[dropped.data('lang')].language  = dropped.data('lang')
        target_image.mappings[dropped.data('lang')].media     = target_image.image._id
        target_storyset.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)

        orders = {}
        for item, index in target_storyset.images
          item.image.order = index
          orders[item.image._id] = index

        imageMappingHelpers.update_images target_image.image.parent, orders, scope.backend_url

        imageMappingHelpers.create_mapping target_image, scope.backend_url

        scope.$digest()

        scope.recalculate_marker_positions(target_storyset.stories[scope.current_museum.language], element)

    true
