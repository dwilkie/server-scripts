require 'spec_helper'

module Server
  module Script
    describe DiskUsage do
      let(:mail_helper) { Server::Script::SpecHelpers::MailHelper.new }
      let(:limit) { 50 }

      subject { build(:disk_usage, :limit => limit) }

      describe "#check!" do
        let(:alert) { mail_helper.last_mail }
        let(:server_name) { "server-name" }

        def sample_df_output(percentage)
          "Filesystem      Size  Used Avail Use% Mounted on\n/dev/sda2       223G   41G  172G  #{percentage}% /\n"
        end

        before do
          subject.stub(:`).with("hostname").and_return(server_name)
          subject.stub(:`).with(/^df/).and_return(df_output)
          subject.check!
        end

        context "given the disk usage is over the limit" do
          let(:df_output) { sample_df_output(limit + 1) }
          it "should send an alert" do
            alert.should_not be_nil
            mail_subject = alert.subject
            mail_subject.should include(server_name)
            mail_subject.should include(limit.to_s)
            mail_subject.should include(subject.mount_point)
          end
        end

        context "given the disk usage is under the limit" do
          let(:df_output) { sample_df_output(limit) }

          it "should not send an alert" do
            alert.should be_nil
          end
        end
      end
    end
  end
end