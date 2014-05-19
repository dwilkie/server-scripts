require "./lib/server/script/disk_usage"
require "./lib/server/script/mailer"

FactoryGirl.define do
  factory :disk_usage, :class => Server::Script::DiskUsage do
    skip_create

    mount_point { "/" }
    limit { "90" }

    initialize_with { new(attributes) }
  end

  factory :mailer, :class => Server::Script::Mailer do
    skip_create
    from { "server-admin-from@example.com" }
    to { ["server-admin-to@example.com"] }
  end
end
