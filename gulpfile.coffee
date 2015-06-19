'use strict'

gulp = require 'gulp'
$ = require('gulp-load-plugins')()
browserSync = require 'browser-sync'

config =
  src: './src'
  dest: './dist'

gulp.task 'browser-sync', ->
  browserSync
    watchOptions:
      debounceDelay: 0
    server:
      baseDir: config.dest
      routes:
        '/bower_components': 'bower_components'
    notify: false
    reloadDelay: 0
    browser: 'Google Chrome Canary'



gulp.task 'html', ['jade'], ->
  assets = $.useref.assets()
  gulp.src config.dest + '/index.html'
    .pipe assets
    .pipe assets.restore()
    .pipe $.useref()
    .pipe gulp.dest config.dest

gulp.task 'jade', ->
  gulp.src config.src + '/*.jade'
    .pipe $.plumber()
    .pipe $.changed config.dest,
      extension: '.html'
    .pipe $.jade
      pretty: true
    .pipe $.prettify
      condense: true
      padcomments: false
      indent: 2
      indent_char: ' '
      indent_inner_html: 'false'
      brace_style: 'expand'
      wrap_line_length: 0
      preserve_newlines: true
    .pipe gulp.dest config.dest
    .pipe browserSync.reload
      stream: true

gulp.task 'sass', ->
    $.rubySass config.src + '/styles/style.scss'
    .on 'error', (err) ->
      console.error 'Error!', err.message
    .pipe $.autoprefixer 'last 2 version', 'ie 9', 'ie 8'
    .pipe $.combineMediaQueries()
    .pipe $.csscomb()
    .pipe gulp.dest config.dest + '/styles'
    .pipe browserSync.reload
      stream: true

gulp.task 'coffee', ->
  gulp.src config.src + '/scripts/*.coffee'
    .pipe $.plumber()
    .pipe $.changed config.dest,
      extension: '.js'
    .pipe $.coffee()
    .pipe gulp.dest config.dest + '/scripts'
    .pipe browserSync.reload
      stream: true

gulp.task 'clean', ->
  del = require 'del'
  del ['dist/scripts/*.js', '!dist/scripts/{main,vendor}.js']

gulp.task 'default', ['jade', 'sass', 'coffee', 'browser-sync'], ->
  gulp.watch config.src + '/*.jade', ['jade']
  gulp.watch config.src + '/styles/*.scss', ['sass']
  gulp.watch config.src + '/scripts/*.coffee', ['coffee']

gulp.task 'prebuild', ['html', 'sass', 'coffee']

gulp.task 'build', ['prebuild'], ->
  gulp.start 'clean'
