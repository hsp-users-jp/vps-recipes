#
# Cookbook Name:: base::phpmyadmin
# Recipe:: phpmyadmin
#
# Copyright 2014, sharkpp
#
# The MIT License
#

include_recipe 'phpmyadmin'

db_users_root = data_bag_item('db_users', 'root')

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
	username db_users_root['username']
	password db_users_root['password']
	hide_dbs %w{ information_schema mysql phpmyadmin performance_schema }
end
