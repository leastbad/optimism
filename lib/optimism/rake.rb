require "fileutils"

desc "Inject some optimism into this application"
task :"optimism:install" do
  app_path_part = (Webpacker && Rails) ? Webpacker.config.source_path.relative_path_from(Rails.root) : "app/javascript"

  CHANNELS = [
    {app_path: "#{app_path_part}/channels/optimism_channel.js", template_path: "../templates/optimism_channel.js" },
    {app_path: "app/channels/optimism_channel.rb", template_path: "../templates/optimism_channel.rb" },
  ]

  CHANNELS.each do |channel|
    if File.exist?("./#{channel[:app_path]}")
      $stderr.puts "=> [ skipping ] #{channel[:app_path]} already exists"
    else
      FileUtils.cp(File.expand_path(channel[:template_path], __dir__), "./#{channel[:app_path]}")
      $stderr.puts "=> #{channel[:app_path]} created"
    end
  end
end
