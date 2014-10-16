
module.exports = function (req, res, next) {
    // currently just using url query for testing
    // this will actually come from the http header
    var tokenValue;
    if(req.isSocket) {
        tokenValue = req.socket.manager.handshaken[req.socket.id].token;
    } else {
    	tokenValue = req.headers["authorization"];
    }

    // validate we have all params
    if (!tokenValue) {
        return res.send(401);
    }
    
    // validate token and set req.user if we have a valid token
    UserManager.authenticateUserToken(tokenValue, function (err, user) {
        if (err) {
            if (err.message === 'invalid-token') return res.send(401);

            return res.send(500);
        }
        if (!user) return res.send(404);
        
        req.user = user;

        next();
    });
};