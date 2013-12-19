@Time =

  now: ->
    @epoch( new Date() )

  epoch: (date) ->
    new Date(date).getTime() / 1000
