###*
Peticion.js

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###
module.exports =
  connection: 'mongo'
  autosubscribe: ['create', 'update', 'destroy']
  autoCreatedAt: true

  attributes:
    cliente:
      model: 'user'
    proveedor:
      model: 'user'
    cerrada:
      type: 'boolean'
      defaulsTo: false
    mensajes:
      collection: 'mensaje'
      via: 'peticion'
    leida:
      type: 'boolean'
      defaultsTo: false


