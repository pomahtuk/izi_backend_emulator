"use strict"

##
## Functions used in whole project
##

# remove all duplicates from array
Object.defineProperty Array::, 'unique',
  value: ->
    a = []
    l = @length
    i = 0

    while i < l
      j = i + 1

      while j < l
        
        # If this[i] is found later in the array
        j = ++i  if this[i] is this[j]
        j++
      a.push this[i]
      i++
    a
  enumerable: false

# legacy from current cms
$.fn.refresh = -> $(this.selector)
$.fn.isEmpty = -> @length == 0

# taken from current content-browser
lastOfLine = (elem) ->
  elem = $(elem)
  top  = elem.offset().top
  pred = ->
    top < $(@).offset().top

  $.merge(elem, elem.nextUntil(pred)).last()

isSameLine = (x, y) ->
  x.length > 0 && y.length > 0 && x.offset().top == y.offset().top

tileGrid = (collection, tileWidth, tileSpace, tileListMargin) ->
  windowWidth = $(window).innerWidth()
  tileRealWidth = tileWidth + tileSpace
  windowRealWidth = windowWidth - tileListMargin * 2 + tileSpace

  lineSize = Math.floor(windowRealWidth / tileRealWidth)
  diff = windowWidth - (lineSize * tileRealWidth - tileSpace)
  marginLeft = Math.floor(diff / 2)

  collection.css 'margin-right': 0, 'margin-left': tileSpace
  collection.each (i) ->
    return if i % lineSize != 0
    $(@).css 'margin-left': marginLeft

# taken from current cms
@gon = {"google_api_key":"AIzaSyCPyGutBfuX48M72FKpF4X_CxxPadq6r4w","acceptable_extensions":{"audio":["mp3","ogg","aac","wav","amr","3ga","m4a","wma","mp4","mp2","flac"],"image":["jpg","jpeg","gif","png","tiff","bmp"],"video":["mp4","m4v","avi", "ogv"]},"development":false}

##
## App controllers
##
angular.module("Museum.controllers", [])
# Main controller
.controller('IndexController', [ '$rootScope', '$scope', '$http', '$filter', '$window', '$modal', '$routeParams', '$location', 'ngProgress', 'storySetValidation', 'errorProcessing', '$i18next', 'imageMappingHelpers', 'backendWrapper', ($rootScope, $scope, $http, $filter, $window, $modal, $routeParams, $location, ngProgress, storySetValidation, errorProcessing, $i18next, imageMappingHelpers, backendWrapper) ->
  
  # for convinient debug - acess all scope functions from console
  window.sc = $scope

  # initial values
  $scope.museum_type_filter         = ''
  $scope.exhibit_search             = ''
  $scope.sort_field                 = 'number'
  $scope.sort_direction             = 1
  $scope.sort_text                  = 'icon-sort-by-order'
  $scope.exhibits_visibility_filter = 'all'
  $scope.ajax_progress              = true
  $scope.story_subtab               = 'video'
  $scope.story_tab                  = 'main'
  $scope.museum_tab                 = 'main'
  $scope.museum_subtab              = 'video'
  $scope.grouped_positions          = {
    draft: false
    passcode: false
    invisible: false
    published: false
  }

  # changes language of translator
  $scope.changeLng = (lng) ->
    $i18next.options.lng = lng

  ##
  ## angular filtering functions
  ##

  # for search input - match name or number 
  $scope.criteriaMatch = ( criteria ) ->
    ( item ) ->
      if item
        if item.stories[$scope.current_museum.language]
          if item.stories[$scope.current_museum.language].name
            if criteria? and typeof(criteria) is 'string'
              in_string = item.stories[$scope.current_museum.language].name.toLowerCase().indexOf(criteria.toLowerCase()) > -1
              number_is = parseInt(item.number, 10) is (parseInt criteria, 10)
              result = in_string || criteria is '' || number_is
              # $scope.grid() if result
              return result
      return true

  # for status filters - match status of story in current language
  $scope.statusMatch = (status = $scope.exhibits_visibility_filter) ->
    (item) ->
      if status isnt 'all'
        if item
          if item.stories[$scope.current_museum.language]?
            if item.stories[$scope.current_museum.language].status && status
              return false unless item.stories[$scope.current_museum.language].status is status
      return true

  # extend current scope with values calculated in backend wrapper
  angular.extend($scope, backendWrapper)

  # stop progressbar at the top of page
  ngProgress.complete()

  ##
  ## dummy data - untill backend methods arent implemented
  ##
  $scope.user = {
    mail: 'pman89@yandex.ru'
    providers: [
      {
        name: 'IZI.travel Test Provider'
      }
      {
        name: 'IZI.travel Second Provider'
      }
    ]
  }

  $scope.provider = {
    name: 'content_1'
    id: '1'
    passcode: 'passcode'
    passcode_edit_link: '/1/pass/edit/'
  }

  $scope.translations = {
    ru: 'Russian'
    en: 'English'
    es: 'Spanish'
    ge: 'German'
    fi: 'Finnish'
    sw: 'Sweedish'
    it: 'Italian'
    fr: 'French'
    kg: 'Klingon'
  }

  # js flag variables
  $scope.element_switch       = true
  $scope.forbid_switch        = false
  $scope.create_new_language  = false
  $scope.new_item_creation    = false
  $scope.all_selected         = false

  # find dropdown in DOM - not real angular-way, legacy fron content-browser
  dropDown   = $('#drop_down').removeClass('hidden').hide()

  # legacy fron content-browser
  findActive = -> $('ul.exhibits li.exhibit.active')

  # function will be called when dropdown for dummy exhibit will be closed
  $scope.dummy_focusout_process = (active) ->
    if dropDown.find('#name').val() is ''
      remove = true
      for field in dropDown.find('#media .form-control:not(#opas_number)')
        field = $ field
        if field.val() isnt ''
          remove = false
      if remove
        $scope.new_item_creation = false
      else
        $scope.dummy_modal_open()

  # closing a dropdown
  $scope.closeDropDown = ->
    console.log 'closing'
    active = findActive()
    $scope.active_exhibit.active = false if $scope.active_exhibit?
    if active.hasClass 'dummy'
      $scope.dummy_focusout_process(active)
    dropDown.hide()
    active.removeClass('active')

  # attaching dropdown, from content-browser with some improovments
  $scope.attachDropDown = (li) ->
    li = $ li
    hasParent = dropDown.hasClass 'inited'
    dropDown.show().insertAfter(lastOfLine(li))

    unless hasParent

      dropDown.addClass 'inited'

      dropDown.find('a.done, .close').not('.delete_maping').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        $scope.closeDropDown()

      dropDown.find('>.prev-ex').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        active = findActive()
        prev = active.prev('.exhibit')
        if prev.attr('id') == 'drop_down' || prev.hasClass 'dummy'
          prev = prev.prev()
        if prev.length > 0
          prev.find('.opener .description').click()
        else
          active.siblings('.exhibit').last().find('.opener').click()

      dropDown.find('>.next-ex').unbind('click').bind 'click', (e) ->
        e.preventDefault()
        active = findActive()
        next = active.next()
        if next.attr('id') == 'drop_down'  || next.hasClass 'dummy'
          next = next.next()
        if next.length > 0
          next.find('.opener .description').click()
        else
          active.siblings('.exhibit').first().find('.opener').click()


      dropDown.find('a.delete_story').unbind('click').bind 'click', (e) ->
        elem = $ @
        if elem.hasClass 'no_margin'
          e.preventDefault()
          e.stopPropagation()
          $scope.closeDropDown()

  # opening dropdown, from content-browser with some improovments
  $scope.open_dropdown = (event, elem) ->
    clicked = $(event.target).parents('li')

    $scope.element_switch = true

    if $scope.forbid_switch is true
      event.stopPropagation()
      return false

    if clicked.hasClass('active') and not $scope.new_item_creation
      $scope.closeDropDown()
      return false

    if $scope.new_item_creation
      $scope.story_tab = 'main'
      if findActive().length > 0
        $scope.closeDropDown()

    for exhibit in $scope.exhibits
      if exhibit?
        exhibit.active = false

    elem.active = true
    setTimeout ->
      $scope.element_switch = false
    , 500
    $scope.active_exhibit = elem

    previous = findActive()

    if previous.hasClass 'dummy'
      $scope.dummy_focusout_process previous

    previous.removeClass('active')
    clicked.addClass('active')

    unless isSameLine(clicked, previous)
      $scope.attachDropDown clicked
      setTimeout ->
        $.scrollTo(clicked, 500)
      , 100
   
    item_publish_settings = dropDown.find('.item_publish_settings')
    delete_story = dropDown.find('.delete_story')

    if $scope.story_tab is 'images'
      $scope.story_tab = 'main'

    if clicked.hasClass 'dummy' or clicked.hasClass 'draft'
      number = clicked.data('number')
      $('#opas_number').val(number).blur()
      $('#name').focus()
      item_publish_settings.hide()
      delete_story.addClass('no_margin')
    else
      item_publish_settings.show()
      delete_story.removeClass('no_margin')
  
  # exhibits grid, untouched
  $scope.grid = ->
    $('ul.exhibits').each ->
      # console.log @
      collection = $(@).find('li.exhibit')
      tileListMargin = 0
      tileWidth = collection.first().width()
      tileSpace = 35 # parseInt(collection.first().css('margin-left'), 10) + parseInt(collection.first().css('margin-right'), 10)
      # $('.exhibits').css 'text-align': 'left'
      tileGrid(collection, tileWidth, tileSpace, tileListMargin)
      # $(window).resize(tileGrid.bind(@, collection, tileWidth, tileSpace, tileListMargin))

  # js-function for museums. Should be rewritten using mediaqueries
  $scope.museum_list_prepare = ->
    list        = $('ul.museum_list')
    count       = list.find('li').length
    width       = $('body').width()
    row_count = (count * 150 + 160) / width
    if row_count > 1
      $('.museum_filters').show()
      list.width(width-200)
    else
      $('.museum_filters').hide()
      list.width(width-100)

  # TODO: find angular hook on after render and refactior. Get rid of setTimeout
  setTimeout ->
    $scope.museum_list_prepare()
  , 200

  $(window).resize ->
    setTimeout ->
      $scope.museum_list_prepare()
    , 100

  # opening museums navigation
  $('.page-wrapper').click ->
    nav_museum = $('.museum_navigation_menu')
    nav_museum.slideUp(100) if nav_museum.height() > 10

  # initial modal windows data
  $scope.modal_options = {
    current_language: 
      name: $scope.translations[$scope.current_museum.language]
      language: $scope.current_museum.language
    languages: $scope.modal_translations
    exhibits: $scope.exhibits
    deletion_password: '123456'
  }

  # for placing initial numbers in newly created exhibits
  get_number = ->
    res = 0
    if $scope.exhibits[$scope.exhibits.length-1]
      res = parseInt($scope.exhibits[$scope.exhibits.length-1].number, 10) + 1
    else
      res = 1
    return res

  # for placing default numbers in newly created exhibits
  get_lang = ->
    $scope.current_museum.language

  # calculate story status for stories in newly exhibit
  get_state = (lang) ->
    if lang is $scope.current_museum.language
      'passcode'
    else
      'dummy'

  # for placing default names in newly created exhibits
  get_name = (lang) ->
    if lang is $scope.current_museum.language
      # may be translation neded
      'Экспонат_'+lang
    else
      ''

  # image mappings hove helper function
  $scope.set_hover = (image, sign) ->
    image.image.hovered = sign

  # recalculating image mapping positions when event triggered. Used in template
  $scope.check_mapped = (event) ->
    console.log 'checking mapping'
    target = $ event.target
    selector = target.parents('.description').find('.timline_container')
    target_storyset = if target.hasClass 'active_exhibit'
      $scope.active_exhibit
    else if target.hasClass 'current_museum'
      $scope.current_museum
    if target_storyset.stories[$scope.current_museum.language].mapped_images.length > 0
      item = target_storyset.stories[$scope.current_museum.language]
      setTimeout ->
        $scope.recalculate_marker_positions(item, selector)
      , 100

  # deleting image to audio mappings
  $scope.delete_mapping = (index, type, event) ->
    target = if type is 'active_exhibit'
      $scope.active_exhibit
    else
      $scope.current_museum
    image = target.images[index]
    lang  = $scope.current_museum.language
    $http.delete("#{$scope.backend_url}/media_mapping/#{image.mappings[lang]._id}").success (data) ->

      console.log 'ok', data
      for mapped_image, sub_index in target.stories[lang].mapped_images
        if mapped_image.image._id is image.image._id
          target.stories[lang].mapped_images.splice(sub_index, 1)
          break
      delete image.mappings[lang]

      target.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)

      orders = {}
      for item, index in target.images
        item.image.order = index
        orders[item.image._id] = index

      imageMappingHelpers.update_images target.images[0].image.parent, orders, $scope.backend_url

    .error ->
      errorProcessing.addError $i18next 'Failed to delete timestamp'

    event.preventDefault()
    event.stopPropagation()

  # recalculating image mapping positions
  $scope.recalculate_marker_positions = (item, selector) ->
    seek_bar   = $('.jp-seek-bar:visible')
    jp_durat   = $('.jp-duration:visible')
    jp_play    = $('.jp-play:visible')
    correction = jp_play.width()

    container_width  = seek_bar.width() - 15
    duration         = jp_durat.text()
    total_seconds    = parseInt(duration.split(':')[1], 10) + parseInt(duration.split(':')[0], 10) * 60
    pixel_sec_weight = total_seconds / container_width

    for marker in $('.image_connection:visible')
      marker = $ marker
      image  = item.mapped_images[marker.data('image-index')]
      left   = image.mappings[$scope.current_museum.language].timestamp / pixel_sec_weight
      marker.css({'left':"#{left + correction}px"})

  # this function crates dummy story
  $scope.create_dummy_story = (id) ->
    dummy_story = {
      playback_algorithm: 'generic'
      content_provider:   $scope.content_provider_id
      story_type:         'story'
      status:             'draft'
      language:           'dummy'
      name:               ''
      short_description:  ''
      long_description:   ''
      story_set:          id
    }
    dummy_story.quiz = {
      story:     ""
      question:  ''
      comment:   ''
      status:    'passcode'
      answers:   []
    }
    for i in [0..3]
      dummy_story.quiz.answers.push
        quiz:     ""
        content:  ''
        correct:  false

    dummy_story.quiz.answers[0].correct = true

    dummy_story

  # creating new language for museum
  $scope.new_museum_language = () ->
    $scope.create_new_language = true

    dummy_story = $scope.create_dummy_story $scope.current_museum._id

    dummy_story.quiz.answers[0].correct = true

    $scope.dummy_museum = angular.copy $scope.current_museum

    $scope.dummy_museum.stories.dummy = dummy_story
    # $scope.dummy_museum.stories.dummy.name = $scope.current_museum.stories[$scope.current_museum.def_lang].name
    $scope.dummy_museum.stories.dummy.status = 'passcode'

    # for exhibit in $scope.exhibits
    #   exhibit.stories.dummy = dummy_story

    $scope.dummy_museum.language = 'dummy'

    $scope.modal_options = {
      museum: $scope.dummy_museum
      translations: $scope.translations
    }

    ModalMuseumInstance = $modal.open(
      templateUrl: "myMuseumModalContent.html"
      controller: ModalMuseumInstanceCtrl
      resolve:
        modal_options: ->
          $scope.modal_options
    )
    ModalMuseumInstance.result.then ((result_string) ->
      switch result_string
        when 'save'
          true
          console.log $scope.dummy_museum

          lang = $scope.dummy_museum.language
          $scope.dummy_museum.stories[lang] = $scope.dummy_museum.stories.dummy
          $scope.dummy_museum.stories[lang].language = lang

          story = $scope.dummy_museum.stories[lang]
          story.story_set = $scope.current_museum._id

          $scope.post_stories story, 'uncommon', (saved_story) ->

            saved_story.quiz = story.quiz

            for exhibit in $scope.exhibits
              exhibit.stories[lang] = angular.copy story
              exhibit.stories[lang].language = lang
              exhibit.stories[lang].name = ""
              exhibit.stories[lang].status = 'draft'
              exhibit.stories[lang].story_set = exhibit._id

              sub_story = angular.copy exhibit.stories[lang]

              $scope.post_stories sub_story, 'uncommon'

            $scope.current_museum.stories[lang] = saved_story
            $scope.modal_translations[lang] = { name: $scope.translations[lang] }
            $scope.current_museum.language = lang

            $scope.create_new_language = false

        when 'discard'
          true
    ), ->
      console.log "Modal dismissed at: " + new Date()


    true

  # creating new exhibit
  $scope.create_new_item = () ->
    unless $scope.new_item_creation is true
      number = get_number()
      $scope.new_exhibit = {
        content_provider: $scope.content_provider_id
        number:           number
        type:             'exhibit'
        distance:         20
        duration:         20
        status:           'draft'
        route:            ''
        category:         ''
        parent:           $scope.museum_id
        name:             ''
        qr_code: {
          url: ''
          print_link: ''
        }
        stories: {}
      }
      $scope.new_exhibit.images = []
      for lang of $scope.current_museum.stories
        $scope.new_exhibit.stories[lang] = {
          playback_algorithm: 'generic'
          content_provider:   $scope.content_provider_id
          story_type:         'story'
          status:             'draft'
          language:           lang
          name:               ''
          short_description:  ''
          long_description:   ''
          story_set:          ""
        }
        $scope.new_exhibit.stories[lang].quiz = {
          story:     ""
          question:  ''
          comment:   ''
          status:    'passcode'
          answers:   []
        }
        for i in [0..3]
          $scope.new_exhibit.stories[lang].quiz.answers.push
            quiz:     ""
            content:  ''
            correct:  false
        $scope.new_exhibit.stories[lang].quiz.answers[0].correct = true

      $scope.new_item_creation = true
      setTimeout ->
        $scope.story_tab = 'main'
        e = {}
        e.target = $('li.exhibit.dummy:visible > .opener.draft')
        $scope.open_dropdown(e, $scope.new_exhibit)

        #hack to tile grid when adding an item to new line
        $scope.grid()
      , 30 

  # update selected count and check if all exhibits selected
  $scope.check_selected = ->
    $scope.selected_count = 0
    $scope.select_all_enabled = false
    for exhibit in $scope.exhibits
      if exhibit.selected is true
        $scope.select_all_enabled = true
        $scope.selected_count += 1
    if $scope.selected_count is $scope.exhibits.length
       $scope.all_selected = true

  # select all exhibits
  $scope.select_all_exhibits = (option) ->
    if option?
      switch option
        when 'select'
          sign = true
        when 'cancel'
          sign = false
    else
      sign = !$scope.all_selected
    for exhibit in $scope.exhibits
      exhibit.selected = sign
    $scope.all_selected = !$scope.all_selected
    $scope.select_all_enabled = sign

  # open a deletion modal window
  $scope.delete_modal_open = ->
    unless $scope.new_item_creation
      $scope.modal_options = {
        current_language: 
          name: $scope.translations[$scope.current_museum.language]
          language: $scope.current_museum.language
        languages: $scope.modal_translations
        exhibits: $scope.exhibits
        deletion_password: '123456'
      }
      ModalDeleteInstance = $modal.open(
        templateUrl: "myModalContent.html"
        controller: ModalDeleteInstanceCtrl
        resolve:
          modal_options: ->
            $scope.modal_options
      )
      ModalDeleteInstance.result.then ((result) ->
        $scope.delete_exhibit $scope.active_exhibit, result.selected
      ), ->
        console.log "Modal dismissed at: " + new Date()
    else
      true

  # open a museum deletion modal window
  $scope.delete_museum_modal_open = ->
    unless $scope.new_item_creation
      $scope.modal_options = {
        current_language: 
          name: $scope.translations[$scope.current_museum.language]
          language: $scope.current_museum.language
        languages: $scope.modal_translations
        exhibits: $scope.exhibits
        deletion_password: '123456'
      }
      museumDeleteInstance = $modal.open(
        templateUrl: "museumDelete.html"
        controller: museumDeleteCtrl
        resolve:
          modal_options: ->
            $scope.modal_options
      )
      museumDeleteInstance.result.then ((selected) ->
        lang = $scope.current_museum.language
        if selected is 'lang'
          delete $scope.modal_translations[lang]
          $scope.current_museum.language = $scope.current_museum.def_lang
          for exhibit in $scope.exhibits
            $scope.delete_story exhibit.stories, lang, (stories, lang) ->
              delete stories[lang]
              true
          $scope.delete_story $scope.current_museum.stories, lang, (stories, lang) ->
            delete stories[lang]
            true
        else
          console.log 'deleting museum story or whole museum'
          museum = $scope.current_museum

          # and now we need to switch museums

          for exhibit in $scope.exhibits
            $scope.delete_story_set exhibit
          $scope.delete_story_set museum

      ), ->
        console.log "Modal dismissed at: " + new Date()
    else
      true

  # open deletion of exhibit process
  $scope.delete_exhibit = (target_exhibit, languages) ->
    if languages.length >= Object.keys(target_exhibit.stories).length
      $scope.closeDropDown()
      for exhibit, index in $scope.exhibits
        if exhibit._id is target_exhibit._id
          $scope.exhibits.splice index, 1
          $scope.grid()
          if target_exhibit._id is $scope.active_exhibit._id
            $scope.active_exhibit = $scope.exhibits[0]
          $scope.delete_story_set target_exhibit
          break
    else
      console.log target_exhibit._id
      for st_index, story of target_exhibit.stories
        for item in languages
          # console.log item, st_index
          if item is st_index
            target_exhibit.selected = false
            story = target_exhibit.stories[st_index]
            story.status = 'draft'
            story.name = ''
            story.short_description = ''
            story.long_description = ''
            story.quiz.question = ''
            story.quiz.comment = ''
            story.quiz.status = ''
            story.quiz.answers = [] unless story.quiz.answers
            story.quiz.answers[0].content = ''
            story.quiz.answers[0].correct = true
            story.quiz.answers[1].content = ''
            story.quiz.answers[1].correct = false
            story.quiz.answers[2].content = ''
            story.quiz.answers[2].correct = false
            story.quiz.answers[3].content = ''
            story.quiz.answers[3].correct = false
            $scope.update_story(story)

  $scope.dummy_modal_open = ->
    ModalDummyInstance = $modal.open(
      templateUrl: "myDummyModalContent.html"
      controller: ModalDummyInstanceCtrl
      resolve:
        modal_options: ->
          {
            exhibit: $scope.active_exhibit
          }
    )
    ModalDummyInstance.result.then ((result_string) ->
      $scope.new_item_creation = false
      $scope.item_deletion     = true
      if result_string is 'save_as'
        $scope.new_exhibit.stories[$scope.current_museum.language].name = "item_#{$scope.new_exhibit.number}"
        $scope.new_exhibit.stories[$scope.current_museum.language].publish_state = "passcode"
        $scope.new_exhibit.active = false
        $scope.exhibits.push $scope.new_exhibit
      else
        $scope.closeDropDown()
        $scope.new_exhibit.active = false
        $scope.active_exhibit = $scope.exhibits[0]
      $scope.item_deletion  = false
    ), ->
      console.log "Modal dismissed at: " + new Date()

  # open museum edit view
  $scope.show_museum_edit = (event) ->
    elem = $ event.target
    unless museum_anim_in_progress
      museum_anim_in_progress = true
      # elem.find('i').toggleClass "icon-chevron-down icon-chevron-up"
      $('.navigation .museum_edit').slideToggle(1000, "easeOutQuint")
      $scope.museum_edit_dropdown_opened = !$scope.museum_edit_dropdown_opened
    false

  # close meseum drop down
  $scope.museum_edit_dropdown_close = () ->
    e = {
      target: $('.museum_edit_opener')
    }
    if $scope.museum_edit_dropdown_opened
      $scope.show_museum_edit(e)

  $scope.update_story = (story) ->
    $http.put("#{$scope.backend_url}/story/#{story._id}", story).success (data) ->
      $http.put("#{$scope.backend_url}/quiz/#{story.quiz._id}", story.quiz).success (data) ->
        for answer in story.quiz.answers
          $scope.put_answers answer
      .error ->
        errorProcessing.addError $i18next 'Failed to update a quiz for story'
    .error ->
      errorProcessing.addError $i18next 'Failed update a story'

  $scope.put_answers = (answer) ->
    $http.put("#{$scope.backend_url}/quiz_answer/#{answer._id}", answer).success (data) ->
      console.log 'done'
    .error ->
      errorProcessing.addError $i18next 'Failed to save quiz answer'

  $scope.post_stories = (original_story, type = 'common', callback) ->

    # story = angular.copy original_story
    story = if type is 'common' 
      original_story
    else
      angular.copy original_story

    $http.post("#{$scope.backend_url}/story/", story).success (data) ->
      story._id = data._id
      story.quiz.story = data._id
      callback(data) if callback?      
      $http.post("#{$scope.backend_url}/quiz/", story.quiz).success (data) ->
        story.quiz._id = data.id
        for answer in story.quiz.answers
          answer.quiz = data._id
          $scope.post_answers answer
      .error ->
       errorProcessing.addError $i18next 'Failed to save quiz for new story'
    .error ->
      errorProcessing.addError $i18next 'Failed to save new story'

  $scope.post_answers = (answer) ->
    $http.post("#{$scope.backend_url}/quiz_answer/", answer).success (data) ->
      # console.log data
      answer._id = data._id
    .error ->
      errorProcessing.addError $i18next 'Failed to save quiz answer'

  $scope.mass_switch_pub = (value) ->
    for exhibit in $scope.exhibits
      if exhibit.selected is true && exhibit.stories[$scope.current_museum.language].status isnt 'dummy'
        validation_item = {}
        validation_item.item = exhibit.stories[$scope.current_museum.language]
        validation_item.root = exhibit
        validation_item.field_type = 'story'
        validation_item.item.status = value
        storySetValidation.checkValidity validation_item
    # $scope.$digest()

  $scope.delete_selected_exhibits = () ->
    $scope.modal_options = {
      current_language: 
        name: $scope.translations[$scope.current_museum.language]
        language: $scope.current_museum.language
      languages: $scope.modal_translations
      exhibits: $scope.exhibits
      deletion_password: '123456'
    }
    ModalDeleteInstance = $modal.open(
      templateUrl: "myModalContent.html"
      controller: ModalDeleteInstanceCtrl
      resolve:
        modal_options: ->
          $scope.modal_options
    )

    ModalDeleteInstance.result.then ((result) ->
      console.log result.ids_to_delete
      for exhibit in result.ids_to_delete
        if exhibit.selected is true
          exhibit.selected = false
          $scope.delete_exhibit exhibit, result.selected
    ), ->
      console.log "Modal dismissed at: " + new Date()

  $scope.delete_story = (stories, lang, callback) ->
    $http.delete("#{$scope.backend_url}/story/#{stories[lang]._id}").success (data) ->
      console.log data
      callback(stories, lang) if callback?
    .error ->
      errorProcessing.addError $i18next('Failed to delete story in languane: ') + $scope.translations[lang]

  $scope.delete_story_set = (target_exhibit) ->
    $http.delete("#{$scope.backend_url}/story_set/#{target_exhibit._id}/").success (data) ->
      console.log data
    .error ->
      errorProcessing.addError $i18next('Failed to delete exhibit with number ') + target_exhibit.number

  # function for processing grouping of exhibits - creating a new object
  # according to publish state and deleting this object
  # also updating a grid
  $scope.group_exhibits_processor = (hide = false) ->
    $scope.closeDropDown()
    if hide or $scope.grouped_exhibits?
      $scope.grouped_exhibits = undefined
      setTimeout ->
        $scope.grid()
      , 100
    else
      $scope.exhibits_visibility_filter = ''
      $scope.grouped_exhibits = {
        published: []
        private: []
        invisible: []
        draft: []
      }
      for exhibit in $scope.exhibits
        switch exhibit.stories[$scope.current_museum.language].status
          when 'published'
            $scope.grouped_exhibits.published.push exhibit
          when 'passcode'
            $scope.grouped_exhibits.private.push exhibit
          when 'opas_invisible'
            $scope.grouped_exhibits.invisible.push exhibit
          else
            $scope.grouped_exhibits.draft.push exhibit
      $scope.grid()


  ##
  ## Angular watchers
  ##

  # watch changes of museum language and update values on backend, also recreating grouped exhibits object
  $scope.$watch 'current_museum.language', (newValue, oldValue) ->
    console.log newValue
    $rootScope.lang = newValue
    if newValue
      if newValue isnt 'dummy'
        if $scope.current_museum._id
          $http.put("#{$scope.backend_url}/story_set/#{$scope.current_museum._id}", $scope.current_museum).success (data) ->
            console.log data
            $scope.last_save_time = new Date()
          .error (error) ->
            errorProcessing.addError $i18next 'Failed to save museum language'


        if $scope.grouped_exhibits?
          $scope.grouped_exhibits = {
            published: []
            private: []
            invisible: []
            draft: []
          }
          for exhibit in $scope.exhibits
            switch exhibit.stories[$scope.current_museum.language].status
              when 'published'
                $scope.grouped_exhibits.published.push exhibit
              when 'passcode'
                $scope.grouped_exhibits.private.push exhibit
              when 'opas_invisible'
                $scope.grouped_exhibits.invisible.push exhibit
              when 'draft'
                $scope.grouped_exhibits.draft.push exhibit
          $scope.grid()

      else
        $scope.modal_options.current_language = 
          name: $scope.translations[$scope.current_museum.language]
          language: $scope.current_museum.language

        $scope.create_new_language = false

  # recreate grouped exhibits on changing status of exhibit
  $scope.$watch 'exhibits', (newValue, oldValue) ->
    if $scope.grouped_exhibits?
      $scope.grouped_exhibits = {
        published: []
        private: []
        invisible: []
        draft: []
      }
      for exhibit in $scope.exhibits
        switch exhibit.stories[$scope.current_museum.language].status
          when 'published'
            $scope.grouped_exhibits.published.push exhibit
          when 'passcode'
            $scope.grouped_exhibits.private.push exhibit
          when 'opas_invisible'
            $scope.grouped_exhibits.invisible.push exhibit
          when 'draft'
            $scope.grouped_exhibits.draft.push exhibit
      $scope.grid()
  , true

  # watch flters and peocess grouping
  $scope.$watch 'exhibits_visibility_filter', (newValue, oldValue) ->
    if newValue?
      if newValue isnt oldValue
        $scope.group_exhibits_processor(true) if newValue isnt ''
        $scope.closeDropDown()

  # update localstorage acording to show/hidden state of group in view
  $scope.$watch 'grouped_positions', (newValue, oldValue) ->
    if newValue?
      localStorage.setItem 'grouped_positions', JSON.stringify $scope.grouped_positions
  , true

  # save in localstorage presence of grouping sign
  $scope.$watch 'grouped_exhibits', (newValue, oldValue) ->
    if newValue?
      localStorage.setItem 'grouped', 'true'
    else
      localStorage.setItem 'grouped', 'false'

  # close dropdown on exhibit search changes
  $scope.$watch 'exhibit_search', (newValue, oldValue) ->
    if newValue?
      if newValue isnt oldValue
        $scope.closeDropDown()

  # open museum edit if publishing of museum fails
  $scope.$watch 'current_museum.invalid', (newValue, oldValue) ->
    if newValue? and newValue
      setTimeout ->
        $('.museum_edit_opener').click() unless $scope.museum_edit_dropdown_opened
      , 10

    true

  ##
  ## Angular listeners
  ##

  # callbacks for events triggered in directives or services
  $scope.$on 'save_new_exhibit', ->
    console.log 'saving!'
    $scope.new_exhibit.stories[$scope.current_museum.language].status = 'passcode'
    $http.post("#{$scope.backend_url}/story_set/", $scope.new_exhibit).success (data) ->
      $scope.exhibits.push $scope.new_exhibit
      $scope.new_exhibit._id = data._id
      $scope.last_save_time = new Date()
      for lang, story of $scope.new_exhibit.stories
        story.publish_state = 'passcode'
        story.story_set = data._id
        $scope.post_stories story
      dropDown.find('.item_publish_settings').show()
    .error ->
      errorProcessing.addError $i18next 'Failed to save new exhibit'
    $scope.new_item_creation = false
    $scope.$digest()

  $scope.$on 'changes_to_save', (event, child_scope) ->
    if child_scope.item._id
      $http.put("#{$scope.backend_url}/#{child_scope.field_type}/#{child_scope.item._id}", child_scope.item).success (data) ->
        child_scope.satus = 'done'
        $scope.last_save_time = new Date()
        console.log data
      .error ->
        errorProcessing.addError $i18next 'Server error - Prototype error.'
      $scope.forbid_switch  = false

  $scope.$on 'quiz_changes_to_save', (event, child_scope, correct_item) ->
    for sub_item in child_scope.collection
      sign = if sub_item._id is correct_item._id
        true
      else
        false
      sub_item.correct = sign
      sub_item.correct_saved = sign
      $http.put("#{$scope.backend_url}/#{child_scope.field_type}/#{sub_item._id}", sub_item).success (data) ->
        console.log data
        $scope.last_save_time = new Date()
      .error ->
        errorProcessing.addError $i18next 'Failed to update quiz'
    $scope.forbid_switch  = false


  # fetch data from localstorage and restore grouping of exhibits ang opened/collapsed groups state
  tmp = localStorage.getItem "grouped_positions"
  if tmp
    $scope.grouped_positions = JSON.parse tmp
  tmp = localStorage.getItem "grouped"
  $scope.group_exhibits_processor() if tmp is 'true'


  # $scope.$watch -> 
  #   $location.path()
  # , (newValue, oldValue) ->
  #   if newValue? && newValue isnt oldValue
  #     $scope.closeDropDown()
  #     ####
  #     $('.museum_navigation_menu').slideUp(300)
  #     ####
  #     ngProgress.complete()
  #     ngProgress.start()
  #     console.log 'anim started'
  #     $scope.museum_change_progress = true
  #     museum_id = newValue.split('/')[1]
  #     $scope.modal_translations = {}
  #     for museum in $scope.museums
  #       if museum._id is museum_id
  #         museum.active = true
  #         $scope.current_museum = museum
  #         for key, value of museum.stories
  #           $scope.modal_translations[key] = {name: $i18next(key)}
  #       else
  #         museum.active = false
  #     $scope.reload_exhibits()

  # $scope.$watch 'museum_change_progress', (newValue, oldValue) ->
  #   if newValue?
  #     if newValue
  #       $('.page-wrapper .page').fadeOut(300)
  #       $('.page-preloader').fadeIn(300)
  #     else
  #       $('.page-wrapper .page').fadeIn(300)
  #       $('.page-preloader').fadeOut(300)

])

.controller('MuseumEditController', [ '$scope', '$http', '$filter', '$window', '$modal', 'storage', ($scope, $http, $filter, $window, $modal, storage) ->

  # hack, we really shouldnt have an isolated scope
  setTimeout ->
    $scope.$parent.museumQuizform = $scope.museumQuizform
    $scope = $scope.$parent
  , 100


  ##
  ## Quiz functions
  ##
  $scope.$watch 'current_museum.stories[current_museum.language].quiz', (newValue, oldValue) ->
    if newValue.state is 'limited'
      unless $("#museum_story_quiz_disabled").is(':checked')
        setTimeout ->
          $("#museum_story_quiz_disabled").click()
        , 10
    else if newValue.state is 'published'
      if $("#museum_story_quiz_enabled").is(':checked')
        setTimeout ->
          unless $scope.museumQuizform.$valid
            setTimeout ->
              $("#museum_story_quiz_disabled").click()
            , 10
        , 100
      else
        setTimeout ->
          $("#museum_story_quiz_enabled").click()
        , 10
  , true

  $scope.$watch 'current_museum.stories[current_museum.language].quiz.question', (newValue, oldValue) ->
    if $scope.museumQuizform?
      if $scope.museumQuizform.$valid
        $scope.mark_quiz_validity($scope.museumQuizform.$valid)
      else
        setTimeout ->
          $("#museum_story_quiz_disabled").click()
          $scope.mark_quiz_validity($scope.museumQuizform.$valid)
        , 10

  $scope.$watch ->
    angular.toJson($scope.current_museum.stories[$scope.current_museum.language].quiz.answers)
  , (newValue, oldValue) ->
    if $scope.museumQuizform?
      if $scope.museumQuizform.$valid
        $scope.mark_quiz_validity($scope.museumQuizform.$valid)
      else
        setTimeout ->
          $("#museum_story_quiz_disabled").click()
        , 10

  , true


  true
])

##
## Modal windows controllers
##
@ModalDeleteInstanceCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.modal_options = modal_options

  $scope.deletion_password = ''

  console.log $scope.modal_options.languages

  $scope.only_one = Object.keys($scope.modal_options.languages).length is 1

  $scope.password_input_shown = false

  $scope.ok = ->
    $scope.selected = []
    $scope.ids_to_delete = []
    for language, value of $scope.modal_options.languages
      $scope.selected.push language if value.checked is true

    for exhibit in modal_options.exhibits
      if exhibit.selected is true
        $scope.ids_to_delete.push exhibit

    result = 
      ids_to_delete: $scope.ids_to_delete
      selected: $scope.selected


    if $scope.ids_to_delete.length <= 1
      $modalInstance.close result
    else
      $scope.password_input_shown = true
      if $scope.deletion_password is modal_options.deletion_password
        $modalInstance.close result

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.mark_all = ->
    for language, value of $scope.modal_options.languages
      value.checked = true

  $scope.mark_default_only = ->
    for language, value of $scope.modal_options.languages
      value.checked = false
      value.checked = true if $scope.modal_options.current_language.language is language

  $scope.mark_default_only()

@museumDeleteCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.modal_options = modal_options

  $scope.deletion_password = ''

  $scope.variant = {
    checked: 'lang'
  }

  $scope.ok = ->
    if $scope.deletion_password is modal_options.deletion_password
      $modalInstance.close $scope.variant.checked

  $scope.cancel = ->
    $modalInstance.dismiss()

@ModalDummyInstanceCtrl = ($scope, $modalInstance, modal_options) ->
  $scope.exhibit = modal_options.exhibit

  $scope.discard = ->
    $modalInstance.close 'discard'

  $scope.save_as = ->
    $modalInstance.close "save_as"

@ModalMuseumInstanceCtrl = ($scope, $modalInstance, modal_options) ->

  $scope.museum = modal_options.museum

  $scope.translations = modal_options.translations

  $scope.discard = ->
    $modalInstance.close 'discard'

  $scope.save_as = ->
    $modalInstance.close "save", $scope.museum