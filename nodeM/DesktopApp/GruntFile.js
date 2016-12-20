/*var NwBuilder = require('nw-builder');
var nw = new NwBuilder({
  files: ['./**'], // simple-glob format
  platforms: ['win64'], // change this to 'win' for/on windows   //osx
  version: '0.14.5'
});

nw.build().then(function () {
  console.log('all done!');
}).catch(function (error) {
  console.error(error);
});*/



module.exports = function(grunt) {

  grunt.initConfig({
    nwjs: {
      options: {
        version: '0.14.5',
        buildDir: './build', // Where the build version of my NW.js app is saved
        //macIcns: './icon.icns', // Path to the Mac icon file
        platforms: ['win64'], // These are the platforms that we want to build
        flavor: 'normal'
      },
      src: './**' // Your NW.js app
    },
  });

  grunt.loadNpmTasks('grunt-nw-builder');
  grunt.registerTask('default', ['nwjs']);
};