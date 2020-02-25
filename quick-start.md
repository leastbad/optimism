# Quick Start

Let's start with the simplest scenario possible: you have a form with multiple input elements, and when the user clicks on the Submit button you want to display any validation error messages beside the elements that have issues. When the user resolves these issues and clicks the Submit button, the form is processed normal and the page navigates to whatever comes next.

Here's sample form partial for a Post model. It has two attributes - **name** and **body** and was generated with a Rails scaffold command.

{% code title="app/views/posts/\_form.html.erb BEFORE Optimism" %}
```ruby
<%= form_with(model: post, local: true) do |form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
        <% post.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :name %>
    <%= form.text_field :name %>
  </div>

  <div class="field">
    <%= form.label :body %>
    <%= form.text_area :body %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```
{% endcode %}

And here is that same form partial, configured to work with Optimism:

{% code title="app/views/posts/\_form.html.erb AFTER Optimism" %}
```ruby
<%= form_with(model: post) do |form| %>
  <div class="field">
    <%= form.label :name %>
    <%= form.text_field :name %>
    <%= form.error_for :name %>
  </div>

  <div class="field">
    <%= form.label :body %>
    <%= form.text_area :body %>
    <%= form.error_for :body %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```
{% endcode %}

Eagle-eyed readers will see that setting up a bare-bones Optimism integration requires removing two things and adding one thing to each attribute:

1. Remove `local: true` from the `form_with` on the first line
2. Remove the error messages block from lines 2-12 entirely
3. Add an `error_for` helper for each attribute

The `error_for` helper creates an empty `span` tag with an id such as _post\_body\_error_, and this is where the error messages for the body attribute will appear. `error_for` will be covered in more detail soon.

{% hint style="success" %}
Even though `form_with` is remote-by-default, many developers were confused and frustrated by the lack of opinionated validation handling out of the box for remote forms. Since scaffolds are for new users to get comfortable, remote forms are disabled. This is the primary reason that Optimism was created: we want our tasty remote forms without any heartburn.
{% endhint %}

That's all there is to it. You now have live - if _unstyled_ - form validations being delivered over websockets.

![](.gitbook/assets/high_five.svg)

{% hint style="info" %}
Optimism is designed to work with ActiveRecord models that have [validations](https://guides.rubyonrails.org/active_record_validations.html#validation-helpers) defined, although it should work with any Ruby class that implements [Active Model](https://guides.rubyonrails.org/active_model_basics.html) and has an `errors` accessor.
{% endhint %}

