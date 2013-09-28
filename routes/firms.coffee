models = require('../models/db')

exports.index = (req, res) ->
  models.Firm.find (err, firms) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(firms)

exports.certain_firm = (req, res) ->
  code = req.params.id
  console.log code
  if code?
    models.Firm.find { '_id': code }, (err, firm) ->
      if err
        console.log err
      else
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(firm)
  else
    res.header 'Content-Type', 'application/json'
    res.send 'no querry found'

exports.delete_firm = (req, res) ->
  models.Firm.findById req.params.id, (err, firm) ->
    models.Order.find { 'firm': req.params.id }, (err, orders) ->
      for order in orders
        order.remove order
      firm.remove firm
      console.log "Deleted firm " + firm._id
      res.send "OK"

exports.update_firm = (req, res) ->
  data = req.body
  models.Firm.findOne
    _id: req.params.id
  , (err, firm) ->
    firm.title      = data.title
    firm.info       = data.info
    firm.adress     = data.adress
    firm.phone      = data.phone
    firm.fixed_pay  = data.fixed_pay
    firm.pay_amount = data.pay_amount
    firm.save((error) ->
      console.log "Updated firm " + firm._id
      unless error
        res.send "OK"
    )

exports.create_firm = (req, res) ->
  firm = new models.Firm(req.body)
  firm.save()
  console.log "Saved firm " + firm._id
  res.send "OK"