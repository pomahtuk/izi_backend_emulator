angular.module("Museum.directives").directive "langList", ($timeout) ->
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
