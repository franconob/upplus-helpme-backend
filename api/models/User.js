var key_del = require('key-del');
var bcrypt = require('bcryptjs');

module.exports = {

    connection: 'mysql',
    tableName: 'yswzk_users',
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
            bcrypt.compare(password, this.password, function(err, res) {
                if(err) {
                    return done(err, res);
                }
                return done(null, res);
            });
        }
    }
};