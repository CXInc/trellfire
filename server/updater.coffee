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
          complete: item.state == "complete"
          owners: @parseOwners(item.name)

  parseOwners: (itemName) ->
    owners = itemName.match(/(\@\w+)/g) || []
    owners.concat("Team")

  upsertTask: (data) ->
    Sprints.find().forEach (sprint) ->
      stillRunning = !sprint.endTime || moment().unix() < sprint.endTime

      if stillRunning
        Tasks.upsert {trelloId: data.trelloId, sprintId: sprint._id}, _.extend data,
          sprintId: sprint._id
          owners: data.owners

  recalculateHours: ->
    console.log "Calculating hours"

    Sprints.find().forEach (sprint) =>
      sprintDone = sprint.endTime && moment().unix() > sprint.endTime
      return if sprintDone || sprint.updating

      ownerHours = @currentHours(sprint._id)

      Sprints.update sprint._id,
        $set:
          hoursRemaining: ownerHours['Team']

      anyHoursChanged = _.any ownerHours, (owner, hours) =>
        @hoursChanged(sprint._id, owner, ownerHours)

      if anyHoursChanged
        _.each ownerHours, (hours, owner) =>
          @addPoint
            sprintId: sprint._id
            hoursRemaining: hours
            owner: owner

  # args
  # - sprintId
  # - hoursRemaining
  # - owner
  addPoint: (args) ->
    @removeRedundantPoint(args)

    DataPoints.insert
      sprintId: args.sprintId
      time: moment().unix()
      hoursRemaining: args.hoursRemaining
      owner: args.owner

  removeRedundantPoint: (args) ->
    unsortedPoints = DataPoints.find
      sprintId: args.sprintId
      owner: args.owner
    ,
      sort: [["time", "desc"]]
    .fetch()

    lastPoints = _.sortBy unsortedPoints, (point) ->
      -point.time

    if lastPoints.length >= 2 && lastPoints[0].hoursRemaining == lastPoints[1].hoursRemaining
      DataPoints.remove lastPoints[0]._id

  hoursChanged: (sprintId, owner, ownerHours) ->
    lastPoint = DataPoints.findOne
      sprintId: sprintId
      owner: owner
    ,
      sort: [["time", "desc"]]

    !lastPoint || lastPoint.hoursRemaining != ownerHours[owner]

  currentHours: (sprintId) ->
    tasks = Tasks.find({sprintId: sprintId}).fetch()

    ownerHours = {"Team": 0, "Post-Lock Total": 0, "Post-Lock Burndown": 0}

    _.each tasks, (task) ->
      if task.postLock
        ownerHours['Post-Lock Total'] += task.hours

        if !task.complete
          ownerHours['Post-Lock Burndown'] += task.hours
      else
        _.each task.owners, (owner) ->
          ownerHours[owner] ||= 0
          ownerHours[owner] += task.hours if !task.complete

    ownerHours
