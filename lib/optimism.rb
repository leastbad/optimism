require "cable_ready"
require "optimism/version"
require "optimism/railtie" if defined?(Rails)

module Optimism
  mattr_accessor :channel_proc, :form_class, :error_class, :disable_submit, :suffix, :emit_events, :add_css, :inject_inline, :container_selector, :error_selector, :form_selector, :submit_selector
  self.channel_proc = ->(context) { "OptimismChannel" }
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

  def self.configure(&block)
    yield self
  end

  def broadcast_errors(model, attributes, reverse_attributes_for: [])
    return unless model&.errors&.messages
    resource = ActiveModel::Naming.param_key(model)
    form_selector, submit_selector = Optimism.form_selector.sub("RESOURCE", resource), Optimism.submit_selector.sub("RESOURCE", resource)
    attributes = case attributes
    when ActionController::Parameters, Hash, ActiveSupport::HashWithIndifferentAccess
      attributes.to_h
    when String, Symbol
      { attributes.to_s => nil }
    when Array
      attributes.flatten.each.with_object({}) { |attr, obj| obj[attr.to_s] = nil }
    else
      raise Exception.new "attributes must be a Hash (Parameters, Indifferent or standard), Array, Symbol or String"
    end
    model.valid? if model.errors.empty?
    process_resource(model, attributes, [resource], reverse_attributes_for: reverse_attributes_for)
    if model.errors.any?
      CableReady::Channels.instance[Optimism.channel_proc[self]].dispatch_event(name: "optimism:form:invalid", detail: {resource: resource}) if Optimism.emit_events
      CableReady::Channels.instance[Optimism.channel_proc[self]].add_css_class(selector: form_selector, name: Optimism.form_class) if Optimism.form_class.present?
      CableReady::Channels.instance[Optimism.channel_proc[self]].set_attribute(selector: submit_selector, name: "disabled") if Optimism.disable_submit
    else
      CableReady::Channels.instance[Optimism.channel_proc[self]].dispatch_event(name: "optimism:form:valid", detail: {resource: resource}) if Optimism.emit_events
      CableReady::Channels.instance[Optimism.channel_proc[self]].remove_css_class(selector: form_selector, name: Optimism.form_class) if Optimism.form_class.present?
      CableReady::Channels.instance[Optimism.channel_proc[self]].remove_attribute(selector: submit_selector, name: "disabled") if Optimism.disable_submit
    end
    CableReady::Channels.instance.broadcast
    head :ok if defined?(head)
  end

  def process_resource(model, attributes, ancestry, reverse_attributes_for: [])
    attributes.keys.each do |attribute|
      if attribute.ends_with?("_attributes")
        resource = attribute[0..-12]
        association = model.send(resource.to_sym)
        association = association.reverse if reverse_attributes_for.include?(resource.to_sym)
        if association.respond_to? :each_with_index
          association.each_with_index do |nested, index|
            process_resource(nested, attributes[attribute][index.to_s], ancestry + [resource, index]) if attributes[attribute].key?(index.to_s)
          end
        else
          process_resource(association, attributes[attribute], ancestry + [resource])
        end
      else
        process_attribute(model, attribute, ancestry.dup)
      end
    end
  end

  def process_attribute(model, attribute, ancestry)
    resource = ancestry.shift
    if ancestry.size == 1
      resource += "_#{ancestry.shift}_attributes"
    else
      resource += "_#{ancestry.shift}_attributes_#{ancestry.shift}" until ancestry.empty?
    end
    container_selector, error_selector = Optimism.container_selector.sub("RESOURCE", resource).sub("ATTRIBUTE", attribute), Optimism.error_selector.sub("RESOURCE", resource).sub("ATTRIBUTE", attribute)
    if model.errors.any?
      if attribute.ends_with?("_id") && model.errors.messages.include?(attribute.delete_suffix("_id").to_sym)
        model.errors.messages[attribute.delete_suffix("_id").to_sym].each do |msg|
          model.errors.add(attribute.to_sym, msg)
        end
      end
      if model.errors.messages.map(&:first).include?(attribute.to_sym)
        message = "#{model.errors.full_message(attribute.to_sym, model.errors.messages[attribute.to_sym].first)}#{Optimism.suffix}"
        CableReady::Channels.instance[Optimism.channel_proc[self]].dispatch_event(name: "optimism:attribute:invalid", detail: {resource: resource, attribute: attribute, text: message}) if Optimism.emit_events
        CableReady::Channels.instance[Optimism.channel_proc[self]].add_css_class(selector: container_selector, name: Optimism.error_class) if Optimism.add_css
        CableReady::Channels.instance[Optimism.channel_proc[self]].text_content(selector: error_selector, text: message) if Optimism.inject_inline
      else
        CableReady::Channels.instance[Optimism.channel_proc[self]].dispatch_event(name: "optimism:attribute:valid", detail: {resource: resource, attribute: attribute}) if Optimism.emit_events
        CableReady::Channels.instance[Optimism.channel_proc[self]].remove_css_class(selector: container_selector, name: Optimism.error_class) if Optimism.add_css
        CableReady::Channels.instance[Optimism.channel_proc[self]].text_content(selector: error_selector, text: "") if Optimism.inject_inline
      end
    end
  end
end

module ActionView::Helpers
  module FormHelper
    def error_for(object_name, attribute, **options)
      tag.span **options.merge(id: error_id_for(object_name, attribute))
    end

    def error_id_for(object_name, attribute)
      Optimism.error_selector.sub("RESOURCE", object_name.to_s.delete("]").tr("[", "_")).sub("ATTRIBUTE", attribute.to_s)[1..-1]
    end
  end

  class FormBuilder
    def container_for(attribute, **options, &block)
      @template.tag.div @template.capture(&block), **options.merge(id: container_id_for(attribute)) if block_given?
    end

    def container_id_for(attribute)
      Optimism.container_selector.sub("RESOURCE", object_name.to_s.delete("]").tr("[", "_")).sub("ATTRIBUTE", attribute.to_s)[1..-1]
    end

    def error_for(attribute, **options)
      @template.error_for(object_name, attribute, **options)
    end
  end
end

class ActionController::Base
  include Optimism
end
