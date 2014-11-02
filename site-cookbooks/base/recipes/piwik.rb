#
# Cookbook Name:: base::piwik
# Recipe:: piwik
#
# Copyright 2014, sharkpp
#
# The MIT License
#

include_recipe 'ya-piwik'

nginx_sites_available = "#{node['nginx']['dir']}/sites-available/localhost-piwik.conf"

template nginx_sites_available do
  source "nginx-piwik.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644
end
