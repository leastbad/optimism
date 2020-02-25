# Quick Start

Let's start with the simplest scenario possible: you have a form with multiple input elements, and when the user clicks on the Submit button you want to display any validation error messages beside the elements that have issues. When the user resolves these issues and clicks the Submit button, the form is processed normal and the page navigates to whatever comes next.

Here's sample form partial for a Post model. It has two attributes - **name** and **body** and was generated with a Rails scaffold command.

{% code title="app/views/posts/\_form.html.erb BEFORE Optimism" %}
```rust
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
```rust
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

The `error_for` helper creates an empty `span` tag with an id such as _posts\_body\_error_, and this is where the error messages for the body attribute will appear.

{% hint style="success" %}
Even though `form_with` is remote-by-default, many developers were confused and frustrated by the lack of opinionated validation handling out of the box for remote forms. Since scaffolds are for new users to get comfortable, remote forms are disabled. This is the primary reason that Optimism was created: we want our tasty remote forms without any heartburn.
{% endhint %}

That's all there is to it. You now have live - if _unstyled_ - form validations being delivered over websockets.

![](.gitbook/assets/high_five.svg)

### Typical Usage

Now that you have seen what Optimism can do, let's flex our muscles a bit and see how far this goes.

{% tabs %}
{% tab title="Vanilla Rails Scaffold" %}
{% code title="app/views/posts/\_form.html.erb" %}
```rust
<%= form_with(model: post, id: "posts_form") do |form| %>
  <%= form.container_for :name, class: "field" do %>
    <%= form.label :name %>
    <%= form.text_field :name %>
    <%= form.error_for :name, class: "danger hide" %>
  <% end %>

  <%= form.container_for :body, class: "field" do %>
    <%= form.label :body %>
    <%= form.text_area :body %>
    <%= form.error_for :body, class: "danger hide" %>
  <% end %>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```
{% endcode %}
{% endtab %}

{% tab title="Bootstrap 4" %}
{% code title="app/views/posts/\_form.html.erb" %}
```rust
<%= form_with(model: post, id: "posts_form") do |form| %>
  <%= form.container_for :name, class: "form-group" do %>
    <%= form.label :name %>
    <%= form.text_field :name, class: "form-control" %>
    <%= form.error_for :name, class: "small align-bottom text-danger d-none" %>
  <% end %>

  <%= form.container_for :body, class: "form-group" do %>
    <%= form.label :body %>
    <%= form.text_area :body, class: "form-control" %>
    <%= form.error_for :body, class: "small align-bottom text-danger d-none" %>
  <% end %>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```
{% endcode %}
{% endtab %}
{% endtabs %}

Here we introduce the `container_for` helper, which wraps a form element in a `div` that has an id similar to the `error_for` helper, except you're looking at _posts\_body\_container_. More importantly, the container receives a CSS class called _error_ that can be used to change the visual characteristics of the error message as well as the input element itself. **It is this interplay between cascading style and the order in which the styles are declared that makes this approach work.** Consider the following CSS:

{% tabs %}
{% tab title="Vanilla Rails Scaffold" %}
```css
.danger {
  color: red;
}

.hide {
  display: none;
}

.field.error > .hide {
  display: block;
}

.field.error > input,
.field.error > textarea {
  background-color: rgba(255, 239, 213, 0.7);
}
```
{% endtab %}

{% tab title="Bootstrap 4" %}
```css
.form-group.error > .d-none {
  display: inline !important;
}

.form-group.error > input,
.form-group.error > textarea {
  background-color: rgba(255, 239, 213, 0.7);
}
```
{% endtab %}
{% endtabs %}

When there is a validation error on an input element, the error message is injected into the span and an _error_ CSS class is added to the container for that element. This results in a cascade where **the class responsible for hiding the error message is now flipped to display it instead**. In this example, we also show how we can change the visual characteristics of the input elements themselves, in this case making the background color a sickly and distressing translucent peach. It really helps sell the urgency.

If you assign an id to the form itself that matches the expected format - in this case, `posts_form` - Optimism will also place an _invalid_ class on the form if there are _any_ errors at all. This gives the developer the flexibility to demonstrate an error state at the form level by tweaking how the form is displayed.

{% hint style="info" %}
Unfortunately, we can't automatically generate the id for the form during its own declaration. Luckily, the format is pretty easy: **resources\_form**.
{% endhint %}

