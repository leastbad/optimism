module Optimism
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/install.rake"
    end
  end
end
