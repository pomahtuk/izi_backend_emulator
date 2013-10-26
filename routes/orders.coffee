models = require('../models/db')
url    = require('url')
require 'date-utils'

dec = (a) -> parseInt a, 10

exports.index = (req, res) ->
  url_parts = url.parse req.url, true

  response = {}
  from   = 0
  limit  = 99999
  search = ''
  field  = 'date'
  order  = -1

  query = url_parts.query

  from   = dec query.from if query.from 
  limit  = dec query.limit if query.limit
  search = query.search if query.search
  field  = query.field if query.field
  order  = dec query.order if query.order

  models.Order.count {}, (err, count) ->
    response.total = count
    response.next = "/data/order/?from=#{from + limit}&limit=#{limit}"
    if from - limit > 0
      response.prev = "/data/order/?from=#{from - limit}&limit=#{limit}"
    sort        = {}
    sort[field] = order
    query_string = {}
    if search.length > 0
      query_string.$or = [ { 'date' : new RegExp(search) } , { 'order_summ' : new RegExp(search) }, { 'delivery_cost' : new RegExp(search) }] #, { 'firm.title' : new RegExp(search) }, { 'curier.name' : new RegExp(search) } 
    models.Order.find(query_string).skip(from).limit(limit).sort(sort).populate('firm curier').exec (err, orders) ->
      if err
        console.log err
      else
        response.orders = orders
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(response)

exports.orders_for_firm = (req, res) ->
  code = req.params.id
  if code?
    models.Order.find({ 'firm': code }).populate('firm curier').exec (err, order) ->
      if err
        console.log err
      else
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(order)
  else
    res.header 'Content-Type', 'application/json'
    res.send 'no querry found'

exports.orders_for_curier = (req, res) ->
  code = req.params.id
  if code?
    models.Order.find({ 'curier': code }).populate('firm').exec (err, order) ->
      if err
        console.log err
      else
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(order)
  else
    res.header 'Content-Type', 'application/json'
    res.send 'no querry found'

exports.certain_order = (req, res) ->
  code = req.params.id
  if code?
    models.Order.find({ '_id': code }).populate('firm curier').exec  (err, order) ->
      if err
        console.log err
      else
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(order)
  else
    res.header 'Content-Type', 'application/json'
    res.send 'no querry found'

exports.delete_order = (req, res) ->
  models.Order.findById req.params.id, (err, order) ->
    order.remove order
    console.log "Deleted order " + order._id
    res.send "OK"

exports.update_order = (req, res) ->
  data = req.body
  models.Order.findOne
    _id: req.params.id
  , (err, order) ->
    order.date            = new Date data.date
    order.day_of_week     = data.day_of_week
    order.firm            = data.firm
    order.order_summ      = data.order_summ
    order.delivery_cost   = data.delivery_cost
    order.curier          = data.curier
    order.delivery_adress = data.delivery_adress
    order.comment         = data.comment
    order.outside         = data.outside
    order.curier_income   = data.curier_income
    order.save((error) ->
      console.log "Updated order " + order._id
      unless error
        res.send "OK"
    )

exports.create_order = (req, res) ->
  order = new models.Order(req.body)
  order.save()
  console.log "Saved order " + order._id
  res.send "OK"

exports.orders_chart = (req, res) ->
  day_corr = [7, 1, 2, 3, 4, 5, 6]
  today = new Date.today()
  range = 'week'
  range = req.params.range if req.params.range
  if range is 'week'
    weekday  = day_corr[today.getDay()]
    start    = new Date.today()
    end      = new Date.today()
    offset   = 1 - weekday
    start.addDays(offset)
    end.addDays(8 - weekday)

  else if range is 'month'
    year  = today.getFullYear()
    month = today.getMonth()
    start = new Date ("#{month+1}.01.#{year}")
    year += 1 if month + 2 > 12
    end   = new Date ("#{month+2}.01.#{year}")
    end.setTime(end.getTime() + 86400000)

  else
    year  = today.getFullYear()
    month = today.getMonth()
    start = new Date ("01.01.#{year}")
    start.setTime(start.getTime())
    end   = new Date ("12.31.#{year}")
    end.setTime(end.getTime() + 86400000*2) 

  match = {
    $match:
      date: { $gt : start, $lt : end }
  }

  project = {
    $project: 
      day_of_week: { $dayOfWeek : "$date" }
      date: 1
      delivery_cost: 1
      #count: { $add : 1 }
      #total: { $add : "$delivery_cost" }
  }

  group = {
    $group:
      _id:   "$day_of_week"
      date:  { $first : "$date" }
      count: { $sum : 1 }
      total: { $sum : "$delivery_cost" }
  }

  sort = {
    $sort:
      _id: 1
  }

  models.Order.aggregate match, project, group, sort, (err, orders) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(orders)

exports.orders_total_day_all = (req, res) ->
  date     = req.params.date
  if date
    start = new Date(date).clearTime()
    end   = new Date(date).clearTime().addDays(1)   
  else
    start    = new Date.today()
    end      = new Date.today()    
    start.clearTime()
    end.clearTime().addDays(1)

  query_string = {
    date: { $gt : start, $lt : end }
  }
  models.Order.find(query_string).sort({'date': 1}).populate('firm curier').exec (err, orders) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(orders)

exports.orders_total_day_firm = (req, res) ->
  start    = new Date.today()
  end      = new Date.today().addDays(1)
  query_string = {
    date: { $gt : start, $lt : end }
    firm: req.params.id
  }
  models.Order.find(query_string).sort({'date': 1}).populate('firm curier').exec (err, orders) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(orders)

exports.orders_total_day = (req, res) ->
  date     = req.params.date
  if date
    start = new Date(date).clearTime()
    end   = new Date(date).clearTime().addDays(1)   
  else
    start    = new Date.today()
    end      = new Date.today()    
    start.clearTime()
    end.clearTime().addDays(1)
  # start    = new Date.today()
  # end      = new Date.today().addDays(1)

  match = {
    $match:
      date: { $gt : start, $lt : end }
  }
  project = {
    $project: 
      date: 1
      delivery_cost: 1
      firm: 1
  }
  group = {
    $group:
      _id:   "$firm"
      count: { $sum : 1 }
      total: { $sum : "$delivery_cost" }
  }
  sort = {
    $sort:
      _id: 1
  }
  models.Order.aggregate match, project, group, sort, (err, orders) ->
    if err
      console.log err
    else
      ids = []
      for order, index in orders
        ids.push order._id

      models.Firm.find({ _id: { '$in': ids} }).exec (err, firms) ->
        for order in orders
          for firm in firms
            if firm._id.toString() is order._id.toString()
              order.firm = firm

        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(orders)

exports.orders_total_month = (req, res) ->
  date  = req.params.date
  if date
    today = new Date date
  else
    today = new Date.today()
  year  = today.getFullYear()
  month = today.getMonth()
  start = new Date ("#{month+1}.01.#{year}")
  year += 1 if month + 2 > 12
  end   = new Date ("#{month+2}.01.#{year}")
  end.setTime(end.getTime() + 86400000)

  match = {
    $match:
      date: { $gt : start, $lt : end }
  }
  project = {
    $project: 
      date: 1
      delivery_cost: 1
      firm: 1
  }
  group = {
    $group:
      _id:   "$firm"
      count: { $sum : 1 }
      total: { $sum : "$delivery_cost" }
  }
  sort = {
    $sort:
      _id: 1
  }
  models.Order.aggregate match, project, group, sort, (err, orders) ->
    if err
      console.log err
    else
      ids = []
      for order, index in orders
        ids.push order._id

      models.Firm.find({ _id: { '$in': ids} }).exec (err, firms) ->
        for order in orders
          for firm in firms
            if firm._id.toString() is order._id.toString()
              order.firm = firm
              if firm.fixed_pay
                order.total += firm.pay_amount

        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(orders)