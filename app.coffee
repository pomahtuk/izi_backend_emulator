###
Module dependencies.
###
express       = require "express"
coffee        = require 'coffee-script'
coffeescript  = require 'connect-coffee-script'
api           = require "./routes/routes"
web           = require "./routes/index"
models        = require "./models/db"
path          = require "path"
fs            = require 'fs'
connect       = require 'connect'
assets        = require 'connect-assets'
connectDomain = require 'connect-domain'
mongoose      = require 'mongoose'
MongoStore    = require('connect-mongo')(express)
upload        = require 'jquery-file-upload-middleware'
formidable    = require 'formidable'
util          = require 'util'


####
## USERS BASE FUNCTIONALITY
####
flash         = require('connect-flash')
passport      = require('passport')
LocalStrategy = require('passport-local').Strategy

upload.configure
  uploadDir: __dirname + "/public/uploads"
  uploadUrl: "/uploads"
  imageVersions:
    thumbnail:
      width: 150
      height: 200

passport.serializeUser (user, done) ->
  done null, user.id

passport.use new LocalStrategy (username, password, done) ->
  models.User.findOne
    'username': username
  , (err, user) ->
    console.log user
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Incorrect username."
      )
    unless user.password is password
      return done(null, false,
        message: "Incorrect password."
      )
    done null, user

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated() 
    return next()
  res.redirect('/login')

passport.deserializeUser (id, done) ->
  models.User.findById id, (err, user) ->
    done err, user

conf =
  db:
    db: "iziteq"
    host: "127.0.0.1"
  secret: "076ee61d63aa10a125ea872411e433b9"

####
## MAIN APP CODE
####
mongoose.connect 'mongodb://localhost/iziteq'

allowCrossDomain = (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE"
  res.header "Access-Control-Allow-Headers", "Content-Type, Content-Disposition"
  next()

app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.set 'view options', {
  layout: false
}
app.use express.favicon('/public/images/favicon.ico')
app.use express.logger("dev")
app.use(express.limit('50mb'))
app.use(coffeescript(
  src: __dirname
  bare: true
  sourceMap: true
))
app.use express.bodyParser(
  keepExtensions: true
  uploadDir: __dirname + "/public"
  limit: "5mb"
)
app.use express.methodOverride()
app.use assets()
app.use express.cookieParser("your secret here")
app.use express.session(
  secret: conf.secret
  maxAge: new Date(Date.now() + 3600000)
  store: new MongoStore({ host: '127.0.0.1', port: 27017, db: 'curier', collection: 'sessions' })
)
app.use connectDomain()
app.use flash()
app.use allowCrossDomain
app.use passport.initialize()
app.use passport.session()
app.use connect.static(__dirname + '/public')
app.use express.static(__dirname + '/public')
app.use app.router

app.use (err, req, res, next) ->
  console.log  err
  res.send 500, "Houston, we have a problem!\n"

app.use express.errorHandler() if "development" is app.get("env")

#
# Main route
#
app.get "/", web.index
###### ensureAuthenticated

#images
app.post   "/api/upload/:parent_id", api.upload_handler
app.put    "/api/upload/:parent_id", api.upload_handler

app.get    "/api/imagedata", api.imagedata

app.post   "/api/resize_thumb/:image_id", api.resize_handler
app.put    "/api/resize_thumb/:image_id", api.resize_handler

app.get    "/api/quiz/:q_id", api.certan_quiz
app.post   "/api/quiz", api.create_quiz
app.put    "/api/quiz/:q_id", api.update_quiz
app.delete "/api/quiz/:q_id", api.delete_quiz

app.get    "/api/quiz_answer/:qa_id", api.certan_quiz_answer
app.post   "/api/quiz_answer", api.create_quiz_answer
app.put    "/api/quiz_answer/:qa_id", api.update_quiz_answer
app.delete "/api/quiz_answer/:qa_id", api.delete_quiz_answer

app.get    "/api/story", api.story_list
app.get    "/api/story/:s_id", api.certan_story
app.post   "/api/story", api.create_story
app.put    "/api/story/:s_id", api.update_story
app.delete "/api/story/:s_id", api.delete_story

app.get    "/api/media", api.media_list
app.get    "/api/media/:m_id", api.certan_media
app.post   "/api/media", api.create_media
app.put    "/api/media/:m_id", api.update_media
app.delete "/api/media/:m_id", api.delete_media
app.post   "/api/media_for/:parent_id/reorder", api.media_reorder

app.post   "/api/media_mapping", api.create_mapping
app.put    "/api/media_mapping/:map_id", api.update_mapping
app.delete "/api/media_mapping/:map_id", api.delete_mapping

app.get    "/api/story_set/:e_id", api.certan_story_set
app.post   "/api/story_set", api.create_story_set
app.put    "/api/story_set/:e_id", api.update_story_set
app.get    "/api/delete/story_set/:e_id", api.delete_story_set
app.delete "/api/story_set/:e_id", api.delete_story_set
app.post   "/api/story_set/update_numbers/:parent_id", api.update_story_set_numbers

app.get    "/api/qr_code/:data", api.qr_code

#/1/museums/1/exhibits/8/properties
app.get    "/api/provider", api.provider_list
app.get    "/api/provider/:cp_id", api.certan_provider
app.get    "/api/provider/:cp_id/museums", api.museum_list
app.get    "/api/provider/:cp_id/museums/:m_id", api.certan_museum
# app.post   "/provider/:cp_id/museums", routes.create_museum
# app.put    "/provider/:cp_id/museums/:m_id", routes.update_museum
# app.delete "/provider/:cp_id/museums/:m_id", routes.delete_museum
app.get    "/api/provider/:cp_id/museums/:m_id/exhibits", api.exhibit_list
app.get    "/api/provider/:cp_id/museums/:m_id/exhibits/:field/:direction", api.exhibit_list

# View routes

app.get "/partials/:name", web.partials
app.get "/template/:folder/:name", web.templates

#
# Auth routes
#
# app.get '/login', manager.login
# app.get '/logout', manager.logout
# app.post '/login', passport.authenticate 'local', { successRedirect: '/', failureRedirect: '/login', failureFlash: true}

app.get '/:id', web.index

app.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")