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

    _.each result.data, (card) =>
      @updateCard(card)

  updateCard: (card) ->
    console.log "requesting card: #{card.id}"
    result = HTTP.get "https://trello.com/1/cards/#{card.id}/checklists?key=#{@key()}&token=#{@token()}"

    _.each result.data, (checklist) =>
      @updateChecklist(checklist, card.id)

  updateChecklist: (checklist, cardId) ->
    _.each checklist.checkItems, (item) =>
      @updateCheckItem(item, checklist.id, cardId)

  updateCheckItem: (item, checklistId, cardId) ->
    if item.state == "incomplete"
      console.log "Incomplete item: #{item.name}"

      matches = item.name.match(/^\((.*?)\)/)

      if matches
        console.log "Found match! #{matches[1]}"
        hours = parseFloat(matches[1])

        if isNaN(hours)
          0
        else
          @upsertTask
            trelloId: item.id
            checklistId: checklistId
            cardId: cardId
            hours: hours
            owners: @parseOwners(item.name)

  parseOwners: (itemName) ->
    owners = itemName.match(/(\@\w+)/g) || []
    owners.concat("team")

  upsertTask: (data) ->
    Sprints.find().forEach (sprint) ->
      stillRunning = !sprint.endTime || Time.now() < sprint.endTime

      if stillRunning
        Tasks.upsert {trelloId: data.trelloId, sprintId: sprint._id}, _.extend data,
          sprintId: sprint._id
          owners: data.owners

  recalculateHours: ->
    console.log "Calculating hours"
    tasks = Tasks.find({}).fetch()

    ownerHours = {}

    _.each tasks, (task) ->
      _.each task.owners, (owner) ->
        ownerHours[owner] ||= 0
        ownerHours[owner] += task.hours

    Sprints.find().forEach (sprint) ->
      stillRunning = !sprint.endTime || Time.now() < sprint.endTime
      return unless stillRunning

      Sprints.update sprint._id,
        $set:
          hoursRemaining: ownerHours.team

      lastPoint = DataPoints.findOne
        sprintId: sprint._id
        owner: 'team'
      ,
        sort: [["time", "desc"]]

      if !lastPoint || lastPoint.hoursRemaining != ownerHours.team
        _.each ownerHours, (hours, owner) ->
          point = DataPoints.insert
            sprintId: sprint._id
            time: Time.now()
            hoursRemaining: hours
            owner: owner
