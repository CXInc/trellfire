Meteor.startup ->
  # use first sprint found by default
  unless Session.get("sprint")
    Session.set "sprint", Sprints.findOne()

Template.sprint.events
  'click .update' : ->
    Session.set "errorMessage", ""

    Meteor.call 'update', (err) ->
      if err
        Session.set "errorMessage", "Update failed :("

  'click .lock' : ->
    console.log "LOCKING"

    endDate = $('.end').val()
    endTime = new Date(endDate).getTime() / 1000 + 24 * 60 * 60

    sprint = Sprints.findOne()

    Sprints.update sprint._id, $set:
      endTime: endTime

    Meteor.call 'lock'

Template.sprint.rendered = ->
  if !@handle
    @handle = Meteor.autorun ->
      points = DataPoints.find({}, {sort: [["time" ]]}).map (point) ->
        {x: point.time, y: point.hoursRemaining}

      sprint = Sprints.findOne()

      return unless sprint && points.length > 1

      lastPoint = DataPoints.findOne {}, {sort: [["time", "desc"]]}
      projectedSlope = -sprint.startHours / (sprint.endTime - sprint.startTime)

      console.log projectedSlope

      currentTime = new Date().getTime() / 1000
      elapsedTime = currentTime - sprint.startTime
      console.log "elapsedTime: #{elapsedTime}"
      projectedCurrentHours = sprint.startHours + projectedSlope * elapsedTime

      series = [{
          color: 'steelblue'
          name: 'Actual'
          data: points
        }]

      if sprint.startTime
        series.push
          color: 'red'
          name: 'Projected'
          data: [
            {x: sprint.startTime, y: sprint.startHours}
            {x: currentTime, y: projectedCurrentHours}
          ]

      console.log("points = #{ JSON.stringify(series,true,2) }")

      window.graph = new Rickshaw.Graph
        element: document.querySelector("#chart")
        width: 800
        height: 600
        renderer: 'line'
        interpolation: 'linear'
        series: series

      xAxis = new Rickshaw.Graph.Axis.Time
        graph: graph

      hoverDetail = new Rickshaw.Graph.HoverDetail
        graph: graph

      graph.render()

Template.sprint.sprint = ->
  Sprints.findOne()

Template.sprint.unlocked = ->
  !Sprints.findOne().endTime

Template.sprint.lockDisabled = ->
  if Sprints.findOne().endTime
    "disabled"
  else
    ""

Template.sprint.updateDisabled = ->
  if Sprints.findOne().updating
    "disabled"
  else
    ""

Template.sprint.errorMessage = ->
  Session.get("errorMessage")

Template.sprint.hoursRemaining = ->
  Sprints.findOne().hoursRemaining
