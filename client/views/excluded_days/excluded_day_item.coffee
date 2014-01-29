Template.excludedDayItem.helpers

  displayDate: ->
    moment(@start, "X").format("dddd, MMMM D, YYYY")

Template.excludedDayItem.events
  'click .remove' : ->
    ExcludedTimes.remove @_id
