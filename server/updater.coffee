@Updater =

  boardId: ->
    Meteor.settings.trelloBoardId

  key: ->
    Meteor.settings.trelloKey

  token: ->
    Meteor.settings.trelloToken

  run: ->
    console.log "requesting board"

    result = HTTP.get "https://trello.com/1/boards/#{@boardId()}/cards?key=#{@key()}&token=#{@token()}"

    _.reduce result.data, (sum, card) =>
      sum + @cardHours(card.id)
    , 0.0

  cardHours: (id) ->
    console.log "requesting card"
    result = HTTP.get "https://trello.com/1/cards/#{id}/checklists?key=#{@key()}&token=#{@token()}"

    _.reduce result.data, (sum, checklist) =>
      sum + @checklistHours(checklist)
    , 0.0

  checklistHours: (checklist) ->
    _.reduce checklist.checkItems, (sum, item) =>
      sum + @checkItemHours(item)
    , 0.0

  checkItemHours: (item) ->
    if item.state == "incomplete"
      console.log "Incomplete item: #{item.name}"

      matches = item.name.match(/^\((.*?)\)/)

      if matches
        console.log "Found match! #{matches[1]}"
        hours = parseFloat(matches[1])

        if isNaN(hours)
          0
        else
          hours
      else
        0
    else
      0
