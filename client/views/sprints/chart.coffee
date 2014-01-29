actualSeries = (sprintId) ->
  points = DataPoints.find
    sprintId: sprintId
  ,
    sort: [["time", "asc"]]

  if points.count() > 0
    grouped = _.groupBy points.fetch(), (point) ->
      point.owner

    palette = new Rickshaw.Color.Palette()

    _.map grouped, (points, owner) ->
      color = if owner == 'team' then 'steelblue' else palette.color()

      {
        color: color
        name: "Actual for #{owner}"
        data: _.map points, (point) ->
          {x: point.time, y: point.hoursRemaining}
      }
  else
    null

projectedSeries = (sprintId) ->
  sprint = Sprints.findOne(sprintId)

  return null unless sprint.startTime

  currentTime = moment().unix()

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

      series = actualSeries(sprintId)
      return unless series

      projected = projectedSeries(sprintId)
      series.push(projected) if projected

      # clear out existing graph
      $('#chart, #legend').html('')

      window.graph = new Rickshaw.Graph
        element: document.querySelector("#chart")
        renderer: 'line'
        interpolation: 'linear'
        series: series

      xAxis = new Rickshaw.Graph.Axis.Time
        graph: graph

      hoverDetail = new Rickshaw.Graph.HoverDetail
        graph: graph

      legend = new Rickshaw.Graph.Legend
        element: document.querySelector('#legend')
        graph: graph

      shelving = new Rickshaw.Graph.Behavior.Series.Toggle
        graph: graph
        legend: legend

      highlighter = new Rickshaw.Graph.Behavior.Series.Highlight
        graph: graph
        legend: legend

      graph.render()

Template.chart.destroyed = ->
  @handle.stop()
