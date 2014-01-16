Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn: ->
    [Meteor.subscribe('sprints'), Meteor.subscribe('data_points')]

isAuthenticated = ->
  if !Meteor.loggingIn() && !Meteor.user()
    @render('signIn')
    @stop()

isAuthorized = ->
  if Meteor.user() && Meteor.user().authCheckComplete && !Meteor.user().authorized
    @render('unauthorized')
    @stop()

hasOneSprint = ->
  sprint = Sprints.findOne({})

  unless sprint?
    @render('newSprint')
    @stop()

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

Router.before isAuthenticated,
  except: ['signIn']

Router.before isAuthorized,
  except: ['signIn', 'unauthorized']

Router.before hasOneSprint,
  except: ['signIn', 'unauthorized']
