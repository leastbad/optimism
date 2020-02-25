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

{% hint style="info" %}
Optimism is designed for ActiveRecord models that have [validations](https://guides.rubyonrails.org/active_record_validations.html#validation-helpers) defined, although it should work with any Ruby class that implements [Active Model](https://guides.rubyonrails.org/active_model_basics.html) and has an `errors` accessor.
{% endhint %}

### Logging

In the default _debug_ log level, ActionCable emits particularly verbose log messages. You can optionally discard everything but exceptions by switching to the _warn_ log level, as is common in development environments:

{% code title="config/environments/development.rb" %}
```ruby
# :debug, :info, :warn, :error, :fatal, :unknown
config.log_level = :warn
```
{% endcode %}

### Troubleshooting

{% hint style="info" %}
If _something_ goes wrong, it's often because of the **spring** gem. You can test this by temporarily setting the `DISABLE_SPRING=1` environment variable and restarting your server.

To remove **spring** forever, here is the process we recommend:

1. `pkill -f spring`
2. `bundle remove spring spring-watcher-listen --install`
3. `bin/spring binstub -remove -all`
{% endhint %}



