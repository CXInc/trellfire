@Updater =

  BOARDID: "51cb0d2399125ad407001a6c"
  TOKEN: "cce33925e5a5dc4087452c8292743c1ef09d88da1e9967bbf39dfe8d18297741"
  KEY: "6e60db58cf32f8f27ec3a41ec232b595"

  run: ->
    console.log "requesting board"
    result = HTTP.get "https://trello.com/1/boards/#{@BOARDID}/cards?key=#{@KEY}&token=#{@TOKEN}"

    _.reduce result.data, (sum, card) =>
      sum + @cardHours(card.id)
    , 0.0

  cardHours: (id) ->
    console.log "requesting card"
    result = HTTP.get "https://trello.com/1/cards/#{id}/checklists?key=#{@KEY}&token=#{@TOKEN}"

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
