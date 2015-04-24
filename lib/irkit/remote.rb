require 'faraday'
require 'faraday_middleware'
require 'json'

require 'irkit/remote/version'

module IRKit
  class Remote
    class Timeout < StandardError; end

    def initialize(client_key: nil, device_id: nil)
      @client_key = client_key
      @device_id  = device_id

      @connection = Faraday.new(url: 'https://api.getirkit.com/1') {|builder|
        builder.request  :url_encoded
        builder.response :json, content_type: /\bjson$/
        builder.response :logger
        builder.adapter  Faraday.default_adapter
      }
    end

    attr_accessor :client_key, :device_id
    attr_reader :connection

    def receive_message(client_key: self.client_key, clear: false)
      raise ArgumentError, 'client_key' unless client_key

      body = connection.get('messages', clientkey: client_key, clear: clear ? 1 : nil).body

      raise Timeout if body == ''

      body
    end

    def send_message(message, client_key: self.client_key, device_id: self.device_id)
      raise ArgumentError, 'client_key, device_id' unless client_key && device_id

      connection.post 'messages', clientkey: client_key, deviceid: device_id, message: message
    end
  end
end
