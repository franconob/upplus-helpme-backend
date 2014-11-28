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



  get: (req, res) ->
    SessionUser.findWithJUser req.param("id"), (result) ->
      res.json result
      return

    return
