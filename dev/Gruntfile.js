/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    meta: {
      banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '* http://wehaverhythm.com/; */'
    },

    concat: {
      dist: {
        src: ['<banner:meta.banner>'
          , 'libs/gs/plugins/CSSPlugin.js'
          , 'libs/gs/easing/EasePack.js'
          , 'libs/gs/TweenLite.js'
          , 'rhythm/Utils.js'
          , 'rhythm/GlobalAbatement.js'
          , 'rhythm/Circle.js'
          , 'rhythm/Wedge.js'
          , 'rhythm/bookingvisualiser/BookingVisualiser.js'
          , 'rhythm/filtercounter/FilterCounter.js'
          , 'rhythm/staggeropacity/StaggerOpacity.js'
        ],
        dest: './uncompressed/<%=pkg.name%>_<%=pkg.version%>_uncompressed.js'
      }
    },

    removelogging: {
      dist: {
        src: '<%= concat.dist.dest %>',
        dest: '<%= concat.dist.dest %>',

        options: {
          // see below for options. this is optional.
        }
      }
    },

    uglify: {
      options: {
        mangle: true,
        report: 'gzip',
        // the banner is inserted at the top of the output
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
      },

      my_target: {
        files: {
          '../www/js/<%=pkg.name%>_<%=pkg.version%>.min.js': ['<%= removelogging.dist.dest %>']
        }
      }
    },

    //http://www.jshint.com/docs/#options
    jshint: {
      files: ['gruntfile.js', 'rhythm/**/*.js', 'rhythm/terry/**/*.js'],
      options: {
        // options here to override JSHint defaults
        laxcomma:true,
        curly: true,
        eqeqeq: true,
        unused: false,

        globals: {
          module: true,
          document: true,
          $: true, Debug:true, RHYTHM:true, requestAnimFrame:true, self:true, io:true, CanvasRenderingContext2D:true, escape:true, unescape:true, jQuery: true, console:true, Modernizr:true, TweenMax:true, TweenLite:true, TimelineMax:true, LOVE:true, TEDDYBEARS:true, Back:true, Quad:true, Linear:true, alert:true, swfobject:true
        }
      }
    },

    

    watch: {
      files: ['<%= jshint.files %>'],
      tasks: ['jshint', 'qunit']
    }
  });
  
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks("grunt-remove-logging");
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task.
  grunt.registerTask('default', ['jshint', 'removelogging', 'concat', 'uglify']);

};
