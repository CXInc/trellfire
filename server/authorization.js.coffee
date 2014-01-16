@Authorization =

  authorize: (user) ->
    token = user.services.github.accessToken
    console.log "github token: #{token}"

    github = new GitHub
      version: "3.0.0"
      debug: true

    github.authenticate
      type: 'oauth'
      token: token

    github.user.getOrgs {}, Meteor.bindEnvironment(
      (err, res) =>
        if err
          console.log "Authorization check failure: #{res}"
        else
          authorized = _.some res, (orgs) ->
            Meteor.settings.org == orgs.login

          Meteor.users.update user._id,
            $set:
              authCheckComplete: true
              authorized: authorized
      , (e) ->
        console.log 'bind failure'
    )
