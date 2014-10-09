/**
 * SessionUserController
 *
 * @description :: Server-side logic for managing sessionusers
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
    create: function (req, res) {
        var suser = req.body.user;
        suser.socketId = sails.sockets.id(req.socket);

        SessionUser.create(suser).exec(function (err, user) {
            if (err) {
                throw err;
            }

            User.findOne(user.userid).exec(function (err, juser) {
                user.juser = juser;
                res.send(user);
            })

        });
    },

    message: function (req, res) {
        Conversation.create({from: req.user.id, to: req.param('to'), message: req.param('message')}).exec(function (err, conversation) {
            Conversation.findOne(conversation.id).exec(function (err, conv) {
                conv.populate(function () {
                    SessionUser.message(req.param('to'), conv, req.socket);
                    res.send(conv);
                })
            });
        });
    },

    list: function (req, res) {
        SessionUser.findWithJUser({userid: {'!': req.user.id}}, function (result) {
            res.json(result);
        });
    },

    get: function (req, res) {
        SessionUser.findWithJUser(req.param('id'), function (result) {
            res.json(result);
        });
    }
};

