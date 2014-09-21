class PubnubClient
  def self.client
    @client ||= subscribe_key.blank? ? NullClient.new : Pubnub.new(
      subscribe_key: subscribe_key,
      publish_key: ENV['PUBNUB_PUBLISH_KEY'],
      origin: ENV['PUBNUB_ORIGIN'],
      logger: Rails.logger
      )
  end

  def self.subscribe_key
    ENV['PUBNUB_SUBSCRIBE_KEY']
  end

  class NullClient
    def publish *args

    end
  end
end