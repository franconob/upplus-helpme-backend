/**
 * Compile CoffeeScript files to JavaScript.
 *
 * ---------------------------------------------------------------
 *
 * Compiles coffeeScript files from `assest/js` into Javascript and places them into
 * `.tmp/public/js` directory.
 *
 * For usage docs see:
 * 		https://github.com/gruntjs/grunt-contrib-coffee
 */
module.exports = function(grunt) {

	grunt.config.set('coffee', {
		dev: {
			options: {
				bare: true,
				sourceMap: true,
				sourceRoot: './'
			},
			files: [{
				expand: true,
				cwd: 'assets/js/',
				src: ['**/*.coffee'],
				dest: '.tmp/public/js/',
				ext: '.js'
			}, {
				expand: true,
				cwd: 'assets/js/',
				src: ['**/*.coffee'],
				dest: '.tmp/public/js/',
				ext: '.js'
			}, {
        expand: true,
        cwd: 'api/controllers/',
        src: ['*.coffee'],
        dest: 'api/controllers/',
        ext: '.js'
      }, {
        expand: true,
        cwd: 'api/models/',
        src: ['*.coffee'],
        dest: 'api/models/',
        ext: '.js'
      }, {
        expand: true,
        cwd: 'api/services/',
        src: ['*.coffee'],
        dest: 'api/services/',
        ext: '.js'
      }]
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
};
