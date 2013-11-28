String.prototype.truncate = (n) ->
  dots = '…' if this.length > n
  return this.substr(0, n-1) + (dots || '')

$ ->
  class MuseumMap
    constructor: (@element, @modal, @planInput) ->
      @container = @element.parents('li')
      @image = @element.find('img')
      @progress = @container.find('.progress')
      @planName = @element.data('title')
      @planInput.val @planName
      @modalBody = @modal.find('.modal-body')
      @modalImage = @modalBody.find('img')
      @modalContainer = @modalBody.find('.modal-container')
      @file = @modal.find(':file').get(0)

      @modalContainer.addClass('hidden')
      @modalImage.attr 'src', @image.attr('src')
      @modalBody.css({'min-height': '200px'}).addClass('ajax-loader')
      @showModal()

      @modalImage.on 'load', =>
        @modalContainer.removeClass('hidden')
        @modalBody.css({'min-height': '0'}).removeClass('ajax-loader')
        @initCallback.call(@) if @initCallback

    showModal: ->
      @modal.modal 'show'

    hideModal: ->
      @modal.modal 'hide'
      @clearImage()

    clearImage: ->
      @modalImage.attr 'src', ''

    save: (@saveCallback) ->
      @progress.show().find('.bar').width('0%')

      progressSave = (evt) =>
        if evt.lengthComputable
          percentComplete = (evt.loaded / evt.total) * 100
          @progress.find('.bar').width "#{percentComplete}%"

      data = new FormData
      data.append 'map[title]', @planInput.val()
      data.append 'map[link]', @file.files[0] if @file.files[0]
      $.ajax
        url: @element.attr('href')
        xhr: ->
          xhr = new XMLHttpRequest()
          xhr.upload.addEventListener 'progress', progressSave, false
          xhr
        type: 'PUT'
        data: data
        cache: false
        contentType: false
        processData: false
        success: (response) =>
          @update.call(@, response)
        error: (response) =>
          @error.call(@, response)
        complete: =>
          @saveCallback.call(@) if @saveCallback
          @progress.hide()

    update: (response) ->
      @container.replaceWith response

    error: (response) ->
      if response.status == 422
        errors = jQuery.parseJSON(response.responseText)
        if errors.link
          for err in errors.link
            Message.error err

  $('#maps').on 'click', 'li form a.thumbnail', (e) ->
    e.preventDefault()

    modal = $('#map_modal')
    saveBtn = modal.find('.save-map')
    updateBtn = modal.find('.change-map')
    planName = modal.find('#plan_name')
    fileField = modal.find('#new_file')

    museumMap = new MuseumMap $(this), modal, planName

    saveBtn.unbind('click').on 'click', ->
      museumMap.hideModal()
      museumMap.save()

    modal.on 'hidden', -> museumMap.clearImage()
    fileField.val ''

    updateBtn.attr 'title', ''
    updateBtn.text updateBtn.data('default')
    updateBtn.unbind('click').on 'click', ->
      $this = $(this)
      fileField.trigger 'click'

    fileField.on 'change', ->
      if this.files[0]
        name = this.files[0].name
        updateBtn.text name.truncate(30)
        updateBtn.attr 'title', name
