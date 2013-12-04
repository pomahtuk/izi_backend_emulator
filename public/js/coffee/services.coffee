"use strict"

# Services 

angular.module("Museum.services", []).service "sharedProperties", ($rootScope) ->
  property = {}
  getProperty: (name) ->
    property[name]

  setProperty: (name, value) ->
    property[name] = value
    $rootScope.$broadcast "exhibitChange"

##
## Service providing validation related functions - checking for presence of images, descriptions, audio
##
.service "storySetValidation", ($rootScope, $timeout) ->
  checkValidity: (scope) ->
    scope.item.images = [] unless scope.item.images?
    scope.item.long_description = '' unless scope.item.long_description?
    if scope.item.long_description.length isnt 0 && scope.item.audio && scope.root.number? && scope.root.images.length >= 1
      @markValid scope
      $rootScope.$broadcast 'changes_to_save', scope
    else
      @markInvalid scope

  markInvalid: (scope) ->
    console.log 'invalid'

    if scope.item.status is 'published'
      scope.root.invalid = true
      $timeout ->
        scope.item.status = 'passcode'
        scope.$digest() if scope.$digest?
        $rootScope.$broadcast 'changes_to_save', scope
      , 100
    else
      $rootScope.$broadcast 'changes_to_save', scope

  markValid: (scope) ->
    console.log 'valid'
    scope.root.invalid = false

##
## Service with mapping helpers - sorting markers by timestamps, 
## calculating timestamps, updating images, creating and updating mappings
##
.service "imageMappingHelpers", ($rootScope, errorProcessing, $http, $i18next) ->

  weight_calc = (item) ->
    weight = 0
    weight += item.image.order
    weight -= 100 if item.mappings[$rootScope.lang]?
    return weight

  sort_weight_func: (a, b) ->
    if weight_calc(a) > weight_calc(b)
      return 1
    else if weight_calc(a) < weight_calc(b)
      return -1
    else
      return 0

  sort_time_func: (a, b) ->
    if a.mappings[$rootScope.lang]? and b.mappings[$rootScope.lang]?
      if a.mappings[$rootScope.lang].timestamp >= 0
        if a.mappings[$rootScope.lang].timestamp > b.mappings[$rootScope.lang].timestamp
          return 1
        else if a.mappings[$rootScope.lang].timestamp < b.mappings[$rootScope.lang].timestamp
          return -1
    return 0

  calc_timestamp: (ui, initial = false) ->
    seek_bar = $('.jp-seek-bar:visible')
    jp_durat = $('.jp-duration:visible')
    jp_play  = $('.jp-play:visible')
    if initial
      current_position = ui.offset.left - seek_bar.offset().left
    else
      current_position = ui.position.left - jp_play.width()
    container_width  = seek_bar.width() - 15
    duration         = jp_durat.text()
    total_seconds    = parseInt(duration.split(':')[1], 10) + parseInt(duration.split(':')[0], 10) * 60
    pixel_sec_weight = total_seconds / container_width
    current_time = Math.round current_position * pixel_sec_weight
    current_time = 0 if current_time <= 0
    current_time

  update_image: (image, backend_url) ->
    $http.put("#{backend_url}/media/#{image.image._id}", image.image).success (data) ->
      console.log 'ok'
      if image.mappings[$rootScope.lang]?
        mapping = image.mappings[$rootScope.lang]
        if mapping._id?
          $http.put("#{backend_url}/media_mapping/#{mapping._id}", mapping).success (data) ->
            console.log 'ok'
          .error ->
            errorProcessing.addError $i18next 'Failed to set timestamp'
    .error ->
      errorProcessing.addError $i18next 'Failed to set timestamp'
    true

  update_images: (parent, orders, backend_url) ->
    $http.post("#{backend_url}/media_for/#{parent}/reorder", orders).success (data) ->
      console.log 'ok'
    .error ->
      errorProcessing.addError $i18next 'Failed to update order'
    true

  create_mapping: (image, backend_url) ->
    $http.post("#{backend_url}/media_mapping/", image.mappings[$rootScope.lang]).success (data) ->
      image.mappings[$rootScope.lang] = data
    .error ->
      errorProcessing.addError $i18next 'Failed to set timestamp'
    true

##
## Service providing helper function for uploading by dragging a link
##
.service "uploadHelpers", ->
  cavas_processor: (img, type = "image/jpeg") ->
    console.log 'called'
    canvas = document.createElement("canvas")
    canvas.width = img.width
    canvas.height = img.height
    if canvas.getContext and canvas.toBlob
      canvas.getContext("2d").drawImage img, 0, 0, img.width, img.height
      canvas.toBlob ((blob) ->
        fileupload = $('#drop_down, #museum_drop_down').filter(':visible').find("input[type=file]")
        fileupload.fileupload "add",
          files: [blob]
      ), type
    true

##
## Service to handle all errors in prototype
##
.service "errorProcessing", ($rootScope, $timeout) ->
  errors: []
  addError: (error) ->
    error_object = 
      error: error
    @errors.push error_object
    $rootScope.$broadcast 'new_error', @errors
  getErrors: ->
    return @errors
  clearErrors: ->
    @errors = []
    $rootScope.$broadcast 'new_error', @errors
  deleteError: (index) ->
    @errors.splice(index, 1)
    $rootScope.$broadcast 'new_error', @errors

##
## Backend-related service, for transforming response and prepairing data, also implements app routing with promices
##
.service "backendWrapper", ($http, ngProgress, $location, $i18next) ->
  ##
  ## Two sections - for prototype and deelopment
  ##
  # museum_id: "529ee18e13b106fb0f000002"
  # content_provider_id: "529ee18e13b106fb0f000001"
  # backend_url: "http://192.168.158.128:3000/api"
  museum_id: "528f05b3c99772031a000002" #prototype
  content_provider_id: "528f05b3c99772031a000001" #prototype
  backend_url: "http://prototype.izi.travel/api" #prototype
  museums: []
  exhibits: []
  modal_translations: []
  langs: []
  current_museum: {}
  active_exhibit: {}
  sort_field: 'number'
  sort_direction: 1
  ajax_progress: true
  grouped_positions: {}
  hier_exhibits: {}

  ##
  ## Sort exhibits by numbers  (2, 1, 2.1, 3) -> (1, 2, 2.1, 3)
  ##
  sortArray: (collection, sort_field = sort_field, sort_direction = sort_direction) ->
    temp_collection = []
    n = undefined
    positive = if sort_direction is 1
      1
    else
      -1
    for item, index in collection
      temp_collection[index] = item
      if item.number?
        temp_collection[index].number = item.number.toString().match(/([^0-9]+)|([0-9]+)/g)
      else
        temp_collection[index].number = ['']
      for sumbol, sumbol_index in temp_collection[index].number
        temp_collection[index].number[sumbol_index] = n unless isNaN(n = parseInt(temp_collection[index].number[sumbol_index]))
    temp_collection.sort (x, y) ->
      for sumbol, i in x.number
        return 0 + positive if x.number[i] < y.number[i] # x is longer
        return 0 - positive if x.number[i] > y.number[i] or y.number.length < i
      0
    for temp_item in temp_collection
      temp_item.number = temp_item.number.join("")
    temp_collection

  ##
  ## Just outdated code for forming hierarchial object of exhibits
  ##
  recurse_enter_hierarchy: (hierarchy, index_arr, new_val) ->
    index = parseInt index_arr[0], 10
    hierarchy[index] = {} unless hierarchy[index]?
    if index_arr.length is 1
      hierarchy[index] = { 0: new_val }
    else
      index_arr.splice(0, 1)
      @recurse_enter_hierarchy(hierarchy[index], index_arr, new_val)

  form_hierarchial_object: (collection) ->
    new_object = {}
    for item in collection
      hierarchy_data  = item.number.split('.')
      @recurse_enter_hierarchy new_object, hierarchy_data, item
    new_object

  ##
  ## Functions to transform backend response to inner models
  ##
  reload_exhibits: (sort_field = sort_field, sort_direction = sort_direction, q) ->
    request = $http.get("#{@backend_url}/provider/#{@content_provider_id}/museums/#{@museum_id}/exhibits/#{@sort_field}/#{@sort_direction}")
    request.success ( (data) ->
        new_exhibits = []
        for item in data
          if item?
            exhibit = item.exhibit
            exhibit.images = []
            exhibit.mapped_images = []
            exhibit.cover  = {}
            for image in item.images
              exhibit.images.push image
              if image.image.cover is true
                exhibit.cover = image.image
              # if image.timestamp >= 0
              #   exhibit.mapped_images.push exhibit.images[exhibit.images.length - 1]
            exhibit.stories = {}
            for story in item.stories
              story.story.quiz = story.quiz.quiz
              story.story.audio = story.audio
              story.story.video = story.video
              story.story.quiz.answers = story.quiz.answers
              story.story.mapped_images = []
              for image in exhibit.images
                if image.mappings[story.story.language]
                  story.story.mapped_images.push image
              exhibit.stories[story.story.language] = story.story
            new_exhibits.push exhibit
        # ngProgress.complete()
        console.log 'anim completed'
        new_exhibits    = @sortArray new_exhibits
        # @hier_exhibits  = @form_hierarchial_object new_exhibits
        @active_exhibit =  new_exhibits[0]
        @exhibits       = new_exhibits
        @ajax_progress  = false
        if new_exhibits.length is 0
          @active_exhibit = {
            index: 0
            name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
            number: '1'
            image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
            thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
            publish_state: 'all'
            description: ''
            qr_code: {
              url: '/img/qr_code.png'
              print_link: 'http://localhost:8000/img/qr_code.png'
            }
            images: [
              {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
                id: 1
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }
              {
                image: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
                thumb: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
                id: 2
                edit_url: 'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
              }
            ]
            stories: {
              ru: {
                name: 'Богоматерь Владимирская, с двунадесятыми праздниками'
                description: 'test description'
                publish_state: 'all'
                audio: 'http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg'
                quiz: {
                  question: 'are you sure?'
                  description: 'can you tell me?'
                  state: 'published'
                  answers: [
                    {
                      title: 'yes'
                      correct: false
                      id: 0
                    }
                    {
                      title: 'may be'
                      correct: true
                      id: 1
                    }
                    {
                      title: 'who cares?'
                      correct: false
                      id: 2
                    }
                    {
                      title: 'nope'
                      correct: false
                      id: 3
                    }
                  ]
                }
              }
            }
          }

        # $scope.museum_change_progress = false

        q.resolve() if q?
      ).bind(@)
    request.error ->
      # ngProgress.complete()
      q.reject() if q?

  fetch_data: (museum_id, q) ->
    ngProgress.color('#fd6e3b')
    ngProgress.start()
    console.log 'anim started', museum_id
    @museum_id = museum_id if museum_id?
    request = $http.get("#{@backend_url}/provider/#{@content_provider_id}/museums")
    request.success ( (data) ->
      @museums = []
      found = false
      @langs = []
      @modal_translations = {}
      for item in data
        museum = item.exhibit
        museum.def_lang = "ru"
        museum.language = "ru" unless museum.language?
        museum.package_status = "process"
        museum.stories = {}
        museum.images = []
        museum.mapped_images = []
        museum.cover = {}
        for image in item.images
          museum.images.push image
          if image.image.cover is true
            museum.cover = image.image
          # if image.timestamp >= 0
          #   museum.mapped_images.push image
        for story in item.stories
          story.story.city = "Saint-Petersburg"
          story.story.quiz = story.quiz.quiz
          story.story.audio = story.audio
          story.story.video = story.video
          story.story.quiz.answers = story.quiz.answers
          story.story.mapped_images = []
          for image in museum.images
            if image.mappings[story.story.language]
              story.story.mapped_images.push image
          museum.stories[story.story.language] = story.story
          @langs.push story.story.language
        @museums.push museum
        museum.active = false
        if museum._id is @museum_id
          museum.active = true
          @current_museum = museum
          found = true
          # for key, value of museum.stories
          #   $scope.modal_translations[key] = {name: $i18next(key)}
        @langs.unique()
      @museums = @sortArray @museums
      unless found
        @current_museum = @museums[0]
        @current_museum.def_lang = "ru"
        @current_museum.language = "ru"  unless museum.language?
        @museum_id = @current_museum._id
      # $scope.form_translations()
      for lang in @langs
        @modal_translations[lang] = 
          name: $i18next(lang)
      @reload_exhibits(null, null, q)
    ).bind(@)
    request.error ->
      # ngProgress.complete()
      q.reject() if q?