angular.module("Museum.directives", []).directive "audioplayer", ->
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
