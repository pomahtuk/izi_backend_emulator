angular.module("Museum.directives").directive "newLangSwitch", ($rootScope) ->
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
