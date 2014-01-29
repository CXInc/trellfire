Accounts.ui.config
  requestPermissions:
    github: ['repo']

Meteor.startup ->
  $(window).resize ->
    Session.set "touch", moment().unix()

  Deps.autorun ->
    Meteor.subscribe 'userData'
