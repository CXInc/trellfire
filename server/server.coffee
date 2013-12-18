Meteor.startup ->
  unless Sprints.findOne()
    Sprints.insert({updating: false, createdAt: new Date().getTime()})

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
    Sprints.update {}, {$set: {updating: false, hoursRemaining: hours}}

    sprint = Sprints.findOne()

    lastPoint = DataPoints.findOne {}, {sort: [["time", "desc"]]}

    if !lastPoint || lastPoint.hoursRemaining != hours
      DataPoints.insert
        sprintId: sprint._id
        time: new Date().getTime() / 1000
        hoursRemaining: hours
        owners: ['team']

  lock: ->
    DataPoints.remove({})
    console.log "all datapoints removed"
    Meteor.call 'update'
    console.log "update called"

    firstPoint = DataPoints.findOne()
    console.log "firstPoint: #{JSON.stringify(firstPoint,true,2)}"

    Sprints.update {}, $set:
      startHours: firstPoint.hoursRemaining
      startTime: new Date().getTime() / 1000

  reset: ->
    DataPoints.remove({})
    Sprints.remove({})
    Sprints.insert({updating: false})
