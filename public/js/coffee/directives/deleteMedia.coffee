angular.module("Museum.directives").directive 'deleteMedia', (storySetValidation, $http) ->
  restrict : 'A'
  scope:
    model: '=parent'
    media: '=media'
  link : (scope, element, attrs) ->
    element        = $ element
    delete_overlay = element.next('.delete_overlay')
    element.click (e) ->
      e.preventDefault()
      e.stopPropagation()
      elem   = $ @

      confirm_text = elem.data('confirm')
      show_overlay = elem.data('show-overlay')
      silent       = elem.data('silent-delete')

      delete_media_function = ->
        # console.log scope.media
        $http.delete(elem.data('link')).success (data) ->
          if show_overlay
            delete_overlay.hide()
            delete_overlay.find('.preloader').hide()
            delete_overlay.find('.overlay_controls, span').show()

          if scope.media.type is 'image'
            for image, index in scope.model.images
              if image?
                if image.image._id is data._id
                  scope.model.images.splice index, 1
                  if image.image.cover is true
                    new_cover = scope.model.images[0]
                    new_cover.image.cover = true
                    scope.model.cover = new_cover.image
                    $http.put("#{scope.$parent.$parent.$parent.backend_url}/media/#{new_cover.image._id}", new_cover.image).success (data) ->
                      console.log 'ok'
                    .error ->
                      console.log 'bad'
                    # imageMappingHelpers.update_image new_cover, scope.$parent.$parent.backend_url

                  # scope.$digest()
            if scope.model.images.length is 0 && scope.model.stories[scope.$parent.$parent.$parent.current_museum.language].status is 'published'
              storySetValidation.checkValidity {item: scope.model.stories[scope.$parent.$parent.$parent.current_museum.language], root: scope.model, field_type: 'story'}
          else if scope.media.type is 'audio'
            parent = scope.$parent.$parent.active_exhibit
            lang   = scope.$parent.$parent.current_museum.language
            # client-side removal
            scope.model.audio         = undefined
            scope.model.mapped_images = []
            scope.$parent.$parent.exhibit_timline_opened = false
            for image in parent.images
              mapping = image.mappings[lang]
              if mapping?
                delete image.mappings[lang]
                # server-side removal
                $http.delete("#{scope.$parent.$parent.backend_url}/media_mapping/#{mapping._id}").success (data) ->
                  console.log data
                .error ->
                  errorProcessing.addError $i18next 'Failed to delete timestamp'
            scope.$digest()
            if scope.model.status is 'published'
              storySetValidation.checkValidity {item: scope.model, root: parent, field_type: 'story'}
          scope.$parent.last_save_time = new Date()

      if show_overlay
        delete_overlay.show()
        delete_overlay.find('.delete').unbind('click').bind 'click', (e) ->
          delete_overlay.find('.preloader').show()
          delete_overlay.find('.overlay_controls, span').hide()
          delete_media_function()
          e.preventDefault()
        delete_overlay.find('.btn-sm.cancel').unbind('click').bind 'click', (e) ->
          delete_overlay.hide()
          e.preventDefault()
      else if silent
        delete_media_function()
      else
        delete_media_function() if confirm confirm_text
