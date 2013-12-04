angular.module("Museum.directives").directive 'canDragAndDrop', (errorProcessing, $i18next) ->
  restrict : 'A'
  scope:
    model: '=model'
    url: '@uploadTo'
    selector: '@selector'
    selector_dropzone: '@selectorDropzone'
  link : (scope, element, attrs) ->

    scope.$parent.loading_in_progress = false

    fileSizeMb = 50

    element = $("##{scope.selector}")
    dropzone = $("##{scope.selector_dropzone}")

    checkExtension = (object) ->
      if object.files[0].name?
        extension = object.files[0].name.split('.').pop().toLowerCase()
        type = 'unsupported'
        type = 'image' if $.inArray(extension, gon.acceptable_extensions.image) != -1
        type = 'audio' if $.inArray(extension, gon.acceptable_extensions.audio) != -1
        type = 'video' if $.inArray(extension, gon.acceptable_extensions.video) != -1
      else
        type = object.files[0].type.split('/')[0]
        object.files[0].subtype = object.files[0].type.split('/')[1]
      type

    correctFileSize = (object) ->
      object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024

    hide_drop_area = ->
      $(".progress").hide()
      setTimeout ->
        $("body").removeClass "in"
        scope.$parent.loading_in_progress = false
        scope.$parent.forbid_switch = false
      , 1000

    initiate_progress = ->
      scope.$parent.loading_in_progress = true
      scope.$parent.forbid_switch = true
      scope.$digest()
      $("body").addClass "in"
      $(".progress .progress-bar").css "width", 0 + "%"
      $(".progress").show()

    file_types = []

    element.fileupload(
      url: scope.url
      dataType: "json"
      dropZone: dropzone
      change: (e, data) ->
        initiate_progress()
      drop: (e, data) ->
        initiate_progress()
        $.each data.files, (index, file) ->
          console.log "Dropped file: " + file.name
      add: (e, data) ->
        # console.log data
        type = checkExtension(data)
        if type is 'image' || type is 'audio' || type is 'video'
          if correctFileSize(data)
            file_types.push type
            parent = scope.model._id
            parent = scope.model.stories[scope.$parent.current_museum.language]._id if type is 'audio' || type is 'video'
            data.formData = {
              type: type
              parent: parent
            }
            data.submit()
            if type is 'audio'
              scope.model.stories[scope.$parent.current_museum.language].audio = 'processing'
          else
            errorProcessing.addError $i18next 'File is bigger than 50mb'
            hide_drop_area()
        else
          errorProcessing.addError $i18next 'Unsupported file type'
          hide_drop_area()
      success: (result) ->
        for file in result
          if file.type is 'image'
            scope.model.images = [] unless scope.model.images?
            new_image = {}
            new_image.image    = file
            new_image.mappings = {}
            if file.cover is true
              scope.$apply scope.model.cover = file
            scope.$apply scope.model.images.push new_image
          else if file.type is 'audio'
            scope.$apply scope.model.stories[scope.$parent.current_museum.language].audio = file
          else if file.type is 'video'
            scope.$apply scope.model.stories[scope.$parent.current_museum.language].video = file
          scope.$digest()
      error: (result, status, errorThrown) ->
        if errorThrown == 'abort'
          errorProcessing.addError $i18next 'Uploading aborted'
        else
          if result.status == 422
            response = jQuery.parseJSON(result.responseText)
            responseText = response.link[0]
            rrorProcessing.addError $i18next 'Error during file upload. Prototype error'
          else
            errorProcessing.addError $i18next 'Error during file upload. Prototype error'
        errorProcessing.addError $i18next 'Error during file upload. Prototype error'
        hide_drop_area()
      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        delimiter = 102.4
        speed = Math.round(data.bitrate / delimiter) / 10
        speed_text = "#{speed} Кб/с"
        if speed > 1000
          speed =  Math.round(speed / delimiter) / 10
          speed_text = "#{speed} Мб/с"
        $(".progress .progress-text").html "#{$i18next('&nbsp;&nbsp; Uploaded')} #{Math.round(data.loaded / 1024)} #{$i18next('Kb of')} #{Math.round(data.total / 1024)} #{$i18next('Kb, speed:')} #{speed_text}"
        $(".progress .progress-bar").css "width", progress + "%"
        if data.loaded is data.total
          scope.$parent.last_save_time = new Date()
          # detect prev file type uploaded
          # console.log data
          types = file_types.unique()
          console.log types
          if types.length is 1 and types[0] is 'audio'
            console.log 'file type is audio'
          else
            setTimeout ->
              first_image = element.parents('li').find('ul.images li.dragable_image a.img_thumbnail').last()
              first_image.click()
            , 1000
          ## should hide preloader
          element.parents('li').find('ul.images .museum_image_placeholder').hide()
          file_types = []
          hide_drop_area()
    ).prop("disabled", not $.support.fileInput).parent().addClass (if $.support.fileInput then `undefined` else "disabled")

    scope.$watch 'url', (newValue, oldValue) ->
      if newValue
        element.fileupload "option", "url", newValue if element.data('file_upload')
