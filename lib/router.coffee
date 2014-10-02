Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'

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
    action: ->
      @wait Meteor.subscribe('current_sprint')

      if @ready()
        sprint = Sprints.findOne()
        @redirect("/sprints/#{ sprint._id }")
      else
        @render('loading')

  @route 'excludedDayList',
    path: '/sprints/:_id/excluded-days'
    waitOn: ->
      [
        Meteor.subscribe('sprint', @params._id)
        Meteor.subscribe('excluded_times', @params._id)
      ]
    data: ->
      Sprints.findOne @params._id

  @route 'newSprint',
    path: '/new'

  @route 'sprintDetail',
    path: '/sprints/:_id'
    waitOn: ->
      [
        Meteor.subscribe('sprint', @params._id)
        Meteor.subscribe('data_points', @params._id)
        Meteor.subscribe('excluded_times', @params._id)
      ]
    data: ->
      Sprints.findOne @params._id
    action: ->
      @wait(IRLibLoader.load('//cdnjs.cloudflare.com/ajax/libs/rickshaw/1.4.6/rickshaw.min.js'))

      if @ready()
        @render('sprintDetail')
      else
        @render('loading')

  @route 'sprintList',
    path: '/sprints'
    waitOn: ->
      Meteor.subscribe('all_sprints')

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
