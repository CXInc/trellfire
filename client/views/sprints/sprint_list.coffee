Template.sprintList.helpers
  sprints: ->
    Sprints.find {}, {sort: [["createdAt", "desc"]]}
