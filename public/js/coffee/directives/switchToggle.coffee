angular.module("Museum.directives").directive 'switchToggle', ($timeout, $i18next) ->
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
