fs            = require 'fs'

exports.index = (req, res) ->
  res.render "index",
    title: "Test web page on node.js using Express and Mongoose"
    pagetitle: "Hello there"
    user: req.user

exports.partials = (req, res) ->
  console.log 'partials'
  name = req.params.name
  res.render 'partials/' + name

exports.templates = (req, res) ->
  console.log req.params
  name   = req.params.name
  console.log name
  folder = req.params.folder
  template = fs.readFileSync "#{__dirname}/../views/template/#{folder}/#{name}", "utf-8"
  res.send template