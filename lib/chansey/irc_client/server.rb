module Chansey
  module IrcClient
    class Server
      def initialize(connection, config)
        @config = config
        @connection = connection
        @connection.on_message(&method(:on_message))

        @connection.send_data "NICK #{@config['nick']}"
        @connection.send_data "USER #{@config['user']} 8 * :#{@config['fullname']}"
      end

      private
      def on_message(message)
        case message[:command]
        when :ping
          @connection.send_data "PONG :#{message[:trailing]}"
        end
      end
    end
  end
end
