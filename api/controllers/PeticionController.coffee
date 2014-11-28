###*
PeticionController

@description :: Server-side logic for managing Peticions
@help        :: See http://links.sailsjs.org/docs/controllers
###
module.exports = {
  listActivas: (req, res) ->
    query = {}

    yo = User.getRolString req.user
    el = User.getRolStringOther req.user

    query[yo] = req.user.id
    query['cerrada'] = false
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

  countActivasNoLeidas: (req, res) ->
    Peticion.count({cliente: req.user.id, leida: false, cerrada: false}).exec (err, total) ->
      res.send
        total: total

  create: (req, res) ->
    Peticion.create(
      cliente: req.user.id
      proveedor: req.param 'proveedor'
    ).exec () ->
      res.send 200

  mensajes: (req, res) ->
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
