/**
 * Community_fields.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {
    connection: 'mysql',
    tableName: 'j3_community_fields_values',
    attributes: {
        user: {
            model: 'user',
            columnName: 'user_id'
        }
    }
};

