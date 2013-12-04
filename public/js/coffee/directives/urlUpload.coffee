angular.module("Museum.directives").directive 'urlUpload', ($http, uploadHelpers) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element = $ element

    testRegex = /^(http(s?):)|([/|.|\w|\s])*\.(?:jpg|jpeg|gif|png)?/

    element.bind 'paste', ->
      setTimeout ->
        url = element.val()
        if testRegex.test(url)
          type = "image/#{url.split('.').reverse()[0]}" 
          console.log 'ok'
          ## probably, should show some preloader or load indicator
          ## the only question is - when should i hide this?
          element.parents('ul.images').find('.museum_image_placeholder').css({'display':'inline-block'})
          $.getImageData
            url: url
            server: "#{scope.$parent.backend_url}/imagedata"
            success: (img) ->
              element.val ''
              uploadHelpers.cavas_processor img, type 
        else
          if url isnt ''
            console.log 'some error should be shown'
            element.addClass 'error'
            setTimeout ->
              element.removeClass 'error'
            , 1500
      , 10
