var gulp = require('gulp'),
    jade = require('gulp-jade'),
    uglify = require('gulp-uglify'),
    sass = require('gulp-sass'),
    prefix = require('gulp-autoprefixer'),
    replace = require('gulp-replace'),
    rename = require("gulp-rename"),

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
var flattenArray = function(videos) {
  var array, i, len, video;
  array = videos.concat();
  for (i = 0, len = videos.length; i < len; i++) {
    video = videos[i];
    if ((video.relatedItems != null) && video.relatedItems.length > 0) {
      array = array.concat(this.flattenArray(video.relatedItems));
    }
  }
  return array;
};
var getAllRelatedItems = function(videos) {
  var array, i, len, ref, video;
  array = [];
  ref = videos;
  for (i = 0, len = ref.length; i < len; i++) {
    video = ref[i];
    if ((video.relatedItems != null) && video.relatedItems.length > 0) {
      array = array.concat(flattenArray(video.relatedItems));
    }
  }
  return array;
};
var getAllFilters = function(videos) {
  return getAllRelatedItems(videos).map(function(item) {
    return item.filters;
  });
};
var getAllFilterItems = function(filter, videos) {
  if (filter == null) {
    filter = 'location';
  }
  return getAllFilters(videos).map(function(item) {
    return item[filter];
  }).filter(function(value, index, self) {
    return self.indexOf(value) === index;
  });
};
var acc = function (t) {
  t = t.replace(/Ά/g, "Α");
  t = t.replace(/ά/g, "α");
  t = t.replace(/Έ/g, "Ε");
  t = t.replace(/έ/g, "ε");
  t = t.replace(/Ή/g, "Η");
  t = t.replace(/ή/g, "η");
  t = t.replace(/Ί/g, "Ι");
  t = t.replace(/Ϊ/g, "Ι");
  t = t.replace(/ί/g, "ι");
  t = t.replace(/ϊ/g, "ι");
  t = t.replace(/ΐ/g, "ι");
  t = t.replace(/Ό/g, "Ο");
  t = t.replace(/ό/g, "ο");
  t = t.replace(/Ύ/g, "Υ");
  t = t.replace(/Ϋ/g, "Υ");
  t = t.replace(/ύ/g, "υ");
  t = t.replace(/ϋ/g, "υ");
  t = t.replace(/ΰ/g, "υ");
  t = t.replace(/Ώ/g, "Ω");
  t = t.replace(/ώ/g, "ω");
  return t;
};

function getOutputDir() {
  return BUILD+env;
}

gulp.task('jade', function() {
  var config = {
    "production": env === PRODUCTION,
    "pretty": env === DEVELOPMENT,
    "locals": {
      'production': env === PRODUCTION
    }
  };

  var jsManifest      = env === PRODUCTION && USE_FINGERPRINTING ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/js/rev-manifest.json', "utf8"))) : {},
      //vendorManifest  = env === PRODUCTION ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/js-vendor/rev-manifest.json', "utf8"))) : {},
      cssManifest     = env === PRODUCTION && USE_FINGERPRINTING? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/css/rev-manifest.json', "utf8"))) : {},
      imagesManifest  = env === PRODUCTION && USE_FINGERPRINTING ? (JSON.parse(fs.readFileSync("./"+BUILD+'/rev/images/rev-manifest.json', "utf8"))) : {};

  gulp.src([SRC+"/templates/index.jade"])
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
  var langsDir = "/json/";
  var langs = fs.readdirSync("./"+SRC+langsDir);
  langs.forEach(function(item) {
    var lang = item.split(".")[0];
    var config = {
      "production": env === PRODUCTION,
      "pretty": env === DEVELOPMENT,
      "locals": {
        'flattenArray': flattenArray,
        'getAllRelatedItems': getAllRelatedItems,
        'getAllFilterItems': getAllFilterItems,
        'acc': acc,
        'lang': lang,
        'data': JSON.parse(fs.readFileSync("./"+SRC+langsDir+item, "utf8")),
        'production': env === PRODUCTION
      }
    };
    gulp.src([SRC+"/templates/doc.jade"])
      .pipe(duration('jade'))
      .pipe(jade(config).on('error', gutil.log))
      .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(jsManifest, { base:'assets/js/', prefix: 'assets/js/' })))
      //.pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(vendorManifest, { base:'assets/js/', prefix: 'assets/js/' })))
      .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(cssManifest, { base:'assets/css/', prefix: 'assets/css/' })))
      .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, fingerprint(imagesManifest, { base:'assets/images/', prefix: 'assets/images/' })))
      .pipe(gulpif(env === PRODUCTION, size()))
      .pipe(rename("index.html"))
      .pipe(gulp.dest(getOutputDir()+"/"+lang)).on('end', function() {
        if (watching) livereload.changed('');
      });
  })

});


gulp.task('coffee', function() {
  function myCoffee() {
    var bundler = browserify({debug: env === DEVELOPMENT})
      .add('./'+SRC+'/coffee/main.coffee');
    if (USE_VENDOR) bundler.external(dependencies);
    return bundler.bundle()
      .on('error', function(err) {
        console.log(err.message);
        // this.end();
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
    .pipe(gulpif(env === PRODUCTION, replace(/..\/images\/sprites/g, 'assets\/images\/sprites')))
    .pipe(gulpif(env === PRODUCTION, replace(/..\/fonts\//g, 'assets\/fonts\/')))
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
gulp.task('images', function() {
  return gulp.src([MOCKUPS+'/{images,sprite}/**/*.{jpg,png,gif,svg,ico}'])
    .pipe(duration('images'))
    .pipe(flatten().on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/images').on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/images')))
});
gulp.task('sounds', function() {
  return gulp.src([MOCKUPS+'/sounds/*.mp3'])
    .pipe(duration('sounds'))
    .pipe(flatten().on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/sounds').on('error', gutil.log))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, rev.manifest()))
    .pipe(gulpif(env === PRODUCTION && USE_FINGERPRINTING, gulp.dest(BUILD+'/rev/sounds')))
});
gulp.task('clean-images', function() {
  gulp.src([getOutputDir()+ASSETS+'/images'])
    .pipe(gulpif(env === PRODUCTION, vinylPaths(del)))
});
gulp.task('fonts', function() {
  return gulp.src(['node_modules/bootstrap/assets/fonts/**', MOCKUPS+"/fonts/*"])
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/fonts'))
});
gulp.task('mainifest', function() {
  return gulp.src([SRC+"/templates/mainfest.json"])
    .pipe(gulp.dest(getOutputDir()))
});

gulp.task('watch', function() {
  watching = true;
  livereload.listen();
  gulp.watch(SRC+'/**/*.{jade,json}', ['jade']).on('error', gutil.log);
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
  runSequence(['fonts','mainifest','images','sounds','spriteSass','autoVariables'],['fonts','coffee','sass'],['jade']);
});
gulp.task('server', ['connect', 'watch']);
gulp.task('production', function() {
  env = PRODUCTION;
  runSequence(['clean-js'],['images','sounds','mainifest'],['fonts','coffee','sass'],['jade']);
});

//gulp watch --jade=filename
