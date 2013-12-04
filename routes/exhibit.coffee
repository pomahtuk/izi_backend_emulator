mongoose    = require 'mongoose'
models      = require '../models/db'
async       = require 'async'

# exhibit

exports.certan_story_set = (req, res) ->
  id = req.params.e_id
  models.StorySet.findOne {'_id': id}, (err, exhibit) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(exhibit)

exports.create_story_set = (req, res) ->
  exhibit = new models.StorySet(req.body)
  exhibit.save()
  # console.log exhibit
  console.log "Saved exhibit " + exhibit._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(exhibit)

exports.update_story_set = (req, res) ->
  id   = req.params.e_id
  data = req.body
  console.log data.language
  models.StorySet.findOne {'_id': id}, (err, exhibit) ->
    if err
      console.log err
    else
      exhibit.content_provider = data.content_provider
      exhibit.type             = data.type
      exhibit.distance         = data.distance
      exhibit.duration         = data.duration
      exhibit.status           = data.status
      exhibit.route            = data.route
      exhibit.category         = data.category
      exhibit.parent           = data.parent
      exhibit.name             = data.name
      exhibit.language         = data.language
      exhibit.number           = data.number

      exhibit.save()
      res.send 'ok'

delete_stories = (story, callback) ->
  async.parallel [ 
    (callback) ->
      models.Story.findOne {'_id': story._id}, (err, story) ->
        if err
          callback err
        else
          if story?
            story.remove story
            console.log "Deleted story " + story._id
          callback null, 'deleted'
    (callback) ->
      models.Media.find {'parent': story._id}, (err, media) ->
        if err
          callback err
        else
          if media.length > 0
            async.map media, delete_media, (err, result) ->
              callback null, 'deleted'
          else
            callback null, 'deleted'
    (callback) ->
      models.Quiz.findOne {'story': story._id}, (err, quiz) ->
        if err
          callback err
        else
          if quiz?
            quiz.remove quiz
            console.log "Deleted quiz " + quiz._id
            models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
              if err
                callback err
              else
                if answers.length > 0          
                  async.map answers, delete_answers, (err, result) ->
                    callback null, 'deleted'
                else
                  callback null, 'deleted'
          else
            callback null, 'deleted'
  ], (err, result) ->
    if err
      callback err
    else
      callback null, 'deleted'

delete_answers = (answers, callback) ->
  models.QuizAnswer.findOne {'_id': answers._id}, (err, answer) ->
    if err
      callback err
    else
      if answer?
        answer.remove answer
        console.log "Deleted answer " + answer._id
        callback null, 'deleted'

delete_media = (media, callback) ->
  models.Media.findOne {'_id': media._id}, (err, media) ->
    if err
      callback err
    else
      if media?
        media.remove media
        console.log "Deleted media " + media._id
        callback null, 'deleted'

exports.delete_story_set = (req, res) ->
  models.StorySet.findById req.params.e_id, (err, exhibit) ->
    if err
      console.log err
    else
      if exhibit
        exhibit.remove exhibit
        console.log "Deleted exhibit " + exhibit._id
        models.Media.find {'parent': exhibit._id}, (err, media) ->
          if err
            console.log err
          else
            if media.length > 0
              for media_item in media
                media_item.remove media_item
                console.log "Deleted media_item " + media_item._id
        models.Story.find {'story_set': exhibit._id} , (err, stories) ->
          if err
            console.log err
          else
            async.map stories, delete_stories, (err, result) ->
              res.send 'deleted'
      else
        console.log 'all'
        res.send 'nope'


    # res.send "OK"

exports.update_story_set_numbers = (req, res) ->
  new_indexes = req.body
  models.StorySet.find { 'parent': req.params.parent_id }, (err, story_set_arr) ->
    if err
      console.log err
    else
      for story_set, index in story_set_arr
        story_set.number = new_indexes[story_set._id]
        story_set.save()
      res.send 'ok'
