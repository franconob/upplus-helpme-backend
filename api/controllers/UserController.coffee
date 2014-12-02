isEmpty = (str) ->
  not str or str.length is 0

module.exports =
  get: (req, res) ->
    User.findOne(req.param("id")).exec (err, user) ->
      res.send user

    return

  create: (req, res) ->
    UserManager.createUser req.param('registro')
    , (err, user) ->
      return res.send(500)  if err
      return res.send("This username is already in use", 400)  unless user
      UserManager.generateUserToken user, (err, token) ->
        return res.send(500)  if err
        res.send token, 201

      return

    return

  update: (req, res) ->
    UserManager.savePerfil req.param('id'), req.param('perfil'), (user, err) ->
      res.send 200


  list: (req, res) ->
    User.find(
      id: "!": req.user.id
      rol: 2
    ).exec (err, users) ->
      res.send users

  login: (req, res) ->
    UserManager.authenticateUserPassword req.param("username"), req.param("password"), (err, user) ->
      return res.send(500)  if err
      return res.send(401)  unless user
      UserManager.generateUserToken user, (err, token) ->
        return res.send(500)  if err
        User.update(
          id: user.id
        ,
          token: token.token
          lastLogin: new Date()
        ).exec (err, updatedUser) ->
          req.user = updatedUser[0]
          delete user.imagen
          res.send(
            token: token
            user: user,
            200
          )

  forgotPassword: (req, res) ->
    UserManager.generateResetToken req.param("username"), (err) ->
      return res.send(500)  if err
      res.send 200
      return

    return

  resetPassword: (req, res) ->
    oldPassword = req.param("oldPassword")
    username = req.param("username")
    newPassword = req.param("newPassword")
    return res.send(400)  if isEmpty(oldPassword) or isEmpty(newPassword)
    UserManager.resetPassword username, oldPassword, newPassword, (err, user) ->
      return res.send(500)  if err
      return res.send(401)  unless user
      res.send 200

    return

  resetPasswordByToken: (req, res) ->
    token = req.param("token")
    username = req.param("username")
    newPassword = req.param("newPassword")
    return res.send(400)  if isEmpty(token) or isEmpty(newPassword)
    UserManager.resetPasswordByToken username, token, newPassword, (err, user) ->
      return res.send(500)  if err
      return res.send(404)  unless user
      UserManager.generateUserToken user, (err, token) ->
        return res.send(500)  if err
        res.send token, 200

      return

    return

  logout: (req, res) ->
    res.send 200

  jsonp: (req, res) ->
    callback = req.param('callback')
    res.send callback + "(200)"

  _config: {}
