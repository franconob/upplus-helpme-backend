/**
 * SessionUserController
 *
 * @description :: Server-side logic for managing sessionusers
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {

    message: function (req, res) {
        Conversation.create({from: req.user.id, to: req.param('to'), message: req.param('message'), type: req.param('type')}).exec(function (err, conversation) {
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

