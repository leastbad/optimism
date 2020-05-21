# Optimism

[![GitHub stars](https://img.shields.io/github/stars/leastbad/optimism?style=social)](https://github.com/leastbad/optimism) [![GitHub forks](https://img.shields.io/github/forks/leastbad/optimism?style=social)](https://github.com/leastbad/optimism) [![Twitter follow](https://img.shields.io/twitter/follow/theleastbad?style=social)](https://twitter.com/theleastbad) [![Discord](https://img.shields.io/discord/681373845323513862)](https://discord.gg/GnweR3)

The missing drop-in solution for realtime remote form validation in Rails.

## Why have optimism?

[Optimism](https://github.com/leastbad/optimism) is an MIT-licensed [Ruby on Rails](https://rubyonrails.org/) gem that makes it easy to give your users instant constructive feedback if they enter invalid data into your application. Instead of dumping a list of errors at the top of your interface, Optimism provides specific instructions directly beside or below individual input elements.

You can try a 👉 [live demo](https://optimism-demo.herokuapp.com) 👈 right now.

![](.gitbook/assets/fill_forms.svg)

## Is optimism for you?

Are you trying to use remote forms but feeling frustrated by their inflexibility? You need to mainline a dose of Optimism, stat!

If you care about reducing churn and giving your users the best experience possible, Optimism is a great way to achieve your UX goals without having to waste time writing repetitive and brittle validation code. Properly constrained and highly opinionated, you'll be able to keep your validation logic on the server where it belongs without sacrificing the immediate response of a reactive Single Page App. Whether you're working on a complex multi-element form with a traditional Submit button or a dynamic search that delivers results as you type, Optimism chops, grinds, slices and dices your validation concerns away.

Optimism is safe and approved for all diets, religions and political appetites. Many developers find that Optimism is highly addictive and lowers stress when applied regularly.

## How does optimism work?

Rails applications receive requests to update database records based on a list of proposed changes that come from a ~~dog~~ user submitting a form in their browser. If all proposed changes can be made without breaking any business rules, ActiveRecord can update the email address and age of the ~~dog~~ user. Optimism kicks in when `user_params = {email: 7, age: "bark_ruffalo@gmail.com"}`.

When a model validation error prevents an update from succeeding, Optimism builds a list of issues that must be resolved. This list is broadcast to the browser over a websocket connection, and the live document is changed to show the necessary validation hints. No page refreshes are required and the entire process happens faster than you can blink.

![](.gitbook/assets/loading.svg)

## Key features and advantages

* [x] Easy to learn, quick to implement
* [x] Automatically handles multi-level nested forms
* [x] Plays well with existing tools such as [StimulusReflex](https://github.com/hopsoft/stimulus_reflex), [Turbolinks](https://github.com/turbolinks/turbolinks) and even [jQuery](https://jquery.com/)
* [x] Contextual user feedback in a few milliseconds
* [x] Supports form-based and in-line edit scenarios equally well
* [x] Optional support for emitting DOM events
* [x] Highly configurable via an optional initializer file
* [x] CSS framework agnostic with Bootstrap and vanilla samples provided
* [x] Lightweight, coming in at ~100 LOC

## Try it now

The project repository lives on Github at [https://github.com/leastbad/optimism](https://github.com/leastbad/optimism) and this documentation is available at [https://optimism.leastbad.com](https://optimism.leastbad.com)

There's a **live demo** that you can try right now at [https://optimism-demo.herokuapp.com](https://optimism-demo.herokuapp.com/)

Even better, the source code for the demo is [available on Github](https://github.com/leastbad/optimism-demo). The project README lists every step required to build the demo application from scratch in about five minutes.

Excited? Great! Let's [setup Optimism](https://optimism.leastbad.com/setup) in your Rails application now. And if you're having any trouble at all, [drop by our Discord server](https://discord.gg/wKzsAYJ) for help.

