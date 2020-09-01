require 'optimism/config/configuration'

module Optimism
  # The Config module adds configuration for the Optimism module,
  # which acts as a default for includers that haven't called #configure
  #
  # This means we can set Optimism options on a per-controller basis to
  # override the project-wide settings.
  #
  module Config
    def self.included(includer)
      config_method = []
      config_method << 'optimism' unless includer == Optimism
      config_method << 'config'
      config_method = config_method.join('_')

      configure_method = ['configure']
      configure_method << 'optimism' unless includer == Optimism
      configure_method = configure_method.join('_')

      configuration_method = []
      configuration_method << 'optimism' unless includer == Optimism
      configuration_method << 'configuration'
      configuration_method = configuration_method.join('_')

      includer.class_eval <<-RB
        class << self
          def #{config_method}(&block)
            if block_given?
              Optimism::Config.configure_context_for(self, &block)
            else
              Optimism::Config.context_for(self)
            end
          end

          alias_method :#{configure_method}, :#{config_method}
          alias_method :#{configuration_method}, :#{config_method}
          delegate_missing_to :#{config_method}
        end
      RB
    end

    def self.context_for(klass)
      return _context[Optimism] if klass == Optimism

      klass.ancestors.each do |k|
        break if k == Optimism

        return _context[k] if _context.include?(k)
      end

      _context[Optimism]
    end

    def self.configure_context_for(klass, &block)
      unless _context.include?(klass)
        parent_context = context_for(klass)

        _context[klass] = Optimism::Config::Configuration.new(klass)

        options.each do |option|
          _context[klass].send("#{option}=", parent_context.send(option))
        end
      end

      yield _context[klass] if block_given?

      _context[klass]
    end

    def self.options
      # Get the ancestors of the configuration class
      # (includes the configuration class as the first element)
      ancestry = Optimism::Config::Configuration.ancestors.dup

      # Shift the configuration class out and get its methods
      options = ancestry.shift.public_instance_methods

      # Get the methods of every ancestor and remove them, leaving
      # us with only the attribute accessor methods defined in
      # the configuration class
      options -= ancestry.map { |k| k.instance_methods }.flatten

      # Return the options, rejecting the attribute writers first.
      options.reject { |o| o.to_s.include?('=') }
    end

    private

    mattr_accessor :_context

    self._context = {
      Optimism => Optimism::Config::Configuration.new(Optimism)
    }
  end
end