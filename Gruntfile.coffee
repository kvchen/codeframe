module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    coffee:
      glob_to_multiple:
        expand: true
        flatten: true
        cwd: 'app/public/src/js'
        src: ['*.coffee']
        dest: 'app/public/dist/js'
        ext: '.js'
    express:
      options:
        port: 3000
        opts: ["node_modules/coffee-script/bin/coffee"]
      dev:
        options:
          script: "./server.coffee"
          node_env: "development"
      prod:
        options:
          script: "./server"
          node_env: "production"

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-express-server'

  grunt.registerTask 'default', ['coffee']