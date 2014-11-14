###*
ConversationController

@description :: Server-side logic for managing conversations
@help        :: See http://links.sailsjs.org/docs/controllers
###
async = require("async")
module.exports =
  
  ###*
  get /conversations/:from/:to
  ###
  get: (req, res) ->
    data = []
    Conversation.find(
      where:
        or: [
          {
            from: req.param("from")
          }
          {
            to: req.param("from")
          }
        ]

      sort: "createdAt ASC"
    ).populate("to").populate("from").exec (err, conversations) ->
      res.send 500, err  if err
      if conversations
        data = _.filter(conversations, (conversation) ->
          return conversation.from.userid is req.param("to") or conversation.to.userid is req.param("to")  if conversation.to
          false
        )
        response = []
        Conversation.update(_.pluck(conversations, "id"),
          read: true
        ).exec (err, updatedConversations) ->
          async.forEach data, ((conversation, callback) ->
            Conversation.findOne(conversation.id).exec (err, conv) ->
              conv.populate ->
                response.push conv
                callback()
                return

              return

            return
          ), ->
            res.send _.sortBy(response, (conversation) ->
              date = new Date(conversation.createdAt)
              date.getTime()
            )
            return

          return

      return

    return

  list: (req, res) ->
    data = {}
    Conversation.find(
      where:
        or: [
          {
            from: req.user.id
          }
          {
            to: req.user.id
          }
        ]

      sort: "id ASC"
    ).exec (err, conversations) ->
      if conversations
        async.forEach conversations, ((conversation, callback) ->
          
          # Si el destinatario soy yo
          if conversation.to is req.user.id
            if typeof data[conversation.from] is "undefined" or conversation.createdAt > data[conversation.from]
              User.findOne(conversation.from).populate("profiles").populate("extras").exec (err, user) ->
                SessionUser.findOne(user.id).exec (err, suser) ->
                  user = user.toJSON()
                  user.online = suser.online
                  data[conversation.from] =
                    message: conversation.message
                    user: user
                    type: conversation.type
                    createdAt: conversation.createdAt
                    read: conversation.read
                    tome: true

                  callback()
                  return

                return

          if conversation.from is req.user.id
            if typeof data[conversation.to] is "undefined" or conversation.createdAt > data[conversation.to]
              User.findOne(conversation.to).populate("profiles").populate("extras").exec (err, user) ->
                SessionUser.findOne(user.id).exec (err, suser) ->
                  user = user.toJSON()
                  user.online = suser.online
                  data[conversation.to] =
                    message: conversation.message
                    user: user
                    type: conversation.type
                    createdAt: conversation.createdAt
                    read: conversation.read
                    tome: false

                  callback()
                  return

                return

          return
        ), ->
          res.send _.sortBy(data, (conv) ->
            new Date(conv.createdAt)
          ).reverse()

      return

    return

  updateReceived: (req, res) ->
    conversationId = req.param("id")
    Conversation.update(conversationId,
      received: true
      read: true
    ).exec (err, updatedConversation) ->
      Conversation.publishUpdate conversationId, updatedConversation[0], req.socket
      res.send 200
      return

    return
