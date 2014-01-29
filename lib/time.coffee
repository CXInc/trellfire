@Time =

  now: ->
    moment().unix()

  dayAfter: (dateString) ->
    moment(dateString).add(1, 'd').unix()
