Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn: ->
    [Meteor.subscribe('sprints'), Meteor.subscribe('data_points')]

Router.map ->
  @route 'currentSprint',
    path: '/'
    data: ->
      Sprints.findOne {}, {sort: [["endTime", "desc"]]}

  @route 'newSprint',
    path: '/new'

  @route 'sprintDetail',
    path: '/sprints/:_id'
    data: ->
      Sprints.findOne @params._id

  @route 'sprintList',
    path: '/sprints'
