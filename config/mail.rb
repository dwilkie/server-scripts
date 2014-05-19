require 'mail'

options = {
  :address => "localhost",
  :port    => 25
}

Mail.defaults do
  delivery_method(:smtp, options)
end
