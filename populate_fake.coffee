mongoose = require 'mongoose'
Faker    = require 'Faker'
models   = require './models/db'
QRCode   = require 'qrcode'
# require 'date-utils'
#mongoose.set('debug', true)

# firmSchema  = new mongoose.Schema
#   title:       String
#   info:        String
#   adress:      String

# orderSchema = new mongoose.Schema
#   date:           { type: Date, default: Date.now }
#   day_of_week:    String
#   firm:           { type : mongoose.Schema.ObjectId, ref : 'firm' }
#   order_summ:     Number
#   delivery_cost:  Number
#   curier:         { type : mongoose.Schema.ObjectId, ref : 'curier' }

# curierSchema = new mongoose.Schema
#   name:         String

# Order    = mongoose.model 'order', orderSchema
# Firm     = mongoose.model 'firm', firmSchema
# Curier   = mongoose.model 'curier', curierSchema

mongoose.connect 'mongodb://localhost/iziteq'

# exports.StorySet        = StorySet
# exports.Story           = Story
# exports.Quiz            = Quiz
# exports.QuizAnswer      = QuizAnswer
# exports.ContentProvider = ContentProvider

content_provider = new models.ContentProvider
  name: 'test prvider'
  limited_pass: '177591'
  copyright: 'pman'
  commerce: false
  quizzes: true
  preffered_app: 'generic'
  status: 'published'

content_provider.save()

museum = new models.StorySet
  content_provider: content_provider._id
  type:             'museum'
  distance:         100
  duration:         100
  status:           'published'
  route:            'ololo'
  category:         'ololo'
  name:             'test museum'

museum.save()

lang     = ['ru', 'en', 'es']
corr_map = [true, false, false, false] 

create_stories_for_object = (object) ->
  for i in [0..2]
    story = {
      name: "Story in #{lang[i]}"
      playback_algorithm: 'no matter'
      content_provider:   content_provider._id
      story_type:         'story'
      status:             'published'
      language:           lang[i]
      short_description:  Faker.Lorem.paragraph()
      long_description:   Faker.Lorem.paragraph()
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

create_stories_for_object(museum)

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
  }
  exhibit = new models.StorySet(exhibit)
  exhibit.save()

  for i in [0..1]
    media = new models.Media  
      parent: exhibit._id
      image:  'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/14845c98-05ec-4da8-8aff-11808ecc123f_800x600.jpg'
      thumb:  'http://media.izi.travel/fc85dcc2-3e95-40a9-9a78-14705a106230/7104d8b7-2f73-4b98-bfb2-b4245a325ce3_480x360.jpg'

    media.save()


  create_stories_for_object(exhibit)