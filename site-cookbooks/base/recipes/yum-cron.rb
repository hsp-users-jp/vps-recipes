#
# Cookbook Name:: base::yum-cron
# Recipe:: yum-cron
#
# Copyright 2014, sharkpp
#
# The MIT License
#

package 'yum-cron' do
    options "--enablerepo=remi"
    action :install
end

template '/etc/sysconfig/yum-cron' do
  source "yum-cron.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service 'yum-cron' do
    action :enable
end

service 'yum-cron' do
    action :start
end
