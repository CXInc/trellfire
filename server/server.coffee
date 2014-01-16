Meteor.startup ->
  Meteor.setInterval ->
    Meteor.call 'update'
  , 3600000

Meteor.users.find({}).observe
  added: (user) ->
    unless user.authorized
      Authorization.authorize(user)

Meteor.methods

  addSprint: (endDate) ->
    endTime = Time.epoch(endDate) + 24 * 60 * 60

    if (!endTime)
      throw new Meteor.Error(422, 'Please select an end date');

    sprintWithSameEnd = Sprints.findOne {endTime: endTime}

    if sprintWithSameEnd
      throw new Meteor.Error 302, 'A sprint with this end date already exists', sprintWithSameEnd._id

    sprint =
      endTime: endTime

    sprintId = Sprints.insert(sprint)

    return sprintId;

  update: ->
    Sprints.update {}, {$set: {updating: true}}, {multi: true}

    console.log "Updatin'"

    try
      hours = Updater.run()

      console.log "Hours: #{hours}"

      Sprints.find().forEach (sprint) ->
        stillRunning = !sprint.endTime || Time.now() < sprint.endTime
        return unless stillRunning

        Sprints.update sprint._id,
          $set:
            hoursRemaining: hours

        lastPoint = DataPoints.findOne {sprintId: sprint._id}, {sort: [["time", "desc"]]}
        console.log "lastPoint: #{lastPoint}"

        if !lastPoint || lastPoint.hoursRemaining != hours
          point = DataPoints.insert
            sprintId: sprint._id
            time: Time.now()
            hoursRemaining: hours
            owners: ['team']
    catch error
      console.log "Update failed: #{error}"
    finally
      Sprints.update {}, {$set: {updating: false}}, {multi: true}

  lock: (sprint) ->
    Sprints.update sprint._id, {$set: {locking: true}}

    console.log "Locking!"
    console.log "sprint: #{JSON.stringify(sprint,true,2)}"

    console.log "removing all datapoints"
    DataPoints.remove({sprintId: sprint._id})

    Meteor.call 'update'
    firstPoint = DataPoints.findOne {sprintId: sprint._id}, {sort: [["time", "asc"]]}
    console.log "firstPoint: #{JSON.stringify(firstPoint,true,2)}"

    Sprints.update sprint._id, $set:
      startHours: firstPoint.hoursRemaining
      startTime: Time.now()
      locking: false
