/**
 * Conversation.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {
  connection: 'localDiskDb',
  autoCreatedAt: true,
  attributes: {
    id: {
      type: 'integer',
      primaryKey: true,
      autoIncrement: true
    },
    from: {
      model: 'sessionuser'
    },
    to: {
      model: 'sessionuser'
    },
    message: 'text',
    read: {
      type: 'boolean',
      defaultsTo: false
    },
    type: {
      type: 'string',
      enum: ['text', 'image'],
      defaultsTo: 'text'
    },

    populateSessionUser: function (cb) {
      var self = this;
      SessionUser.findOne(self.from).exec(function (err, from) {
        self.from = from;
        SessionUser.findOne(self.to).exec(function (err2, to) {
          self.to = to;

          return cb();
        });
      });
    },

    populateProfiles: function (cb) {
      var self = this;
      Profile.findOne(self.from.userid).exec(function (err, profile) {
        profile = profile.toJSON();
        self.from.profile = profile;
        Profile.findOne(self.to.userid).exec(function (err, profileto) {
          profileto = profileto.toJSON();
          self.to.profile = profileto;
          return cb(self);
        });
      })
    },

    populate: function (cb) {
      var self = this;
      if (!_.isObject(self.from)) {
        self.populateSessionUser(function () {
          self.populateProfiles(function () {
            return cb();
          })
        })
      } else {
        this.populateProfiles(function () {
          return cb();
        })
      }

    }
  }
};

