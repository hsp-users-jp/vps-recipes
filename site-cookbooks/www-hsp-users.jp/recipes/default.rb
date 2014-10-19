#
# Cookbook Name:: www-hsp-users.jp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

nginx_sites_available = "#{node['nginx']['dir']}/sites-available/hsp-users.jp"
nginx_sites_enabled   = "#{node['nginx']['dir']}/sites-enabled/hsp-users.jp"
install_dir = "/var/www/hsp-users.jp"

# configure nginx for hsp-users.jp
template nginx_sites_available do
  source "nginx.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644
  # reload conf request to nginx
  notifies :reload, "service[nginx]"
end

# configure php-fpm for hsp-users.jp
php_fpm "hsp-users.jp" do
  action :add
  user  'nginx'
  group 'nginx'
  socket true
  socket_path '/var/run/php-fpm/hsp-users.jp.php-fpm.sock'
  socket_perms "0666"
#  start_servers 2
#  min_spare_servers 2
#  max_spare_servers 8
#  max_children 8
  terminate_timeout (node['php']['ini_settings']['max_execution_time'].to_i + 20)
  slow_filename "#{node['php']['fpm_log_dir']}/hsp-users.jp.slow.log"
  value_overrides({
    :chdir => "#{install_dir}",
    :error_log => "#{node['php']['fpm_log_dir']}/hsp-users.jp.error.log"
  })
  env_overrides({
    :FUEL_ENV => "production"
  })
end

# enable hsp-users.jp
execute "enable-hsp-users.jp" do
  command <<-EOC
     ln -fs #{nginx_sites_available} #{nginx_sites_enabled}
  EOC
  not_if { ::File.exists?(nginx_sites_enabled) }
end

# install git command
%w{git}.each do |pkg|
  package pkg do
    options "--enablerepo=remi"
#   action :install
  end
end

# checkout pkg.hsp-users.jp from github.com
git "#{install_dir}" do
  repository "https://github.com/hsp-users-jp/hsp-users.jp.git"
  reference "master"
  action :sync
  enable_submodules true
end
