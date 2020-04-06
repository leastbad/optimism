require "fileutils"

desc "Inject some optimism into this application"
task :"optimism:install" do
  CHANNELS = [
    {app_path: "app/javascript/channels/optimism_channel.js", template_path: "../templates/optimism_channel.js" },
    {app_path: "app/channels/optimism_channel.rb", template_path: "../templates/optimism_channel.rb" },
  ]

  FileUtils.mkdir_p "./app/javascript/channels"

  CHANNELS.each do |channel|
    if File.exist?("./#{channel[:app_path]}")
      $stderr.puts "=> [ skipping ] #{channel[:app_path]} already exists"
    else
      FileUtils.cp(File.expand_path(channel[:template_path], __dir__), "./#{channel[:app_path]}")
      $stderr.puts "=> #{channel[:app_path]} created"
    end
  end
end
