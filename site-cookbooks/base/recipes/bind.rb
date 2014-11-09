#
# Cookbook Name:: base::bind
# Recipe:: bind
#
# Copyright 2014, sharkpp
#
# The MIT License
#

bind_user = 'named'
bind_group= 'named'
bind_home = '/var/named'
root_hints_url = 'ftp://ftp.rs.internic.net/domain/named.root'
root_hints_path = "#{bind_home}/named.ca"

# make named group
group bind_group do
  action :create
end

# make named user
user bind_user do
  gid bind_group
  home bind_home
  shell "/bin/false"
  action :create
end

# install BIND9 package
package "bind" do
  action :install
end

# modified user and group
execute "modified user and group" do
  command <<-EOF
    chown -R "#{bind_user}:#{bind_group}" #{bind_home} /etc/named*
  EOF
  action :run
end

template "/etc/named.conf" do
  source "named.conf.erb"
  owner  bind_user
  group  bind_group
  action :create
end

template "/etc/named.special.zones" do
  source "named.special.zones.erb"
  owner  bind_user
  group  bind_group
  action :create
end

# ========================================================================

dns_ip = '192.168.33.10';

template "#{bind_home}/hsp-users.jp.zone" do
  source "named-xxx.zone.erb"
  owner  bind_user
  group  bind_group
  variables ({
          :domain     => 'hsp-users.jp.',
          :ttl        => '3600',
          :dns_server => 'ns1.hsp-users.jp.',
          :hostmaster => 'hostmaster@hsp-users.jp'.gsub(/@/, '.') + '.',
          :serial     => Date.today.strftime("%Y%m%d") + sprintf('%02d', ((DateTime.now - Date.today) * 100).to_i),
          :refresh    => '3600',
          :retry      => '1200',
          :expire     => '1209600',
          :minimum    => '900',
          :records => [
              { :name => '',    :type => 'NS',   :value => 'ns1.hsp-users.jp.' },
              { :name => '',    :type => 'NS',   :value => 'ns2.hsp-users.jp.' },
              { :name => '',    :type => 'MX',   :value => 'mail.hsp-users.jp.', :preference => '10' },
              { :name => '',    :type => 'TXT',  :value => '"v=spf1 mx ~all"' }, # SPF record
              { :name => '',    :type => 'A',    :value => dns_ip },
              { :name => 'ns1', :type => 'A',    :value => dns_ip },
              { :name => 'ns1', :type => 'A',    :value => dns_ip },
              { :name => 'ns2', :type => 'A',    :value => dns_ip },
              { :name => 'mail',:type => 'A',    :value => dns_ip },
              { :name => 'pkg', :type => 'A',    :value => dns_ip },
              { :name => 'www', :type => 'CNAME',:value => '@' }
            ]
    })
  action :create
end

template "#{bind_home}/#{dns_ip}.zone" do
  source "named-xxx.zone.erb"
  owner  bind_user
  group  bind_group
  variables ({
          :domain     => "#{dns_ip}-in-addr.arpa.",
          :ttl        => '3600',
          :dns_server => 'ns1.hsp-users.jp.',
          :hostmaster => 'hostmaster@hsp-users.jp'.gsub(/@/, '.') + '.',
          :serial     => Date.today.strftime("%Y%m%d") + sprintf('%02d', ((DateTime.now - Date.today) * 100).to_i),
          :refresh    => '3600',
          :retry      => '1200',
          :expire     => '1209600',
          :minimum    => '900',
          :records => [
              { :name => '',    :type => 'NS', :value => 'ns1.hsp-users.jp.' },
              { :name => '',    :type => 'NS', :value => 'ns2.hsp-users.jp.' },
              { :name => '',    :type => 'PTR',:value => 'hsp-users.jp.' },
            ]
        })
  action :create
end

template "/etc/named.hsp-users.jp.zones" do
  source "named-xxx.zones.erb"
  owner  bind_user
  group  bind_group
  variables :zones => [
    {
      :domain => 'hsp-users.jp',
      :path => 'hsp-users.jp.zone',
      :fields => [
          { :name => 'allow-transfer', :value => [ '124.34.146.122' ] },
          { :name => 'notify', :value => 'yes' },
          { :name => 'also-notify', :value => [ '124.34.146.122' ] }
        ]
    },
    {
      :domain => "#{dns_ip}-in-addr.arpa",
      :path => "#{dns_ip}.zone",
      :fields => [
          { :name => 'allow-transfer', :value => [ '124.34.146.122' ] },
          { :name => 'notify', :value => 'yes' },
          { :name => 'also-notify', :value => [ '124.34.146.122' ] }
        ]
    }
  ]
  action :create
end

# BIND service enable and start
service "named" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end

# Allow DNS port
simple_iptables_rule "dns" do
  rule [ "--proto tcp --dport 53",
         "--proto udp --dport 53" ]
  jump "ACCEPT"
end
