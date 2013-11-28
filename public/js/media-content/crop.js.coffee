#= require jquery.Jcrop.min

class @Crop
  constructor: (@element, @modal, @initCallback) ->
    @image = @element.find('img')
    @progress = @element.parent().find('.progress')
    @cropImage = $('<img />', { class: 'hidden', src: @image.attr('data-crop-url') })
    @cropData = @image.attr('data-crop')
    @modal.find('.image-for-crop').html @cropImage
    @modalBody = @modal.find('.modal-body')

    @modalBody.css({'min-height': '200px'}).addClass('ajax-loader')
    @showModal()

    @cropImage.on 'load', =>
      @imageWidth = @cropImage.get(0).naturalWidth
      @imageHeight = @cropImage.get(0).naturalHeight

      options =
        boxWidth: 530
        boxHeight: 400
        setSelect: @getSelection()
        trueSize: [@imageWidth, @imageHeight]
        aspectRatio: @detectRatio()
        onChange: @onChange()

      jcrop = null

      @cropImage.removeClass('hidden')
      @modalBody.css({'min-height': '0'}).removeClass('ajax-loader')

      @cropImage.Jcrop options, -> jcrop = this
      @jcrop = jcrop

      @modal.unbind('hide').on 'hide', => @jcrop.destroy()
      @initCallback.call(@) if @initCallback

  cropDataArray: ->
    return false unless @cropData
    array = @cropData.split(/\s*,\s*/)

    if !array.empty() && array[0]
      array[0] = parseInt(array[0], 10)
      array[1] = parseInt(array[1], 10)
      array[2] = array[0] + parseInt(array[2], 10)
      array[3] = array[1] + parseInt(array[3], 10)
      array
    else
      false

  getSelection: ->
    cropSelect = @cropDataArray()

    if !cropSelect && @imageWidth && @imageHeight
      cropSelect = [0, 0, @imageWidth, @imageHeight]

    cropSelect

  detectRatio: (sel = @getSelection()) ->
    sameWidth = sel[2] == @imageWidth
    sameHeight = sel[3] == @imageHeight
    goodSizesHW = sameHeight && (sel[3] / sel[2] <= 3/4 + 1e-2)
    goodSizesWH = sameWidth && (sel[3] / sel[2] >= 3/4 - 1e-2)

    if (sameWidth || sameHeight) && (goodSizesHW || goodSizesWH)
      null
    else
      4/3

  onChange: ->
    self = @
    previousRatio = @detectRatio()
    ->
      unless @ instanceof Window
        sel = @tellSelect()
        sel = [parseInt(sel.x, 10),
               parseInt(sel.y, 10),
               parseInt(sel.w, 10),
               parseInt(sel.h, 10)]
        newRatio = self.detectRatio(sel)

        if newRatio != previousRatio
          previousRatio = newRatio
          @setOptions
            aspectRatio: newRatio

  showModal: ->
    @modal.modal 'show'

  hideModal: ->
    @modal.modal 'hide'

  save: (@saveCallback) ->
    data = new FormData
    cropOptions = @jcrop.tellSelect()
    @image.attr 'data-crop', [cropOptions.x, cropOptions.y, cropOptions.w, cropOptions.h].join(',')
    data.append 'image[crop_x]', cropOptions.x
    data.append 'image[crop_y]', cropOptions.y
    data.append 'image[crop_w]', cropOptions.w
    data.append 'image[crop_h]', cropOptions.h

    $.ajax
      url: @element.attr('href')
      type: 'POST'
      data: data
      cache: false
      contentType: false
      processData: false
      beforeSend: =>
        @progress.show().find('.bar').width('100%')
      success: (response) =>
        @update.apply(@, [response])
      error: (response) =>
        @error.apply(@, [response])
      complete: =>
        @progress.hide().find('.bar').width('0%')
        @saveCallback.call(@) if @saveCallback

  update: (response) ->
    @image.attr 'src', (response.thumb + '?_=' + new Date().getTime())

  error: (response) ->
    if response.status == 422
      errors = jQuery.parseJSON(response.responseText)
      if errors.link
        Message.error err for err in errors.link

$ ->
  $('#images').on 'click', 'li form a.thumbnail', (e) ->
    e.preventDefault()

    modal = $('#crop_modal')
    saveBtn = modal.find('.save-crop')
    crop = new Crop $(this), modal

    saveBtn.unbind('click').on 'click', ->
      crop.hideModal()
      crop.save -> $('a.thumb').trigger 'image:cropped'
