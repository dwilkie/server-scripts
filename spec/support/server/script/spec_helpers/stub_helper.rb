module Server
  module Script
    module SpecHelpers
      class StubHelper
        attr_accessor :subject

        def initialize(subject)
          self.subject = subject
        end

        def stub_hostname
          subject.stub(:`).with("hostname").and_return(server_name)
        end

        def server_name
          "server-name"
        end
      end
    end
  end
end
