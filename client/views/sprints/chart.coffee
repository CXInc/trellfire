Template.chart.rendered = ->
  sprintId = @data._id

  if !@handle
    @handle = Meteor.autorun ->
      Session.get("touch")

      points = DataPoints.find({sprintId: sprintId}, {sort: [["time", "asc"]]}).map (point) ->
        {x: point.time, y: point.hoursRemaining}
      console.log "found #{points.length} points for #{sprintId}"

      return unless points.length > 0

      sprint = Sprints.findOne(sprintId)
      lastPoint = DataPoints.findOne {sprintId: sprintId}, {sort: [["time", "desc"]]}
      projectedSlope = -sprint.startHours / (sprint.endTime - sprint.startTime)

      console.log "projectedSlope: #{projectedSlope}"

      currentTime = Time.now()
      elapsedTime = currentTime - sprint.startTime
      console.log "elapsedTime: #{elapsedTime}"
      projectedCurrentHours = sprint.startHours + projectedSlope * elapsedTime

      series = [{
          color: 'steelblue'
          name: 'Actual'
          data: points
        }]

      if sprint.startTime && sprint.endTime
        series.push
          color: 'red'
          name: 'Projected'
          data: [
            {x: sprint.startTime, y: sprint.startHours}
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

Template.chart.destroyed = ->
  @handle.stop()
