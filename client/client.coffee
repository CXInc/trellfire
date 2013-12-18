Meteor.startup ->
  $(window).resize ->
    Session.set("touch", new Date())
