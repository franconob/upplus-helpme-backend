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
                SessionUser.publishCreate(user, req.socket);
                res.send(user);
            })

        });
    },

    message: function (req, res) {
        SessionUser.findOne(req.user.id).exec(function (err, sender) {
            // Publish a message to that user's "room".  In our app, the only subscriber to that
            // room will be the socket that the user is on (subscription occurs in the onConnect
            // method of config/sockets.js), so only they will get this message.
            SessionUser.message(req.param('to'), {from: sender, msg: req.param('msg')}, req.socket);
            res.send(200);
        })
    },

    list: function (req, res) {
        var data = [];
        SessionUser.find({userid: {'!': req.user.id}}).exec(function (err, users) {
            var usersid = _.map(users, function (user) {
                return user.userid;
            });
            User.find({id: usersid}).populate('profiles').exec(function (err, jusers) {
                _.each(jusers, function (juser) {
                    var suser = _.find(users, function (user) {
                        return user.userid == juser.id;
                    });
                    suser.juser = juser;
                    data.push(suser);
                });
                return res.json(data);
            });
        });
    }
};

