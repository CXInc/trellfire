Meteor.startup ->
  # use first sprint found by default
  unless Session.get("sprint")
    Session.set "sprint", Sprints.findOne()

  $(window).resize ->
    Session.set("touch", new Date())
