angular.module("Museum.directives").directive "switchpub", ($timeout) ->
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
