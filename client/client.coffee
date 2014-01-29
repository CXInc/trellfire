Accounts.ui.config
  requestPermissions:
    github: ['repo']

Meteor.startup ->
  $(window).resize ->
    Session.set "touch", Time.now()

  Deps.autorun ->
    Meteor.subscribe 'userData'
