mongoose    = require 'mongoose'
models      = require '../models/db'

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
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(quiz)

exports.update_quiz = (req, res) ->
  id   = req.params.q_id
  data = req.body
  models.Quiz.findOne {'_id': id}, (err, quiz) ->
    if err
      console.log err
    else
      # console.log data
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
