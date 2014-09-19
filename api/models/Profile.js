/**
 * Profile.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {
    connection: 'mysql',
    tableName: 'j3_community_users',
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
        }
    }
};

