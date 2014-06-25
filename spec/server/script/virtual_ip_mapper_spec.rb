require 'spec_helper'

describe Server::Script::VirtualIpMapper do
  subject { build(:virtual_ip_mapper) }

  let(:mail_helper) { Server::Script::SpecHelpers::MailHelper.new }
  let(:stub_helper) { Server::Script::SpecHelpers::StubHelper.new(subject) }
  let(:alert) { mail_helper.last_mail }

  describe "#map!" do
    def stub_local_ip(return_value)
      subject.stub(:`).with(/^\/sbin\/ifconfig/).and_return(return_value)
    end

    def stub_iptables_rules(return_value)
      subject.stub(:`).with(/^sudo iptables-save/).and_return(return_value)
    end

    let(:local_ip) { "192.168.1.161" }
    let(:mapped_local_ip) { "192.168.1.160" }

    let(:ip_tables_rules_result) {
      "# Generated by iptables-save v1.4.21 on Tue Jun 24 17:15:24 2014\n*filter\n:INPUT ACCEPT [1196909:722306742]\n:FORWARD ACCEPT [0:0]\n:OUTPUT ACCEPT [1057639:276268015]\nCOMMIT\n# Completed on Tue Jun 24 17:15:24 2014\n# Generated by iptables-save v1.4.21 on Tue Jun 24 17:15:24 2014\n*nat\n:PREROUTING ACCEPT [5813:1626537]\n:INPUT ACCEPT [1023:135366]\n:OUTPUT ACCEPT [2400:235425]\n:POSTROUTING ACCEPT [2400:235425]\n-A PREROUTING -d #{subject.virtual_ip}/32 -j NETMAP --to #{mapped_local_ip}/32\n-A POSTROUTING -d 54.251.107.12/32 -j SNAT --to-source 27.109.112.25\n-A POSTROUTING -d 54.251.107.12/32 -j SNAT --to-source 27.109.112.25\nCOMMIT\n# Completed on Tue Jun 24 17:15:24 2014\n"
    }

    let(:local_ip_result) { "#{local_ip}\n" }

    before do
      stub_local_ip(local_ip_result)
      stub_iptables_rules(ip_tables_rules_result)
    end

    def assert_alert_message!(mail_subject)
      mail_subject.should include(stub_helper.server_name)
    end

    context "failures" do
      before do
        stub_helper.stub_hostname
      end

      context "No local ip address could be found for the given interface" do
        let(:local_ip) { "" }

        it "should send out an alert" do
          subject.map!
          alert.should_not be_nil
          mail_subject = alert.subject
          assert_alert_message!(mail_subject)
          mail_subject.should include(subject.network_interface)
        end
      end

      context "No ip table rules were found" do
        let(:ip_tables_rules_result) { "" }

        it "should send out an alert" do
          subject.map!
          alert.should_not be_nil
          mail_subject = alert.subject
          assert_alert_message!(mail_subject)
          mail_subject.should include("ip table rules")
        end
      end
    end

    context "existing rule for local ip" do
      let(:mapped_local_ip) { local_ip }

      it "should do nothing" do
        subject.map!
        alert.should be_nil
      end
    end

    context "no rule for local ip" do
      before do
        stub_update_ip_tables_rule("D", mapped_local_ip)
        stub_update_ip_tables_rule("A", local_ip)
        stub_helper.stub_hostname
      end

      def update_ip_tables_rule_command(switch, mapped_ip)
        "sudo iptables -t nat -#{switch} PREROUTING -d #{subject.virtual_ip}/32 -j NETMAP --to #{mapped_ip}/32"
      end

      def stub_update_ip_tables_rule(switch, mapped_ip)
        subject.stub(:`).with(update_ip_tables_rule_command(switch, mapped_ip))
      end

      def assert_update_ip_tables_rule!(switch, mapped_ip)
        subject.should_receive(:`).with(update_ip_tables_rule_command(switch, mapped_ip))
      end

      it "should update the rule" do
        assert_update_ip_tables_rule!("D", mapped_local_ip)
        assert_update_ip_tables_rule!("A", local_ip)
        subject.map!
      end

      it "should send out an alert" do
        subject.map!
        alert.should_not be_nil
        mail_subject = alert.subject
        assert_alert_message!(mail_subject)
        mail_subject.should include(subject.virtual_ip)
        mail_subject.should include(local_ip)
      end
    end
  end
end
