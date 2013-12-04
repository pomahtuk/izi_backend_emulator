angular.module("Museum.directives").directive 'exhibitsSortable', ($http, errorProcessing, backendWrapper, $i18next) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element  = $ element
    backend  = scope.backend_url
    element.disableSelection()
    index          = 0
    exhibit_name   = ""
    elements_space = 0
    element_width  = 0
    element_height = 0
    first_margin   = 0
    exhibit        = {}
    multiply_mode  = false
    new_number     = ''
    after_index    = 0
    start_index    = 0
    items          = []

    collection     = switch attrs['collection']
      when 'common'
        scope.exhibits
      when 'published'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.published
        else
          []
      when 'private'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.private
        else
          []
      when 'invisible'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.invisible
        else
          []
      when 'draft'
        if scope.grouped_exhibits?
          scope.grouped_exhibits.draft
        else
          []

    get_closest_element = (elements, x, y) ->
      for el, index in elements
        el  = $ el
        position = el.offset()
        compare_x_to = first_margin + element_width + position.left
        if x - compare_x_to < elements_space
          if y >= position.top and y <= position.top + element_height + 30 # may be i shoul get rid of this magic number?
            return el
            break
      return null

    find_by_id = (id) ->
      for item in collection
        if item._id is id
          return item
      return null

    element.sortable
      placeholder: "exhibits_placeholder"
      tolerance: 'intersect'
      helper: 'clone'
      appendTo: document.body
      cursor: "move"
      cursorAt: { left: -10, top: 0 }
      items: "> li.exhibit:not(.dummy)"
      scroll: false
      delay: 100
      start: (event, ui) ->
        index             = ui.item.data('exhibit-id')
        exhibit           = find_by_id index
        exhibit_name      = exhibit.stories[scope.current_museum.language].name
        exhibit.active    = true
        ui.item.show()
        ui.helper.html("<span class='info'>Move #{exhibit_name}</span>").addClass('exhibits_info')
        ui.helper.addClass 'dragged'
        elements_space = parseInt $(element.find('li.exhibit')[1]).css('margin-left').split('px')[0], 10
        element_width  = ui.item.width()
        element_height = ui.item.height()
        first_margin   = parseInt $(element.find('li.exhibit')[0]).css('margin-left').split('px')[0], 10
        margin         = elements_space / 2
        element.find('.exhibits_placeholder').html("<span class='helper'></span>").find('.helper').css {'margin-left': "#{margin}px"}
        scope.grid()

      sort: (event, ui) ->
        ##
        ## new number shoul be found other way in case if we are using grouping
        ##

        multiply_mode  = if scope.selected_count > 1
          true
        else
          false
        target         = $(event.toElement)
        target_element = target.parents('li.exhibit')
        if target_element.length is 0
          # new_number = ''
          move_text  = if multiply_mode
            "Move #{scope.selected_count} exhibits"
          else
            "Move #{exhibit_name}"
          inset_after = get_closest_element target.find('li.exhibit'), event.pageX, event.pageY
          if inset_after?
            after_index = inset_after.data('exhibit-id')
            inset_after_exhibit = find_by_id(after_index)
            new_number  = inset_after_exhibit.number.split('.')
            new_number[new_number.length - 1] = parseInt(new_number[new_number.length - 1], 10) + 1
            # console.log new_number
        else
          target_index      = target_element.data('exhibit-id')
          target_exhibit    = find_by_id(target_index)
          next_num = if target_index + 1 < collection.length
            find_by_id(target_index + 1).number.split('.')
          else
            [999999999]
          curr_num = target_exhibit.number.split('.')
          if curr_num.length <= next_num.length or next_num[0] > curr_num[0]
            new_number = curr_num
            new_number.push 1
          else
            for i in [target_index + 1..collection.length - 2]
              next_num = find_by_id(i + 1).number
              curr_num = find_by_id(i).number
              if next_num.length isnt curr_num.length
                res_number      = curr_num.split('.')
                res_last_number = res_number[res_number.length - 1]
                res_last_number = parseInt(res_last_number, 10) + 1
                res_number[res_number.length - 1] = res_last_number
                new_number = res_number
          move_text = if multiply_mode
            "Move #{scope.selected_count} exhibits"
          else
            "#{new_number.join('.')} #{exhibit_name}"

        element.find('.exhibits_placeholder').insertAfter inset_after
        ui.helper.find('.info').text move_text

      stop: ( event, ui ) ->
        # console.log new_number
        elements          = element.find('li')
        exhibit.active    = false
        ex_id             = ui.item.data('exhibit-id')
        find_by_id(ex_id).number = new_number.join('.')
        looking_for_id = find_by_id(ex_id)._id

        if multiply_mode
          items = element.find('li.exhibit.selected:not(.active)')
          items.insertAfter ui.item
          for item, index in items
            item = $ item
            exhibit = find_by_id(item.data('exhibit-id'))
            new_item_number[new_number.length - 1]  = parseInt(new_number[new_number.length - 1], 10) + 1 + index
            exhibit.number = new_item_number.join('.')

        collection = backendWrapper.sortArray collection

        prev_incremented = false
        for index in [0..collection.length - 2]
          current_item  = collection[index]
          next_item     = collection[index + 1]
          current_arr   = current_item.number.split('.')
          next_arr      = next_item.number.split('.')
          # console.log current_arr, next_arr
          if current_arr.length is next_arr.length
            # console.log 'array same'
            next_last_number    = parseInt next_arr[next_arr.length - 1], 10
            current_last_number = parseInt current_arr[current_arr.length - 1], 10
            prev_incremented    = false
            if next_last_number isnt current_last_number + 1
              prev_incremented = true
              next_arr[next_arr.length - 1] = current_last_number + 1
              next_item.number = next_arr.join('.')              
          else if next_arr.length > current_arr.length
            # console.log 'array is bigger'
            if prev_incremented is true 
              if next_arr[next_arr.length - 2] isnt current_arr[current_arr.length - 1]
                console.log 'item was incremented and next item is child of'
            next_arr[next_arr.length - 1] = 1 if next_arr[next_arr.length - 1] isnt 1
            next_item.number = next_arr.join('.')

          else if next_arr.length < current_arr.length
            # console.log 'array smaller'
            next_last_number    = parseInt next_arr[next_arr.length - 1], 10
            current_last_number = parseInt current_arr[current_arr.length - 2], 10
            prev_incremented    = false
            if next_arr[next_arr.length - 1] isnt current_last_number + 1
              prev_incremented = true
              next_arr[next_arr.length - 1] = current_last_number + 1
              next_item.number = next_arr.join('.')

        scope.$digest()
        scope.grid()
        setTimeout ->
          element.sortable().refresh()
        , 100

        # sort exhibits!
        sort_obj = {}
        for exhibit in collection
          sort_obj[exhibit._id] = exhibit.number
        # console.log sort_obj

        $http.post("#{scope.backend_url}/story_set/update_numbers/#{scope.current_museum._id}", sort_obj).success (data) ->
          console.log data
          setTimeout ->
            element.sortable "enable"
          , 100
          true
        .error ->
          errorProcessing.addError $i18next 'Failed to save sort status'
