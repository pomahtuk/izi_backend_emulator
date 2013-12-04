angular.module("Museum.directives").directive "player", ->
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
