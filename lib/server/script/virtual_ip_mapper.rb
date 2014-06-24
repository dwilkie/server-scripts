require_relative "base"

module Server
  module Script
    class VirtualIpMapper < ::Server::Script::Base
      attr_accessor :network_interface, :virtual_ip

      def initialize(options = {})
        self.network_interface = options[:network_interface] || ENV["NETWORK_INTERFACE"] || "eth0"
        self.virtual_ip = options[:virtual_ip] || ENV["VIRTUAL_IP"]
      end

      def map!
        if !local_ip_valid?
          mailer.alert!(error_message("Could not find a local ip for interface #{network_interface}"))
          return
        end

        if !has_ip_table_rules?
          mailer.alert!(error_message("Could not find any ip table rules"))
          return
        end

        return if ip_table_rule_exists?

        update_ip_tables_rule!
        mailer.alert!(success_message)
      end

      private

      def success_message
        "Successfuly updated the virtual ip mapping for #{virtual_ip} to #{local_ip} on #{host}"
      end

      def error_message(reason)
        "Failed to update the virtual ip mapping for #{virtual_ip} on #{host}. #{reason}"
      end

      def has_ip_table_rules?
        !ip_table_rules.empty?
      end

      def ip_table_rule_exists?
        ip_table_rules =~ /#{ip_tables_rule_command('A', local_ip)}/
      end

      def local_ip
        @local_ip ||= `/sbin/ifconfig #{network_interface} | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
      end

      def local_ip_valid?
        local_ip =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
      end

      def ip_table_rules
        @ip_table_rules ||= `sudo iptables-save`
      end

      def update_ip_tables_rule!
        `sudo iptables -t nat #{ip_tables_rule_command("A", local_ip)}`
      end

      def ip_tables_rule_command(action_switch, mapped_ip)
        "-#{action_switch} PREROUTING -d #{virtual_ip}/32 -j NETMAP --to #{mapped_ip}/32"
      end
    end
  end
end
