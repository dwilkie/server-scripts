require 'mail'

options = {
  :address => ENV["MAIL_SMTP_SERVER"] || "localhost",
  :port    => ENV["MAIL_SMTP_SERVER_PORT"] || 25,
}

options.merge!(:user_name => ENV["MAIL_USER_NAME"]) if ENV["MAIL_USER_NAME"]
options.merge!(:password => ENV["MAIL_PASSWORD"]) if ENV["MAIL_PASSWORD"]
options.merge!(:authentication => ENV["MAIL_AUTHENTICATION"].to_sym) if ENV["MAIL_AUTHENTICATION"]
options.merge!(:enable_starttls_auto => true) if ENV["MAIL_ENABLE_START_TLS_AUTO"].to_i == 1

Mail.defaults do
  delivery_method(:smtp, options)
end
