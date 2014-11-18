###*
Conversation.js

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###
module.exports =
  connection: "mongo"
  autoCreatedAt: true
  attributes:
    usuario:
      model: "user"

    mensaje: "text"

    enviado:
      type: "boolean"
      defaultsTo: false

    recibido:
      type: "boolean"
      defaultsTo: false

    leido:
      type: "boolean"
      defaultsTo: false

    tipo:
      type: "string"
      enum: [
        "text"
        "image"
      ]
      defaultsTo: "text"

    peticion:
      model: 'peticion'
