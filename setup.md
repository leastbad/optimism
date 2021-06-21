---
description: Form validations in five minutes or it's free
---

# Setup

Optimism has a relatively small number of dependencies, but it does assume that it's being run in a Rails project with ActionCable configured for the environments you intend to operate in. You can easily install Optimism to new and existing Rails projects.

```bash
bundle add optimism
yarn add cable_ready
rake optimism:install
```

The terminal commands above will ensure that Optimism is installed. It creates the client-side websocket channel infrastructure required to process the list of commands from the server. All of this is possible because it's built on the shoulders of the incredible [CableReady](https://cableready.stimulusreflex.com/) gem, which gives developers the ability to tweak many different aspects of the current page from the server.

**Anyhow... that's it: you're ready to start integrating Optimism into your user interfaces**.

![](.gitbook/assets/setup.svg)

# Authentication

{% hint style="info" %}
If you're just experimenting with Optimism or trying to bootstrap a proof-of-concept application on your local workstation, you can actually skip this section until you're planning to deploy.
{% endhint %}

Out of the box, ActionCable doesn't give Optimism the ability to distinguish between multiple concurrent users looking at the same page.

**If you deploy to a host with more than one person accessing your app, you'll find that you're sharing a session and seeing other people's updates.** That isn't what most developers have in mind!

When the time comes, it's easy to configure your application to support authenticating users by their Rails session or current_user scope. Just check out the Authentication page and choose your own adventure.

{% page-ref page="authentication.md" %}

# Logging

In the default _debug_ log level, ActionCable emits particularly verbose log messages. You can optionally discard everything but exceptions by switching to the _warn_ log level, as is common in development environments:

{% code title="config/environments/development.rb" %}
```ruby
# :debug, :info, :warn, :error, :fatal, :unknown
config.log_level = :warn
```
{% endcode %}

# Troubleshooting

{% hint style="info" %}
If _something_ goes wrong, it's often because of the **spring** gem. You can test this by temporarily setting the `DISABLE_SPRING=1` environment variable and restarting your server.

To remove **spring** forever, here is the process we recommend:

1. `pkill -f spring`
2. `bundle remove spring spring-watcher-listen --install`
3. `bin/spring binstub -remove -all`
{% endhint %}



