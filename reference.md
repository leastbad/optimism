# Reference

## ActionController Mixins

### **broadcast\_errors**\(model, attributes\)

**model**: an instance of an Active Record model, or a class inheriting from Active Model  
**attributes**: one or many attributes in the form of a ActionController::Parameters, Hash, HashWithIndifferentAccess, Symbol, String or Array \(of Strings or Symbols\)

Call this method in a resource controller's `create` or `update` actions when a model validation fails. A list of instructions for the client browser will be prepared and dispatched via a persistent websocket connection.

The two most common use cases are form-based \(Parameters\) or in-line editing of a single attribute \(Symbol or String\).

#### Example

```ruby
if @post.update(post_params)
  # Eat. Pray. Love.
else
  broadcast_errors @post, post_params
end
```



## Form Builder Helpers

### container\_for\(attribute, \*\*options, &block\)

**attribute**: Symbol identifying the the model attribute to use  
**options**: an implicit Hash allowing you to pass in class names, data attributes and other HTML attributes  
**block**: all ERB content passed to this helper inside the do..end will be rendered as content

Call this helper to create a `div` that will wrap your input element along with any labels and error messages. It will have an id attribute that will allow Optimism to route any validation errors to the correct place. When a validation failure occurs, this `div` will have an _error_ class added to it, allowing a style cascade to change the visual appearance of the input element and the error message.

#### Example

```rust
  <%= form.container_for :name, class: "field" do %>
    <%= form.text_field :name %>
  <% end %>
```



### container\_id\_for\(attribute\)

**attribute**: Symbol identifying the the model attribute to use

Returns the id required for a container to wrap your input elements and receive CSS updates. Use it if you are forced to create your own container markup from scratch; generally it is easiest to make use of **container\_for** if possible.

#### Example

```rust
<blockquote id="<%= form.container_id_for :name %>"></blockquote>
```



### error\_for\(attribute, \*\*options\)

**attribute**: Symbol identifying the the model attribute to use  
**options**: an implicit Hash allowing you to pass in class names, data attributes and other HTML attributes

Call this helper to create a `span` that you place adjacent to your your input elements. It will have an id attribute that will allow Optimism to route any validation errors to the correct place. When a validation failure occurs, this `span` will have the error message injected into it. It is typically hidden unless there is a message present.

#### Example

```rust
<%= form.error_for :name, class: "d-none text-danger small form-group" %>
```



### error\_id\_for\(attribute\)

**attribute**: Symbol identifying the the model attribute to use

Returns the id required for a container to receive validation error text. Use it if you are forced to create your own error message markup from scratch; generally it is easiest to make use of **error\_for** if possible.

```rust
<blockquote id="<%= form.error_id_for :name %>"></blockquote>
```



![](.gitbook/assets/master_plan.svg)

## Initializer

Optimism is configurable via an optional initializer file. As with all initializers, changes only take effect after your Rails server has been restarted. Here is a sample initializer file that contains all of the default values for the configuration of the library. All changes apply globally to all instances of Optimism.

{% code title="config/initializers/optimism.rb" %}
```ruby
Optimism.configure do |config|
  config.channel = ->(context) { "OptimismChannel" }
  config.form_class = "invalid"
  config.error_class = "error"
  config.disable_submit = false
  config.suffix = ""
  config.emit_events = false
  config.add_css = true
  config.inject_inline = true
  config.container_selector = "#RESOURCE_ATTRIBUTE_container"
  config.error_selector = "#RESOURCE_ATTRIBUTE_error"
  config.form_selector = "#RESOURCE_form"
  config.submit_selector = "#RESOURCE_submit"
end
```
{% endcode %}

**channel**: The ActionCable channel created by the `rake optimism:install` setup task. Good enough to get you up and running in development, you will need to pull your desired identifier from the context Optimism is running in and let the `broadcasting_for` method on `OptimismChannel` call the shots. Find out more on the [authentication](https://optimism.leastbad.com/authentication) page.

**form\_class**: The CSS class that will be applied to the form if the id has been properly set eg. `posts_form` \(following the simple pattern **resources\_form**\). If form\_class is set to false or nil, no CSS class will be applied.

**error\_class**: The CSS class the will be applied to a container when a validation fails. Use this class to cascade to the input elements and change their appearance.

**disable\_submit**: If set to true and your Submit button is named properly eg. `posts_submit` \(following the simple pattern **resources\_submit**\), your Submit button will be disabled if there are validation errors. It will also be re-enabled if the validation errors are corrected. Only use this if you are working with in-line validations or else your users will lose the ability to Submit your form more than once.

**suffix**: Likely the most important setting of all, this string will be appended to all validation error messages. While most validation errors on the web today do not have a trailing period, this is a matter of developer preference and when you're working on Rails, we care about your trails.

**emit\_events**: Optimism is so flexible that you can opt to have it fire DOM events in addition to \(or instead of\) text content and CSS updates. Scroll down for more information on the events that will be sent.

**add\_css**: Flag to control whether containers will receive CSS updates when a form is invalid.

**inject\_inline**: Flag to control whether validation error messages will be displayed inside _error\_for_ spans.

**container\_selector**: This is the pattern from which container id CSS selectors will be constructed. You probably shouldn't change this.

**error\_selector**: This is the pattern from which error\_for span id CSS selectors will be constructed. You probably shouldn't change this.

**form\_selector**: This is the pattern from which form id CSS selectors will be constructed. You probably shouldn't change this.

**submit\_selector**: This is the pattern from which Submit button id CSS selectors will be constructed. You probably shouldn't change this.



## Events

If you set the `emit_events` property to true in your initializer, Optimism will emit DOM events in response to validation errors. This can happen in addition to or instead of CSS and text updates. This is a great alternative for complicated integrations where you have legacy components which need to be notified of error conditions on the backend.

In practical terms, DOM events give you tooling options and creative flexibility that are difficult to achieve with textual error messages and CSS error classes. It's simply a fact that no library can anticipate every design pattern or UI innovation. Today you might connect DOM events to a [toast notification library](https://www.jqueryscript.net/blog/Best-Toast-Notification-jQuery-Plugins.html#vanilla), but tomorrow there could be a mass proliferation of embedded ocular computers with sub-vocalization control interfaces, and we aren't going to tell you how those devices should punish users for bad input.

### Form-level events

Event: **optimism:form:invalid**  
Detail: resource

Event: **optimism:form:valid**  
Detail: resource

One of these events will fire, depending on whether the model is valid. Resource is the pluralized class name of the Active Record model, eg. `posts`

### Attribute-level events

Event: **optimism:attribute:invalid**  
Detail: resource, attribute, text

Event: **optimism:attribute:valid**  
Detail: resource, attribute

One of these events will fire **for each attribute**, depending on whether that attribute is valid. Resource is the pluralized class name of the Active Record model, eg. `posts`. Attribute is hopefully self-explanatory. Text is the text content of the validation error message.

![](.gitbook/assets/alien_science.svg)

