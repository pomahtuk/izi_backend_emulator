mongoose = require 'mongoose'
# mongoose.set('debug', true)

story_setSchema = new mongoose.Schema
  content_provider: { type : mongoose.Schema.ObjectId, ref : 'content_provider' }
  type:             String
  distance:         String
  duration:         String
  status:           String
  route:            String
  category:         String
  language:         String
  parent:           { type : mongoose.Schema.ObjectId, ref : 'story_set' }
  name:             String
  number:           Number

storySchema = new mongoose.Schema
  playback_algorithm: String
  content_provider:   { type : mongoose.Schema.ObjectId, ref : 'content_provider' }
  story_type:         String
  status:             String
  language:           String
  name:               String
  short_description:  String
  long_description:   String
  story_set:          { type : mongoose.Schema.ObjectId, ref : 'story_set' }

quizSchema = new mongoose.Schema
  story:     { type : mongoose.Schema.ObjectId, ref : 'story' }
  question:  String
  comment:   String
  status:    String

quiz_answerSchema = new mongoose.Schema
  quiz:     { type : mongoose.Schema.ObjectId, ref : 'quiz' }
  content:  String
  correct:  Boolean

mediaSchema = new mongoose.Schema
  parent:       String
  name:         String
  size:         Number
  url:          String
  thumbnailUrl: String
  deleteUrl:    String
  deleteType:   String
  type:         String
  selection:    String
  updated:      { type: Date, default: Date.now }

content_providerSchema = new mongoose.Schema
  name:          String
  limited_pass:  String
  copyright:     String
  commerce:      Boolean
  quizzes:       Boolean
  preferred_app: String
  status:        String

userSchema = new mongoose.Schema
  password:     String
  username:     String

User            = mongoose.model 'user', userSchema
StorySet        = mongoose.model 'story_set', story_setSchema
Story           = mongoose.model 'story', storySchema
Quiz            = mongoose.model 'quiz', quizSchema
QuizAnswer      = mongoose.model 'quiz_answer', quiz_answerSchema
ContentProvider = mongoose.model 'content_provider', content_providerSchema
Media           = mongoose.model 'media', mediaSchema

exports.User            = User
exports.StorySet        = StorySet
exports.Story           = Story
exports.Quiz            = Quiz
exports.QuizAnswer      = QuizAnswer
exports.ContentProvider = ContentProvider
exports.Media           = Media