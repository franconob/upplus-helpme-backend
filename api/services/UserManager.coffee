
# this would need to live in sails config
doesUsernameExist = (email, done) ->
  User.findOne(correo: email).exec (err, user) ->
    return done(err)  if err
    done null, !!user

  return

#
# todo: look at updating this to not increment the failed attempts
# if the same incorrect password is being used
#
updateUserLockState = (user, done) ->
  now = moment().utc()
  lastFailure = null
  lastFailure = moment(user.lastPasswordFailure)  if user.lastPasswordFailure

  # do we have a previously failed login attempt in the last x amount of time
  if lastFailure isnt null and now.diff(lastFailure, "seconds") < 1800
    user.passwordFailures += 1

    # lock if this is the 4th incorrect attempt
    user.locked = true  if user.passwordFailures > 3
  else

    # reset the failed attempts
    user.passwordFailures = 1
  user.lastPasswordFailure = now.toDate()
  user.save done
  return
setUserPassword = (user, password, done) ->
  hash password, null, (err, hashedPassword, salt) ->
    return done(err)  if err
    user.salt = salt
    user.password = hashedPassword
    user.resetToken = null
    user.save done
    return

  return
jwt = require("jwt-simple")
moment = require("moment")
shortid = require("shortid")
jwtSecret = "xStmbyc066BOFn40gIr29y09Ud94z1P7"
module.exports =
  hashPassword: (password, salt, done) ->
    hash password, salt, (err, hashedPassword, salt) ->
      return done(err)  if err
      done null, hashedPassword, salt
      return

    return

  createUser: (values, done) ->
    doesUsernameExist values.username, (err, exists) ->
      return done(err)  if err

      # todo: a better return result
      return done()  if exists
      values.rol = 2
      User.create(values).exec (createErr, user) ->
        return done(createErr)  if createErr

        # todo: send welcome email
        done null, user
        return

      return

    return

  savePerfil: (userid, values, done) ->
    User.update(userid, values).exec (user, err) ->
      if err
        return done  null, err
      else
        return done user[0], null

  generateUserToken: (user, done) ->
    issueDate = moment().utc().format()
    encodedToken = null
    try
      encodedToken = jwt.encode(
        id: user.id
        issued: issueDate
      , jwtSecret)
    catch err
      return done(err)
    done null,
      token: encodedToken
      id: user.id
      username: user.username


  authenticateUserToken: (token, done) ->
    tokenObj = null

    # check the issue date to see if the token has expired (quick way to kick out expired tokens)
    # to check accurately for minutes we need to check in seconds as moment rounds the result down
    # to the nearest unit
    try
      tokenObj = jwt.decode(token, jwtSecret)
    catch err
      return done(err)

    # find the user and set req.user
    User.findOne(id: tokenObj.id).exec (err, user) ->
      return done(err)  if err
      done null, user

    return

  authenticateUserPassword: (username, password, done) ->
    User.findOne(correo: username).exec (err, user) ->
      return done(err)  if err
      return done()  if not user or user.block
      user.validatePassword password, (vpErr, isValid) ->
        return done(vpErr)  if vpErr
        unless isValid
          done()
        else
          done null, user

      return

    return

  generateResetToken: (username, done) ->
    User.findOne(username: username).exec (err, user) ->
      return done(err)  if err
      return done()  unless user
      user.resetToken = shortid.generate()
      user.save (saveErr, user) ->
        return done(saveErr)  if saveErr

        #
        #           todo: email the token to the user - look in db for token or
        #           uncomment line below
        #

        # console.log(user.resetToken);
        done null
        return

      return

    return

  resetPassword: (username, oldPassword, newPassword, done) ->
    @authenticateUserPassword username, oldPassword, (err, user) ->
      return done(err)  if err
      return done(null, false)  unless user
      setUserPassword user, newPassword, done
      return

    return

  resetPasswordByToken: (username, token, newPassword, done) ->
    User.findOne(
      username: username
      resetToken: token
    ).exec (err, user) ->
      return done(err)  if err
      return done()  unless user
      setUserPassword user, newPassword, done
      return

    return
