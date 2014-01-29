@Excluder =

  excludeWeekends: (sprintId) ->
    sprint = Sprints.findOne(sprintId)

    unless sprint.endTime
      console.log "Attempted to exclude weekends on a sprint with no endTime!"
      return

    end = moment(sprint.endTime, "X")
    current = moment()

    while(current < end)
      if _.contains [0,6], current.day()
        excludedStart = current.startOf('day').unix()
        excludedEnd = current.endOf('day').unix()

        ExcludedTimes.upsert
          sprintId: sprintId
          start: excludedStart
          end: excludedEnd
        ,
          sprintId: sprintId
          start: excludedStart
          end: excludedEnd 

      current.add(1, 'd')
