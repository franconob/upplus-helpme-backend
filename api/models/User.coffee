key_del = require("key-del")
bcrypt = require("bcryptjs")
module.exports =
  connection: "mongo"
  tableName: "user"
  autosubscribe: ["update", "delete"],
  attributes:
    nombre: "string"
    apellido: "string"
    telefono: "string"
    ciudad: "string"
    rol: "integer"
    correo:
      type: "email"
      unique: true
    claveInicial: "string"
    clave: "string"
    perfilResumen: "text"
    imagen: "string"
    ultimoLogin: "datetime"
    activo:
      type: "boolean"
      defaultsTo: true
    token: "string"
    socketId: "string"
    online:
      type: "boolean"
      defaultsTo: false

    validatePassword: (password, done) ->
      bcrypt.compare password, @clave, (err, res) ->
        return done(err, res) if err

        done(null, res)

    toJSON: () ->
      object = @toObject()

      if object.clave
        delete object.clave

        return object

  beforeCreate: (values, cb) ->
    bcrypt.hash values.clave, 10, (err, hash) ->
      return cb(err) if err

      values.clave = hash
      console.log values

      cb()

