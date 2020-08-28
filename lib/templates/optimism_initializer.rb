Optimism.config do |c|
  # Cable ready channel class that Optimism will use
  #
  c.channel = 'OptimismChannel'

  # CSS selectors for HTML elements controlled by Optimism
  #
  # Because optimism uses these values during run time to compute
  # actual CSS selectors, they must all contain the literal string
  # "RESOURCE".
  #
  # Additionally, the `container_selector` and `error_selector`
  # values must contain the literal string "ATTRIBUTE".
  #
  c.container_selector = '#RESOURCE_ATTRIBUTE_container'
  c.error_selector = '#RESOURCE_ATTRIBUTE_error'
  c.form_selector = '#RESOURCE_form'
  c.submit_selector = '#RESOURCE_submit'

  # CSS classes that Optimism toggles
  # 
  # The `add_css` option controls whether or not Optimism will actually
  # toggle classes at all.
  #
  c.add_css = true
  c.form_class = 'invalid'
  c.error_class = 'error'

  # Disable the form submit button when resource becomes invalid
  c.disable_submit = false

  # Emit events when resource validity changes
  c.emit_events = false

  # TODO: track down what this is used for (forgot)
  c.inject_inline = true

  # TODO: determine if this is used for anything/anyone
  # if not, remove it.
  c.suffix = ''
end