# Server::Scripts

A set of useful server scripts

## Installation

Add this line to your application's Gemfile:

    gem 'server-scripts'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install server-scripts

## Configuration

### Mailer

The mailer should be configured to email alerts to the system administrator. Configuration for the mailer is done through environment variables. See [.env](https://github.com/dwilkie/server-scripts/blob/master/.env) for available configuration options.

#### Gmail

See [.env.gmail](https://github.com/dwilkie/server-scripts/blob/master/.env.gmail) for configuration options

## Usage

The [bin](https://github.com/dwilkie/server-scripts/tree/master/bin) directory contains the executable server scripts. If these scripts are being run on a production server, the [cron exporter](https://github.com/dwilkie/server-scripts-cron) is useful for creating wrapper scripts which can be executed by different environments such as cron.

## Scripts

### Disk Usage

[View source](https://github.com/dwilkie/server-scripts/tree/master/lib/server/script/disk_usage.rb)

Disk usage checks your disk usage and sends an alert if it's over your defined limit. You can export this to a cron job by using the [cron exporter](https://github.com/dwilkie/server-scripts-cron)

### Virtual IP Mapper

[View source](https://github.com/dwilkie/server-scripts/tree/master/lib/server/script/virtual_ip_mapper.rb)

This script is useful when configuring a VPN on Amazon EC2. Amazon EC2 uses DHCP to allocate your static local IP which [can change anytime](http://stackoverflow.com/questions/10733244/solution-for-local-ip-changes-of-aws-ec2-instances). You can use a Virtual IP and and iptables to route traffic sent to your virtual IP to your local ip. That way you can give out your virtual ip instead of your actual local IP. The following iptables command would add such a rule.

```
sudo iptables -t nat -A PREROUTING -d virtual_ip/32 -j NETMAP --to actual_local_ip/32
```

[Virtual IP Mapper](https://github.com/dwilkie/server-scripts/tree/master/lib/server/script/virtual_ip_mapper.rb) will automatically update your IP table rule when your static local IP address changes via DHCP.

To install the script use the [cron exporter](https://github.com/dwilkie/server-scripts-cron) adding the environment variables `NETWORK_INTERFACE` and `VIRTUAL_IP` to your `.env.production` in addition to your mailer config. Finally create a new file in `/etc/dhcp/dhclient-enter-hooks.d/virtual_ip_mapper` with the following code:

```
su - <user> -c '/path/to/exported/file/generated/from/cron/exporter'
```

Test the code by running:

```
sudo dhclient -v eth0
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
