Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn: ->
    [Meteor.subscribe('sprints'), Meteor.subscribe('data_points'), Meteor.subscribe('excluded_times')]

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

  @route 'trelloWebhook',
    path: '/webhook'
    where: 'server'
    action: ->
      TrelloEvents.handle(@request.body)
      @response.writeHead 200,
        'Content-Type': 'application/json'
      @response.write('{"result":"OK"}');

Router.before isAuthenticated,
  except: ['signIn', 'trelloWebhook']

Router.before isAuthorized,
  except: ['signIn', 'unauthorized', 'trelloWebhook']

Router.before hasOneSprint,
  except: ['signIn', 'unauthorized', 'trelloWebhook']
