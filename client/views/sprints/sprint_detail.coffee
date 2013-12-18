Template.sprintDetail.events
  'click .update' : ->
    Session.set "errorMessage", ""

    Meteor.call 'update', (err) ->
      if err
        Session.set "errorMessage", "Update failed :("

  'click .lock' : ->
    console.log "LOCKING"

    endDate = $('.end').val()
    endTime = new Date(endDate).getTime() / 1000 + 24 * 60 * 60

    Sprints.update @_id, $set:
      endTime: endTime

    Meteor.call 'lock'

Template.sprintDetail.rendered = ->
  if !@handle
    @handle = Meteor.autorun ->
      Session.get("touch")

      points = DataPoints.find({}, {sort: [["time" ]]}).map (point) ->
        {x: point.time, y: point.hoursRemaining}

      lastPoint = DataPoints.findOne {}, {sort: [["time", "desc"]]}
      projectedSlope = -@startHours / (@endTime - @startTime)

      console.log projectedSlope

      currentTime = new Date().getTime() / 1000
      elapsedTime = currentTime - @startTime
      console.log "elapsedTime: #{elapsedTime}"
      projectedCurrentHours = @startHours + projectedSlope * elapsedTime

      series = [{
          color: 'steelblue'
          name: 'Actual'
          data: points
        }]

      if @startTime
        series.push
          color: 'red'
          name: 'Projected'
          data: [
            {x: @startTime, y: @startHours}
            {x: currentTime, y: projectedCurrentHours}
          ]

      console.log("points = #{ JSON.stringify(series,true,2) }")

      # clear out existing graph
      $('#chart').html('')

      window.graph = new Rickshaw.Graph
        element: document.querySelector("#chart")
        renderer: 'line'
        interpolation: 'linear'
        series: series

      xAxis = new Rickshaw.Graph.Axis.Time
        graph: graph

      hoverDetail = new Rickshaw.Graph.HoverDetail
        graph: graph

      graph.render()

Template.sprintDetail.helpers
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
