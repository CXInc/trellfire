Migrations.add
  version: 1
  name: 'Update for handling per-individual burndown',
  up: ->
    Tasks.update {owners: {$exists: false}}, {$set: {owners: ['team']}}, {multi: true}
    DataPoints.update {owner: {$exists: false}}, {$set: {owner: 'team'}}, {multi: true}

Migrations.add
  version: 2
  name: 'Update task and data point owner names',
  up: ->
    Tasks.update {owners: ['team']}, {$set: {owners: ['Team']}}, {multi: true}
    DataPoints.update {owner: 'team'}, {$set: {owner: 'Team'}}, {multi: true}
    DataPoints.update {owner: 'Post-Lock'}, {$set: {owner: 'Post-Lock Burndown'}}, {multi: true}

Migrations.migrateTo(2)
