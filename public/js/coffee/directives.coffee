"use strict"

# Directives 
angular.module("Museum.directives", [])

# Focus and blur support
.directive "ngBlur", ->
  (scope, elem, attrs) ->
    elem.bind "blur", ->
      scope.$apply attrs.ngBlur

.directive "ngFocus", ($timeout) ->
  (scope, elem, attrs) ->
    scope.$watch attrs.ngFocus, (newval) ->
      if newval
        $timeout (->
          elem[0].focus()
        ), 0, false

.directive "focusMe", ($timeout, $parse) ->  
  link: (scope, element, attrs) ->
    model = $parse(attrs.focusMe)
    scope.$watch model, (value) ->
      if value is true
        $timeout ->
          element[0].focus()
    element.bind "blur", ->
      scope.$apply model.assign(scope, false)

# Helper directives
.directive "stopEvent", ->
  link: (scope, element, attr) ->
    element.bind attr.stopEvent, (e) ->
      e.stopPropagation()

.directive "resizer", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.focus ->
      elem.animate {'width': '+=150'}, 200
    elem.blur ->
      elem.animate {'width': '-=150'}, 200

.directive "toggleMenu", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      $('.museum_navigation_menu').slideToggle(300)
      setTimeout ->
        $.scrollTo(0,0)
      , 0

.directive "toggleFilters", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      filters = $('.filters_bar')
      placeholder = $('.filters_placeholder')
      # actions = $('.actions_bar')
      margin = filters.css('top')
      if margin is '0px'
        filters.animate {'top': '-44px'}, 300
        placeholder.animate {'height': '0px'}, 300
      else
        filters.animate {'top': '0px'}, 300
        placeholder.animate {'height': '44px'}, 300
      scope.filters_opened = !scope.filters_opened

.directive 'postRender', ($timeout) ->
  restrict : 'A',
  # terminal : true
  # transclude : true
  link : (scope, element, attrs) ->
    if scope.$last
      $timeout scope.grid, 200
      opener = {
        target: $('.museum_edit_opener')
      }
      $("ul.exhibits.common").scrollspy
        min: 50
        max: 99999
        onEnter: (element, position) ->
          $(".float_menu").addClass "navbar-fixed-top"
          $(".navigation").addClass "bottom-padding"
          $(".to_top").show()

        onLeave: (element, position) ->
          $(".float_menu").removeClass "navbar-fixed-top"
          $(".navigation").removeClass "bottom-padding"
          $(".to_top").hide() unless $(".to_top").hasClass 'has_position'

        onTick: (position,state,enters,leaves) ->
          scope.show_museum_edit(opener) if scope.museum_edit_dropdown_opened
    true

# Custom HTML elements
.directive "switchpubitem", ($timeout, storySetValidation, $i18next) ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    provider: '=ngProvider'
    current_museum: '=ngMuseum'
    trans: '=translations'
    field: '@field'
    field_type: '@type'
    root: '=root'
  template: """
    <div class="btn-group pull-right item_publish_settings" ng-hide="item.status == 'draft'">
      <button class="btn btn-default dropdown-toggle" ng-class="{'btn-success': item.status == 'published', 'btn-warning': item.status == 'passcode', 'btn-danger': item.status == 'opas_invisible'}" ng-switch on="item[field]">
        <div class="extra" ng-switch ng-switch on="item[field]">
          <i ng-switch-when="published" class="icon-globe"></i>
          <i ng-switch-when="passcode" class="icon-lock"></i>
          <i ng-switch-when="opas_invisible" class="icon-eye-close"></i>
        </div>
        <!-- span ng-switch-default>{{ 'Publish' | i18next }}</span> -->
        <span ng-switch-when="published">{{ 'Published' | i18next }}</span>
        <span ng-switch-when="passcode">{{ 'Private' | i18next }}</span>
        <span ng-switch-when="opas_invisible">{{ 'Invisible' | i18next }}</span>
        <span>
          &nbsp;<i class="icon-caret-down"></i>
        </span>
      </button>


      <!-- <button class="btn btn-default" ng-hide="item.status == 'opas_invisible'" ng-class="{'active btn-warning': item.status == 'passcode' }" ng-click="item.status = 'passcode'; status_process()" type="button" ng-switch on="item[field]">
        <div class="extra">
          <i class="icon-lock"></i>
        </div>
        <span ng-switch-when="passcode">{{ 'Private' | i18next }}</span>
        <span ng-switch-when="published">{{ 'Make private' | i18next }}</span>
      </button>


      <button class="btn btn-default" ng-show="item.status == 'opas_invisible'" ng-class="{'active btn-danger': item.status == 'opas_invisible' }" ng-click="item.status = 'opas_invisible'; status_process()" type="button">
        <div class="extra">
          <i class="icon-eye-close"></i>
        </div>
        <span>{{ 'Invisible' | i18next }}</span>
      </button> -->


      <!-- <button class="btn btn-default dropdown-toggle">
        <span>
          <i class="icon-caret-down"></i>
        </span>
      </button> -->
      <ul class="dropdown-menu">
        <li ng-hide="item.status == 'published'">
          <a href="#" ng-click="item.status = 'published'; status_process()">
            <i class="icon-globe"></i> &nbsp;{{ 'Publish' | i18next }}
          </a>
        </li>
        <li ng-hide="item.status == 'passcode'">
          <a href="#" ng-click="item.status = 'passcode'; status_process()">
            <i class="icon-lock"></i> &nbsp;&nbsp;{{ 'Make private' | i18next }}
          </a>
        </li>
        <li ng-hide="item.status == 'opas_invisible'">
          <a href="#" ng-click="item.status = 'opas_invisible'; status_process()">
            <i class="icon-eye-close"></i> {{ 'Make invisible' | i18next }}
          </a>
        </li>
      </ul>
    </div>
  """ 
  controller: ($scope, $rootScope, $element, $attrs, storySetValidation) ->
    $scope.status_process = ->
      if $scope.$parent.grouped_exhibits
        switch $scope.item.status
          when 'published'
            $scope.$parent.grouped_positions.published = false
          when 'passcode'
            $scope.$parent.grouped_positions.passcode = false
          when 'opas_invisible'
            $scope.$parent.grouped_positions.invisible = false
        setTimeout ->
          $scope.$parent.grid()
        , 200
        $scope.$parent.active_exhibit.reopen_dropdown = true
        $scope.$parent.closeDropDown()
        setTimeout ->
          target =  $('li.exhibit.reopen > .opener')
          $scope.$parent.open_dropdown( {target: target}, $scope.$parent.active_exhibit)
          $scope.$parent.active_exhibit.reopen_dropdown = false
        , 500
      storySetValidation.checkValidity $scope

  link: (scope, element, attrs) ->
    scope.hidden_list = true
    true

.directive "switchpub", ($timeout) ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    provider: '=ngProvider'
    field: '@field'
    field_type: '@type'
    root: '=root'
  template: """
    <div class="btn-group pull-right">
      <button class="btn btn-default" type="button">
        <div ng-switch on="item[field]">
          <i class="icon-globe" ng-switch-when="published" ng-click="item[field] = 'passcode'; status_process()" ></i>
          <i class="icon-lock" ng-switch-when="passcode" ng-click="item[field] = 'published'; status_process()" ></i>
          <i class="icon-eye-close" ng-switch-when="opas_invisible" ng-click="item[field] = 'published'; status_process()" ></i>
        </div>
      </button>
    </div>
  """  
  controller: ($scope, $rootScope, $element, $attrs, storySetValidation) ->
    $scope.status_process = ->
      storySetValidation.checkValidity $scope

  link: (scope, element, attrs) ->
    true

.directive "newLangSwitch", ($rootScope) ->
  restrict: "E"
  replace: true
  scope:
    museum: '=museum'
  template: """
    <div class="form-group">
      <label class="col-xs-2 control-label" for="museum_language_select">{{ 'Language' | i18next }}</label>
      <div class="help ng-scope" popover="{{ 'Select language' | i18next }}" popover-animation="true" popover-placement="bottom" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-xs-6 triggered">
        <select class="form-control" ng-model="museum.language">
          <option disabled="" selected="" value="dummy">{{ 'Select a new language' | i18next }}</option>
          <option value="{{translation}}" ng-repeat="(translation, lang) in $parent.$parent.translations">{{translation | i18next }}</option>
        </select>
     </div>
    </div>
  """
  controller: ($scope, $element, $attrs) ->
    true
  link: (scope, element, attrs) ->
    
    scope.$watch 'museum.language', (newValue, oldValue) ->
      if newValue?
        if newValue isnt 'new_lang'
          console.log 'select', newValue
          # scope.$parent.create_new_language = false
          # $rootScope.$broadcast 'new_museum_language', newValue

    true

.directive "placeholderfield", ($timeout) ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
    inv_sign: '=invalidsign'
    placeholder: '=placeholder'
    field_type: '@type'
  template: """
    <div class="form-group textfield {{field}}">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">
        {{title}}
        <span class="label label-danger informer" ng-show="empty_name_error">{{ "can't be empty" | i18next }}</span>
      </label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      {{active_exhibit}}
      <div class="col-xs-7 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-7 triggered">
        <input type="hidden" id="original_{{id}}" ng-model="item[field]" required>
        <input type="text" class="form-control" id="{{id}}" value="{{item[field]}}" placeholder="{{placeholder}}">
        <div class="additional_controls">
          <a href="#" class="apply"><i class="icon-ok"></i></a>
          <!--<a href="#" class="cancel"><i class="icon-remove"></i></a>-->
        </div>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]

    $scope.status_process = ->
      if $scope.item[$scope.field] isnt $scope.oldValue
        $scope.status = 'progress'
        $scope.$digest()
        if $scope.$parent.new_item_creation and $scope.field is 'name'
          if $scope.item[$scope.field] && $scope.item[$scope.field].length isnt 0 
            $rootScope.$broadcast 'save_new_exhibit'
            return true
        if $scope.field is 'name' && $scope.item.status is 'draft'
          $scope.item.status = 'passcode'

        $rootScope.$broadcast 'changes_to_save', $scope

  link: (scope, element, attrs) ->
    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    control = element.find('.triggered > .form-control')
    additional = triggered.find('.additional_controls')

    scope.empty_name_error = false

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show()
      control.val scope.item[scope.field]
      control.focus()
      control.removeClass 'ng-invalid'

    element.find('.triggered > .form-control').focus ->
      additional.show()

    element.find('.triggered > .form-control').blur ->
      elem = $ @
      value = elem.val()
      additional.hide()
      $timeout ->
        unless scope.$parent.new_item_creation && scope.field is 'number'
          scope.item[scope.field] = value
          scope.$digest()
          if elem.val().length > 0
            scope.status_process()
          else
            return true
        if elem.val().length > 0
          triggered.hide()
          trigger.show()
        else
          elem.addClass 'ng-invalid'
          if scope.field is 'name' && scope.item.status isnt 'dummy'
            elem.val scope.oldValue
            scope.item[scope.field] = scope.oldValue
            scope.$digest()
            # element.find('.error_text').show()
            # setTimeout ->
            #   element.find('.error_text').hide()
            # , 2000
            triggered.hide()
            trigger.show()
            scope.status_process() if scope.item[scope.field] isnt ''
      , 100

    element.find('.triggered > .form-control').keyup ->  
      elem = $ @
      val = elem.val()
      if val is '' and scope.field is 'name' and scope.item[scope.field] isnt ''
        $timeout ->
          elem.val scope.oldValue
          scope.item[scope.field] = scope.oldValue
          scope.empty_name_error = true
          scope.$digest()
          setTimeout ->
            scope.empty_name_error = false
            scope.$digest()
          , 2000
          scope.status_process()
        , 0, false
      true

    scope.$watch 'item[field]', (newValue, oldValue) ->
      scope.status = ''
      criteria = if scope.field is 'number'
        newValue?
      else
        newValue
      unless criteria
        additional.hide()
        trigger.hide()
        triggered.show()
        control.val ''
        if scope.field is 'name'
          triggered.find('.form-control').focus()
      else
        additional.show()
        # if scope.$parent.element_switch is true
        element.find('.triggered > .form-control').val newValue
        trigger.show()
        triggered.hide()

    true

.directive "placeholdertextarea", ($timeout, storySetValidation, $i18next) ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
    max_length: '@maxlength'
    placeholder: '=placeholder'
    field_type: '@type'
  template: """
    <div class="form-group textfield large_field">
      <label class="col-xs-2 control-label" for="{{id}}" ng-click="edit_mode = false">
        {{title}}
        <span class="label label-danger" ng-show="field == 'long_description' && item[field].length == 0">{{ "Fill to publish" | i18next }}</span>
      </label>
      <div class="help" popover="{{help}}" popover-placement="bottom" popover-animation="true" popover-trigger="mouseenter">
        <i class="icon-question-sign"></i>
      </div>
      <div class="col-xs-7 trigger">
        <div class="placeholder large" ng-click="update_old()">{{item[field]}}</div>
      </div>
      <div class="col-xs-7 triggered">
        <input type="hidden" id="original_{{id}}" ng-model="item[field]" required">
        <div class="content_editable" contenteditable="true" id="{{id}}" placeholder="{{placeholder}}">{{item[field]}}</div>
        <div class="additional_controls">
          <a href="#" class="apply"><i class="icon-ok"></i></a>
          <!--<a href="#" class="cancel"><i class="icon-remove"></i></a>-->
        </div>
      </div>
      <span class="sumbols_left">
        {{length_text}}
      </span>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """ 
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.field]
    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]
    $scope.status_process = ->
      if $scope.item[$scope.field] isnt $scope.oldValue
        $scope.status = 'progress'
        $scope.$digest()
        $rootScope.$broadcast 'changes_to_save', $scope
  link: (scope, element, attrs) ->
    scope.length_text = "#{scope.max_length} symbols left"

    scope.max_length ||= 2000

    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    sumbols_left = element.find('.sumbols_left')
    control = triggered.children('.content_editable')
    additional = triggered.find('.additional_controls')

    element.find('div.placeholder').click ->
      trigger.hide()
      triggered.show()
      control.text scope.item[scope.field]
      control.focus()
      scope.length_text = "#{scope.max_length - control.text().length} #{$i18next('symbols left')}"
      sumbols_left.show()

    control.focus ->
      sumbols_left.show()
      additional.show()

    control.blur ->
      elem = $ @
      sumbols_left.hide()
      scope.item[scope.field] = elem.text()
      scope.$digest()
      scope.status_process()
      if elem.text() isnt ''
        triggered.hide()
        trigger.show()
        scope.status_process()
      else
        additional.hide()

    control.keyup (e) ->
      elem = $ @
      value = elem.text()
      if value.length > scope.max_length
        elem.text value.substr(0, scope.max_length)
      scope.length_text = "#{scope.max_length - value.length} #{$i18next('symbols left')}"
      scope.$digest()

    scope.$watch 'item[field]', (newValue, oldValue) ->
      scope.max_length ||= 2000
      
      unless newValue
        scope.length_text = "2000 #{$i18next('symbols left')}"
        control.text ''
        trigger.hide()
        triggered.show()
        # sumbols_left.show()
        additional.hide()
        if scope.field is 'long_description'
          storySetValidation.checkValidity {item: scope.item, root: scope.$parent.active_exhibit, field_type: 'story'}
      else
        additional.show()
        scope.length_text = "#{scope.max_length - newValue.length} #{$i18next('symbols left')}"
        # if newValue.length >= scope.max_length
        #   scope.item[scope.field] = newValue.substr(0, scope.max_length-1)
        if scope.$parent.element_switch is true
          trigger.show()
          triggered.hide()
          sumbols_left.hide()
        true
    true

.directive "quizanswer", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    collection: '=ngCollection'
    id: '@ngId'
    field: '@field'
    field_type: '@type'
  template: """
    <div class="form-group textfield string optional checkbox_added">
      <label class="string optional control-label col-xs-2" for="{{id}}">
        <span class='correct_answer_indicator'>{{ "correct" | i18next }}</span>
      </label>
      <input class="coorect_answer_radio" name="correct_answer" type="radio" value="{{item._id}}" ng-model="checked" ng-click="check_items(item)">
      <div class="col-xs-5 trigger">
        <span class="placeholder" ng-click="update_old()">{{item[field]}}</span>
      </div>
      <div class="col-xs-5 triggered">
        <input class="form-control" id="{{id}}" name="{{item._id}}" placeholder="Enter option" type="text" ng-model="item[field]" required>
        <div class="error_text">{{ "can't be blank" | i18next }}</div>
      </div>
      <status-indicator ng-binding="status"></statusIndicator>
    </div>
  """
  controller : ($scope, $rootScope, $element, $attrs) ->
    $scope.item.statuses = {} unless $scope.item.statuses?
    $scope.status = $scope.item.statuses[$scope.item.content]
    $scope.item.correct_saved = false unless $scope.item.correct_saved?

    $scope.check_items = (item) ->
      $rootScope.$broadcast 'quiz_changes_to_save', $scope, item

    $scope.update_old = ->
      $scope.oldValue = $scope.item[$scope.field]

    $scope.status_process = ->
      if $scope.item[$scope.field] isnt $scope.oldValue 
        $scope.status = 'progress'
        $scope.$digest()
        $rootScope.$broadcast 'changes_to_save', $scope

  link: (scope, element, attrs) ->
    element = $ element
    trigger = element.find('.trigger')
    triggered = element.find('.triggered')
    indicator = element.find('.correct_answer_indicator')

    element.find('span.placeholder').click ->
      trigger.hide()
      triggered.show().children().first().focus()

    element.find('.triggered > *').blur ->
      elem = $ @
      scope.status_process()
      if elem.val() isnt ''
        triggered.hide()
        trigger.show()

    scope.$watch 'collection', (newValue, oldValue) ->
      if newValue
        scope.checked = newValue[0]._id
        for single_item in newValue
          scope.checked = single_item._id if single_item.correct is true            

    scope.$watch 'item.content', (newValue, oldValue) ->
      unless newValue
        trigger.hide()
        triggered.show()
      else
        if scope.$parent.element_switch is true
          trigger.show()
          triggered.hide()

    scope.$watch 'item.correct_saved', (newValue, oldValue) ->
      if newValue is true
        indicator.show()
        setTimeout ->
          indicator.hide()
          scope.$apply scope.item.correct_saved = false
        , 1000

    , true

.directive "statusIndicator", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngBinding'
    field: '=ngField'
  template: """
    <div class="statuses">
      <div class='preloader' ng-show="item=='progress'"></div>
      <div class="save_status" ng-show="item=='done'">
        <i class="icon-ok-sign"></i>{{ "saved" | i18next }}
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.$watch 'item', (newValue, oldValue) ->
      # code below just emulates work of server and some latency
      if newValue
        if newValue is 'progress'
          scope.progress_timeout = setTimeout ->
            scope.$apply scope.item = 'done'
          , 500
        if newValue is 'done'
          scope.done_timeout = setTimeout ->
            scope.$apply scope.item = ''
          , 700
      else
        clearTimeout(scope.done_timeout)
        clearTimeout(scope.progress_timeout)
    , true

    true

.directive "audioplayer", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
    parent: '=parent'
  template: """
    <div class="form-group audio">
      <label class="col-xs-2 control-label" for="audio">
        {{ "Audio" | i18next }}
        <span class="label label-danger" ng-show="edit_mode == 'empty'">{{ "Fill to publish" | i18next }}</span>
      </label>
      <div class="help">
        <i class="icon-question-sign" data-content="{{ "Supplementary field." | i18next }}" data-placement="bottom"></i>
      </div>
      <div class="col-xs-9 trigger" ng-show="edit_mode == 'value'">
        <div class="jp-jplayer" id="jquery_jplayer_{{id}}">
        </div>
        <div class="jp-audio" id="jp_container_{{id}}">
          <div class="jp-type-single">
            <div class="jp-gui jp-interface">
              <ul class="jp-controls">
                <li>
                <a class="jp-play" href="javascript:;" tabindex="1"></a>
                </li>
                <li>
                <a class="jp-pause" href="javascript:;" tabindex="1"></a>
                </li>
              </ul>
            </div>
            <div class="jp-timeline">
              <div class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="#" id="visibility_filter">{{item[field].name}}<span class="caret"></span></a>
                <ul class="dropdown-menu" role="menu">
                  <li role="presentation">
                    <a href="#" class="replace_media" data-confirm="Are you sure you wish to replace this audio?" data-method="delete" data-link="{{$parent.$parent.backend_url}}/media/{{item[field]._id}}">Replace</a>
                  </li>
                  <li role="presentation">
                    <a href="{{item[field].url}}" target="_blank">Download</a>
                  </li>
                  <li role="presentation">
                    <a class="remove" href="#" data-confirm="Are you sure you wish to delete this audio?" data-method="delete" data-link="{{$parent.$parent.backend_url}}/media/{{media._id}}" delete-media="" stop-event="" media="item[field]" parent="item">Delete</a>
                  </li>
                </ul>
              </div>
              <div class="jp-progress">
                <div class="jp-seek-bar">
                  <div class="jp-play-bar">
                  </div>
                </div>
              </div>
              <div class="jp-time-holder">
                <div class="jp-current-time">
                </div>
                <div class="jp-duration">
                </div>
              </div>
              <div class="jp-no-solution">
                <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank"></a>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="triggered" ng-show="edit_mode == 'empty'">
        <img class="upload_audio" src="/img/audio_drag.png" />
        <span>drag audio here or </span>
        <a href="#" class="btn btn-default" button-file-upload="">Click to upload</a>
      </div>
      <div class="col-xs-9 processing" ng-show="edit_mode == 'processing'">
        <img class="upload_audio" src="/img/medium_loader.GIF" style="float: left;"/> 
        <span>{{ "&nbsp;&nbsp;processing audio" | i18next }}</span>
      </div>
      <status-indicator ng-binding="item" ng-field="field"></statusIndicator>
    </div>
  """
  # controller: ($scope, $element, $attrs) ->
  #   $scope.replace_media = ()  ->
  #     true
  link: (scope, element, attrs) ->

    scope.edit_mode = false

    element = $ element
    element.find('.replace_media').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      elem   = $ @

      # if confirm elem.data('confirm')
      parent = elem.parents('#drop_down, #museum_drop_down')
      parent.click()
      input = parent.find('input:file')
      input.click()

    scope.$watch 'item[field]', (newValue, oldValue) ->
      unless newValue
        scope.edit_mode = 'empty'
      else if newValue is 'processing'
        scope.edit_mode = 'processing'
      else
        scope.edit_mode = 'value'
        $("#jquery_jplayer_#{scope.id}").jPlayer
          cssSelectorAncestor: "#jp_container_#{scope.id}"
          swfPath: "/js"
          wmode: "window"
          preload: "auto"
          smoothPlayBar: true
          # keyEnabled: true
          supplied: "mp3, ogg"
        $("#jquery_jplayer_#{scope.id}").jPlayer "setMedia",
          mp3: newValue.url
          ogg: newValue.thumbnailUrl
    true

.directive "player", ->
  restrict: "E"
  replace: true
  require: "?ngModel"
  scope:
    item: '=ngItem'
    help: '@ngHelp'
    id: '@ngId'
    title: '@ngTitle'
    field: '@ngField'
    container: '=container'
  template: """
    <div class="player">
      <div class="jp-jplayer" id="jquery_jplayer_{{id}}">
      </div>
      <div class="jp-audio" id="jp_container_{{id}}">
        <div class="jp-type-single">
          <div class="jp-gui jp-interface">
            <ul class="jp-controls">
              <li>
              <a class="jp-play" href="javascript:;" tabindex="1"></a>
              </li>
              <li>
              <a class="jp-pause" href="javascript:;" tabindex="1"></a>
              </li>
            </ul>
          </div>
          <div class="jp-timeline">
            <a class="dropdown-toggle" href="#">&nbsp;</a>
            <div class="jp-progress">
              <div class="jp-seek-bar">
                <div class="jp-play-bar">
                </div>
              </div>
            </div>
            <div class="jp-time-holder">
              <div class="jp-current-time">
              </div>
              <div class="jp-duration">
              </div>
            </div>
            <div class="jp-no-solution">
              <span>Update Required</span>To play the media you will need to either update your browser to a recent version or update your browser to a recent version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank"></a>
            </div>
          </div>
        </div>
      </div>
      <div class="points_position_holder">
        <div class="image_connection" ng-class="{'hovered': image.image.hovered}" data-image-index="{{$index}}" js-draggable ng-repeat="image in container.stories[$parent.current_museum.language].mapped_images" ng-mouseenter="set_hover(image, true)" ng-mouseout="set_hover(image, false)">
          {{ charFromNum(image.image.order) }}
        </div>
      </div>
    </div>
  """
  controller: ($scope, $element, $attrs) ->
    $scope.charFromNum = (num)  ->
      String.fromCharCode(num + 97).toUpperCase()

    $scope.set_hover = (image, sign) ->
      sub_sign = if sign
        sign
      else
        if image.dragging
          true
        else
          sign
      image.image.hovered = sub_sign
      $scope.container.has_hovered = sub_sign

  link: (scope, element, attrs) ->
    scope.$watch 'item[field]', (newValue, oldValue) ->
      if newValue
        $("#jquery_jplayer_#{scope.id}").jPlayer
          cssSelectorAncestor: "#jp_container_#{scope.id}"
          swfPath: "/js"
          wmode: "window"
          preload: "auto"
          smoothPlayBar: true
          # keyEnabled: true
          supplied: "mp3, ogg"
        $("#jquery_jplayer_#{scope.id}").jPlayer "setMedia",
          mp3: newValue.url
          ogg: newValue.thumbnailUrl
      else
        console.log 'no audio'

    true

.directive "museumSearch", ->
  restrict: "E"
  replace: true
  transclude: true
  require: "?ngModel"
  scope:
    item: '=ngModel'
  template: """
    <div class="searches">
      <div class="search" ng-hide="museum_search_visible" ng-click="museum_search_visible=true; museum_input_focus = true">
        <i class="icon-search"></i>
        <a href="#">{{item || 'Search' | i18next }}</a>
      </div>
      <div class="search_input" ng-show="museum_search_visible">
        <input class="form-control" ng-model="item" placeholder="{{ "Search" | i18next }}" type="text" focus-me="museum_input_focus">
        <a class="search_reset" href="#" ng-click="item=''">
          <i class="icon-remove-sign"></i>
        </a>
      </div>
    </div>
  """ 
  controller: ($scope, $element) ->
    $scope.museum_search_visible = false
    $scope.museum_input_focus = false

    $($element).find('.search_input input').blur ->
      elem   = $ @
      $scope.$apply $scope.museum_input_focus = false
      elem.animate {width: '150px'}, 150, ->
        $scope.$apply $scope.museum_search_visible = false
        true

    $($element).find('.search_input input').focus ->
      input = $ @
      width = $('body').width() - 700
      if width > 150
        input.animate {width: "#{width}px"}, 300

  link: (scope, element, attrs) ->
    true

.directive 'canDragAndDrop', (errorProcessing, $i18next) ->
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

.directive "buttonFileUpload", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    # upload = $("##{attr[selector]}")

    elem.click (e) ->
      e.preventDefault()
      elem = $ @
      parent = elem.parents('#drop_down, #museum_edit_dropdown')
      parent.find(':file').click()

.directive 'deleteMedia', (storySetValidation, $http) ->
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

.directive 'dragAndDropInit', (uploadHelpers) ->
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

.directive 'urlUpload', ($http, uploadHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element = $ element

    testRegex = /^(http(s?):)|([/|.|\w|\s])*\.(?:jpg|jpeg|gif|png)?/

    element.bind 'paste', ->
      setTimeout ->
        url = element.val()
        if testRegex.test(url)
          type = "image/#{url.split('.').reverse()[0]}" 
          console.log 'ok'
          ## probably, should show some preloader or load indicator
          ## the only question is - when should i hide this?
          element.parents('ul.images').find('.museum_image_placeholder').css({'display':'inline-block'})
          $.getImageData
            url: url
            server: "#{scope.$parent.backend_url}/imagedata"
            success: (img) ->
              element.val ''
              uploadHelpers.cavas_processor img, type 
        else
          if url isnt ''
            console.log 'some error should be shown'
            element.addClass 'error'
            setTimeout ->
              element.removeClass 'error'
            , 1500
      , 10

.directive 'dropDownEdit', ($timeout, $http) ->
  restrict: 'A'
  link: (scope, element, attrs) ->

    quiz_watcher     = null
    question_watcher = null
    name_watcher     = null
    answers_watcher  = null
    qr_code_watcher  = null

    scope.$watch 'active_exhibit.stories[current_museum.language]', (newValue, oldValue) ->
      quiz_watcher() if quiz_watcher?
      question_watcher() if question_watcher?
      name_watcher() if name_watcher?
      answers_watcher() if answers_watcher?
      qr_code_watcher() if qr_code_watcher?
      if newValue?
        quiz_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].quiz', (newValue, oldValue) ->
          if newValue?
            if newValue isnt oldValue
              if newValue.status is 'published'
                console.log 'pub'
                unless $("#story_quiz_enabled").is(':checked')
                  setTimeout ->
                    unless scope.quizform.$valid
                      setTimeout ->
                        $("#story_quiz_disabled").click()
                      , 10
                  , 100
                else
                  setTimeout ->
                    $("#story_quiz_enabled").click()
                  , 10
              else
                unless $("#story_quiz_disabled").is(':checked')
                  setTimeout ->
                    $("#story_quiz_disabled").click()
                  , 10

        question_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].quiz.question', (newValue, oldValue) ->
          if scope.quizform? && newValue isnt oldValue
            # console.log $scope.quizform
            if scope.quizform.$valid
              scope.mark_quiz_validity(scope.quizform.$valid)
            else
              setTimeout ->
                $("#story_quiz_disabled").click()
                scope.mark_quiz_validity(scope.quizform.$valid)
              , 10

        name_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].name', (newValue, oldValue) ->
          if newValue?
            form = $('#media form')
            if form.length > 0
              if scope.active_exhibit.stories[scope.current_museum.language].status is 'dummy'
                scope.active_exhibit.stories[scope.current_museum.language].status = 'passcode' if newValue
              else
                unless scope.new_item_creation
                  unless newValue 
                    scope.active_exhibit.stories[scope.current_museum.language].name = oldValue
                    scope.empty_name_error = true
                    setTimeout ->
                      scope.empty_name_error = false
                    , 1500
                # else
                #   if newValue and $scope.$parent.new_item_creation
                #     $rootScope.$broadcast 'save_new_exhibit'

        answers_watcher = scope.$watch ->
          if scope.active_exhibit.stories[scope.current_museum.language]?
            angular.toJson(scope.active_exhibit.stories[scope.current_museum.language].quiz.answers)
          else
            undefined
        , (newValue, oldValue) ->
          if newValue?
            if scope.quizform?
              if scope.quizform.$valid
                scope.mark_quiz_validity(scope.quizform.$valid)
              else
                setTimeout ->
                  $("#story_quiz_disabled").click()
                , 10

        # qr_code workaround
        qr_code_watcher =  scope.$watch 'active_exhibit.stories[current_museum.language]', (newValue, oldValue) ->
          if newValue
            unless scope.active_exhibit.stories[scope.current_museum.language].qr_code
              $http.get("#{scope.backend_url}/qr_code/#{scope.active_exhibit.stories[scope.current_museum.language]._id}").success (d) ->
                scope.active_exhibit.stories[scope.current_museum.language].qr_code = d

.directive 'openLightbox', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    parent   = element.parents('#drop_down, #museum_edit_dropdown')
    lightbox = parent.find('.lightbox_area')
    element.click ->
      if element.parents('li').hasClass('dragged')
        element.parents('li').removeClass('dragged')
      else
        lightbox.show()
        parent.height(lightbox.height() + 45) if lightbox.height() + 45 > parent.height()
        setTimeout ->
          $(".slider:visible .thumb.item_#{attrs.openLightbox} img").click()
        , 100
    true

.directive 'lightboxCropper', ($http, errorProcessing, $i18next) ->
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

.directive 'sortable', ($http, errorProcessing, imageMappingHelpers, $i18next) ->
  restrict: 'A'
  scope:
    images: "=sortable"
    lang: "=lang"
  link: (scope, element, attrs) ->
    element  = $ element
    backend  = scope.$parent.backend_url || scope.$parent.$parent.backend_url
    element.disableSelection()
    console.log scope.lang
    element.sortable
      placeholder: "ui-state-highlight"
      tolerance: 'pointer'
      helper: 'clone'
      cancel: ".timestamp, .upload_item"
      items: "li:not(.timestamp):not(.upload_item)"
      # revert: true
      scroll: false
      delay: 100
      start: (event, ui) ->
        ui.item.data 'start', ui.item.index()
        ui.helper.addClass 'dragged'
        element.parents('.description').find('.timline_container').addClass('highlite')
      stop: ( event, ui ) ->
        elements = element.find('li')
        start    = ui.item.data('start')
        end      = ui.item.index()
        scope.images.splice(end, 0, scope.images.splice(start, 1)[0])
        element.parents('.description').find('.timline_container').removeClass('highlite')
        if scope.images[end].image.order isnt end
          orders = {}
          for image, index in scope.images
            image.image.order = index
            orders[image.image._id] = index
          imageMappingHelpers.update_images scope.images[0].image.parent, orders, backend
          scope.$apply()

.directive 'jsDraggable', ($rootScope, $i18next, imageMappingHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element

    weight_calc = imageMappingHelpers.weight_calc

    element.draggable
      axis: "x"
      containment: "parent"
      cursor: "pointer"
      start: (event, ui) ->
        image = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        image.dragging = true
      drag: (event, ui) ->
        current_time = imageMappingHelpers.calc_timestamp(ui, false)
        image        = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        if image?
          if image.mappings[$rootScope.lang].timestamp isnt current_time
            image.mappings[$rootScope.lang].timestamp = current_time
        true
      stop: ( event, ui ) ->
        console.log 'drag_stop'
        current_time   = imageMappingHelpers.calc_timestamp(ui, false)
        image          = scope.$parent.container.stories[scope.$parent.$parent.current_museum.language].mapped_images[ui.helper.data('image-index')]
        image.dragging = false
        scope.$parent.set_hover( image, false )
        if image?
          if image.mappings[$rootScope.lang].timestamp isnt current_time
            image.mappings[$rootScope.lang].timestamp = current_time

        scope.$parent.container.images.sort(imageMappingHelpers.sort_weight_func).sort(imageMappingHelpers.sort_time_func)

        orders = {}
        for item, index in scope.$parent.container.images
          item.image.order = index
          orders[item.image._id] = index
          if item.image._id is image.image._id
            imageMappingHelpers.update_image item, scope.$parent.$parent.backend_url

        imageMappingHelpers.update_images image.image.parent, orders, scope.$parent.$parent.backend_url

        scope.$parent.$parent.$digest()
        event.stopPropagation()

.directive 'droppable', ($http, errorProcessing, $i18next, imageMappingHelpers) ->
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

.directive 'exhibitsSortable', ($http, errorProcessing, backendWrapper, $i18next) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    backend  = scope.backend_url
    element.disableSelection()
    index          = 0
    exhibit_name   = ""
    elements_space = 0
    element_width  = 0
    element_height = 0
    first_margin   = 0
    exhibit        = {}
    multiply_mode  = false
    new_number     = ''
    after_index    = 0
    start_index    = 0
    items          = []

    collection     = switch attrs['collection']
      when 'common'
        scope.exhibits
      when 'published'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.published
        else
          []
      when 'private'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.private
        else
          []
      when 'invisible'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.invisible
        else
          []
      when 'draft'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.draft
        else
          []

    get_closest_element = (elements, x, y) ->
      for el, index in elements
        el  = $ el
        position = el.offset()
        compare_x_to = first_margin + element_width + position.left
        if x - compare_x_to < elements_space
          if y >= position.top and y <= position.top + element_height + 30 # may be i shoul get rid of this magic number?
            return el
            break
      return null

    find_by_id = (id) ->
      for item in collection
        if item._id is id
          return item
      return null

    element.sortable
      placeholder: "exhibits_placeholder"
      tolerance: 'intersect'
      helper: 'clone'
      appendTo: document.body
      cursor: "move"
      cursorAt: { left: -10, top: 0 }
      items: "> li.exhibit:not(.dummy)"
      scroll: false
      delay: 100
      start: (event, ui) ->
        index             = ui.item.data('exhibit-id')
        exhibit           = find_by_id index
        exhibit_name      = exhibit.stories[scope.current_museum.language].name
        exhibit.active    = true
        ui.item.show()
        ui.helper.html("<span class='info'>Move #{exhibit_name}</span>").addClass('exhibits_info')
        ui.helper.addClass 'dragged'
        elements_space = parseInt $(element.find('li.exhibit')[1]).css('margin-left').split('px')[0], 10
        element_width  = ui.item.width()
        element_height = ui.item.height()
        first_margin   = parseInt $(element.find('li.exhibit')[0]).css('margin-left').split('px')[0], 10
        margin         = elements_space / 2
        element.find('.exhibits_placeholder').html("<span class='helper'></span>").find('.helper').css {'margin-left': "#{margin}px"}
        scope.grid()

      sort: (event, ui) ->
        ##
        ## new number shoul be found other way in case if we are using grouping
        ##

        multiply_mode  = if scope.selected_count > 1
          true
        else
          false
        target         = $(event.toElement)
        target_element = target.parents('li.exhibit')
        if target_element.length is 0
          # new_number = ''
          move_text  = if multiply_mode
            "Move #{scope.selected_count} exhibits"
          else
            "Move #{exhibit_name}"
          inset_after = get_closest_element target.find('li.exhibit'), event.pageX, event.pageY
          if inset_after?
            after_index = inset_after.data('exhibit-id')
            inset_after_exhibit = find_by_id(after_index)
            new_number  = inset_after_exhibit.number.split('.')
            new_number[new_number.length - 1] = parseInt(new_number[new_number.length - 1], 10) + 1
            # console.log new_number
        else
          target_index      = target_element.data('exhibit-id')
          target_exhibit    = find_by_id(target_index)
          next_num = if target_index + 1 < collection.length
            find_by_id(target_index + 1).number.split('.')
          else
            [999999999]
          curr_num = target_exhibit.number.split('.')
          if curr_num.length <= next_num.length or next_num[0] > curr_num[0]
            new_number = curr_num
            new_number.push 1
          else
            for i in [target_index + 1..collection.length - 2]
              next_num = find_by_id(i + 1).number
              curr_num = find_by_id(i).number
              if next_num.length isnt curr_num.length
                res_number      = curr_num.split('.')
                res_last_number = res_number[res_number.length - 1]
                res_last_number = parseInt(res_last_number, 10) + 1
                res_number[res_number.length - 1] = res_last_number
                new_number = res_number
          move_text = if multiply_mode
            "Move #{scope.selected_count} exhibits"
          else
            "#{new_number.join('.')} #{exhibit_name}"

        element.find('.exhibits_placeholder').insertAfter inset_after
        ui.helper.find('.info').text move_text

      stop: ( event, ui ) ->
        # console.log new_number
        elements          = element.find('li')
        exhibit.active    = false
        ex_id             = ui.item.data('exhibit-id')
        find_by_id(ex_id).number = new_number.join('.')
        looking_for_id = find_by_id(ex_id)._id

        if multiply_mode
          items = element.find('li.exhibit.selected:not(.active)')
          items.insertAfter ui.item
          for item, index in items
            item = $ item
            exhibit = find_by_id(item.data('exhibit-id'))
            new_item_number[new_number.length - 1]  = parseInt(new_number[new_number.length - 1], 10) + 1 + index
            exhibit.number = new_item_number.join('.')

        collection = backendWrapper.sortArray collection

        prev_incremented = false
        for index in [0..collection.length - 2]
          current_item  = collection[index]
          next_item     = collection[index + 1]
          current_arr   = current_item.number.split('.')
          next_arr      = next_item.number.split('.')
          # console.log current_arr, next_arr
          if current_arr.length is next_arr.length
            # console.log 'array same'
            next_last_number    = parseInt next_arr[next_arr.length - 1], 10
            current_last_number = parseInt current_arr[current_arr.length - 1], 10
            prev_incremented    = false
            if next_last_number isnt current_last_number + 1
              prev_incremented = true
              next_arr[next_arr.length - 1] = current_last_number + 1
              next_item.number = next_arr.join('.')              
          else if next_arr.length > current_arr.length
            # console.log 'array is bigger'
            if prev_incremented is true 
              if next_arr[next_arr.length - 2] isnt current_arr[current_arr.length - 1]
                console.log 'item was incremented and next item is child of'
            next_arr[next_arr.length - 1] = 1 if next_arr[next_arr.length - 1] isnt 1
            next_item.number = next_arr.join('.')

          else if next_arr.length < current_arr.length
            # console.log 'array smaller'
            next_last_number    = parseInt next_arr[next_arr.length - 1], 10
            current_last_number = parseInt current_arr[current_arr.length - 2], 10
            prev_incremented    = false
            if next_arr[next_arr.length - 1] isnt current_last_number + 1
              prev_incremented = true
              next_arr[next_arr.length - 1] = current_last_number + 1
              next_item.number = next_arr.join('.')

        scope.$digest()
        scope.grid()
        setTimeout ->
          element.sortable().refresh()
        , 100

        # sort exhibits!
        sort_obj = {}
        for exhibit in collection
          sort_obj[exhibit._id] = exhibit.number
        # console.log sort_obj

        $http.post("#{scope.backend_url}/story_set/update_numbers/#{scope.current_museum._id}", sort_obj).success (data) ->
          console.log data
          setTimeout ->
            element.sortable "enable"
          , 100
          true
        .error ->
          errorProcessing.addError $i18next 'Failed to save sort status'

.directive 'switchToggle', ($timeout, $i18next) ->
  restrict: 'A'
  controller:  ($scope, $rootScope, $element, $attrs, $http) ->
    selector = $attrs['quizSwitch']
    $scope.quiz_state = (form, item) ->
      $scope.mark_quiz_validity(form.$valid)
      if form.$valid
        $timeout ->
          $http.put("#{$scope.backend_url}/quiz/#{item._id}", item).success (data) ->
            console.log data
          .error ->
            errorProcessing.addError $i18next 'Failed to save quiz state'
          true
        , 0
      else
        setTimeout ->
          $("##{selector}_disabled").click()
        , 300     
      true

    $scope.mark_quiz_validity = (valid) ->
      form = $("##{selector} form")
      if valid
        form.removeClass 'has_error'
      else
        form.addClass 'has_error'
        question = form.find('#story_quiz_attributes_question, #museum_story_quiz_attributes_question')
        question.addClass 'ng-invalid' if question.val() is ''
      true

  link: (scope, element, attrs) ->
    selector = attrs['quizSwitch']
    $("##{selector}_enabled, ##{selector}_disabled").change ->
      elem = $ @
      if elem.attr('id') is "#{selector}_enabled"
        $("label[for=#{selector}_enabled]").text($i18next('Enabled'))
        $("label[for=#{selector}_disabled]").text($i18next('Disable'))
        true
      else
        $("label[for=#{selector}_disabled]").text($i18next('Disabled'))
        $("label[for=#{selector}_enabled]").text($i18next('Enable'))
        true

.directive 'errorNotification', (errorProcessing) ->
  restrict: "E"
  replace: true
  transclude: true
  template: """
    <div class="error_notifications" ng-hide="errors.length == 0">
      <div class="alert alert-danger" ng-repeat="error in errors">
        {{error.error}}
        <a class="close" href="#" ng-click="dismiss_error($index)" >&times;</a>
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    scope.errors = errorProcessing.getErrors()

    scope.dismiss_error = (index) ->
      errorProcessing.deleteError(index)

    scope.$on 'new_error', (event, errors) ->
      scope.errors = errors

# .directive 'scrollspyInit', ->
#   restrict: 'A'
#   link: (scope, element, attrs) ->
#     console.log 'inited'
#     opener = {
#       target: $('.museum_edit_opener')
#     }
#     $("ul.exhibits.common").scrollspy
#       min: 50
#       max: 99999
#       onEnter: (element, position) ->
#         $(".float_menu").addClass "navbar-fixed-top"
#         $(".navigation").addClass "bottom-padding"
#         $(".to_top").show()

#       onLeave: (element, position) ->
#         $(".float_menu").removeClass "navbar-fixed-top"
#         $(".navigation").removeClass "bottom-padding"
#         $(".to_top").hide() unless $(".to_top").hasClass 'has_position'

#       onTick: (position,state,enters,leaves) ->
#         scope.show_museum_edit(opener) if scope.museum_edit_dropdown_opened

.directive 'toTop', (errorProcessing) ->
  restrict: "E"
  replace: true
  transclude: true
  template: """
    <div class="to_top">
      <div class="to_top_panel">
        <div class="to_top_button" title="Наверх">
          <span class="arrow"><i class="icon-long-arrow-up"></i></span>
        </div>
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    element = $ element

    element.click ->
      if element.hasClass 'has_position'
        element.removeClass 'has_position'
        pos = element.data('scrollPosition')
        element.find('.arrow i').removeClass("icon-long-arrow-down").addClass("icon-long-arrow-up")
        $.scrollTo pos, 0
      else
        element.addClass 'has_position'
        pos = $(document).scrollTop()
        element.data('scrollPosition', pos)
        element.find('.arrow i').addClass("icon-long-arrow-down").removeClass("icon-long-arrow-up")
        $.scrollTo 0, 0

.directive "langList", ($timeout) ->
  restrict: "E"
  replace: true
  transclude: true
  template: """
    <ul class="nav nav-tabs lang_list">
      <li class="active">
        <a href="#" class="dropdown-toggle">
          {{current_museum.language | i18next}}
          <i class="icon-chevron-down"></i>
        </a>
        <ul class="dropdown-menu">
          <li ng-repeat="story in lang_arr">
            <a href="#" ng-click="current_museum.language = story.language">{{ story.language | i18next}}</a>
          </li>
          <li class="divider" ng-hide="lang_arr.length == 0"></li>
          <li>
            <a href="#" ng-click="new_museum_language()"> {{ 'newLanguage' | i18next }} </a>
          </li>
        </ul>        
      </li>
    </ul>
  """  
  link: (scope, element, attrs) ->

    weight_calc = (item) ->
      weight = 0
      weight -= 100 if item.language is scope.current_museum.language
      # weight -= 50 if item.language is scope.oldLang
      return weight

    lang_sort = (a, b) ->
      if weight_calc(a) > weight_calc(b)
        return 1
      else if weight_calc(a) < weight_calc(b)
        return -1
      else
        return 0

    scope.$watch 'current_museum.language', ( newValue, oldValue ) ->

      scope.lang_arr = []

      # scope.oldLang  = oldValue

      for key, value of scope.current_museum.stories
        scope.lang_arr.push value

      scope.lang_arr.sort(lang_sort)
      scope.lang_arr.splice(0, 1)
      # scope.last_display  = scope.lang_arr

      # scope.$digest()
