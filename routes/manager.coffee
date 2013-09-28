models = require('../models/db')

exports.login = (req, res) ->
  res.render "login",
    title: "Курьерская служба доставки"
    pagetitle: "Hello there"

exports.logout = (req, res) ->
  req.logout()
  res.redirect('/login')