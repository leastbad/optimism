# Quick Start

Let's start with the simplest scenario possible: you have a form with multiple input elements, and when the user clicks on the Submit button you want to display any validation error messages beside the elements that have issues. When the user resolves these issues and clicks the Submit button, the form is processed normal and the page navigates to whatever comes next.

## Model

Validations are covered in-depth by the [official documentation](https://guides.rubyonrails.org/active_record_validations.html#validation-helpers). Optimism doesn't require anything special.

{% hint style="info" %}
Optimism is designed for ActiveRecord models that have validations defined, although it should work with any Ruby class that implements [Active Model](https://guides.rubyonrails.org/active_model_basics.html) and has an `errors` accessor.
{% endhint %}

## View

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

## Controller

The last step is to slightly modify the **create** and **update** actions in our PostsController. The other actions have been removed for brevity:

{% code title="app/controllers/posts\_controller.rb" %}
```rust
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { broadcast_errors @post, post_params }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { broadcast_errors @post, post_params }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end
```
{% endcode %}

The only meaningful change required \(as seen on lines 8 and 20 in this example\) is to replace `render :new` and `render :edit` with a call to `broadcast_errors` which has two mandatory parameters: the model instance and the list of attributes to validate. Usually this is the whitelisted params hash, but you can pass a subset as small as one attribute to be validated.

That's all there is to it. You now have live - if _unstyled_ - form validations being delivered over websockets.

![](.gitbook/assets/high_five.svg)

