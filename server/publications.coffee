authorized = Authorization.authorized

Deps.autorun ->
  Meteor.publish 'current_sprint', ->
    if authorized(@userId)
      Sprints.find {}, {sort: [["endTime", "desc"]], limit: 1}
    else
      @stop()

  Meteor.publish 'sprint', (id) ->
    if authorized(@userId)
      Sprints.find {_id: id}
    else
      @stop()

  Meteor.publish 'all_sprints', ->
    if authorized(@userId)
      Sprints.find {}
    else
      @stop()

  Meteor.publish 'data_points', (sprintId) ->
    if authorized(@userId)
      DataPoints.find {sprintId: sprintId}
    else
      @stop()

  Meteor.publish 'excluded_times', (sprintId) ->
    if authorized(@userId)
      ExcludedTimes.find {sprintId: sprintId}
    else
      @stop()

  Meteor.publish 'userData', ->
    Meteor.users.find {_id: @userId},
      fields:
        authorized: 1
        authCheckComplete: 1
