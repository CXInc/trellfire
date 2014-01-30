authorized = (userId) ->
  user = Meteor.users.findOne({_id: userId})
  user && user.authorized

Deps.autorun ->
  Meteor.publish 'sprints', (options) ->
    if authorized(@userId)
      Sprints.find {}, options
    else
      @stop()

  Meteor.publish 'data_points', (options) ->
    if authorized(@userId)
      DataPoints.find {}, options
    else
      @stop()

  Meteor.publish 'excluded_times', (options) ->
    if authorized(@userId)
      ExcludedTimes.find {}, options
    else
      @stop()

  Meteor.publish 'userData', ->
    Meteor.users.find {_id: @userId},
      fields:
        authorized: 1
        authCheckComplete: 1
