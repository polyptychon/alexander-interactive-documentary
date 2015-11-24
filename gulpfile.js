var gulp = require('gulp'),
    jade = require('gulp-jade'),
    uglify = require('gulp-uglify'),
    sass = require('gulp-sass'),
    prefix = require('gulp-autoprefixer'),

    minifyCSS = require('gulp-minify-css'),
    glob = require('glob'),
    plumber = require('gulp-plumber'),
    browserify = require('browserify'),
    concat = require('gulp-concat'),
    sourcemaps = require('gulp-sourcemaps'),
    changed = require('gulp-changed'),
    rev = require('gulp-rev'),
    gutil = require('gulp-util'),
    flatten = require('gulp-flatten'),
    fingerprint = require('gulp-fingerprint'),
    buffer = require('gulp-buffer'),
    size = require('gulp-size'),
    fs = require('fs'),
    crypto = require('crypto'),
    _ = require('lodash'),

    del = require('del'),
    vinylPaths = require('vinyl-paths'),

    webserver = require('gulp-webserver'),

    source = require('vinyl-source-stream'),
    coffee = require('coffee-script'),

    duration = require('gulp-duration'),
    argv = require('yargs').argv,

    runSequence = require('run-sequence'),
    livereload = require('gulp-livereload'),
    gulpif = require('gulp-if');

var DEVELOPMENT = 'development',
    PRODUCTION = 'production',
    USE_FINGERPRINTING = false,
    USE_VENDOR = false,
    BUILD = "builds/",
    ASSETS = "/assets",
    MOCKUPS = "_mockups",
    SRC = "_src",
    useServer = false,
    TEST = "test",
    watching = false,
    not_in_dependencies_libs = ['jquery', 'bootstrapify'];

var env = process.env.NODE_ENV || DEVELOPMENT;
if (env!==DEVELOPMENT) env = PRODUCTION;

var jadeFiles = argv.jade || '*';
var dependencies = [];//Object.keys(packageJson && packageJson.dependencies || []);

_.forEach(not_in_dependencies_libs, function(d) {
  dependencies.push(d);
});

function getOutputDir() {
  return BUILD+env;
}

gulp.task('jade', function() {
  var config = {
    "production": env === PRODUCTION,
    "pretty": env === DEVELOPMENT,
    "locals": {}
  };

  var jsManifest      = env === PRODUCTION && USE_FINGERPRINTING ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/js/rev-manifest.json', "utf8"))) : {},
      //vendorManifest  = env === PRODUCTION ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/js-vendor/rev-manifest.json', "utf8"))) : {},
      cssManifest     = env === PRODUCTION && USE_FINGERPRINTING? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/css/rev-manifest.json', "utf8"))) : {},
      imagesManifest  = env === PRODUCTION && USE_FINGERPRINTING ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/images/rev-manifest.json', "utf8"))) : {};

  gulp.src(SRC+"/templates/"+jadeFiles+".jade")
    .pipe(duration('jade'))
    .pipe(jade(config).on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(jsManifest, { base:'assets/js/', prefix: 'assets/js/' })))
    //.pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(vendorManifest, { base:'assets/js/', prefix: 'assets/js/' })))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(cssManifest, { base:'assets/css/', prefix: 'assets/css/' })))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(imagesManifest, { base:'assets/images/', prefix: 'assets/images/' })))
    .pipe(gulpif(env === PRODUCTION, size()))
    .pipe(gulp.dest(getOutputDir())).on('end', function() {
      if (watching) livereload.changed('');
    });
});


gulp.task('coffee', function() {
  function myCoffee() {
    var bundler = browserify({debug: env === DEVELOPMENT})
      .add('./'+SRC+'/coffee/main.coffee');
    if (USE_VENDOR) bundler.external(dependencies);
    return bundler.bundle()
      .on('error', function(err) {
        console.log(err.message);
        this.end();
      })
      .pipe(duration('coffee'))
      .pipe(source('main.js'))
      .pipe(buffer())
      .pipe(gulpif(env === PRODUCTION, uglify()))
      .pipe(gulpif(env === PRODUCTION, size()))
      .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
      .pipe(gulp.dest(getOutputDir()+ASSETS+'/js'))
      .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
      .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/js')))
  }

  gulp.src('./'+SRC+'/coffee/main.coffee')
    .pipe(plumber())
    .pipe(myCoffee());
});

gulp.task('clean-js', function() {
  gulp.src(getOutputDir()+ASSETS+'/js', { read: false })
    .pipe(gulpif(env === PRODUCTION, vinylPaths(del).on('error', gutil.log)))
});
gulp.task('vendor', function() {
  gulp.src(dependencies)
    .pipe(gulpif(env === DEVELOPMENT, sourcemaps.init()))
    .pipe(concat('vendor.js'))
    .pipe(gulpif(env === DEVELOPMENT, sourcemaps.write()))
    .pipe(gulpif(env === PRODUCTION, uglify({mangle:false})))
    .pipe(gulpif(env === PRODUCTION, size()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/js'))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/js-vendor')))
});

gulp.task('autoVariables', function() {
  return gulp.src(MOCKUPS+'/ai/autovariables.scss')
    .pipe(changed(SRC+'/sass'))
    .pipe(gulp.dest(SRC+'/sass'))
});
gulp.task('spriteSass', function() {
  return gulp.src(MOCKUPS+'/sprite/sprites.scss')
    .pipe(changed(SRC+'/sass'))
    .pipe(gulp.dest(SRC+'/sass'))
});
gulp.task('sass', function() {
  var imagesManifest = env === PRODUCTION && USE_FINGERPRINTING ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/images/rev-manifest.json', "utf8"))) : {};
  var config = { errLogToConsole: true };

  if (env === DEVELOPMENT) {
    config.sourceComments = 'map';
  } else if (env === PRODUCTION) {
    config.outputStyle = 'compressed';
  }
  return gulp.src(SRC+'/sass/main.scss')
    .pipe(duration('sass'))
    .pipe(plumber())
    .pipe(gulpif(env === DEVELOPMENT, sourcemaps.init()))
    .pipe(sass(config).on('error', gutil.log))
    .pipe(gulpif(env === DEVELOPMENT, sourcemaps.write()))
    //.pipe(gulpif(env === PRODUCTION, prefix("last 2 versions", "> 1%", "ie 8", "ie 7", { cascade: true })))
    .pipe(gulpif(env === PRODUCTION, minifyCSS()))
    .pipe(gulpif(env === PRODUCTION, size()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(imagesManifest, { base:'../images/', prefix: '../images/' })))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/css'))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/css')))
});
gulp.task('editorSass', function() {
  var imagesManifest = env === PRODUCTION && USE_FINGERPRINTING ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/images/rev-manifest.json', "utf8"))) : {};
  var config = { errLogToConsole: true };

  if (env === DEVELOPMENT) {
    config.sourceComments = 'map';
  } else if (env === PRODUCTION) {
    config.outputStyle = 'compressed';
  }
  return gulp.src(SRC+'/sass/editor.scss')
    .pipe(duration('sass'))
    .pipe(plumber())
    .pipe(sass(config).on('error', gutil.log))
    //.pipe(gulpif(env === PRODUCTION, prefix("last 2 versions", "> 1%", "ie 8", "ie 7", { cascade: true })))
    .pipe(gulpif(env === PRODUCTION, minifyCSS()))
    .pipe(gulpif(env === PRODUCTION, size()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(imagesManifest, { base:'../images/', prefix: '../images/' })))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/css'))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/css')))
});
gulp.task('clean-css', function() {
  gulp.src(getOutputDir()+ASSETS+'/css', { read: false })
    .pipe(gulpif(env === PRODUCTION, vinylPaths(del).on('error', gutil.log)))
});
gulp.task('images',['clean-images'], function() {
  return gulp.src([MOCKUPS+'/{images,sprite}/**/*.{jpg,png,gif,svg}'])
    .pipe(duration('images'))
    .pipe(flatten().on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/images').on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/images')))
});
gulp.task('clean-images', function() {
  gulp.src([getOutputDir()+ASSETS+'/images'])
    .pipe(gulpif(env === PRODUCTION, vinylPaths(del)))
});
gulp.task('fonts', function() {
  return gulp.src(['node_modules/bootstrap/assets/fonts/**', MOCKUPS+"/fonts/*"])
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/fonts'))
});

gulp.task('watch', function() {
  watching = true;
  livereload.listen();
  gulp.watch(SRC+'/**/*.jade', ['jade']).on('error', gutil.log);
  gulp.watch(SRC+'/**/*.{js,coffee}', ['coffee']).on('error', gutil.log);
  gulp.watch(SRC+'/**/*.scss', ['sass']).on('error', gutil.log);
  gulp.watch(BUILD+env+'/assets/**').on('change', function(file) {
    console.log(file.path);
    livereload.changed(file.path);
  }).on('error', gutil.log);
});

gulp.task('connect', function() {
  useServer = true;
  gulp.src(BUILD+env)
    .pipe(webserver({
      host: '0.0.0.0',
      livereload: true,
      directoryListing: true,
      open: "index.html"
    }));
});

gulp.task('default', ['coffee', 'sass', 'jade']);
gulp.task('live', ['coffee', 'jade', 'sass', 'watch']);
gulp.task('editor', ['editorSass']);

gulp.task('build', function() {
  runSequence(['fonts','images','spriteSass','autoVariables'],['fonts','coffee','sass'],['jade']);
});
gulp.task('server', ['connect', 'watch']);
gulp.task('production', function() {
  env = PRODUCTION;
  runSequence(['clean-images', 'clean-js'],['images'],['fonts','coffee','sass'],['jade']);
});

//gulp watch --jade=filename