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
      color = if owner == 'Team' then 'steelblue' else palette.color()

      {
        color: color
        name: owner
        data: _.map points, (point) ->
          {x: point.time, y: point.hoursRemaining}
      }
  else
    null

projectedSeries = (sprintId) ->
  sprint = Sprints.findOne(sprintId)

  return null unless sprint.startTime

  data = [
    {x: sprint.startTime, y: sprint.startHours}
  ]

  currentTime = moment().unix()

  excludedTimes = ExcludedTimes.find(
    sprintId: sprint._id
  ,
    sort: [["start", "asc"]]
  ).fetch()

  totalExcludedTime = _.reduce excludedTimes, (sum, excludedTime) ->
    start = Math.max( Math.min(excludedTime.start, sprint.endTime), sprint.startTime)
    end = Math.min( Math.max(excludedTime.end, sprint.startTime), sprint.endTime)
    sum + (end - start)
  , 0

  totalBurnTime = sprint.endTime - sprint.startTime - totalExcludedTime
  projectedSlope = -sprint.startHours / totalBurnTime

  _.each excludedTimes, (excludedTime) ->
    return if currentTime < excludedTime.start || excludedTime.end < sprint.startTime

    lastPoint = _.last(data)

    elapsedTime = excludedTime.start - lastPoint.x
    hours = lastPoint.y + projectedSlope * elapsedTime

    data.push
      x: excludedTime.start
      y: hours
    
    if currentTime > excludedTime.end
      data.push
        x: excludedTime.end
        y: hours

  lastPoint = _.last(data)

  if currentTime > sprint.endTime
    endTime = sprint.endTime
    hours = 0
  else
    endTime = currentTime
    elapsedTime = endTime - lastPoint.x
    hours = lastPoint.y + projectedSlope * elapsedTime

  data.push
    x: endTime
    y: hours


  {
    color: 'red'
    name: 'Projected'
    data: data
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
  @handle.stop() if @handle
