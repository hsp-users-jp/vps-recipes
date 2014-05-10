#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'phpmyadmin'

nginx_sites_available = "#{node['nginx']['dir']}/sites-available/localhost-phpmyadmin.conf"

template nginx_sites_available do
  source "nginx-phpmyadmin.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644
end

phpmyadmin_db 'localhost' do
	host '127.0.0.1'
	port 3306
	username 'root'
	password 'qazwsx'
	hide_dbs %w{ information_schema mysql phpmyadmin performance_schema }
end
