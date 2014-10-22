/**
 * Gps.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {

    autosubscribe: ['destroy', 'update', 'create'],
    connection: 'localDiskDb',
    autoPK: false,
    attributes: {
        userid: {
            model: 'sessionuser',
            primaryKey: true,
            autoincrement: false
        },
        latitude: 'string',
        longitude: 'string'
    }
};

