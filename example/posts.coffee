@Posts = new Mongo.Collection 'posts'
@Tags = new Mongo.Collection 'tags'

Tags.attachSchema
  name:
    type: String

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
          value: Meteor.uuid()
  tags:
    type: [String]
    optional: true
    autoform:
      type: 'oafSelect'
      multiple: true
      options: ->
        Tags.find().map (tag) ->
          label: tag.name
          value: tag._id
      oafSelectOptions:
        create: (value) ->
          value: Tags.insert name: value
          label: value
        createText: (value) -> "add #{value}"

# if Meteor.isServer
#   Meteor.startup ->
#     for i in [1...20]
#       Tags.insert name: Fake.word()
