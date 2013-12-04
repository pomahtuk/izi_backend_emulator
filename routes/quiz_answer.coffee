mongoose    = require 'mongoose'
models      = require '../models/db'

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
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(quiz_answer)

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
