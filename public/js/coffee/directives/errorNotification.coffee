angular.module("Museum.directives").directive 'errorNotification', (errorProcessing) ->
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
