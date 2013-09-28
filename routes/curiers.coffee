models = require('../models/db')

exports.index = (req, res) ->
  models.Curier.find (err, curiers) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(curiers)

exports.certain_curier = (req, res) ->
  code = req.params.id
  if code?
    models.Curier.find { '_id': code }, (err, curier) ->
      if err
        console.log err
      else
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(curier)
  else
    res.header 'Content-Type', 'application/json'
    res.send 'no querry found'

exports.delete_curier = (req, res) ->
  models.Curier.findById req.params.id, (err, curier) ->
    models.Order.find { 'curier': req.params.id }, (err, orders) ->
      for order in orders
        order.remove order
      curier.remove curier
      console.log "Deleted curier " + curier._id
      res.send "OK"

exports.update_curier = (req, res) ->
  data = req.body
  models.Curier.findOne
    _id: req.params.id
  , (err, curier) ->
    curier.name  = data.name
    curier.phone = data.phone
    curier.save((error) ->
      console.log "Updated curier " + curier._id
      unless error
        res.send "OK"
    )

exports.create_curier = (req, res) ->
  curier = new models.Curier(req.body)
  curier.save()
  console.log "Saved curier " + curier._id
  res.send "OK"