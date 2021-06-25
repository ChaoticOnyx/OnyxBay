'use strict';
var gulp = require('gulp');
//var sourcemaps = require('gulp-sourcemaps');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var browserify = require('browserify');
var watchify = require('watchify');
var less = require('gulp-less');
var concat = require('gulp-concat');
var log = require('gulplog');

var bundler = browserify({entries: './index.js', debug: true, cache: {}, packageCache: {}});

function bundle(used_bundler = bundler) {
	return used_bundler.bundle()
		.on('error', function(err) {
			log.error(err.toString());
			this.emit('end');
		})
		.pipe(source('out.js'))
		.pipe(buffer())
		//.pipe(sourcemaps.init({loadMaps: true}))
		//.pipe(sourcemaps.write('./'))
		.pipe(gulp.dest('./out/'));
}

gulp.task('js', function() {
	return bundle();
});

gulp.task('css', function() {
	return gulp.src("./css/**/*.less")
//		.pipe(sourcemaps.init())
		.pipe(less())
		.pipe(concat('out.css'))
//		.pipe(sourcemaps.write())
		.pipe(gulp.dest('./out/'));
});

gulp.task('watch', function() {
	bundler.plugin(watchify);
	gulp.series('js')();
	bundler.on('update', gulp.series('js'));
	return gulp.watch(['css/**/*.less'], gulp.series('css'));
});

gulp.task('default', gulp.parallel('js', 'css'));

gulp.task('all', gulp.series('css', 'watch'));
