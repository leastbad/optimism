require "fileutils"

desc "Inject some optimism into this application"
task :"optimism:install" do
  app_js_path = (Webpacker && Rails) ? Webpacker.config.source_path.relative_path_from(Rails.root) : "app/javascript"
  app_initializers_path = 'config/initializers'

  FILES = [
    { app_path: "#{app_js_path}/channels/optimism_channel.js", template_path: "../templates/optimism_channel.js" },
    { app_path: "app/channels/optimism_channel.rb", template_path: "../templates/optimism_channel.rb" },
    { app_path: 'config/initializers/optimism.rb', template_path: '../templates/optimism_initializer.rb' }
  ]

  FileUtils.mkdir_p "./#{app_js_path}/channels"

  FILES.each do |file|
    if File.exist?("./#{file[:app_path]}")
      $stderr.puts "=> [ skipping ] #{file[:app_path]} already exists"
    else
      FileUtils.cp(File.expand_path(file[:template_path], __dir__), "./#{file[:app_path]}")
      $stderr.puts "=> #{file[:app_path]} created"
    end
  end
end
