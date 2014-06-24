require_relative "base"

module Server
  module Script
    class DiskUsage < ::Server::Script::Base
      attr_accessor :mount_point, :limit

      def initialize(options = {})
        self.mount_point = options[:mount_point] || ENV['MOUNT_POINT']
        self.limit = (options[:limit] || ENV['LIMIT']).to_i
      end

      def check!
        usage = `df -h #{mount_point}`.split(/\n/)[1]
        percentage = usage.split(/\s+/)[4].to_i
        mailer.alert!("Disk Usage on #{host} at #{mount_point} is over #{limit}%!") if percentage > limit
      end
    end
  end
end
