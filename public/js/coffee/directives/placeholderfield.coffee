angular.module("Museum.directives").directive "placeholderfield", ($timeout) ->
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
