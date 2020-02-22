require "pathname"

module Optimism
  class Railtie < Rails::Railtie
    railtie_name :optimism

    rake_tasks do
      load Pathname.new(__dir__).join("rake.rb")
    end
  end
end
