###*
Gps.js

@description :: TODO: You might write a short summary of how this model works and what it represents here.
@docs        :: http://sailsjs.org/#!documentation/models
###
module.exports =
  autosubscribe: [
    "destroy"
    "update"
    "create"
  ]
  connection: "mongo"
  autoPK: false
  attributes:
    userid:
      model: "user"
      primaryKey: true
      autoIncrement: false

    latitude: "string"
    longitude: "string"
