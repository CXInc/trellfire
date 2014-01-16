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
    if @updating || @startHours || @locking
      "disabled"
    else
      ""

  lockButtonText: ->
    if @startHours
      "Sprint Locked"
    else if @locking
      "Locking Sprint..."
    else
      "Lock Sprint"

  updateDisabled:  ->
    if @updating
      "disabled"
    else
      ""

  updateButtonText: ->
    if @updating
      "Updating..."
    else
      "Update"

  errorMessage:  ->
    Session.get("errorMessage")

  hoursRemaining:  ->
    @hoursRemaining
