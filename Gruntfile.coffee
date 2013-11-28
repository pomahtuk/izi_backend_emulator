module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    coffee:
      options:
        sourceMap: true
      app:
        expand: true
        cwd: 'public/'
        src: ['**/*.coffee']
        dest: 'public/'
        ext: '.js'

    watch:
      scripts:
        files: 'public/**/*.coffee'
        tasks: ['coffee', 'reload']    
      templates:
        files: '**/*.slim'
        tasks: ['slim', 'reload']
      styles:
        files: '**/*.sass'
        tasks: ['compass', 'reload']
      express:
        files:  [ 'app.coffee', 'routes/*.coffee', 'models/.coffee' ],
        tasks:  [ 'nodemon' ]
        options:
          spawn: false  # Without this option specified express won't be reloaded

    slim:
      dist:
        files: [
          expand: true
          src: ['**/*.slim']
          ext: '.html'
        ]

    compass:
      dist:
        options:
          sassDir: 'public/css'
          cssDir: 'public/css'

    nodemon:
      dev:
        options:
          file: "app.coffee"

    reload:
      port: 35729
      liveReload: true
      # iframe:
      #   target: '192.168.158.128'
      # proxy:
      #   host: '192.168.158.128'

    concurrent:
      first:
        tasks: ['reload', 'coffee', 'compass', 'slim']
        options:
          logConcurrentOutput: true
      second:
        tasks: ['nodemon', 'watch']
        options:
          logConcurrentOutput: true


  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-slim'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks 'grunt-reload'

  # Default task.
  # grunt.registerTask 'default', ['coffee', 'slim', 'compass', 'nodemon', 'watch']

  grunt.registerTask 'default', [
    'concurrent:first',
    'concurrent:second'
  ]