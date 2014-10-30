/**
 * SessionUserController
 *
 * @description :: Server-side logic for managing sessionusers
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {

  message: function (req, res) {
    SessionUser.findOne(req.param('to')).exec(function (err, suser) {
      if (!suser) {
        SessionUser.create({
          userid: req.param('to'),
          online: false
        }).exec(function (err, createdUser) {
          Conversation.create({
            from: req.user.id,
            to: createdUser.userid,
            message: req.param('message'),
            type: req.param('type'),
            sent: true
          }).exec(function (err, conversation) {
            Conversation.subscribe(req, conversation, 'update');
            Conversation.findOne(conversation.id).exec(function (err, conv) {
              conv.populate(function () {
                SessionUser.message(req.param('to'), conv, req.socket);
                res.send(conv);
              })
            });
          });
        })
      } else {
        Conversation.create({
          from: req.user.id,
          to: req.param('to'),
          message: req.param('message'),
          type: req.param('type'),
          sent: true
        }).exec(function (err, conversation) {
          Conversation.subscribe(req, conversation, 'update');
          Conversation.findOne(conversation.id).exec(function (err, conv) {
            conv.populate(function () {
              SessionUser.message(req.param('to'), conv, req.socket);
              res.send(conv);
            })
          });
        });
      }
    })

  },

  list: function (req, res) {
    var haveSession = [];
    SessionUser.find({userid: {'!': req.user.id}}).exec(function (err, sessionUsers) {
        User.find({
          limit: 10,
          skip: req.param('skip') || 0,
          where: {id: {'!': req.user.id}}
        }).populate('profiles').populate('extras').exec(function (err, users) {
          if (sessionUsers.length > 0) {
            var found;
            _.each(sessionUsers, function (suser) {
              found = _.find(users, {id: suser.userid});
              suser.juser = found.toJSON();
              haveSession.push(suser);
            });

          }
          var response = [];
          _.each(users, function (user) {

            var alreadyIn;

            alreadyIn = _.find(haveSession, function (suser) {
              return suser.userid == user.id
            });

            if (!alreadyIn) {
              response.push({
                userid: user.id,
                name: user.name,
                juser: user,
                online: false
              });
            }
          });
          res.send(_.sortBy(response.concat(haveSession), {online: false}));

        });
      }
    )
  },

  get: function (req, res) {
    SessionUser.findWithJUser(req.param('id'), function (result) {
      res.json(result);
    });
  }


}
;

