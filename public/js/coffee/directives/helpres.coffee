# Helper directives
angular.module("Museum.directives").directive "stopEvent", ->
  link: (scope, element, attr) ->
    element.bind attr.stopEvent, (e) ->
      e.stopPropagation()

angular.module("Museum.directives").directive "resizer", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.focus ->
      elem.animate {'width': '+=150'}, 200
    elem.blur ->
      elem.animate {'width': '-=150'}, 200

angular.module("Museum.directives").directive "toggleMenu", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      $('.museum_navigation_menu').slideToggle(300)
      setTimeout ->
        $.scrollTo(0,0)
      , 0

angular.module("Museum.directives").directive "toggleFilters", ->
  restrict: "A"
  link: (scope, element, attr) ->
    elem = $ element
    elem.click ->
      filters = $('.filters_bar')
      placeholder = $('.filters_placeholder')
      # actions = $('.actions_bar')
      margin = filters.css('top')
      if margin is '0px'
        filters.animate {'top': '-44px'}, 300
        placeholder.animate {'height': '0px'}, 300
      else
        filters.animate {'top': '0px'}, 300
        placeholder.animate {'height': '44px'}, 300
      scope.filters_opened = !scope.filters_opened

angular.module("Museum.directives").directive 'postRender', ($timeout) ->
  restrict : 'A',
  # terminal : true
  # transclude : true
  link : (scope, element, attrs) ->
    if scope.$last
      $timeout scope.grid, 200
      opener = {
        target: $('.museum_edit_opener')
      }
      $("ul.exhibits.common").scrollspy
        min: 50
        max: 99999
        onEnter: (element, position) ->
          $(".float_menu").addClass "navbar-fixed-top"
          $(".navigation").addClass "bottom-padding"
          $(".to_top").show()

        onLeave: (element, position) ->
          $(".float_menu").removeClass "navbar-fixed-top"
          $(".navigation").removeClass "bottom-padding"
          $(".to_top").hide() unless $(".to_top").hasClass 'has_position'

        onTick: (position,state,enters,leaves) ->
          scope.show_museum_edit(opener) if scope.museum_edit_dropdown_opened
    true
