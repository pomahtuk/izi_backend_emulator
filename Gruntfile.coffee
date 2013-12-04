module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    coffee:
      options:
        sourceMap: false
      app:
        expand: true
        cwd: 'public/js/coffee/'
        src: ['*.coffee']
        dest: 'public/js/'
        ext: '.js'
      directives:
        options:
          join: true
        files:
          'public/js/directives_new.js': ['public/js/coffee/directives/*.coffee']

    watch:
      scripts:
        files: ['public/js/coffee/**/*.coffee']
        tasks: ['coffee']
        options:
          livereload: true
      templates:
        files: '**/*.slim'
        tasks: ['slim']
        options:
          livereload: true
      styles:
        files: '**/*.sass'
        tasks: ['compass']
        options:
          livereload: true

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
          ignoredFiles: ['public/**', 'views/**', 'partials/**', 'locales/**', 'Gruntfile.coffee'],
          file: "app.coffee"

    concurrent:
      first:
        tasks: ['coffee', 'compass', 'slim']
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

  # Default task.
  grunt.registerTask 'default', [
    'concurrent:first',
    'concurrent:second'
  ]

  grunt.registerTask 'build', ['coffee', 'compass', 'slim']