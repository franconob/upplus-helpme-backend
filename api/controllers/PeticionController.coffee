###*
PeticionController

@description :: Server-side logic for managing Peticions
@help        :: See http://links.sailsjs.org/docs/controllers
###
module.exports = {
  listActivas: (req, res) ->
    query = {}

    query[User.getRolString req.user] = req.user.id
    query['cerrada'] = false
    query['sort'] = 'createdAt DESC'

    Peticion.find(query).populate('proveedor').exec (err, peticiones) ->
      res.json
        peticiones: peticiones,
        200

  countActivasNoLeidas: (req, res) ->
    Peticion.count({cliente: req.user.id, leida: false, cerrada: false}).exec (err, total) ->
      res.send
        total: total
}
