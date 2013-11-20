mongoose    = require 'mongoose'
models      = require '../models/db'
async       = require 'async'
formidable  = require 'formidable'
gm          = require 'gm'
imageMagick = gm.subClass({ imageMagick: true })
mmm         = require 'mmmagic'
Magic       = mmm.Magic
magic       = new Magic(mmm.MAGIC_MIME_TYPE)
ffmpeg      = require 'fluent-ffmpeg'
QRCode      = require 'qrcode'
sys         = require 'util'
fs          = require 'fs'
http        = require 'http'
https       = require 'https'

# backend_url  = "http://192.168.158.128:3000"
backend_url  = "http://prototype.izi.travel"
# backend_path = "./"
backend_path = "/home/ubuntu/izi_backend_emulator/"

exports.certan_provider = (req, res) ->
  cp_id = req.params.cp_id
  models.ContentProvider.findOne {'_id': cp_id}, (err, content_provider) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(content_provider)

exports.provider_list = (req, res) ->
  models.ContentProvider.find (err, content_providers) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(content_providers)

exports.museum_list = (req, res) ->
  cp_id = req.params.cp_id
  models.StorySet.find {'type': 'museum', 'content_provider': cp_id }, (err, museums) ->
    if err
      console.log err
    else
      async.map museums, fetch_stories, (err, result) ->
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(result)

exports.certan_museum = (req, res) ->
  m_id = req.params.m_id
  cp_id = req.params.cp_id
  models.StorySet.findOne {'_id': m_id, 'content_provider': cp_id}, (err, museum) ->
    if err
      console.log err
    else
      fetch_stories museum, (err, data)->
        if err
          console.log err
        else          
          res.header 'Content-Type', 'application/json'
          res.send JSON.stringify(data)

exports.create_museum = (req, res) ->
  cp_id = req.params.cp_id
  models.ContentProvider.findOne {'_id': cp_id}, (err, content_provider) ->
    if err
      console.log err
    else
      req.body.content_provider = content_provider._id
      museum = new models.Curier(req.body)
      museum.save()
      console.log "Saved museum " + museum._id
      res.send "OK"

fetch_stories = (exhibit, callback) ->
  # console.log exhibit.lng
  if exhibit._id?
    criteria = {}
    criteria.story_set =  exhibit._id
    models.Story.find criteria, (err, stories) ->
      if err
        callback err
      else
        ex_result = {}
        ex_result.exhibit = exhibit
        models.Media.find {'parent': exhibit._id, 'type': 'image'}, null, {sort: {order: 1}}, (err, media) ->
          if err
            callback err
          else
            ex_result.images  = media
            async.map media, fetch_mappings, (err, m_result) ->
              callback err if err
              # console.log 'fetched'
              ex_result.images = m_result

              async.map stories, fetch_quiz, (err, result) ->
                callback err if err
                ex_result.stories = result
                # callback null, ex_result
                async.map result, fetch_images, (err, img_result) ->
                  callback err if err
                  ex_result.stories = img_result
                  callback null, ex_result
  else
    callback 'error'

fetch_mappings = (image, callback) ->
  if image?
    models.MediaMapping.find {'media': image._id}, (err, media_mappings) ->
      if err
        callback err
      else
        result = {}
        result.mappings = {}
        result.image = image
        for mapping in media_mappings
          result.mappings[mapping.language] = mapping
        # result.mappings = media_mappings
        callback null, result
  else
    callback 'error'  

fetch_images = (story, callback) ->
  if story?
    models.Media.find {'parent': story.story._id}, (err, media) ->
      if err
        callback err
      else
        me_result = {}
        me_result.images = []
        me_result.story  = story.story
        me_result.quiz   = story.quiz
        for file in media
          if file.type is 'image'
            me_result.images.push file
          else if file.type is 'audio'
            console.log 'audio!!!'
            me_result.audio = file
          else if file.type is 'video'
            console.log 'video!!!'
            me_result.video = file
        callback null, me_result
  # else
  #   callback 'ololo'

fetch_quiz = (story, callback) ->
  if story?
    models.Quiz.findOne {'story': story._id}, (err, quiz) ->
      if err
        callback err
      else
        if quiz?
          st_result = {}
          st_result.story = story 
               
          models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
            if err
              callback err
            else
              qw_result = {}
              qw_result.answers = answers
              qw_result.quiz  = quiz
              st_result.quiz  = qw_result
              callback null, st_result
        else
          callback 'error'
  else
    callback 'error'

fetch_answers = (quiz, callback) ->
  if quiz?
    models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
      if err
        callback err
      else
        qw_result = {}
        qw_result.answers = answers
        qw_result.quiz  = quiz
      callback null, qw_result
  else
    callback 'err'

exports.exhibit_list = (req, res) ->
  cp_id     = req.params.cp_id
  m_id      = req.params.m_id
  lang      = req.params.lang
  field     = req.params.field || 'number'
  direction = req.params.direction || -1

  sort_obj = {}
  sort_obj[field] = parseInt direction, 10

  # console.log sort_obj

  # setTimeout ->
  models.StorySet.find {'type': 'exhibit', 'content_provider': cp_id, 'parent': m_id }, null, { sort: sort_obj }, (err, exhibits) ->
    if err
      console.log err
    else
      async.map exhibits, fetch_stories, (err, result) ->
        res.header 'Content-Type', 'application/json'
        res.send JSON.stringify(result)
  # , 1000

exports.certan_exhibit = (req, res) ->
  cp_id = req.params.cp_id
  ex_id = req.params.ex_id
  m_id = req.params.m_id
  models.StorySet.findOne {'type': 'exhibit', 'content_provider': cp_id, 'parent': m_id, '_id': ex_id }, (err, exhibit) ->
    if err
      console.log err
    else
      models.Story.find {'story_set': ex_id}, (err, stories) ->
        if err
          console.log err
        else
          res.header 'Content-Type', 'application/json'
          response = {}
          response.exhibit = exhibit
          response.stories = stories
          res.send JSON.stringify(response)

## quiz

exports.certan_quiz = (req, res) ->
  id = req.params.q_id
  models.Quiz.findOne {'_id': id}, (err, quiz) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(quiz)

exports.create_quiz = (req, res) ->
  quiz = new models.Quiz(req.body)
  quiz.save()
  console.log "Saved quiz " + quiz._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(quiz)

exports.update_quiz = (req, res) ->
  id   = req.params.q_id
  data = req.body
  models.Quiz.findOne {'_id': id}, (err, quiz) ->
    if err
      console.log err
    else
      # console.log data
      quiz.story     = data.story
      quiz.question  = data.question
      quiz.comment   = data.comment
      quiz.status    = data.status

      quiz.save()
      res.send 'ok'

exports.delete_quiz = (req, res) ->
  models.Quiz.findById req.params.q_id, (err, quiz) ->
    quiz.remove quiz
    console.log "Deleted quiz " + quiz._id
    res.send "OK"

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

## story

exports.story_list = (req, res) ->
  models.Story.find (err, stories) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(stories)

exports.certan_story = (req, res) ->
  id = req.params.s_id
  models.Story.findOne {'_id': id}, (err, story) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(story)

exports.create_story = (req, res) ->
  story = new models.Story(req.body)
  console.log story
  story.save()
  # console.log "Saved story " + story._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(story)

exports.update_story = (req, res) ->
  id   = req.params.s_id
  data = req.body
  models.Story.findOne {'_id': id}, (err, story) ->
    if err
      console.log err
    else
      story.playback_algorithm = data.playback_algorithm
      story.content_provider   = data.content_provider
      story.story_type         = data.story_type
      story.status             = data.status
      story.language           = data.language
      story.name               = data.name
      story.short_description  = data.short_description
      story.long_description   = data.long_description
      story.story_set          = data.story_set

      story.save()
      res.send 'ok'

exports.delete_story = (req, res) ->
  models.Story.findById req.params.s_id, (err, story) ->
    story.remove story
    console.log "Deleted story " + story._id
    res.send "OK"

# exhibit

exports.certan_story_set = (req, res) ->
  id = req.params.e_id
  models.StorySet.findOne {'_id': id}, (err, exhibit) ->
    if err
      console.log err
    else
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(exhibit)

exports.create_story_set = (req, res) ->
  exhibit = new models.StorySet(req.body)
  exhibit.save()
  # console.log exhibit
  console.log "Saved exhibit " + exhibit._id
  res.header 'Content-Type', 'application/json'
  res.send JSON.stringify(exhibit)

exports.update_story_set = (req, res) ->
  id   = req.params.e_id
  data = req.body
  console.log data.language
  models.StorySet.findOne {'_id': id}, (err, exhibit) ->
    if err
      console.log err
    else
      exhibit.content_provider = data.content_provider
      exhibit.type             = data.type
      exhibit.distance         = data.distance
      exhibit.duration         = data.duration
      exhibit.status           = data.status
      exhibit.route            = data.route
      exhibit.category         = data.category
      exhibit.parent           = data.parent
      exhibit.name             = data.name
      exhibit.language         = data.language
      exhibit.number           = data.number

      exhibit.save()
      res.send 'ok'

delete_stories = (story, callback) ->
  async.parallel [ 
    (callback) ->
      models.Story.findOne {'_id': story._id}, (err, story) ->
        if err
          callback err
        else
          if story?
            story.remove story
            console.log "Deleted story " + story._id
          callback null, 'deleted'
    (callback) ->
      models.Media.find {'parent': story._id}, (err, media) ->
        if err
          callback err
        else
          if media.length > 0
            async.map media, delete_media, (err, result) ->
              callback null, 'deleted'
          else
            callback null, 'deleted'
    (callback) ->
      models.Quiz.findOne {'story': story._id}, (err, quiz) ->
        if err
          callback err
        else
          if quiz?
            quiz.remove quiz
            console.log "Deleted quiz " + quiz._id
            models.QuizAnswer.find {'quiz': quiz._id}, (err, answers) ->
              if err
                callback err
              else
                if answers.length > 0          
                  async.map answers, delete_answers, (err, result) ->
                    callback null, 'deleted'
                else
                  callback null, 'deleted'
          else
            callback null, 'deleted'
  ], (err, result) ->
    if err
      callback err
    else
      callback null, 'deleted'

delete_answers = (answers, callback) ->
  models.QuizAnswer.findOne {'_id': answers._id}, (err, answer) ->
    if err
      callback err
    else
      if answer?
        answer.remove answer
        console.log "Deleted answer " + answer._id
        callback null, 'deleted'

delete_media = (media, callback) ->
  models.Media.findOne {'_id': media._id}, (err, media) ->
    if err
      callback err
    else
      if media?
        media.remove media
        console.log "Deleted media " + media._id
        callback null, 'deleted'

exports.delete_story_set = (req, res) ->
  models.StorySet.findById req.params.e_id, (err, exhibit) ->
    if err
      console.log err
    else
      if exhibit
        exhibit.remove exhibit
        console.log "Deleted exhibit " + exhibit._id
        models.Media.find {'parent': exhibit._id}, (err, media) ->
          if err
            console.log err
          else
            if media.length > 0
              for media_item in media
                media_item.remove media_item
                console.log "Deleted media_item " + media_item._id
        models.Story.find {'story_set': exhibit._id} , (err, stories) ->
          if err
            console.log err
          else
            async.map stories, delete_stories, (err, result) ->
              res.send 'deleted'
      else
        console.log 'all'
        res.send 'nope'


    # res.send "OK"

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

# images manipulation

extract_file_name = (path) ->
  path   = path.split('/')
  path   = path[path.length - 1]
  path

cleanup_media = (media, mode) ->
  if mode is 'full'
    if media.fullUrl?
      if media.fullUrl isnt media.url
        fs.unlink "#{backend_path}public/#{extract_file_name(media.fullUrl)}", (err) ->
          console.log err if err
          console.log 'deleted full'
  else
    if media.thumbnailUrl?
      if media.thumbnailUrl isnt media.url
        fs.unlink "#{backend_path}public/#{extract_file_name(media.thumbnailUrl)}", (err) ->
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
  path         = "#{backend_path}public/#{name}"
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

      imageMagick(path).crop(width, height, 0, 0).write "#{backend_path}public/#{resized_name}", (err) ->
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
          fs.writeFile "#{backend_path}public/#{name}", data, (err) ->
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

          imageMagick(file.path).crop(width, height, 0, 0).write "#{backend_path}public/#{resized_name}", (err) ->
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
                media.url             = "#{backend_url}/#{name}"
                media.thumbnailUrl    = "#{backend_url}/#{resized_name}"
                media.thumbnailUrl    = "#{backend_url}/#{name}"
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

        proc = new ffmpeg({source:file.path}).withAudioCodec('libvorbis').toFormat('ogg').saveToFile "#{backend_path}public/#{converted}", (retcode, error) ->
          if error
            console.log error
          media.name         = client_name
          media.size         = 100
          media.url          = "#{backend_url}/#{name}"
          media.thumbnailUrl = "#{backend_url}/#{converted}"
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
        proc.saveToFile "./public/#{converted}", (retcode, error) ->
          console.log retcode
          if error
            console.log error
          media.name         = file.originalFilename.substr(0, 20) + '...'
          media.size         = 100
          media.url          = "#{backend_url}/#{converted}"
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

        imageMagick("#{backend_path}public/#{media_name}").crop(params.w, params.h, params.x, params.y).write "#{backend_path}public/#{resized_name}", (err) ->
          if err
            console.log err
          else
            if params.mode is 'full'
              media.fullUrl        = "#{backend_url}/#{resized_name}"
              media.full_selection = JSON.stringify(params)
              media.selection      = ''
              recreate_thumb media, media_resized_callback(media).bind(@)
            else
              media.thumbnailUrl = "#{backend_url}/#{resized_name}"
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

# qr code

exports.qr_code = (req, res) ->
  QRCode.toDataURL req.params.data, (error, data)->
    res.header 'Content-Type', 'data:image/png'
    res.send data

