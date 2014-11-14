###*
GpsController

@description :: Server-side logic for managing Gps
@help        :: See http://links.sailsjs.org/docs/controllers
###
module.exports = receive: (req, res) ->
  data =
    latitude: req.param("position").coords.latitude
    longitude: req.param("position").coords.longitude

  Gps.update(
    userid: req.param("from")
  , data).exec (err, gps) ->
    throw err  if err
    if gps.length is 0
      Gps.create(_.merge(data,
        userid: req.param("from")
      )).exec (err, gps) ->
        Gps.publishCreate _.merge(gps,
          user: req.param("from")
        ), req.socket
        res.send 200
        return

    else
      Gps.publishUpdate gps[0].id, _.merge(gps[0],
        user: req.param("from")
      ), req.socket
    res.send 200
    return

  return
