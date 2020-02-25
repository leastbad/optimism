# Typical Usage

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

![](.gitbook/assets/web_developer.svg)

