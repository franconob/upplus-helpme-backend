###*
Conversation.js

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###
module.exports =
  connection: "localDiskDb"
  autoCreatedAt: true
  attributes:
    id:
      type: "integer"
      primaryKey: true
      autoIncrement: true

    from:
      type: "integer"

    to:
      type: "integer"

    message: "text"
    sent:
      type: "boolean"
      defaultsTo: false

    received:
      type: "boolean"
      defaultsTo: false

    read:
      type: "boolean"
      defaultsTo: false

    type:
      type: "string"
      enum: [
        "text"
        "image"
      ]
      defaultsTo: "text"

    populateSessionUser: (cb) ->
      self = this
      SessionUser.findOne(self.from).exec (err, from) ->
        self.from = from
        SessionUser.findOne(self.to).exec (err2, to) ->
          self.to = to
          cb()

        return

      return

    populateProfiles: (cb) ->
      self = this
      Profile.findOne(self.from.userid).exec (err, profile) ->
        profile = profile.toJSON()
        self.from.profile = profile
        Profile.findOne(self.to.userid).exec (err, profileto) ->
          profileto = profileto.toJSON()
          self.to.profile = profileto
          cb self

        return

      return

    populate: (cb) ->
      self = this
      unless _.isObject(self.from)
        self.populateSessionUser ->
          self.populateProfiles ->
            cb()

          return

      else
        @populateProfiles ->
          cb()

      return
