@TrelloEvents =

  handle: (data) ->
    return unless data.action

    actionData = data.action.data

    switch data.action.type
      when 'createCheckItem', 'updateCheckItemStateOnCard', 'deleteCheckItem'
        @updateItemTask(actionData.checkItem, actionData.checklist.id, actionData.card.id)
      when 'removeChecklistFromCard'
        @removeChecklist(actionData.checklist)
      when 'deleteCard'
        @removeCard(actionData.card)
      when 'updateCard'
        @updateCard(actionData.card)

  updateItemTask: (item, listId, cardId) ->
    console.log "updating check item #{item.id}"
    Updater.updateCheckItem(item, listId, cardId)

    Updater.recalculateHours()

  removeChecklist: (checklist) ->
    console.log "removeChecklist"

    Tasks.update {checklistId: checklist.id}, {$set: {complete: true}}, {multi: true}
    Updater.recalculateHours()

  removeCard: (card) ->
    console.log "removeCard"

    Tasks.update {cardId: card.id}, {$set: {complete: true}}, {multi: true}
    Updater.recalculateHours()

  updateCard: (card) ->
    console.log "updateCard"

    if card.closed
      # archive treated the same as deleting the card
      @removeCard(card)
    else
      Updater.updateCard(card)

    Updater.recalculateHours()
