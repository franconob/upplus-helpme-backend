/**
 * Gps.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {

    autosubscribe: ['destroy', 'update', 'create'],
    connection: 'localDiskDb',
    attributes: {
        userid: {
            model: 'sessionuser'
        },
        latitude: 'string',
        longitude: 'string'
    }
};

