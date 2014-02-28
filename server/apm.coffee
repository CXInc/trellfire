Meteor.startup ->
  if Meteor.settings.apmId && Meteor.settings.apmSecret
    Apm.connect Meteor.settings.apmId, Meteor.settings.apmSecret
