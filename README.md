Trellfire
=========

Trellfire is an app that generates burndown charts from Trello boards. It uses the [Trello webhook API](https://trello.com/docs/gettingstarted/webhooks.html) to provide real-time updates to the burndown chart. Authentication is currently done through GitHub, and authorization can either be based on a whitelist of usernames or membership in a GitHub organization.

[Demo](http://trellfire.meteor.com) and the [Trello Board](https://trello.com/b/dCWRlbJW/trellfire-demo) it's attached to

Deploying your own instance
---------------------------

Trellfire is a [Meteor](https://www.meteor.com) app. The easiest way to deploy it is through Meteor themselves, however there are other [deployment options](http://docs.meteor.com/#deploying).

  * Install [Meteor](https://www.meteor.com)
  * Clone the repo or [Download](https://github.com/CXInc/trellfire/archive/master.zip) Trellfire

In the Trellfire folder, make a copy of the example settings:

    cp settings.json.example settings.json

You'll have to decide on one of these three available authorization methods:

  * username - The GitHub username of the user must be on a whitelist
  * github-org - The user must belong to the specified GitHub org
  * none - All authenticated users are authorized. This is used in the demo, but may also be reasonable if you're using Trellfire on a server that isn't publicly accessible.

Edit it to add the configuration values you'll be using

  * appName - Shows up in the app header
  * authorizationMethod - Either "github-org", "username" or "none"
  * authorizedUsernames - When authorizationMethod is "username", this is the array of GitHub usernames authorized to use the app
  * org - When authorizationMethod is "github-org", this is the GitHub org name that users must belong to in order to access the app
  * trelloBoardId - Open the board in Trello, and go to Menu -> Share, Print, and Export... -> Export JSON. The first id is the board ID.
  * trelloKey - Get one at https://trello.com/1/appKey/generate
  * trelloToken - Substitute your key into this URL, and go through authorization: https://trello.com/1/authorize?key=YOUR-KEY-HERE&name=Trellfire&expiration=never&response_type=token

Deploy:

    meteor deploy NAME --password --debug --settings settings.json

Replace NAME with whatever you want the subdomain for you app to be, for example trellfire.meteor.com. Turning on password protection of your app is recommended, but not required. The debug option is necessary because there's a Trellfire dependency that breaks during Meteor's minification process.

Usage
-----

Trellfire relies upon some conventions for naming Trello checklist items. Tasks added prior to locking a sprint must be named as follows:

    (<number of hours>) @<trello username> <task description>

For example:

    (2.5) @frodo Destroy the ring

The parenthesis containing the number of hours has to be at the very beginning, however the username tags can be anywhere in the name.

Tasks added post-lock simply have the text "POSTLOCK" added to the beginning, for instance:

    POSTLOCK (1) @samwise Leave the Shire

Trellfire only looks at the names of checklist items, so card and checklist names can be named however you want.

Caveats
-------

The Trello webhook API doesn't send notifications when a task name is changed, which can cause Trellfire to be inconsistent with the data in Trello. Because of this, Trellfire does a full poll of the Trello board every hour.

Developing
----------

In order to receive Trello notifications, the app must be able to receive requests from Trello. When developing locally, one easy way to do this is to use [ngrok](https://ngrok.com). Start it up on the default Meteor port:

    ngrok 3000

A forwarding URL will be show up after a tunnel has been established. Add a "rootUrl" configuration in your settings.json with the URL ngrok provides, for example http://193a1520.ngrok.com.

Start the app:

    meteor --settings settings.json
