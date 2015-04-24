Package.describe({
  name: 'oaf:autoform-select',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
  api.use('coffeescript');
  api.use('stylus');
  api.use('reactive-var');
  api.use('templating@1.0.0');
  api.use('blaze@2.0.0');
  api.use('aldeed:autoform@5.0.0');
  api.addFiles([
    'oafselect/oafselect.html',
    'oafselect/oafselect.coffee',
    'oafselect/oafselect.styl',

    'oafselect/selected_item/selected_item.html',
    'oafselect/selected_item/selected_item.coffee',
    'oafselect/dropdown_item/dropdown_item.html',
    'oafselect/dropdown_item/dropdown_item.coffee',
  ],'client');
});
