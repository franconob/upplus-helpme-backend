/**
 * GpsController
 *
 * @description :: Server-side logic for managing Gps
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
    receive: function (req, res) {

        var data = {
            latitude: req.param('position').coords.latitude,
            longitude: req.param('position').coords.longitude

        };

        Gps.update({userid: req.param('from')}, data).exec(function (err, gps) {
            if (err) {
                throw err;
            }
            if (gps.length == 0) {
                Gps.create(_.merge(data, {userid: req.param('from')})).exec(function (err, gps) {
                    Gps.publishCreate(_.merge(gps, {user: req.param('from')}), req.socket);
                    res.send(200);
                });
            } else {
                Gps.publishUpdate(gps[0].id, _.merge(gps[0], {user: req.param('from')}), req.socket);
            }
            res.send(200);
        });

    }
};

