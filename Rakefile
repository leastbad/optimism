require 'bundler/gem_tasks'
require_relative 'lib/optimism/rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

task :c => :console
task :console do
  require 'active_support/all'
  require 'action_view'
  require 'byebug'
  require 'pry'

  unless defined?(ActionController::Base)
    module ActionController
      class Base
      end
    end
  end

  require 'optimism'

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/optimism\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end
