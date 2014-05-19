module Server
  module Script
    module SpecHelpers
      class MailHelper
        def last_mail
          ::Mail::TestMailer.deliveries.last
        end
      end
    end
  end
end
