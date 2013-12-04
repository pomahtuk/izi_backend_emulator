angular.module("Museum.directives").directive 'dropDownEdit', ($timeout, $http) ->
  restrict: 'A'
  link: (scope, element, attrs) ->

    quiz_watcher     = null
    question_watcher = null
    name_watcher     = null
    answers_watcher  = null
    qr_code_watcher  = null

    scope.$watch 'active_exhibit.stories[current_museum.language]', (newValue, oldValue) ->
      quiz_watcher() if quiz_watcher?
      question_watcher() if question_watcher?
      name_watcher() if name_watcher?
      answers_watcher() if answers_watcher?
      qr_code_watcher() if qr_code_watcher?
      if newValue?
        quiz_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].quiz', (newValue, oldValue) ->
          if newValue?
            if newValue isnt oldValue
              if newValue.status is 'published'
                console.log 'pub'
                unless $("#story_quiz_enabled").is(':checked')
                  setTimeout ->
                    unless scope.quizform.$valid
                      setTimeout ->
                        $("#story_quiz_disabled").click()
                      , 10
                  , 100
                else
                  setTimeout ->
                    $("#story_quiz_enabled").click()
                  , 10
              else
                unless $("#story_quiz_disabled").is(':checked')
                  setTimeout ->
                    $("#story_quiz_disabled").click()
                  , 10

        question_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].quiz.question', (newValue, oldValue) ->
          if scope.quizform? && newValue isnt oldValue
            # console.log $scope.quizform
            if scope.quizform.$valid
              scope.mark_quiz_validity(scope.quizform.$valid)
            else
              setTimeout ->
                $("#story_quiz_disabled").click()
                scope.mark_quiz_validity(scope.quizform.$valid)
              , 10

        name_watcher = scope.$watch 'active_exhibit.stories[current_museum.language].name', (newValue, oldValue) ->
          if newValue?
            form = $('#media form')
            if form.length > 0
              if scope.active_exhibit.stories[scope.current_museum.language].status is 'dummy'
                scope.active_exhibit.stories[scope.current_museum.language].status = 'passcode' if newValue
              else
                unless scope.new_item_creation
                  unless newValue 
                    scope.active_exhibit.stories[scope.current_museum.language].name = oldValue
                    scope.empty_name_error = true
                    setTimeout ->
                      scope.empty_name_error = false
                    , 1500
                # else
                #   if newValue and $scope.$parent.new_item_creation
                #     $rootScope.$broadcast 'save_new_exhibit'

        answers_watcher = scope.$watch ->
          if scope.active_exhibit.stories[scope.current_museum.language]?
            angular.toJson(scope.active_exhibit.stories[scope.current_museum.language].quiz.answers)
          else
            undefined
        , (newValue, oldValue) ->
          if newValue?
            if scope.quizform?
              if scope.quizform.$valid
                scope.mark_quiz_validity(scope.quizform.$valid)
              else
                setTimeout ->
                  $("#story_quiz_disabled").click()
                , 10

        # qr_code workaround
        qr_code_watcher =  scope.$watch 'active_exhibit.stories[current_museum.language]', (newValue, oldValue) ->
          if newValue
            unless scope.active_exhibit.stories[scope.current_museum.language].qr_code
              $http.get("#{scope.backend_url}/qr_code/#{scope.active_exhibit.stories[scope.current_museum.language]._id}").success (d) ->
                scope.active_exhibit.stories[scope.current_museum.language].qr_code = d
