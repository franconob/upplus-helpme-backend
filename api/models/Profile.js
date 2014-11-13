/**
 * Profile.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {
    connection: 'mysql',
    tableName: 'yswzk_community_users',
    schema: true,
    attributes: {
        userid: {
            type: 'integer',
            primaryKey: true
        },
        avatar: {
            type: 'string'
        },
        user: {
            model: 'user',
            columnName: 'userid'
        },

        toJSON: function() {
            var object = this.toObject();

            object.avatar = 'http://www.upplus.es/' + object.avatar;
            delete object.params;

            return object;
        }
    }
};

