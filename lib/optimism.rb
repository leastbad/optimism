require 'cable_ready'
require 'optimism/version'
require 'optimism/railtie' if defined?(Rails)

module Optimism
  include CableReady::Broadcaster

  class << self
    mattr_accessor :add_css, :channel, :container_selector, :disable_submit,
      :emit_events, :error_class, :error_selector, :form_class, :form_selector,
      :inject_inline, :submit_selector,:suffix

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

    def configure(&block)
      yield self
    end

    private

    def _id_for(element, resource, attribute = nil)
      _selector_for(element, resource, attribute)[1..-1]
    end

    def _selector_for(element, resource, attribute = nil)
      selector = send("#{element}_selector").dup
      selector.sub!('RESOURCE', resource.to_s) if selector.include?('RESOURCE')
      selector.sub!('ATTRIBUTE', attribute.to_s) if selector.include?('ATTRIBUTE')
      selector
    end

    def _resource_from_object_name(object_name)
      object_name.to_s.delete("]").tr("[", "_")
    end
  end

  def broadcast_errors(model, attributes, attribute_names = {})
    return unless model&.errors&.messages

    resource = ActiveModel::Naming.param_key(model)
    form_selector = Optimism.send(:_selector_for, :form, resource)
    submit_selector = Optimism.send(:_selector_for, :submit, resource)

    attributes = case attributes
    when ActionController::Parameters, Hash, ActiveSupport::HashWithIndifferentAccess
      attributes.to_h
    when String, Symbol
      { attributes => nil }
    when Array
      attributes.flatten.each.with_object({}) { |attr, obj| obj[attr] = nil }
    else
      raise Exception.new "attributes must be a Hash (Parameters, Indifferent or standard), Array, Symbol or String"
    end

    attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
    attribute_names = ActiveSupport::HashWithIndifferentAccess.new(attribute_names)

    model.valid? if model.errors.empty?

    process_resource(model, attributes, attribute_names, [resource])

    if model.errors.any?
      cable_ready[Optimism.channel[self]].dispatch_event(name: "optimism:form:invalid", detail: {resource: resource}) if Optimism.emit_events
      cable_ready[Optimism.channel[self]].add_css_class(selector: form_selector, name: Optimism.form_class) if Optimism.form_class.present?
      cable_ready[Optimism.channel[self]].set_attribute(selector: submit_selector, name: "disabled") if Optimism.disable_submit
    else
      cable_ready[Optimism.channel[self]].dispatch_event(name: "optimism:form:valid", detail: {resource: resource}) if Optimism.emit_events
      cable_ready[Optimism.channel[self]].remove_css_class(selector: form_selector, name: Optimism.form_class) if Optimism.form_class.present?
      cable_ready[Optimism.channel[self]].remove_attribute(selector: submit_selector, name: "disabled") if Optimism.disable_submit
    end

    cable_ready.broadcast

    head :ok if defined?(head)
  end

  def process_resource(model, attributes, attribute_names, ancestry)
    attribute_names ||= ActiveSupport::HashWithIndifferentAccess.new({})

    attributes.keys.each do |attribute|
      if attribute.ends_with?("_attributes")
        resource = attribute[0..-12]
        association = model.send(resource.to_sym)
        if association.respond_to? :each_with_index
          association.each_with_index do |nested, index|
            process_resource(nested, attributes[attribute][index.to_s], attribute_names[attribute], ancestry + [resource, index]) if attributes[attribute].key?(index.to_s)
          end
        else
          process_resource(association, attributes[attribute], attribute_names[attribute], ancestry + [resource])
        end
      else
        process_attribute(model, attribute, attribute_names[attribute], ancestry.dup)
      end
    end
  end

  def process_attribute(model, attribute, attribute_name, ancestry)
    resource = ancestry.shift

    if ancestry.size == 1
      resource += "_#{ancestry.shift}_attributes"
    else
      resource += "_#{ancestry.shift}_attributes_#{ancestry.shift}" until ancestry.empty?
    end

    container_selector = Optimism.send(:_selector_for, :container, resource, attribute)
    error_selector = Optimism.send(:_selector_for, :error, resource, attribute)
    
    if model.errors.any? && model.errors.messages.map(&:first).include?(attribute.to_sym)
      err_msg = model.errors.messages[attribute.to_sym].first
      if attribute_name
        message = "#{attribute_name} #{err_msg}"
      elsif attribute_name == false
        message = err_msg
      else
        message = model.errors.full_message(attribute.to_sym, err_msg)
      end
      message.squish!

      cable_ready[Optimism.channel[self]].dispatch_event(name: "optimism:attribute:invalid", detail: {resource: resource, attribute: attribute, text: message}) if Optimism.emit_events
      cable_ready[Optimism.channel[self]].add_css_class(selector: container_selector, name: Optimism.error_class) if Optimism.add_css
      cable_ready[Optimism.channel[self]].text_content(selector: error_selector, text: message) if Optimism.inject_inline
    else
      cable_ready[Optimism.channel[self]].dispatch_event(name: "optimism:attribute:valid", detail: {resource: resource, attribute: attribute}) if Optimism.emit_events
      cable_ready[Optimism.channel[self]].remove_css_class(selector: container_selector, name: Optimism.error_class) if Optimism.add_css
      cable_ready[Optimism.channel[self]].text_content(selector: error_selector, text: "") if Optimism.inject_inline
    end
  end
end

module ActionView::Helpers
  class FormBuilder
    def container_for(attribute, **options, &block)
      @template.tag.div @template.capture(&block), options.merge!(id: container_id_for(attribute)) if block_given?
    end

    def container_id_for(attribute)
      Optimism.send(
        :_id_for,
        :container,
        Optimism.send(:_resource_from_object_name, object_name),
        attribute
      )
    end

    def error_for(attribute, **options)
      @template.tag.span options.merge! id: error_id_for(attribute)
    end

    def error_id_for(attribute)
      Optimism.send(
        :_id_for,
        :error,
        Optimism.send(:_resource_from_object_name, object_name),
        attribute
      )
    end
  end
end

class ActionController::Base
  include Optimism
end
