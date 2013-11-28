#= require jQuery-File-Upload/vendor/jquery.ui.widget.js
#= require jQuery-File-Upload/jquery.iframe-transport.js
#= require jQuery-File-Upload/jquery.fileupload.js
#= require jQuery-File-Upload/jquery.fileupload-fp.js
#= require jQuery-File-Upload/locale.js

fileSizeMb = 50
# acceptableExtensions = gon.acceptable_extensions
acceptableExtensions = {"audio":["mp3","ogg","aac","wav","amr","3ga","m4a","wma","mp4","mp2","flac"],"image":["jpg","jpeg","gif","png","tiff","bmp"],"video":["mp4","m4v"]}

@correctExtension = (object) ->
  extension = object.files[0].name.split('.').pop().toLowerCase()
  $.inArray(extension, acceptableExtensions[object.fileInput.context.dataset.accept]) != -1

@correctFileSize = (object) ->
  object.files[0] && object.files[0].size < fileSizeMb * 1024 * 1024

@initFileUpload = (e, object = null, options={}) ->
  (object || $('.fileupload')).each ->
    upload = null
    $this = $ this
    form = $this.parent('form')
    container = form.parent()
    button = form.find('a.btn.browse')
    cancel = form.find('a.btn.cancel')
    progress = options.progress || form.find('.progress')

    cancel.unbind 'click'
    cancel.bind 'click', (e) ->
      e.preventDefault()
      upload.abort() if upload

    $this.fileupload
      add: (e, data) ->
        if correctExtension(data)
          if correctFileSize(data)
            button.addClass 'disabled'
            cancel.removeClass 'hide'
            progress.removeClass 'hide'
            data.form.find('.help-tooltip').remove()
            data.submit()
          else
            Message.error t('message.errors.media_content.file_size', file_size: fileSizeMb)
        else
          Message.error t('message.errors.media_content.file_type')
      beforeSend: (jqXHR) ->
        progress.find('.bar').width('0%')
        upload = jqXHR
      success: (result) ->
        container.replaceWith(result).hide().fadeIn ->
          $('a.thumb').trigger 'image:uploaded'
        $('#edit_story_form').trigger 'form:loaded'
        Message.notice t('message.media_content.uploaded')
      complete: ->
        cancel.addClass 'hide'
        progress.addClass 'hide'
        button.removeClass 'disabled'
      error: (result, status, errorThrown) ->
        $this.val ''
        if errorThrown == 'abort'
          Message.notice t('message.media_content.canceled')
        else
          if result.status == 422
            response = jQuery.parseJSON(result.responseText)
            responseText = response.link[0]
            Message.error responseText
          else
            Message.error t('message.errors.media_content.try_again')
      progressall: (e, data) ->
        percentage = parseInt(data.loaded / data.total * 100, 10)
        progress.find('.bar').width(percentage + '%')

# load media urls and check that url exist
@checkAudioFiles = ->
  $('#audio_form[data-audio-check-url]').each ->
    $this = $(this)
    url = $this.data 'audio-check-url'

    $.ajax
      url: url
      type: 'GET'
      dataType: 'json'
      success: (response) ->
        $.each response, (key, item) ->
          btn = $('.btn.' + key)

          if item.exist
            audio = $this.find('.audio-upload-form').find('audio.' + key)
            audio.empty()
            $('<source>').attr('src', item.file).appendTo audio
            audioElement = audio.get(0)

            if audioElement
              audioElement.pause()
              audioElement.load()
              canPlay = !!audioElement.canPlayType && audioElement.canPlayType(item.content_type) != ''
              console.log canPlay + ' - ' + item.content_type

            $('.play.' + key).find('i').removeClass('icon-pause').addClass 'icon-play'
            if canPlay
              btn.removeClass 'disabled hide'
            else
              btn.addClass('disabled').removeClass('hide')
          else
            btn.addClass 'disabled'
      error: ->
        Message.notice t('message.media_content.not_processed_yet')

$ ->
  $(document).on 'click', 'form a.browse', ->
    $this = $(this)
    form = $this.parents 'form'
    unless $this.hasClass('disabled')
      form.find(':file').trigger 'click'

  initFileUpload()
