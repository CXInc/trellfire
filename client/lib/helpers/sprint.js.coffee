@SprintHelpers =

  displayDate:  ->
    moment(@endTime, "X").format("MMMM D YYYY")
