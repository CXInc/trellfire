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

      name = item.name

      if matches = item.name.match(/^\((.*?)\)/)
        hoursString = matches[1]
        postLock = false
      else if matches = item.name.match(/^POSTLOCK\s*\((.*?)\)/i)
        hoursString = matches[1]
        postLock = true

      if hoursString
        hours = parseFloat(hoursString)

        if isNaN(hours)
          0
        else
          @upsertTask
            trelloId: item.id
            checklistId: checklistId
            cardId: cardId
            hours: hours
            postLock: postLock
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

    Sprints.find().forEach (sprint) =>
      stillRunning = !sprint.endTime || Time.now() < sprint.endTime
      return unless stillRunning

      ownerHours = @currentHours(sprint._id)

      Sprints.update sprint._id,
        $set:
          hoursRemaining: ownerHours.team

      teamChange = @hoursChanged(sprint._id, "team", ownerHours)
      postLockChange = @hoursChanged(sprint._id, "Post-Lock", ownerHours)

      if teamChange || postLockChange
        _.each ownerHours, (hours, owner) ->
          point = DataPoints.insert
            sprintId: sprint._id
            time: Time.now()
            hoursRemaining: hours
            owner: owner

  hoursChanged: (sprintId, owner, ownerHours) ->
    lastPoint = DataPoints.findOne
      sprintId: sprintId
      owner: owner
    ,
      sort: [["time", "desc"]]

    !lastPoint || lastPoint.hoursRemaining != ownerHours[owner]

  currentHours: (sprintId) ->
    tasks = Tasks.find({sprintId: sprintId}).fetch()

    ownerHours = {team: 0, "Post-Lock": 0}

    _.each tasks, (task) ->
      if task.postLock
        ownerHours['Post-Lock'] += task.hours
      else
        _.each task.owners, (owner) ->
          ownerHours[owner] ||= 0
          ownerHours[owner] += task.hours

    ownerHours
