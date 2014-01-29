Template.newSprint.events
  'submit form': (e) ->
    e.preventDefault()

    Session.set "isCreatingSprint", true

    data = {}

    $.each $(e.target).serializeArray(), ->
      data[@name] = @value


    Meteor.call 'addSprint', data, (error, id) ->
      Session.set "isCreatingSprint", false

      if (error)
        return alert(error.reason);

      Router.go('sprintDetail', {_id: id})
      Meteor.call 'update'

Template.newSprint.helpers
  buttonText:  ->
    if Session.get("isCreatingSprint")
      "Submitting..."
    else
      "Submit"
