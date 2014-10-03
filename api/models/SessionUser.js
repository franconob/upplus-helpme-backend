/**
 * SessionUser.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {

    connection: 'localDiskDb',
    autoPK: false,
    attributes: {
        socketId: 'string',
        name: 'string',
        userid: {
            type: 'integer',
            primaryKey: true,
            autoIncrement: false
        },
        conversations: {
            collection: 'conversation',
            via: 'from'
        }
    },

    findWithJUser: function (query, cb) {
        var populatedSUsers = [];
        this.find(query).exec(function (err, susers) {
            if (_.isArray(susers)) {
                var usersid = _.map(susers, function (user) {
                    return user.userid;
                });
            } else {
                usersid = susers.userid;
            }

            User.find(usersid).populate('profiles').exec(function (_err, _jusers) {
                var populatedSUser = {};
                if (_.isArray(_jusers)) {
                    _.each(_jusers, function (_juser) {
                        var suser = _.find(susers, function (user) {
                            return user.userid == _juser.id;
                        });
                        suser.juser = _juser.toJSON();
                        populatedSUser = suser;
                        populatedSUsers.push(suser);
                    })
                } else {
                    susers.juser = _jusers.toJSON();
                    populatedSUser = susers;
                    populatedSUsers.push(populatedSUser);
                }

                return cb(populatedSUsers);

            });
        })
    }
};

