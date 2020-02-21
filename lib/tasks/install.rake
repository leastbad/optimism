# frozen_string_literal: true

namespace :optimism do
  desc "Inject some optimism into this application"
  task install: :environment do
    system "bundle exec rails generate channel optimism"

    filepath = Rails.root.join("app/channels/optimism_channel.rb")
    puts "Updating #{filepath}"

    content = <<~EOF
class OptimismChannel < ApplicationCable::Channel
  def subscribed
    stream_from "OptimismChannel"
  end
end
    EOF

    File.open(filepath, "w") { |f| f.write content }

    filepath = Rails.root.join("app/javascript/channels/optimism_channel.js")
    puts "Updating #{filepath}"
    content = <<~EOF
import consumer from "./consumer"

consumer.subscriptions.create("OptimismChannel", {
  received (data) {
    if (data.cableReady)
      CableReady.perform(data.operations, {
        emitMissingElementWarnings: false
      })
  }
})
    EOF

    File.open(filepath, "w") { |f| f.write content }
  end
end
