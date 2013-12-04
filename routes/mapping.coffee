mongoose    = require 'mongoose'
models      = require '../models/db'

# media mapping

exports.update_mapping = (req, res) ->
  id   = req.params.map_id
  data = req.body
  models.MediaMapping.findOne {'_id': id}, (err, media_mapping) ->
    if err
      console.log err
    else
      media_mapping.timestamp = data.timestamp
      media_mapping.language  = data.language
      media_mapping.media     = data.media
      media_mapping.save()
      res.send 'ok'

exports.create_mapping = (req, res) ->
  console.log req.body
  media_mapping = new models.MediaMapping(req.body)
  media_mapping.save()
  console.log "Saved media_mapping " + media_mapping._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(media_mapping)

exports.delete_mapping = (req, res) ->
  models.MediaMapping.findById req.params.map_id, (err, media_mapping) ->
    if media_mapping?
      media_mapping.remove media_mapping
      console.log "Deleted media_mapping " + media_mapping._id
      res.send media_mapping._id
    else
      res.send 'nope'