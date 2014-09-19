var md5 = require('md5');

module.exports = {

    connection: 'mysql',
    tableName: 'j3_users',
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