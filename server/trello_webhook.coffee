@TrelloWebhook =

  check: ->
    webhooks = Webhooks.find()

    if webhooks.count() == 0
      @create()
    else if !@verify( webhooks.fetch() )
      @create()

  verify: (webhooks) ->
    results = _.map webhooks, (webhook) =>
      url = "https://api.trello.com/1/webhooks/#{webhook.trelloId}?key=#{@key()}&token=#{@token()}"

      try
        result = HTTP.get url
        success = result.callbackURL == @webhookUrl()

        @destroy(webhook) unless success

        success
      catch error
        console.log "Webhook did not verify: #{error}"
        @destroy(webhook)
        false

    _.any results

  destroy: (webhook) ->
    console.log "Destroying webhook: #{ JSON.stringify(webhook, true, 2) }"
    url = "https://api.trello.com/1/webhooks/#{webhook.trelloId}?key=#{@key()}&token=#{@token()}"

    try
      result = HTTP.del url
    catch error
      console.log "Failed to delete webhook: #{error}"
    finally
      Webhooks.remove webhook._id

  create: ->
    url = "https://api.trello.com/1/webhooks?key=#{@key()}&token=#{@token()}"

    result = HTTP.put url,
      data:
        description: "trellfire"
        callbackURL: @webhookUrl()
        idModel: Meteor.settings.trelloBoardId
    console.log "Created webhook: #{JSON.stringify(result.data,true,2)}"

    Webhooks.insert
      trelloId: result.data.id

  key: ->
    Meteor.settings.trelloKey

  token: ->
    Meteor.settings.trelloToken

  webhookUrl: ->
    rootUrl = Meteor.settings.rootUrl || Meteor.absoluteUrl.defaultOptions.rootUrl
    rootUrl + "/webhook"
