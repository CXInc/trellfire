Template.sprintDetailControls.events
  'click .update' : ->
    Session.set "errorMessage", ""

    Meteor.call 'update', (err) ->
      if err
        Session.set "errorMessage", "Update failed :("

  'click .lock' : ->
    console.log "LOCKING"

    endDate = $('.end').val()

    Meteor.call 'lock', @, endDate

Template.sprintDetailControls.helpers
  unlocked:  ->
    !@endTime

  lockDisabled:  ->
    if @endTime
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
