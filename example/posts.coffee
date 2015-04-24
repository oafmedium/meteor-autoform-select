@Posts = new Mongo.Collection 'posts'

Posts.attachSchema
  name:
    type: String
  author:
    type: String
    autoform:
      type: 'oafSelect'
      options: ->
        for i in [1...10]
          label: Fake.user().fullname
          value: Meteor.uuid
  tags:
    type: [String]
    optional: true
    autoform:
      type: 'oafSelect'
      options: ->
        for i in [1...20]
          Fake.word()
