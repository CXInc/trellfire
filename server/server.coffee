Meteor.startup ->
  unless Sprints.findOne()
    Sprints.insert({updating: false, createdAt: Time.now()})

  Meteor.setInterval ->
    Meteor.call 'update'
  , 3600000

Meteor.methods

  addSprint: (attributes) ->
    if (!attributes.name)
      throw new Meteor.Error(422, 'Please add a name');

    sprintWithSameName = Sprints.findOne {name: attributes.name}

    if sprintWithSameName
      throw new Meteor.Error 302, 'A sprint with this name already exists', sprintWithSameName._id

    sprint = _.extend _.pick(attributes, 'name'),
      createdAt: new Date().getTime()

    sprintId = Sprints.insert(sprint)

    return sprintId;

  update: ->
    Sprints.update {}, {$set: {updating: true}}
    console.log "Updatin'"

    hours = Updater.run()

    console.log "Hours: #{hours}"

    Sprints.find().forEach (sprint) ->
      stillRunning = !sprint.endTime || Time.now() < sprint.endTime
      return unless stillRunning

      Sprints.update sprint._id,
        $set:
          updating: false
          hoursRemaining: hours

      lastPoint = DataPoints.findOne {sprintId: sprint._id}, {sort: [["time", "desc"]]}
      console.log "lastPoint: #{lastPoint}"

      if !lastPoint || lastPoint.hoursRemaining != hours
        point = DataPoints.insert
          sprintId: sprint._id
          time: Time.now()
          hoursRemaining: hours
          owners: ['team']

  lock: (sprint, endDate) ->
    console.log "removing all datapoints"
    DataPoints.remove({sprintId: sprint._id})

    Meteor.call 'update'
    firstPoint = DataPoints.findOne {sprintId: sprint._id}, {sort: [["time", "asc"]]}
    console.log "firstPoint: #{JSON.stringify(firstPoint,true,2)}"

    Sprints.update sprint._id, $set:
      startHours: firstPoint.hoursRemaining
      startTime: Time.now()
      endTime: Time.epoch(endDate) + 24 * 60 * 60
