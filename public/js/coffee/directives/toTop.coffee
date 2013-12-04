angular.module("Museum.directives").directive 'toTop', (errorProcessing) ->
  restrict: "E"
  replace: true
  transclude: true
  template: """
    <div class="to_top">
      <div class="to_top_panel">
        <div class="to_top_button" title="Наверх">
          <span class="arrow"><i class="icon-long-arrow-up"></i></span>
        </div>
      </div>
    </div>
  """
  link: (scope, element, attrs) ->
    element = $ element

    element.click ->
      if element.hasClass 'has_position'
        element.removeClass 'has_position'
        pos = element.data('scrollPosition')
        element.find('.arrow i').removeClass("icon-long-arrow-down").addClass("icon-long-arrow-up")
        $.scrollTo pos, 0
      else
        element.addClass 'has_position'
        pos = $(document).scrollTop()
        element.data('scrollPosition', pos)
        element.find('.arrow i').addClass("icon-long-arrow-down").removeClass("icon-long-arrow-up")
        $.scrollTo 0, 0
