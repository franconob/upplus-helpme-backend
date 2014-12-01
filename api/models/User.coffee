bcrypt = require("bcryptjs")
module.exports =
  connection: "mongo"
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

      delete object.clave
      delete object.auth
      delete object.socketId
      delete object.previousSocketId

      object.fullName = object.apellido + " " + object.nombre

      return object

  beforeCreate: (values, cb) ->
    bcrypt.hash values.clave, 10, (err, hash) ->
      return cb(err) if err

      values.clave = hash
      delete values.r_clave

      cb()

  getRolString: (user) ->
    switch user.rol
      when 2 then 'cliente'
      when 3 then 'proveedor'

  getRolStringOther: (user) ->
    switch user.rol
      when 2 then 'proveedor'
      when 3 then 'cliente'

