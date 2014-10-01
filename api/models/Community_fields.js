/**
 * Community_fields.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/#!documentation/models
 */

module.exports = {
    connection: 'mysql',
    tableName: 'j3_community_fields_values',
    schema: true,
    attributes: {
        user: {
            model: 'user',
            columnName: 'user_id'
        },

        toJSON: function() {
            var object = this.toObject();

            if(object.field_id == 11) {
                object.country = object.value;
            }

            if(object.field_id == 10) {
                object.city = object.value;
            }

            if(object.field_id == 9) {
                object.state = object.value;
            }

            if(object.field_id == 56) {
                object.areaPractica = object.value;
            }

            if(object.field_id == 4) {
                object.acercaDeMi = object.value;
            }

            return _.pick(object, ['city', 'state', 'country', 'areaPractica', 'acercaDeMi']);

        }
    }
};

