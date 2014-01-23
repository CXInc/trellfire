Migrations.add
  version: 1
  name: 'Update for handling per-individual burndown',
  up: ->
    console.log "Updating tasks and data points"
    Tasks.update {owners: {$exists: false}}, {$set: {owners: ['team']}}, {multi: true}
    DataPoints.update {owner: {$exists: false}}, {$set: {owner: 'team'}}, {multi: true}

Migrations.migrateTo(1)
