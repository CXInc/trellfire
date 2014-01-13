Accounts.ui.config
  requestPermissions:
    github: ['repo']

Meteor.startup ->
  $(window).resize ->
    Session.set("touch", new Date())

  Deps.autorun ->
    Meteor.subscribe('userData')
