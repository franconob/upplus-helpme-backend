###*
PeticionController

@description :: Server-side logic for managing Peticions
@help        :: See http://links.sailsjs.org/docs/controllers
###
module.exports = {
  list: (req, res) ->
    query = {}

    yo = User.getRolString req.user
    el = User.getRolStringOther req.user

    query[yo] = req.user.id
    query['cerrada'] = if req.query.activa is '0' then true else false;
    query['sort'] = 'createdAt DESC'

    Peticion.find(query).populate(el).populate('mensajes',
      sort: 'createdAt DESC',
      limit: 1)
    .exec (err, peticiones) ->
      peticiones = peticiones.map (peticion) ->
        peticion.el = peticion[el]
        delete peticion[yo]
        delete peticion[el]

        peticion.ultimoMensaje = peticion.mensajes.pop()
        delete peticion.mensajes

        return peticion

      res.json
        peticiones: peticiones,
        200

  contadores: (req, res) ->
    query = {}
    query[User.getRolString req.user] = req.user.id
    query['leida'] = query['cerrada'] = false
    populate = if User.getRolString(req.user) == 'cliente' then 'proveedor' else 'cliente'

    Peticion.findOne(req.param('id')).populate('mensajes').populate(populate).exec (err, peticion) ->
      _.each peticion.mensajes, (mensaje) ->
        if mensaje.usuario is req.user.id
          mensaje.avatar = req.user.imagen
        else
          mensaje.avatar = peticion[populate].imagen

        if not mensaje.recibido
          mensaje.recibido = mensaje.leido = true
          mensaje.save () ->
            Mensaje.publishUpdate mensaje.id, mensaje, req.socket

      peticion.el = peticion[populate].toJSON()
      delete peticion[populate]

      res.send peticion

  enviarMensaje: (req, res) ->
    Peticion.findOne(req.param('id')).exec (err, peticion) ->
      peticion.mensajes.add
        mensaje: req.param('mensaje')
        usuario: req.user.id
        enviado: true
        tipo: req.param('tipo')

      peticion.save (err, pet) ->
        throw err if err
        mensaje = pet.mensajes.pop()

        Mensaje.subscribe(req.socket, mensaje, 'update')

        Peticion.message(pet.id, mensaje, req.socket);
        res.send mensaje

  mensajeLeido: (req, res) ->
    Mensaje.update req.param('mensajeid'), {recibido: true, leido: true}, (err, mensaje) ->
      Mensaje.publishUpdate mensaje[0].id, mensaje[0], req.socket
      res.send 200
}
