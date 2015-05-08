Package.describe({
  name: 'oaf:autoform-select',
  version: '0.2.0',
  // Brief, one-line summary of the package.
  summary: 'Provides a better select input for autoform',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/oafmedium/meteor-autoform-select',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: null //'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('stylus');
  api.use('reactive-var');
  api.use('templating@1.0.0');
  api.use('blaze@2.0.0');
  api.use('aldeed:autoform@4.0.0 || 5.0.0');
  api.addFiles([
    'bluractive.coffee',
    'oafselect.coffee',
    'afoafselect.html',
    'afoafselect.coffee',
    'afoafselect.styl',
    'autoform.coffee',
  ],'client');
});
