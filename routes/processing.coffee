gm          = require 'gm'
imageMagick = gm.subClass({ imageMagick: true })
mmm         = require 'mmmagic'
Magic       = mmm.Magic
magic       = new Magic(mmm.MAGIC_MIME_TYPE)
ffmpeg      = require 'fluent-ffmpeg'
mongoose    = require 'mongoose'
models      = require '../models/db'
fs          = require 'fs'
http        = require 'http'
https       = require 'https'
async       = require 'async'


# backend_url  = "http://192.168.158.128:3000"
backend_url  = "http://prototype.izi.travel"
# backend_path = "./"
backend_path = "/home/ubuntu/izi_backend_emulator/"

# images manipulation

extract_file_name = (path) ->
  path   = path.split('/')
  path   = path[path.length - 1]
  path

cleanup_media = (media, mode) ->
  if mode is 'full'
    if media.fullUrl?
      if media.fullUrl isnt media.url
        fs.unlink "#{backend_path}public/uploads/#{extract_file_name(media.fullUrl)}", (err) ->
          console.log err if err
          console.log 'deleted full'
  else
    if media.thumbnailUrl?
      if media.thumbnailUrl isnt media.url
        fs.unlink "#{backend_path}public/uploads/#{extract_file_name(media.thumbnailUrl)}", (err) ->
          console.log err if err
          console.log 'deleted thumb'

makeid = ->
  text = ""
  possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  i = 0

  while i < 5
    text += possible.charAt(Math.floor(Math.random() * possible.length))
    i++
  text

recreate_thumb = (media, callback) ->
  name         = extract_file_name media.thumbnailUrl
  path         = "#{backend_path}public/uploads/#{name}"
  ext          = name.split('.')
  ext          = '.'+ext[ext.length - 1]
  resized_name = name.split(ext)[0] + makeid() + ext
  imageMagick(path).size (err, size) ->
    if err
      callback err
    else
      width = 0
      height = 0
      if size.width >= size.height and size.width*0.75 >= size.height
        width  = size.height / 0.75
        height = size.height
      else
        width  = size.width
        height = size.width * 0.75

      params = 
        x: 0
        y: 0
        x2: width
        y2: height
        width: width
        height: height

      imageMagick(path).crop(width, height, 0, 0).write "#{backend_path}public/uploads/#{resized_name}", (err) ->
        if err
          console.log err, 'recreate thumb'
        else
          callback() if callback?

file_callback = (file, callback) ->

  magic.detectFile file.path, (err, result) ->
    throw err  if err

    # console.log result, file

    if result.indexOf('image') isnt -1

      if file.originalFilename is 'blob'
        ext  = '.' + result.split('/')[1]
        name = makeid() + ext
        fs.readFile file.path, ( err, data ) ->
          console.log err
          fs.writeFile "#{backend_path}public/uploads/#{name}", data, (err) ->
            console.log err
      else
        ext  = file.originalFilename.split('.')
        ext  = '.' + ext[ext.length - 1]
        name = file.path.split('/')
        name = name[name.length - 1]

      resized_name = name.split(ext)[0] + '_480x360' + ext

      imageMagick(file.path).size (err, size) ->
        if err
          callback err
        else
          width = 0
          height = 0
          if size.width >= size.height and size.width*0.75 >= size.height
            width  = size.height / 0.75
            height = size.height
          else
            width  = size.width
            height = size.width * 0.75

          params = 
            x: 0
            y: 0
            x2: width
            y2: height
            width: width
            height: height

          imageMagick(file.path).crop(width, height, 0, 0).write "#{backend_path}public/uploads/#{resized_name}", (err) ->
            if err
              console.log err
              callback err
            else
              models.Media.find {'parent':file.parent}, null, {sort: {order: 1}} , (err, images) ->
                order = 0
                if images.length > 0
                  last_img = images[images.length-1]
                  order = last_img.order + 1 if last_img.order?
                media              = new models.Media
                media.name         = resized_name
                media.size         = 100
                media.order        = order
                media.cover        = if order is 0
                  true
                else
                  false                
                media.url             = "#{backend_url}/uploads/#{name}"
                media.thumbnailUrl    = "#{backend_url}/uploads/#{resized_name}"
                media.thumbnailUrl    = "#{backend_url}/uploads/#{name}"
                media.deleteUrl       = "#{backend_url}/media/#{media._id}"
                media.deleteType      = "DELETE"
                media.selection       = JSON.stringify(params)
                media.full_selection  = JSON.stringify(params)
                media.parent          = file.parent
                media.type            = 'image'
                media.updated         =  new Date
                console.log "resized #{name} to #{resized_name}, updated media #{media._id}"
                media.save()
                callback null, media

    else if result.indexOf('audio') isnt -1

      models.Media.findOne {parent: file.parent, type: 'audio'}, (err, media) ->
        console.log media
        unless media?
          media = new models.Media

        name         = file.path.split('/')
        name         = name[name.length - 1]
        ext          = file.originalFilename.split('.')
        ext          = '.'+ext[ext.length - 1]
        converted    = name.split(ext)[0] + '.ogg'

        client_name = if file.originalFilename.length > 52
          file.originalFilename.substr(0, 50) + '...'
        else
          file.originalFilename

        proc = new ffmpeg({source:file.path}).withAudioCodec('libvorbis').toFormat('ogg').saveToFile "#{backend_path}public/uploads/#{converted}", (retcode, error) ->
          if error
            console.log error
          media.name         = client_name
          media.size         = 100
          media.url          = "#{backend_url}/uploads/#{name}"
          media.thumbnailUrl = "#{backend_url}/uploads/#{converted}"
          media.deleteUrl    = "#{backend_url}/media/#{media._id}"
          media.deleteType   = "DELETE"
          media.parent       = file.parent
          media.type         = 'audio'
          console.log "converted #{name} to #{converted}, updated media #{media._id}"
          media.save()
          callback null, media

    else if result.indexOf('video') isnt -1 || file.type is 'video'

      console.log 'video'
      
      models.Media.findOne {parent: file.parent, type: 'video'}, (err, media) ->
        console.log media
        unless media?
          media = new models.Media

        name         = file.path.split('/')
        name         = name[name.length - 1]
        ext          = file.originalFilename.split('.')
        ext          = '.'+ext[ext.length - 1]
        converted    = name.split(ext)[0] + '.m4v'
        thumb        = ""

        proc = new ffmpeg({source:file.path})
        proc.withSize('150x100')
        proc.takeScreenshots(1, "./public/video_thumbs/#{name}/", (err, filenames) ->
          console.log err
          thumb = filenames[0]
        )
        proc.toFormat('m4v')
        proc.withAspect('4:3')
        proc.withSize('640x360')
        proc.saveToFile "./public/uploads/#{converted}", (retcode, error) ->
          console.log retcode
          if error
            console.log error
          media.name         = file.originalFilename.substr(0, 20) + '...'
          media.size         = 100
          media.url          = "#{backend_url}/uploads/#{converted}"
          media.thumbnailUrl = "#{backend_url}/video_thumbs/#{name}/#{thumb}"
          media.deleteUrl    = "#{backend_url}/media/#{media._id}"
          media.deleteType   = "DELETE"
          media.parent       = file.parent
          media.type         = 'video'
          console.log "converted #{name} to #{converted}, updated media #{media._id}"
          media.save()
          callback null, media

    else
      callback 'unsupported type'

exports.upload_handler = (req, res) ->

  parent   = req.params.parent_id
  image    = req.files.files[0]

  for file in req.files.files
    file.parent = req.body.parent
    file.type   = req.body.type

  async.map req.files.files, file_callback, (err, result) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(result)

exports.resize_handler = (req, res) ->

  parent   = req.params.image_id

  params = req.body

  models.Media.findOne { _id: parent }, (err, media) ->
    if err
      console.log err
    else
      if params.mode? and params.x?
        media_name   = if params.mode is 'full'
          media.url
        else
          media.fullUrl || media.url
        # media_name   = extract_file_name media_name
        media_name   = media_name.split('/')
        media_name   = media_name[media_name.length - 1]
        ext          = media_name.split('.')
        ext          = '.'+ext[ext.length - 1]
        resized_name = if params.mode is 'thumb'
          media_name.split(ext)[0] + '_thumb' + makeid() + ext
        else
          media_name.split(ext)[0] + makeid() + ext

        cleanup_media(media, params.mode)

        media_resized_callback = (media) ->
          ->
            media.type         = 'image'
            media.updated      = new Date
            media.save()

            console.log "resized #{media_name} to #{resized_name}, updated media #{media._id}"

            res.header 'Content-Type', 'application/json'
            res.send JSON.stringify(media)

        imageMagick("#{backend_path}public/uploads/#{media_name}").crop(params.w, params.h, params.x, params.y).write "#{backend_path}public/uploads/#{resized_name}", (err) ->
          if err
            console.log err
          else
            if params.mode is 'full'
              media.fullUrl        = "#{backend_url}/uploads/#{resized_name}"
              media.full_selection = JSON.stringify(params)
              media.selection      = ''
              recreate_thumb media, media_resized_callback(media).bind(@)
            else
              media.thumbnailUrl = "#{backend_url}/uploads/#{resized_name}"
              media.selection    = JSON.stringify(params)
              media_resized_callback(media)()

      else
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(media)   

exports.imagedata = (req, res) ->
  # If a URL and callback parameters are present 
  if req.param("url") and req.param("callback")    
    # Get the parameters
    url = unescape req.param("url")
    callback = req.param("callback")

    protocol = url.split(':')[0]

    req_sender = if protocol is 'https'
      https
    else
      http

    request = req_sender.get url, (result) ->
      imagedata = ""
      mimetype  = result.headers["content-type"]

      if mimetype is "image/gif" or mimetype is "image/jpeg" or mimetype is "image/jpg" or mimetype is "image/png" or mimetype is "image/tiff"
        # Create the prefix for the data URL
        type_prefix = "data:" + mimetype + ";base64,"
        filename = "#{backend_path}public/" + url.substring(url.lastIndexOf("/") + 1)

        result.setEncoding "binary"
        result.on "data", (chunk) ->
          imagedata += chunk
        result.on "end", ->
          buffer   = new Buffer(imagedata, "binary")
          image_64 = type_prefix + buffer.toString("base64")
          fs.writeFile filename, imagedata, "binary", (err) ->
            throw err if err
            console.log "File saved."
            imageMagick(filename).size (err, size) ->
              # Delete the tmp image
              fs.unlink filename
              # Error getting dimensions
              unless err
                width = size.width
                height = size.height
                # The data to be returned 
                return_variable =
                  width: width
                  height: height
                  data: image_64
                # Stringifiy the return variable and wrap it in the callback for JSONP compatibility
                return_variable = callback + "(" + JSON.stringify(return_variable) + ");"
                # Set the headers as OK and JS
                res.writeHead 200,
                  "Content-Type": "application/javascript; charset=UTF-8"
                # Return the data
                res.end return_variable
              else
                res.send "problem", 500 
  else
    res.send "No URL or no callback was specified. These are required", 400
