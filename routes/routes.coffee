mongoose    = require 'mongoose'
models      = require '../models/db'
async       = require 'async'
QRCode      = require 'qrcode'
sys         = require 'util'
fs          = require 'fs'
http        = require 'http'
https       = require 'https'

exports.certan_provider = (req, res) ->
  cp_id = req.params.cp_id
  models.ContentProvider.findOne {'_id': cp_id}, (err, content_provider) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(content_provider)

exports.provider_list = (req, res) ->
  models.ContentProvider.find (err, content_providers) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(content_providers)

exports.museum_list = (req, res) ->
  cp_id = req.params.cp_id
  models.StorySet.find {'type': 'museum', 'content_provider': cp_id }, (err, museums) ->
    if err
      console.log err
    else
      async.map museums, fetch_stories, (err, result) ->
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(result)

exports.certan_museum = (req, res) ->
  m_id = req.params.m_id
  cp_id = req.params.cp_id
  models.StorySet.findOne {'_id': m_id, 'content_provider': cp_id}, (err, museum) ->
    if err
      console.log err
    else
      fetch_stories museum, (err, data)->
        if err
          console.log err
        else          
          res.header 'Content-Type', 'application/json'
          res.send JSON.stringify(data)

exports.create_museum = (req, res) ->
  cp_id = req.params.cp_id
  models.ContentProvider.findOne {'_id': cp_id}, (err, content_provider) ->
    if err
      console.log err
    else
      req.body.content_provider = content_provider._id
      museum = new models.Curier(req.body)
      museum.save()
      console.log "Saved museum " + museum._id
      res.send "OK"

fetch_stories = (exhibit, callback) ->
  # console.log exhibit.lng
  if exhibit._id?
    criteria = {}
    criteria.story_set =  exhibit._id
    models.Story.find criteria, (err, stories) ->
      if err
        callback err
      else
        ex_result = {}
        ex_result.exhibit = exhibit
        models.Media.find {'parent': exhibit._id, 'type': 'image'}, null, {sort: {order: 1}}, (err, media) ->
          if err
            callback err
          else
            ex_result.images  = media
            async.map media, fetch_mappings, (err, m_result) ->
              callback err if err
              # console.log 'fetched'
              ex_result.images = m_result

              async.map stories, fetch_quiz, (err, result) ->
                callback err if err
                ex_result.stories = result
                # callback null, ex_result
                async.map result, fetch_images, (err, img_result) ->
                  callback err if err
                  ex_result.stories = img_result
                  callback null, ex_result
  else
    callback 'error'

fetch_mappings = (image, callback) ->
  if image?
    models.MediaMapping.find {'media': image._id}, (err, media_mappings) ->
      if err
        callback err
      else
        result = {}
        result.mappings = {}
        result.image = image
        for mapping in media_mappings
          result.mappings[mapping.language] = mapping
        # result.mappings = media_mappings
        callback null, result
  else
    callback 'error'  

fetch_images = (story, callback) ->
  if story?
    models.Media.find {'parent': story.story._id}, (err, media) ->
      if err
        callback err
      else
        me_result = {}
        me_result.images = []
        me_result.story  = story.story
        me_result.quiz   = story.quiz
        for file in media
          if file.type is 'image'
            me_result.images.push file
          else if file.type is 'audio'
            console.log 'audio!!!'
            me_result.audio = file
          else if file.type is 'video'
            console.log 'video!!!'
            me_result.video = file
        callback null, me_result
  # else
  #   callback 'ololo'

fetch_quiz = (story, callback) ->
  if story?
    models.Quiz.findOne {'story': story._id}, (err, quiz) ->
      if err
        callback err
      else
        if quiz?
          st_result = {}
          st_result.story = story 
               
          models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
            if err
              callback err
            else
              qw_result = {}
              qw_result.answers = answers
              qw_result.quiz  = quiz
              st_result.quiz  = qw_result
              callback null, st_result
        else
          callback 'error'
  else
    callback 'error'

fetch_answers = (quiz, callback) ->
  if quiz?
    models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
      if err
        callback err
      else
        qw_result = {}
        qw_result.answers = answers
        qw_result.quiz  = quiz
      callback null, qw_result
  else
    callback 'err'

exports.exhibit_list = (req, res) ->
  cp_id     = req.params.cp_id
  m_id      = req.params.m_id
  lang      = req.params.lang
  field     = req.params.field || 'number'
  direction = req.params.direction || -1

  sort_obj = {}
  sort_obj[field] = parseInt direction, 10

  # console.log sort_obj

  # setTimeout ->
  models.StorySet.find {'type': 'exhibit', 'content_provider': cp_id, 'parent': m_id }, null, { sort: sort_obj }, (err, exhibits) ->
    if err
      console.log err
    else
      async.map exhibits, fetch_stories, (err, result) ->
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(result)
  # , 1000

exports.certan_exhibit = (req, res) ->
  cp_id = req.params.cp_id
  ex_id = req.params.ex_id
  m_id = req.params.m_id
  models.StorySet.findOne {'type': 'exhibit', 'content_provider': cp_id, 'parent': m_id, '_id': ex_id }, (err, exhibit) ->
    if err
      console.log err
    else
      models.Story.find {'story_set': ex_id}, (err, stories) ->
        if err
          console.log err
        else
          res.header 'Content-Type', 'application/json'
          response = {}
          response.exhibit = exhibit
          response.stories = stories
          res.send JSON.stringify(response)

# qr code

exports.qr_code = (req, res) ->
  QRCode.toDataURL req.params.data, (error, data)->
    res.header 'Content-Type', 'data:image/png'
    res.send data
