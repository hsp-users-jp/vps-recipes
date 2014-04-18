#
# Cookbook Name:: www-pkg.hsp-users.jp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/nginx/sites-available/pkg.hsp-users.jp" do
  source "nginx.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644

  # reload conf request to nginx
  notifies :reload, "service[nginx]"
end

# enable pkg.hsp-users.jp
execute "enable-pkg.hsp-users.jp" do
  command <<-EOC
     ln -fs /etc/nginx/sites-available/pkg.hsp-users.jp /etc/nginx/sites-enabled/
  EOC
end

php_fpm "pkg.hsp-users.jp" do
  action :add
  user 'nginx'
  group 'nginx'
  socket true
  socket_path '/var/run/php-fpm/pkg.hsp-users.jp.php-fpm.sock'
  socket_perms "0666"
#  start_servers 2
#  min_spare_servers 2
#  max_spare_servers 8
#  max_children 8
  terminate_timeout (node['php']['ini_settings']['max_execution_time'].to_i + 20)
  slow_filename "#{node['php']['fpm_log_dir']}/pkg.hsp-users.jp.slow.log"
  value_overrides({
    :error_log => "#{node['php']['fpm_log_dir']}/pkg.hsp-users.jp.error.log"
  })
end

# install git command
%w{git}.each do |pkg|
    package pkg do
#        options "--enablerepo=remi"
        action :install
    end
end

#mysql> GRANT SELECT , INSERT , UPDATE , DELETE ON *.* TO ユーザＩＤ@"localhost" IDENTIFIED BY "パスワード";
#mysql> FLUSH PRIVILEGES;
#GRANT SELECT , INSERT , UPDATE , DELETE , CREATE , DROP , INDEX , ALTER , CREATE TEMPORARY TABLES , CREATE VIEW , EVENT, TRIGGER, SHOW VIEW , CREATE ROUTINE , ALTER ROUTINE , EXECUTE ON `pkg_hsp_users_jp`.* TO 'fuel_app'@'localhost' IDENTIFIED BY "パスワード";

mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database 'pkg_hsp_users_jp' do
  connection    mysql_connection_info
  action :create
end

mysql_database_user 'pkg_admin' do
  connection    mysql_connection_info
  password      'super_secret****a'
  database_name 'pkg_hsp_users_jp'
  host          'localhost'
  privileges    [:all]
  action        :grant
end

mysql_database_user 'pkg_user' do
  connection    mysql_connection_info
  password      'super_secret****b'
  database_name 'pkg_hsp_users_jp'
  host          'localhost'
  privileges    [:select,:insert,:update,:delete]
  action        :grant
end

mysql_database 'flush the privileges' do
  connection mysql_connection_info
  sql        'flush privileges'
  action     :query
end

# checkout pkg.hsp-users.jp from github.com
git "/var/www/pkg.hsp-users.jp" do
  repository "https://github.com/hsp-users-jp/pkg.hsp-users.jp.git"
  reference "master"
  action :sync
  enable_submodules true
end

# inatall composer packages
execute "composer-install" do
  command <<-EOC
     pushd /var/www/pkg.hsp-users.jp/
     php composer.phar self-update
     php composer.phar install
     popd
  EOC
end
