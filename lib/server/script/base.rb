require_relative "mailer"

module Server
  module Script
    class Base

      private

      def host
        @host ||= `hostname`
      end

      def mailer
        @mailer ||= Mailer.new
      end
    end
  end
end
