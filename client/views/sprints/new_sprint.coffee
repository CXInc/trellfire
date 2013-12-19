Template.newSprint.events
  'submit form': (e) ->
    e.preventDefault()

    endDate = $(e.target).find('[name=end]').val()

    Meteor.call 'addSprint', endDate, (error, id) ->
      if (error)
        return alert(error.reason);

      Router.go('sprintDetail', {_id: id})
