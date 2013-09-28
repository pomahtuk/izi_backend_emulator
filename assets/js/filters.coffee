'use strict'

angular.module('myApp.filters', []).filter "startFrom", ->
  (input, start) ->
    if input
      start = +start #parse to int
      return input.slice(start)
    []

angular.module('myApp.filters', []).filter "add_space_in_price", ->
  (input, start) ->
    if input
      input = input.toString()
      if input.split('.').length <= 1
        if input.length > 3
          price_arr = input.split('').reverse()
          price_arr.splice(3,0,' ')
          price_arr.reverse()
          return price_arr.join('')
        else
          return input
      else
        price_parts = input.split('.')
        if price_parts[0].length > 3
          price_arr = price_parts[0].split('').reverse()
          price_arr.splice(3,0,' ')
          price_arr.reverse()
          first_part = price_arr.join('')
          input = first_part + '.' + price_parts[1]
          return input
        else
          return price_parts.join('.')
    []