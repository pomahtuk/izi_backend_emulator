###
Module dependencies.
###
express       = require "express"
coffee        = require 'coffee-script'
routes        = require "./routes/routes"
# firms         = require "./routes/firms"
# orders        = require "./routes/orders"
# curiers       = require "./routes/curiers"
# manager       = require "./routes/manager"
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

# dbref = require "mongoose-dbref"
# utils = dbref.utils
# loaded = dbref.install mongoose


allowCrossDomain = (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE"
  res.header "Access-Control-Allow-Headers", "Content-Type"
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
# app.use '/upload', upload.fileHandler()
# app.use "/list", (req, res, next) ->
#   upload.fileManager().getFiles (files) ->
#     res.json files
# app.use express.bodyParser({ keepExtensions: true, uploadDir: __dirname + '/public/files' })
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
# app.get "/", routes.index
###### ensureAuthenticated

#images
app.post   "/api/upload/:parent_id", routes.upload_handler
app.put    "/api/upload/:parent_id", routes.upload_handler

app.post   "/api/resize_thumb/:image_id", routes.resize_handler
app.put    "/api/resize_thumb/:image_id", routes.resize_handler

app.get    "/api/quiz/:q_id", routes.certan_quiz
app.post   "/api/quiz", routes.create_quiz
app.put    "/api/quiz/:q_id", routes.update_quiz
app.delete "/api/quiz/:q_id", routes.delete_quiz

app.get    "/api/quiz_answer/:qa_id", routes.certan_quiz_answer
app.post   "/api/quiz_answer", routes.create_quiz_answer
app.put    "/api/quiz_answer/:qa_id", routes.update_quiz_answer
app.delete "/api/quiz_answer/:qa_id", routes.delete_quiz_answer

app.get    "/api/story", routes.story_list
app.get    "/api/story/:s_id", routes.certan_story
app.post   "/api/story", routes.create_story
app.put    "/api/story/:s_id", routes.update_story
app.delete "/api/story/:s_id", routes.delete_story

app.get    "/api/media", routes.media_list
app.get    "/api/media/:m_id", routes.certan_media
app.post   "/api/media", routes.create_media
app.put    "/api/media/:m_id", routes.update_media
app.delete "/api/media/:m_id", routes.delete_media

app.get    "/api/story_set/:e_id", routes.certan_story_set
app.post   "/api/story_set", routes.create_story_set
app.put    "/api/story_set/:e_id", routes.update_story_set
app.get    "/api/delete/story_set/:e_id", routes.delete_story_set
app.delete "/api/story_set/:e_id", routes.delete_story_set

app.get    "/api/qr_code/:data", routes.qr_code

#/1/museums/1/exhibits/8/properties
app.get    "/api/provider", routes.provider_list
app.get    "/api/provider/:cp_id", routes.certan_provider
app.get    "/api/provider/:cp_id/museums", routes.museum_list
# app.post   "/provider/:cp_id/museums", routes.create_museum
app.get    "/api/provider/:cp_id/museums/:m_id", routes.certan_museum
# app.put    "/provider/:cp_id/museums/:m_id", routes.update_museum
# app.delete "/provider/:cp_id/museums/:m_id", routes.delete_museum
app.get    "/api/provider/:cp_id/museums/:m_id/exhibits", routes.exhibit_list
app.get    "/api/provider/:cp_id/museums/:m_id/exhibits/:field/:direction", routes.exhibit_list
# app.get    "/provider/:cp_id/museums/:m_id/exhibits/:ex_id", routes.certan_exhibit
# app.post   "/provider/:cp_id/museums/:m_id/exhibits", routes.create_exhibit
# app.put    "/provider/:cp_id/museums/:m_id/exhibits/:ex_id", routes.update_exhibit
# app.delete "/provider/:cp_id/museums/:m_id/exhibits/:ex_id", routes.delete_exhibit

# app.get '/*', (req, res) ->
#   res.redirect('http://mydomain.com'+req.url)

#
# View routes
#
# app.get "/partials/:name", routes.partials
# app.get "/template/:folder/:name", routes.templates

#
# Auth routes
#
# app.get '/login', manager.login
# app.get '/logout', manager.logout
# app.post '/login', passport.authenticate 'local', { successRedirect: '/', failureRedirect: '/login', failureFlash: true}


app.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")