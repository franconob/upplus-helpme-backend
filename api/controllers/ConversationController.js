/**
 * ConversationController
 *
 * @description :: Server-side logic for managing conversations
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

var async = require('async');

module.exports = {

  /** get /conversations/:from/:to */
  get: function (req, res) {
    var data = [];
    Conversation.find({
      where: {
        or: [
          {from: req.param('from')},
          {to: req.param('from')}
        ]
      },
      sort: 'createdAt ASC'
    }).populate('to').populate('from').exec(function (err, conversations) {
      if (err) {
        res.send(500, err);
      }
      if (conversations) {
        data = _.filter(conversations, function (conversation) {
          if (conversation.to) {
            return conversation.from.userid == req.param('to') || conversation.to.userid == req.param('to');
          }
          return false;
        });

        var response = [];
        Conversation.update(_.pluck(conversations, 'id'), {read: true}).exec(function (err, updatedConversations) {
          async.forEach(data, function (conversation, callback) {
            Conversation.findOne(conversation.id).exec(function (err, conv) {
              conv.populate(function () {
                response.push(conv);
                callback();
              })
            })
          }, function () {
            res.send(_.sortBy(response, function (conversation) {
              var date = new Date(conversation.createdAt);
              return date.getTime();
            }));
          })
        });
      }
    });
  },

  list: function (req, res) {
    var data = {};

    Conversation.find({
      where: {
        or: [
          {from: req.user.id},
          {to: req.user.id}
        ]
      },
      sort: 'id ASC'
    }).exec(function (err, conversations) {
        if (conversations) {
          async.forEach(conversations, function (conversation, callback) {
              // Si el destinatario soy yo
              if (conversation.to == req.user.id) {
                if (typeof data[conversation.from] === "undefined" || conversation.createdAt > data[conversation.from]) {
                  User.findOne(conversation.from).populate('profiles').populate('extras').exec(function (err, user) {
                    data[conversation.from] = {
                      message: conversation.message,
                      user: user.toJSON(),
                      type: conversation.type,
                      createdAt: conversation.createdAt,
                      read: conversation.read,
                      tome: true
                    };
                    callback();
                  });
                }
              }
              if (conversation.from == req.user.id) {
                if (typeof data[conversation.to] === "undefined" || conversation.createdAt > data[conversation.to]) {
                  User.findOne(conversation.to).populate('profiles').populate('extras').exec(function (err, user) {
                    data[conversation.to] = {
                      message: conversation.message,
                      user: user.toJSON(),
                      type: conversation.type,
                      createdAt: conversation.createdAt,
                      read: conversation.read,
                      tome: false
                    };
                    callback();
                  });
                }
              }
            }, function () {
              return res.send(_.sortBy(data, function (conv) {
                return new Date(conv.createdAt);
              }).reverse());
            }
          )
        }
      }
    );
  },

  updateReceived: function (req, res) {
    var conversationId = req.param('id');

    Conversation.update(conversationId, {received: true}).exec(function (err, updatedConversation) {
      Conversation.publishUpdate(conversationId, updatedConversation[0], req.socket);

      res.send(200);
    })
  }
};
