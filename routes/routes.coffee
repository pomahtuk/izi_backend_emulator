mongoose = require 'mongoose'
models   = require '../models/db'
require 'date-utils'
async    = require 'async'
QRCode   = require 'qrcode'

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
  console.log cp_id
  models.StorySet.find {'type': 'museum', 'content_provider': cp_id }, (err, museums) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(museums)

exports.certan_museum = (req, res) ->
  m_id = req.params.m_id
  cp_id = req.params.cp_id
  models.StorySet.findOne {'_id': m_id, 'content_provider': cp_id}, (err, museum) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(museum)

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

exports.update_museum = (req, res) ->
  true

exports.delete_museum = (req, res) ->
  true

fetch_stories = (exhibit, callback) ->
  models.Story.find {'story_set': exhibit._id}, (err, stories) ->
    if err
      callback err
    else
      ex_result = {}
      ex_result.exhibit = exhibit
      models.Media.find {'parent': exhibit._id}, (err, media) ->
        if err
          callback err
        else
          ex_result.images  = media
      async.concat stories, fetch_quiz, (err, result) ->
        ex_result.stories = result
        callback null, ex_result

fetch_quiz = (story, callback) ->
  models.Quiz.findOne {'story': story._id}, (err, quiz) ->
    if err
      callback err
    else
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

fetch_answers = (quiz, callback) ->
  models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
    if err
      callback err
    else
      qw_result = {}
      qw_result.answers = answers
      qw_result.quiz  = quiz
    callback null, qw_result

exports.exhibit_list = (req, res) ->
  cp_id = req.params.cp_id
  m_id  = req.params.m_id
  calls = []
  models.StorySet.find {'type': 'exhibit', 'content_provider': cp_id, 'parent': m_id }, (err, exhibits) ->
    if err
      console.log err
    else
      async.concat exhibits, fetch_stories, (err, result) ->
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(result)

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

exports.create_exhibit = (req, res) ->
  true

exports.update_exhibit = (req, res) ->
  true

exports.delete_exhibit = (req, res) ->
  true

## quiz

exports.certan_quiz = (req, res) ->
  id = req.params.q_id
  models.Quiz.findOne {'_id': id}, (err, quiz) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(quiz)

exports.create_quiz = (req, res) ->
  quiz = new models.Quiz(req.body)
  quiz.save()
  console.log "Saved quiz " + quiz._id
  res.send "OK"

exports.update_quiz = (req, res) ->
  id   = req.params.q_id
  data = req.body
  models.Quiz.findOne {'_id': id}, (err, quiz) ->
    if err
      console.log err
    else
      quiz.story     = data.story
      quiz.question  = data.question
      quiz.comment   = data.comment
      quiz.status    = data.status

      quiz.save()
      res.send 'ok'

exports.delete_quiz = (req, res) ->
  models.Quiz.findById req.params.q_id, (err, quiz) ->
    quiz.remove quiz
    console.log "Deleted quiz " + quiz._id
    res.send "OK"

## quiz_answer

exports.certan_quiz_answer = (req, res) ->
  id = req.params.qa_id
  models.QuizAnswer.findOne {'_id': id}, (err, quiz_answer) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(quiz_answer)

exports.create_quiz_answer = (req, res) ->
  quiz_answer = new models.QuizAnswer(req.body)
  quiz_answer.save()
  console.log "Saved quiz_answer " + quiz_answer._id
  res.send "OK"

exports.update_quiz_answer = (req, res) ->
  id   = req.params.qa_id
  data = req.body
  models.QuizAnswer.findOne {'_id': id}, (err, quiz_answer) ->
    if err
      console.log err
    else
      quiz_answer.quiz    = data.quiz
      quiz_answer.content = data.content
      quiz_answer.correct = data.correct

      quiz_answer.save()
      res.send 'ok'

exports.delete_quiz_answer = (req, res) ->
  models.QuizAnswer.findById req.params.qa_id, (err, quiz_answer) ->
    quiz_answer.remove quiz_answer
    console.log "Deleted quiz_answer " + quiz_answer._id
    res.send "OK"

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
  story.save()
  console.log "Saved story " + story._id
  res.send "OK"

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
  models.Story.findById req.params.qa_id, (err, story) ->
    story.remove story
    console.log "Deleted quiz_answer " + story._id
    res.send "OK"

# exhibit
exports.certan_story_set = (req, res) ->
  id = req.params.s_id
  models.StorySet.findOne {'_id': id}, (err, exhibit) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(exhibit)

exports.create_story_set = (req, res) ->
  exhibit = new models.StorySet(req.body)
  exhibit.save()
  console.log "Saved exhibit " + exhibit._id
  res.send "OK"

exports.update_story_set = (req, res) ->
  id   = req.params.e_id
  data = req.body
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
      exhibit.number           = data.number

      exhibit.save()
      res.send 'ok'

exports.delete_story_set = (req, res) ->
  models.StorySet.findById req.params.qa_id, (err, exhibit) ->
    exhibit.remove exhibit
    console.log "Deleted exhibit " + exhibit._id
    res.send "OK"

exports.qr_code = (req, res) ->
  # QRCode.save __dirname + './qr_codes/', req.params.data, (error, data) ->
  #   console.log error, data
  QRCode.toDataURL req.params.data, (error, data)->
    # res.header 'Content-Type', 'data:image/png'
    res.send data