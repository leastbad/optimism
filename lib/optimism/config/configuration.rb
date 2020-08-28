module Optimism::Config
  class Configuration
    # Initialize with some sane defaults
    def initialize(context)
      @context = context

      self.add_css = true
      self.channel = ->(context) { 'OptimismChannel' }
      self.container_selector = '#RESOURCE_ATTRIBUTE_container'
      self.disable_submit = false
      self.emit_events = false
      self.error_class = 'error'
      self.error_selector = '#RESOURCE_ATTRIBUTE_error'
      self.form_class = 'invalid'
      self.form_selector = '#RESOURCE_form'
      self.inject_inline = true
      self.submit_selector = '#RESOURCE_submit'
      self.suffix = ''
    end

    def add_css=(boolean)
      @add_css = boolean ? true : false
    end
    attr_reader :add_css

    def channel=(callable_or_string)
      if callable_or_string.respond_to?(:call)
        @channel = callable_or_string
      else
        @channel = -> (context) { callable_or_string.to_s }
      end
    end
    attr_reader :channel

    def container_selector=(string)
      @container_selector = string.to_s
    end
    attr_reader :container_selector

    def disable_submit=(boolean)
      @disable_submit = boolean ? true : false
    end
    attr_reader :disable_submit

    def emit_events=(boolean)
      @emit_events = boolean ? true : false
    end
    attr_reader :emit_events

    def error_class=(string)
      @error_class = string.to_s
    end
    attr_reader :error_class

    def error_selector=(string)
      @error_selector = string.to_s
    end
    attr_reader :error_selector

    def form_class=(string)
      @form_class = string.to_s
    end
    attr_reader :form_class

    def form_selector=(string)
      @form_selector = string.to_s
    end
    attr_reader :form_selector

    def emit_events=(boolean)
      @emit_events = boolean ? true : false
    end
    attr_reader :emit_events

    def inject_inline=(boolean)
      @inject_inline = boolean ? true : false
    end
    attr_reader :inject_inline

    def submit_selector=(string)
      @submit_selector = string.to_s
    end
    attr_reader :submit_selector

    def suffix=(string)
      @suffix = string.to_s
    end
    attr_reader :suffix

    private

    attr_reader :context
  end
end