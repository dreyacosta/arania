gulp  = require 'gulp'
mocha = require 'gulp-mocha'

source =
  specs: ['specs/*.coffee']

gulp.task 'watch', ->
  gulp.watch source.specs, ['test']

gulp.task 'test', ->
  gulp.src source.specs, read: false
    .pipe mocha
      reporter: 'spec'
      require: 'coffee-script/register'