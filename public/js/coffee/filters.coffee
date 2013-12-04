"use strict"

# Filters 
angular.module("Museum.filters", [])

.filter "numstring", ->
  (input) ->
    String.fromCharCode(input + 97).toUpperCase()

.filter "truncate", ->
  (text, length, end) ->
    length = 10  if isNaN(length)
    end = "..."  unless end
    if text.length <= length or text.length - end.length <= length
      text
    else
      String(text).substring(0, length - end.length) + end

.filter "timerepr", ->
  (input) ->
    source_seconds = parseInt(input, 10)
    unless isNaN source_seconds
      minutes = Math.floor(source_seconds/60)
      if minutes.toString().length is 1
        minutes = "0#{minutes}"
      seconds = source_seconds - minutes * 60
      if seconds.toString().length is 1
        seconds = "0#{seconds}"
      "#{minutes}:#{seconds}"