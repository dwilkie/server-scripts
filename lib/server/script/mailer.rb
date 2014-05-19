require_relative "../../../config/mail"

module Server
  module Script
    class Mailer
      attr_accessor :from, :to

      def initialize(options = {})
        self.from = options[:from] || ENV["SERVER_SCRIPT_FROM_EMAIL"]
        self.to = [options[:to] || ENV["SERVER_SCRIPT_TO_EMAILS"].to_s.split(";")].compact.flatten
      end

      def alert!(message)
        from_address = from
        to_addresses = to

        Mail.deliver do
          subject(message)
          from(from_address)
          to(to_addresses)
        end
      end
    end
  end
end
