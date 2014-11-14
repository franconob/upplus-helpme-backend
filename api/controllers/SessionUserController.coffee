###*
SessionUserController

@description :: Server-side logic for managing sessionusers
@help        :: See http://links.sailsjs.org/docs/controllers
###
module.exports =
  message: (req, res) ->
    SessionUser.findOne(req.param("to")).exec (err, suser) ->
      unless suser
        SessionUser.create(
          userid: req.param("to")
          online: false
        ).exec (err, createdUser) ->
          Conversation.create(
            from: req.user.id
            to: createdUser.userid
            message: req.param("message")
            type: req.param("type")
            sent: true
          ).exec (err, conversation) ->
            Conversation.subscribe req, conversation, "update"
            Conversation.findOne(conversation.id).exec (err, conv) ->
              conv.populate ->
                SessionUser.message req.param("to"), conv, req.socket
                res.send conv
                return

              return

            return

          return

      else
        Conversation.create(
          from: req.user.id
          to: req.param("to")
          message: req.param("message")
          type: req.param("type")
          sent: true
        ).exec (err, conversation) ->
          Conversation.subscribe req, conversation, "update"
          Conversation.findOne(conversation.id).exec (err, conv) ->
            conv.populate ->
              SessionUser.message req.param("to"), conv, req.socket
              res.send conv
              return

            return

          return

      return

    return

  list: (req, res) ->
    haveSession = []
    SessionUser.find(userid:
      "!": req.user.id
    ).exec (err, sessionUsers) ->
      User.find(
        limit: 10
        skip: req.param("skip") or 0
        where:
          id:
            "!": req.user.id
      ).populate("profiles").populate("extras").exec (err, users) ->
        if sessionUsers.length > 0
          found = undefined
          _.each sessionUsers, (suser) ->
            found = _.find(users,
              id: suser.userid
            )
            suser.juser = found.toJSON()
            haveSession.push suser
            return

        response = []
        _.each users, (user) ->
          alreadyIn = undefined
          alreadyIn = _.find(haveSession, (suser) ->
            suser.userid is user.id
          )
          unless alreadyIn
            response.push
              userid: user.id
              name: user.name
              juser: user
              online: false

          return

        res.send _.sortBy(response.concat(haveSession),
          online: false
        )
        return

      return

    return

  get: (req, res) ->
    SessionUser.findWithJUser req.param("id"), (result) ->
      res.json result
      return

    return
