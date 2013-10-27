mongoose = require 'mongoose'
Faker    = require 'Faker'
models   = require './models/db'
QRCode   = require 'qrcode'
# require 'date-utils'
mongoose.set('debug', false)

mongoose.connect 'mongodb://localhost/iziteq'

# exports.StorySet        = StorySet
# exports.Story           = Story
# exports.Quiz            = Quiz
# exports.QuizAnswer      = QuizAnswer
# exports.ContentProvider = ContentProvider

args = process.argv.splice(2)
mode = args[0]

lang     = ['ru', 'en', 'es']
corr_map = [true, false, false, false] 

create_stories_for_object = (object, content_provider, story_name = 'Story in') ->
  for i in [0..0]
    story = {
      name: "#{story_name}"
      playback_algorithm: 'no matter'
      content_provider:   content_provider._id
      story_type:         'story'
      status:             'passcode'
      language:           lang[i]
      short_description:  ''
      long_description:   ''
      story_set:          object._id
    }
    story = new models.Story(story)
    story.save()
    quiz = {
      story:     story._id
      question:  'question'
      comment:   'test of data pregeneration'
    }
    quiz = new models.Quiz(quiz)
    quiz.save()

    for i in [0..3]
      answer = models.QuizAnswer
        quiz:     quiz._id
        content:  "answer ##{i}"
        correct:  corr_map[i]
      answer.save()

create_base_records = ->
  content_provider = new models.ContentProvider
    name: 'test prvider'
    limited_pass: '177591'
    copyright: 'pman'
    commerce: false
    quizzes: true
    preffered_app: 'generic'
    status: 'published'

  content_provider.save()

  provider_id = content_provider._id

  museum = new models.StorySet
    content_provider: content_provider._id
    type:             'museum'
    distance:         100
    duration:         100
    status:           'published'
    route:            'ololo'
    category:         'ololo'
    name:             'test museum'
    number:           0

  museum.save()

  museum_id = museum._id

  create_stories_for_object museum, content_provider

  for i in [0..24]
    exhibit = {
      content_provider: content_provider._id
      type:             'exhibit'
      distance:         100
      duration:         100
      status:           'published'
      route:            'ololo'
      category:         'ololo'
      name:             "test exhibit ##{i}"
      parent:           museum._id
      number:           i
    }
    exhibit = new models.StorySet(exhibit)
    exhibit.save()

    # for i in [0..1]
    #   media = new models.Media  
    #     parent:       exhibit._id
    #     name:         '7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
    #     siz:          100
    #     url:          'http://habrastorage.org/storage3/cb6/d13/0a0/cb6d130a09c3c4b13446c3283067033b.jpg'
    #     thumbnailUrl: 'http://habrastorage.org/storage3/cb6/d13/0a0/cb6d130a09c3c4b13446c3283067033b.jpg'
    #     deleteType:   "DELETE"
    #     type:         "image"
    #   media.save()

    create_stories_for_object exhibit, content_provider

  console.log "provider: #{provider_id}  and museum:  #{museum_id}"

create_museums = ->
  models.ContentProvider.find {}, (err, provider) ->
    provider = provider[0]

    for i in [0..9]

      museum = new models.StorySet
        content_provider: provider._id
        type:             "museum"
        distance:         100
        duration:         100
        status:           'passcode'
        route:            'ololo'
        category:         'ololo'
        name:             "test museum #{i}"
        number:           0

      museum.save()

      # for i in [0..1]
      #   media = new models.Media  
      #     parent:       museum._id
      #     name:         '7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'
      #     siz:          100
      #     url:          'http://habrastorage.org/storage3/cb6/d13/0a0/cb6d130a09c3c4b13446c3283067033b.jpg'
      #     thumbnailUrl: 'http://habrastorage.org/storage3/cb6/d13/0a0/cb6d130a09c3c4b13446c3283067033b.jpg'
      #     deleteType:   "DELETE"
      #     type:         "image"
      #   media.save()

      create_stories_for_object museum, provider, "Museum #{i}"

  # mongoose.connection.close()

delete_records = ->
  models.StorySet.find({}).remove().exec()
  models.Story.find({}).remove().exec()
  models.Quiz.find({}).remove().exec()
  models.QuizAnswer.find({}).remove().exec()
  models.ContentProvider.find({}).remove().exec()
  mongoose.connection.close()
          
switch mode
  when 'create_base'
    console.log 'creating'
    create_base_records()
    setTimeout ->
      mongoose.connection.close()
    , 2000
  when 'create_museums'
    console.log 'museum'
    create_museums()
    setTimeout ->
      mongoose.connection.close()
    , 2000
  when 'drop_database'
    console.log 'droping'
    delete_records()
  when 'help'
    console.log "create_base  drop_database  create_museums"
    mongoose.connection.close()
  else
    console.log "create_base  drop_database  create_museums"
    mongoose.connection.close()
    true

