Meteor.publish 'sprints', (options) ->
  Sprints.find {}, options

Meteor.publish 'data_points', (options) ->
  DataPoints.find {}, options
