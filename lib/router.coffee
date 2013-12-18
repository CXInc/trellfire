Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn: ->
    [Meteor.subscribe('sprints'), Meteor.subscribe('data_points')]

Router.map ->
  @route 'currentSprint',
    path: '/'
    data: ->
      Sprints.findOne {}, {sort: [["endDate", "desc"]]}
