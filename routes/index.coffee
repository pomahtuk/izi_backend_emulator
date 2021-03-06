fs = require 'fs'

exports.index = (req, res) ->
  index = fs.readFileSync "#{__dirname}/../views/index.html", "utf-8"
  res.send index

exports.partials = (req, res) ->
  console.log 'partials'
  name    = req.params.name
  partial = fs.readFileSync "#{__dirname}/../partials/#{name}", "utf-8"
  res.send partial

exports.templates = (req, res) ->
  console.log req.params
  name   = req.params.name
  console.log name
  folder = req.params.folder
  template = fs.readFileSync "#{__dirname}/../views/template/#{folder}/#{name}", "utf-8"
  res.send template

exports.locales = (req, res) ->
  console.log req.params
  locale  = req.params.locale
  file    = req.params.file
  # folder = req.params.folder
  translation = fs.readFileSync "#{__dirname}/../locales/#{locale}/#{file}", "utf-8"
  res.send translation