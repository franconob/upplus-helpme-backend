var md5 = require('md5');
var key_del = require('key-del');

module.exports = {

    connection: 'mysql',
    tableName: 'j3_users',
    schema: true,
    attributes: {

        id: {
            type: 'integer',
            primaryKey: true
        },
        name: {
            type: 'string'
        },
        username: 'string',
        email: 'string',
        password: 'string',
        profiles: {
            collection: 'profile',
            via: 'user'
        },
        extras: {
            collection: 'community_fields',
            via: 'user'
        },

        toJSON: function() {
            var object = this.toObject();
            object = key_del(object, 'password');
            if(object.profiles) {
                object.profile = object.profiles[0];
                object = key_del(object, 'profiles');
            }

            if(object.extras) {
                object.extras = _.merge.apply(null, object.extras);
            }

            return object;
        },

        validatePassword: function (password, done) {
            var hash = this.password.split(':');
            var salt = hash[1];

            var encPasswd = md5.digest_s(password + salt);

            if(encPasswd + ':' + salt == this.password) {
                return done(null, true)
            } else {
                return done(null, false);
            }
        }
    }
};