Template.newSprint.events
  'submit form': (e) ->
    e.preventDefault()

    sprint =
      name: $(e.target).find('[name=name]').val()

    Meteor.call 'addSprint', sprint, (error, id) ->
      if (error)
        return alert(error.reason);

      Router.go('sprintDetail', {_id: id})
