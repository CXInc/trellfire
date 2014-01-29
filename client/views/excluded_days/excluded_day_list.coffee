Template.excludedDayList.helpers(SprintHelpers)

Template.excludedDayList.helpers
  excludedTimes: ->
    ExcludedTimes.find {sprintId: @_id}, {sort: [["start", "asc"]]}

Template.excludedDayList.events
  'submit form': (e) ->
    e.preventDefault()

    day = moment( $(e.target).find("[name=date]").val() )

    ExcludedTimes.insert
      sprintId: @_id
      start: day.startOf('day').unix()
      end: day.endOf('day').unix()
