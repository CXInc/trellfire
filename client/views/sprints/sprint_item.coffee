Template.sprintItem.helpers
  displayDate:  ->
    moment(@endTime * 1000).format("MMMM D YYYY")
