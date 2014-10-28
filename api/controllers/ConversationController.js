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
      or: [
        {from: req.param('from')},
        {to: req.param('from')}
      ]
    }).populate('to').populate('from').exec(function (err, conversations) {
      if (err) {
        res.send(500, err);
      }
      if (conversations) {
        data = _.filter(conversations, function (conversation) {
          return conversation.from.userid == req.param('to') || conversation.to.userid == req.param('to');
        });

        var response = [];

        async.forEach(data, function (conversation, callback) {
          Conversation.findOne(conversation.id).exec(function (err, conv) {
            conv.populate(function () {
              response.push(conv);
              callback();
            })
          })
        }, function () {
          res.send(response);
        })

      }

    });
  },

  list: function (req, res) {
    var data = [];

    Conversation.find({
      or: [
        {from: req.user.id},
        {to: req.user.id}
      ]
    }).exec(function(err, conversations) {
      if(conversations) {
        var uniqueConversations = _.indexBy(conversations, 'from');
        console.log(uniqueConversations);
      }
    })
  }
};

