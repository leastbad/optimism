require "cable_ready"
require "optimism/version"
require "optimism/railtie" if defined?(Rails)

module Optimism
  include CableReady::Broadcaster
  class << self
    mattr_accessor :channel, :form_class, :error_class, :disable_submit, :suffix, :emit_events, :add_css, :inject_inline, :container_selector, :error_selector, :form_selector, :submit_selector
    self.channel = "OptimismChannel"
    self.form_class = "invalid"
    self.error_class = "error"
    self.disable_submit = false
    self.suffix = ""
    self.emit_events = false
    self.add_css = true
    self.inject_inline = true
    self.container_selector = "#RESOURCE_ATTRIBUTE_container"
    self.error_selector = "#RESOURCE_ATTRIBUTE_error"
    self.form_selector = "#RESOURCE_form"
    self.submit_selector = "#RESOURCE_submit"
  end

  def self.configure(&block)
    yield self
  end

  def broadcast_errors(model, attributes)
    return unless model&.errors&.messages
    resource = model.class.to_s.downcase
    form_selector, submit_selector = Optimism.form_selector.sub("RESOURCE", resource), Optimism.submit_selector.sub("RESOURCE", resource)
    attributes = case attributes
    when ActionController::Parameters, Hash, ActiveSupport::HashWithIndifferentAccess
      attributes.to_h.keys
    when String, Symbol
      [attributes.to_s]
    when Array
      attributes.flatten.map &:to_s
    else
      raise Exception.new "attributes must be a Hash (Parameters, Indifferent or standard), Array, Symbol or String"
    end
    process_resource(model, attributes, [resource])
    if model.errors.any?
      cable_ready[Optimism.channel].dispatch_event(name: "optimism:form:invalid", detail: {resource: resource}) if Optimism.emit_events
      cable_ready[Optimism.channel].add_css_class(selector: form_selector, name: Optimism.form_class) if Optimism.form_class.present?
      cable_ready[Optimism.channel].set_attribute(selector: submit_selector, name: "disabled") if Optimism.disable_submit
    else
      cable_ready[Optimism.channel].dispatch_event(name: "optimism:form:valid", detail: {resource: resource}) if Optimism.emit_events
      cable_ready[Optimism.channel].remove_css_class(selector: form_selector, name: Optimism.form_class) if Optimism.form_class.present?
      cable_ready[Optimism.channel].remove_attribute(selector: submit_selector, name: "disabled") if Optimism.disable_submit
    end
    cable_ready.broadcast
    head :ok
  end

  def process_resource(model, attributes, ancestry)
    attributes.each do |attribute|
      if attribute.ends_with?("_attributes")
        resource = attribute[0..-12]
        nested_models = model.send(resource.to_sym)
        nested_models.each_with_index do |nested, index|
          process_resource(nested, attributes[attribute][index.to_s], ancestry + [resource, index]) if attributes[attribute].key?(index.to_s)
        end
      else
        process_attribute(model, attribute, ancestry.dup)
      end
    end
  end

  def process_attribute(model, attribute, ancestry)
    resource = ancestry.shift
    resource += "_#{ancestry.shift}_attributes_#{ancestry.shift}" until ancestry.empty?
    container_selector, error_selector = Optimism.container_selector.sub("RESOURCE", resource).sub("ATTRIBUTE", attribute), Optimism.error_selector.sub("RESOURCE", resource).sub("ATTRIBUTE", attribute)
    if model.errors.messages.map(&:first).include?(attribute.to_sym)
      message = "#{model.errors.full_message(attribute.to_sym, model.errors.messages[attribute.to_sym].first)}#{Optimism.suffix}"
      cable_ready[Optimism.channel].dispatch_event(name: "optimism:attribute:invalid", detail: {resource: resource, attribute: attribute, text: message}) if Optimism.emit_events
      cable_ready[Optimism.channel].add_css_class(selector: container_selector, name: Optimism.error_class) if Optimism.add_css
      cable_ready[Optimism.channel].text_content(selector: error_selector, text: message) if Optimism.inject_inline
    else
      cable_ready[Optimism.channel].dispatch_event(name: "optimism:attribute:valid", detail: {resource: resource, attribute: attribute}) if Optimism.emit_events
      cable_ready[Optimism.channel].remove_css_class(selector: container_selector, name: Optimism.error_class) if Optimism.add_css
      cable_ready[Optimism.channel].text_content(selector: error_selector, text: "") if Optimism.inject_inline
    end
  end
end

module ActionView::Helpers
  class FormBuilder
    def container_for(attribute, **options, &block)
      @template.tag.div @template.capture(&block), options.merge!(id: container_id_for(attribute)) if block_given?
    end

    def container_id_for(attribute)
      Optimism.container_selector.sub("RESOURCE", object_name.delete("]").tr("[", "_")).sub("ATTRIBUTE", attribute.to_s)[1..-1]
    end

    def error_for(attribute, **options)
      @template.tag.span options.merge! id: error_id_for(attribute)
    end

    def error_id_for(attribute)
      Optimism.error_selector.sub("RESOURCE", object_name.delete("]").tr("[", "_")).sub("ATTRIBUTE", attribute.to_s)[1..-1]
    end
  end
end

class ActionController::Base
  include Optimism
end
