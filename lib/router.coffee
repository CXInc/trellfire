Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn: ->
    [Meteor.subscribe('sprints'), Meteor.subscribe('data_points'), Meteor.subscribe('excluded_times')]

isAuthenticated = (pause) ->
  if !Meteor.loggingIn() && !Meteor.user()
    @render('signIn')
    pause()

isAuthorized = (pause) ->
  if Meteor.user() && Meteor.user().authCheckComplete && !Meteor.user().authorized
    @render('unauthorized')
    pause()

hasOneSprint = (pause) ->
  sprint = Sprints.findOne({})

  if isAuthorized() && !sprint?
    @render('newSprint')
    pause()

Router.map ->
  @route 'currentSprint',
    path: '/'
    data: ->
      Sprints.findOne {}, {sort: [["endTime", "desc"]]}

  @route 'excludedDayList',
    path: '/sprints/:_id/excluded-days'
    data: ->
      Sprints.findOne @params._id

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
      @response.write('{"result":"OK"}')
      @response.end()

Router.onBeforeAction isAuthenticated,
  except: ['signIn', 'trelloWebhook']

Router.onBeforeAction isAuthorized,
  except: ['signIn', 'unauthorized', 'trelloWebhook']

Router.onBeforeAction hasOneSprint,
  except: ['signIn', 'unauthorized', 'trelloWebhook']
