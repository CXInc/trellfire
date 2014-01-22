actualSeries = (sprintId) ->
  points = DataPoints.find({sprintId: sprintId}, {sort: [["time", "asc"]]}).map (point) ->
    {x: point.time, y: point.hoursRemaining}

  if points.length > 0
    {
      color: 'steelblue'
      name: 'Actual'
      data: points
    }
  else
    null

projectedSeries = (sprintId) ->
  sprint = Sprints.findOne(sprintId)

  return null unless sprint.startTime

  currentTime = Time.now()

  if currentTime > sprint.endTime
    endTime = sprint.endTime
    endHours = 0
  else
    endTime = currentTime

    projectedSlope = -sprint.startHours / (sprint.endTime - sprint.startTime)
    elapsedTime = currentTime - sprint.startTime
    endHours = sprint.startHours + projectedSlope * elapsedTime

  {
    color: 'red'
    name: 'Projected'
    data: [
      {x: sprint.startTime, y: sprint.startHours}
      {x: endTime, y: endHours}
    ]
  }

Template.chart.rendered = ->
  sprintId = @data._id

  if !@handle
    @handle = Meteor.autorun ->
      Session.get("touch")

      actual = actualSeries(sprintId)
      return unless actual

      series = [actual]

      projected = projectedSeries(sprintId)
      series.push(projected) if projected

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
