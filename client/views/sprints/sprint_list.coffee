Template.sprintList.helpers
  sprints: ->
    Sprints.find {}, {sort: [["endTime", "desc"]]}
