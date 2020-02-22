class OptimismChannel < ApplicationCable::Channel
  def subscribed
    stream_from "OptimismChannel"
  end
end
