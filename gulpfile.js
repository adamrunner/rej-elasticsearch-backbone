var gulp       = require('gulp');
var webserver  = require('gulp-webserver');
var coffee     = require('gulp-coffee');
var sass       = require('gulp-sass');
var gutil      = require('gulp-util');
var browserify = require('gulp-browserify');
var concat     = require('gulp-concat');
var handlebars = require('gulp-handlebars');
var wrap       = require('gulp-wrap');
var declare    = require('gulp-declare');

gulp.task('coffee', function() {
  gulp.src(['src/models/*.coffee','src/views/*.coffee','src/app.coffee'])
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(concat('app.js'))
    .pipe(gulp.dest('./public/js/'));
});


gulp.task('styles', function() {
    gulp.src('sass/**/*.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./public/css/'))
});

gulp.task('templates', function(){
  gulp.src('src/templates/*.hbs')
    .pipe(handlebars({
      handlebars: require('handlebars')
    }))
    .pipe(wrap('Handlebars.template(<%= contents %>)'))
    .pipe(declare({
      namespace: 'App.templates',
      noRedeclare: true, // Avoid duplicate declarations
    }))
    .pipe(concat('templates.js'))
    .pipe(gulp.dest('public/js/'));
});


//Watch task

gulp.task('watch',function() {
  gulp.watch('src/index.html', ['copy']);
  gulp.watch('src/**/*.coffee', ['coffee']);
  gulp.watch('src/**/*.js', ['browserify']);
  gulp.watch('sass/**/*.scss',['styles']);
  gulp.watch('src/templates/**/*.hbs', ['templates']);

});


gulp.task('webserver', function() {
  gulp.src('./public')
    .pipe(webserver({
      livereload: true,
      directoryListing: false
    }));
});

gulp.task('browserify', function() {
  gulp.src('src/js/*.js')
    .pipe(browserify({transform: 'hbsfy'}))
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest('public/js'));
});

gulp.task('copy', function() {
  gulp.src('src/index.html')
    .pipe(gulp.dest('public'));
});

gulp.task('default', ['styles', 'coffee', 'copy', 'templates', 'browserify', 'webserver', 'watch']);
