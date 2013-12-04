angular.module("Museum.directives").directive 'dragAndDropInit', (uploadHelpers) ->
  link: (scope, element, attrs) ->

    $(document).bind 'drop dragover', (e) ->
      e.preventDefault()

    $(document).bind "dragover", (e) ->

      if $(e.originalEvent.srcElement).hasClass 'do_not_drop'
        e.preventDefault()
        e.stopPropagation()
        return false 

      dropZone = $(".dropzone")
      doc      = $("body")
      timeout = scope.dropZoneTimeout
      unless timeout
        doc.addClass "in"
      else
        clearTimeout timeout
      found = false
      found_index = 0
      node = e.target
      loop
        if node is dropZone[0]
          found = true
          found_index = 0
          break
        else if node is dropZone[1]
          found = true
          found_index = 1
          break
        node = node.parentNode
        break unless node?
      if found
        dropZone[found_index].addClass "hover"
      else
        scope.dropZoneTimeout = setTimeout ->
          unless scope.loading_in_progress
            scope.dropZoneTimeout = null
            dropZone.removeClass "in hover"
            doc.removeClass "in"
        , 300

    $(document).bind "drop", (e) ->
      fileupload = $(e.originalEvent.target).parents('li').find("input[type='file']")
      if e.originalEvent.dataTransfer
        if $(e.target).hasClass 'do_not_drop'
          e.stopPropagation()
          e.preventDefault()
          return false 
        url = $(e.originalEvent.dataTransfer.getData("text/html")).filter("img").attr("src")
        if url
          if url.indexOf('data:image') >= 0
            type = url.split(';base64')[0].split('data:')[1]
            img = new Image()
            img.src = url
            img.onload = ->
              uploadHelpers.cavas_processor img, type
          else
            $.getImageData
              url: url
              server: "#{scope.backend_url}/imagedata"
              success: uploadHelpers.cavas_processor     
