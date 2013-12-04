mongoose    = require 'mongoose'
models      = require '../models/db'

# media

exports.media_list = (req, res) ->
  models.Media.find (err, media) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(media)

exports.certan_media = (req, res) ->
  id = req.params.m_id
  models.Media.findOne {'_id': id}, (err, media) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(media)

exports.create_media = (req, res) ->
  media = new models.Media(req.body)
  media.fullUrl = media.url
  media.save()
  console.log "Saved media " + media._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(media)

exports.update_media = (req, res) ->
  id   = req.params.m_id
  data = req.body
  # console.log req
  models.Media.findOne {'_id': id}, (err, media) ->
    if err
      console.log err
    else
      media.parent      = data.parent
      media.image       = data.image
      media.thumb       = data.thumb
      media.cover       = data.cover
      media.order       = data.order
      media.save()
      res.send 'ok'

exports.delete_media = (req, res) ->
  models.Media.findById req.params.m_id, (err, media) ->
    if media?
      media.remove media
      console.log "Deleted media " + media._id
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(media)
    else
      res.send 'nope'

exports.media_reorder = (req, res) ->
  new_indexes = req.body
  models.Media.find { 'parent': req.params.parent_id }, (err, media_arr) ->
    if err
      console.log err
    else
      for media, index in media_arr
        media.order = new_indexes[media._id]
        media.save()
      res.send 'ok'