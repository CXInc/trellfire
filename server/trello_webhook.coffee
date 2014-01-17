@TrelloWebhook =

  check: ->
    webhook = Webhooks.findOne()

    if !webhook
      @create()
    else if !@verify(webhook)
      @destroy(webhook)
      @create()

  verify: (webhook) ->
    url = "https://api.trello.com/1/webhooks/#{webhook.trelloId}?key=#{@key()}&token=#{@token()}"
    result = HTTP.get url
    console.log "verify result: #{JSON.stringify(result.data,true,2)}"

    true

  destroy: (webhook) ->
    url = "https://api.trello.com/1/webhooks/#{webhook.trelloId}?key=#{@key()}&token=#{@token()}"
    result = HTTP.del url
    console.log "destroy result: #{JSON.stringify(result.data,true,2)}"

  create: ->
    url = "https://api.trello.com/1/webhooks?key=#{@key()}&token=#{@token()}"

    result = HTTP.post url,
      data:
        description: "trello-burndown"
        callbackURL: Meteor.absoluteUrl.defaultOptions.rootUrl + "/webhook"
        idModel: Meteor.settings.trelloBoardId
    console.log "create result: #{JSON.stringify(result.data,true,2)}"

    Webhooks.insert
      trelloId: result.data.id

  key: ->
    Meteor.settings.trelloKey

  token: ->
    Meteor.settings.trelloToken
