angular.module("Museum.directives").directive "switchpubitem", ($timeout, storySetValidation, $i18next) ->
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
