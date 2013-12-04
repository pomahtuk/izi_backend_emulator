angular.module("Museum.directives").directive "placeholdertextarea", ($timeout, storySetValidation, $i18next) ->
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
