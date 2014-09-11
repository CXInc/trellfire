Meteor.startup ->
  if Meteor.settings.kadiraId && Meteor.settings.kadiraSecret
    Kadira.connect Meteor.settings.kadiraId, Meteor.settings.kadiraSecret
