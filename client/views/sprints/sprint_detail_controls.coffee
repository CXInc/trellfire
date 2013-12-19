Template.sprintDetailControls.events
  'click .update' : ->
    Session.set "errorMessage", ""

    Meteor.call 'update', (err) ->
      if err
        Session.set "errorMessage", "Update failed :("

  'click .lock' : ->
    console.log "LOCKING"

    Meteor.call 'lock', @

Template.sprintDetailControls.helpers
  lockDisabled:  ->
    if @startHours
      "disabled"
    else
      ""

  updateDisabled:  ->
    if @updating
      "disabled"
    else
      ""

  errorMessage:  ->
    Session.get("errorMessage")

  hoursRemaining:  ->
    @hoursRemaining
