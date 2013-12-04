angular.module("Museum.directives").directive 'lightboxCropper', ($http, errorProcessing, $i18next) ->
  restrict: "E"
  replace: true
  transclude: true
  scope:
    model: '=model'
  template: """
    <div class="lightbox_area">
      <ul class="nav nav-tabs">
        <li ng-class="{'active': story_tab == 'thumb'}">
          <a href="#" ng-click="update_media(active_image_index); story_tab = 'thumb'" >{{ 'Select thumbnail area' | i18next }}</a>
        </li>
        <li ng-class="{'active': story_tab == 'full'}">
          <a href="#" ng-click="update_media(active_image_index); story_tab = 'full'" >{{ 'Select fullsize image area' | i18next }}</a>
        </li>        
      </ul>
        <button class="btn btn-warning apply_resize" type="button">{{ "Done image editing" | i18next }}</button>
        <div class="lightbox_preloader">
          <img src="/img/big_loader_2.GIF">
        </div>
        <div class="content {{story_tab}}">
          <div class="cropping_area {{story_tab}}">
            {{story_tab}}
            <img class="cropper_thumb" src="{{model.images[active_image_index].image.fullUrl || model.images[active_image_index].image.url}}">
            <img class="cropper_full" src="{{model.images[active_image_index].image.url}}">
          </div>
          <div class="notification" ng-switch on="story_tab">
            <span ng-switch-when="thumb">
              {{ "Select the preview area. Images won't crop. You can always return to this later on." | i18next }}
            </span>
            <span ng-switch-when="full">
              {{ "Images won't crop. You can always return to this later on." | i18next }}
            </span>
          </div>
          <div class="preview" ng-hide="story_tab == 'full'">
            {{ "Thumbnail preview" | i18next }}
            <div class="mobile">
              <div class="image">
                <img src="{{ model.images[active_image_index].image.fullUrl || model.images[active_image_index].image.url }}">
              </div>
            </div>
          </div>
        </div>
        <div class="slider">
          <ul class="images_sortable" sortable="model.images" lang="$parent.current_museum.language">
            <li class="thumb item_{{$index}} " ng-class="{'active':image.image.active, 'timestamp': image.mappings[lang].timestamp >= 0}" ng-repeat="image in images">
              <img ng-click="$parent.$parent.set_index($index)" src="{{image.image.thumbnailUrl}}" />
              <div class="label_timestamp" ng-show="image.mappings[lang].timestamp >= 0">
                <span class="letter_label">
                  {{ image.image.order | numstring }}
                </span>
                <span class="time">
                  {{ image.mappings[lang].timestamp | timerepr }}
                </span>
              </div>
              <a class="cover pointer_events" ng-class="{'active':image.image.cover}" ng-click="$parent.$parent.make_cover($index)" ng-switch on="image.image.cover">
                <span ng-switch-when="true"><i class="icon-ok"></i> {{ "Cover" | i18next }}</span>
                <span ng-switch-default><i class="icon-ok"></i> {{ "Set cover" | i18next }}</span>
              </a>
            </li>
          </ul>
        </div>
    </div>
  """
  controller: ($scope, $element, $attrs) ->

    $scope.set_index = (index, tab) ->
      $scope.update_media $scope.active_image_index, ->
        $scope.active_image_index = index
        if tab? and tab isnt $scope.story_tab
          $scope.story_tab = tab

    $scope.make_cover = (index) ->
      console.log 'making a cover'
      $scope.model.cover = $scope.model.images[index].image
      for image in $scope.model.images
        if image.image._id isnt $scope.model.cover._id
          image.image.cover = false
        else
          image.image.cover  = true
          $scope.model.cover = image.image
          setTimeout (->
            @.order = 0).bind(image.image)()
          , 500
        $http.put("#{$scope.$parent.backend_url}/media/#{image.image._id}", image.image).success (data) ->
          console.log 'ok'
        .error ->
          errorProcessing.addError $i18next 'Failed to set cover' 

    $scope.check_active_image = ->
      for image, index in $scope.model.images
        image.image.active = if index is $scope.active_image_index
          true
        else
          false
      
  link: (scope, element, attrs) ->
    # scope.active_image_index = 0
    scope.story_tab  = 'thumb'
    scope.img_url    = ''
    element          = $ element
    preloader        = element.find('.lightbox_preloader')
    content          = element.find('.content')
    right            = element.find('a.right')
    left             = element.find('a.left')
    cropper_thumb    = element.find('.cropping_area img.cropper_thumb')
    cropper_full     = element.find('.cropping_area img.cropper_full')
    preview          = element.find('.mobile .image img')
    done             = element.find('.apply_resize')
    parent           = element.parents('#drop_down, #museum_edit_dropdown')
    imageWidth       = 0
    imageWidth_full  = 0
    imageHeight_full = 0
    imageHeight      = 0
    max_height       = 330
    max_width        = 450
    prev_height      = 133
    prev_width       = 177
    selected_thumb   = {}
    selected_full    = {}
    bounds           = []

    done.click ->
      scope.update_media scope.active_image_index
      scope.story_tab = 'thumb'
      # this line resizes parent back
      parent.attr('style', '')
      #####
      element.hide()
      false

    scope.update_media = (index, callback) ->
      console.log 'updating media'
      if scope.story_tab is 'full'
        selected = selected_full
        preloader.show()
        content.hide()
        console.log 'hiding thumb'
      else
        selected = selected_thumb
      scope.active_image_index = 0 unless scope.model.images[scope.active_image_index]?
      $http.put("#{scope.$parent.backend_url}/resize_thumb/#{scope.model.images[scope.active_image_index].image._id}", selected).success (data) ->
        # console.log data

        # console.log scope.model.images[index].image.thumbnailUrl, data.thumbnailUrl

        delete scope.model.images[index].image.url
        delete scope.model.images[index].image.fullUrl
        delete scope.model.images[index].image.selection
        delete scope.model.images[index].image.full_selection
        delete scope.model.images[index].image.thumbnailUrl
        # cropper_thumb.attr('src', data.thumbnailUrl)
        angular.extend(scope.model.images[index].image, data)
        ## and now - close preloader and show data with 50ms delay
        # console.log selected
        # setTimeout ->
        #   preloader.hide()
        #   content.show()
        # , 200 if selected.mode is 'thumb'
        callback() if callback
        return true
      .error ->
        errorProcessing.addError $i18next 'Failed to update a thumbnail'
        return false

    showPreview = (coords) ->
      selected_thumb = coords
      selected_thumb.mode = 'thumb'
      rx = 177 / selected_thumb.w
      ry = 133 / selected_thumb.h
      preview.css
        width: Math.round(rx * bounds[0]) + "px"
        height: Math.round(ry * bounds[1]) + "px"
        marginLeft: "-" + Math.round(rx * selected_thumb.x) + "px"
        marginTop: "-" + Math.round(ry * selected_thumb.y) + "px"

    getSelection = (selection) ->
      # console.log selection
      result = [selection.x, selection.y, selection.x2, selection.y2] #array [ x, y, x2, y2 ]
      result

    update_selection = (coords) ->
      selected_full      = coords
      selected_full.mode = 'full'
      true

    cropper_thumb.on 'load', ->
      console.log 'thumb reloaded'
      preloader.hide()
      content.show()
      setTimeout (->
        imageWidth  = cropper_thumb.get(0).naturalWidth
        imageHeight = cropper_thumb.get(0).naturalHeight

        new_imageWidth  = imageWidth
        new_imageHeight = imageHeight

        if imageHeight > max_height
          new_imageWidth  = imageWidth * ( max_height / imageHeight )
          new_imageHeight = max_height

        if new_imageWidth > max_width
          new_imageHeight = new_imageHeight * (max_width / new_imageWidth)
          new_imageWidth  = max_width

        cropper_thumb.height new_imageHeight
        cropper_thumb.width new_imageWidth

        # console.log imageWidth, imageHeight, new_imageWidth, new_imageHeight

        preview.attr 'style', ""

        selection = scope.model.images[scope.active_image_index].image.selection

        if selection
          selected_thumb = JSON.parse selection
        else
          selected_thumb = {
            x: 0
            y: 0
            w: imageWidth
            h: imageHeight
            x2: imageWidth
            y2: imageHeight
            mode: 'thumb'
          }

        options =
          boxWidth: cropper_thumb.width()
          boxHeight: cropper_thumb.height()
          setSelect: getSelection(selected_thumb)
          trueSize: [imageWidth, imageHeight]
          onChange: showPreview
          onSelect: showPreview
          aspectRatio: 4 / 3
        
        @thumb_jcrop.destroy() if @thumb_jcrop

        thumb_jcrop = null

        cropper_thumb.Jcrop options, -> 
          thumb_jcrop = @
          bounds = thumb_jcrop.getBounds()

        showPreview selected_thumb

        @thumb_jcrop = thumb_jcrop
      ).bind(@)
      , 20

    cropper_full.on 'load', ->
      setTimeout (->
        imageWidth_full  = cropper_full.get(0).naturalWidth
        imageHeight_full = cropper_full.get(0).naturalHeight

        new_full_imageWidth  = imageWidth_full
        new_full_imageHeight = imageHeight_full

        if imageHeight_full > max_height
          new_full_imageWidth  = imageWidth_full * ( max_height / imageHeight_full )
          new_full_imageHeight = max_height

        if new_full_imageWidth > max_width
          new_full_imageHeight = new_full_imageHeight * (max_width / new_full_imageWidth)
          new_imageWidth  = max_width

        cropper_full.height new_full_imageHeight
        cropper_full.width new_full_imageWidth

        full_selection = scope.model.images[scope.active_image_index].image.full_selection

        if full_selection
          selected_full = JSON.parse full_selection
        else
          selected_full = {
            x: 0
            y: 0
            w: imageWidth_full
            h: imageHeight_full
            x2: imageWidth_full
            y2: imageHeight_full
            mode: 'full'
          }

        options =
          boxWidth: cropper_full.width()
          boxHeight: cropper_full.height()
          setSelect: getSelection(selected_full)
          trueSize: [imageWidth_full, imageHeight_full]
          onChange: update_selection
          onSelect: update_selection
        
        @full_jcrop.destroy() if @full_jcrop

        full_jcrop = null

        cropper_full.Jcrop options, -> 
          full_jcrop = @
          # bounds = full_jcrop.getBounds()

        # showPreview selected_full

        @full_jcrop = full_jcrop
      ).bind(@)
      , 20

    scope.$watch 'model.images', (newValue, oldValue) ->
      if newValue?
        scope.story_tab = 'thumb'
        if newValue.length > 0
          for image in newValue
            image.image.active = false
          newValue[0].active = true
          left.css({'opacity': 0})
          scope.active_image_index = 0

    # scope.$watch 'story_tab', (newValue, oldValue) ->
    #   scope.update_media scope.active_image_index

    scope.$watch 'active_image_index', (newValue, oldValue) ->
      scope.check_active_image()      

    true
