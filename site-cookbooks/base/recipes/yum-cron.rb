#
# Cookbook Name:: base::yum-cron
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
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
