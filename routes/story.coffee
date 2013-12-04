mongoose    = require 'mongoose'
models      = require '../models/db'

## story

exports.story_list = (req, res) ->
  models.Story.find (err, stories) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(stories)

exports.certan_story = (req, res) ->
  id = req.params.s_id
  models.Story.findOne {'_id': id}, (err, story) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(story)

exports.create_story = (req, res) ->
  story = new models.Story(req.body)
  console.log story
  story.save()
  # console.log "Saved story " + story._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(story)

exports.update_story = (req, res) ->
  id   = req.params.s_id
  data = req.body
  models.Story.findOne {'_id': id}, (err, story) ->
    if err
      console.log err
    else
      story.playback_algorithm = data.playback_algorithm
      story.content_provider   = data.content_provider
      story.story_type         = data.story_type
      story.status             = data.status
      story.language           = data.language
      story.name               = data.name
      story.short_description  = data.short_description
      story.long_description   = data.long_description
      story.story_set          = data.story_set

      story.save()
      res.send 'ok'

exports.delete_story = (req, res) ->
  models.Story.findById req.params.s_id, (err, story) ->
    story.remove story
    console.log "Deleted story " + story._id
    res.send "OK"