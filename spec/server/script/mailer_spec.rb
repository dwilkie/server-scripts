require 'spec_helper'

describe Server::Script::Mailer do
  let(:mail_helper) { Server::Script::SpecHelpers::MailHelper.new }

  subject { build(:mailer) }

  describe "#alert!(message)" do
    let(:message) { "some alert message" }

    it "should send mail with the message as the subject" do
      subject.alert!(message)
      mail = mail_helper.last_mail
      mail.subject.should == message
      mail.to.should == subject.to
      mail.from.should == [subject.from]
    end
  end
end
