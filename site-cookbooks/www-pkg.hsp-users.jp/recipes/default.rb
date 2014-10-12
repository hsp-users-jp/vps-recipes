#
# Cookbook Name:: www-pkg.hsp-users.jp
# Recipe:: default
#
# Copyright 2014, sharkpp
#
# All rights reserved - Do Not Redistribute
#

o = ['!', '#', '$', '%', '&', '(', ')', '*', '+', ',', '-', '.', '/', ':', 
     ';', '<', '=', '>', '?', '@', '[', ']', '^', '_', '{', '|', '}', '~', 
     ('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a rescue i }.flatten

nginx_sites_available = "#{node['nginx']['dir']}/sites-available/pkg.hsp-users.jp"
nginx_sites_enabled   = "#{node['nginx']['dir']}/sites-enabled/pkg.hsp-users.jp"
db_users_root = data_bag_item('db_users', 'root')
db_users_pkg_hsp_users_jp = data_bag_item('db_users', 'pkg_hsp_users_jp')
install_dir = "/var/www/pkg.hsp-users.jp"

# enable pkg.hsp-users.jp
execute "enable-pkg.hsp-users.jp" do
  command <<-EOC
     ln -fs #{nginx_sites_available} #{nginx_sites_enabled}
  EOC
  not_if { ::File.exists?(nginx_sites_enabled) }
end

template nginx_sites_available do
  source "nginx.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644
  # reload conf request to nginx
  notifies :reload, "service[nginx]"
end

php_fpm "pkg.hsp-users.jp" do
  action :add
  user  'nginx'
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
    :chdir => "#{install_dir}",
    :error_log => "#{node['php']['fpm_log_dir']}/pkg.hsp-users.jp.error.log"
  })
  env_overrides({
    :FUEL_ENV => "production"
  })
end

mysql_connection_info = {
  :host     => 'localhost',
  :username => db_users_root['username'],
  :password => db_users_root['password']
}

mysql_database 'pkg_hsp_users_jp' do
  connection    mysql_connection_info
  action :create
end

mysql_database_user db_users_pkg_hsp_users_jp['username'] do
  connection    mysql_connection_info
  password      db_users_pkg_hsp_users_jp['password']
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

ya_piwik_site 'make piwik config' do
  idsite 1
  siteName 'pkg.hsp-users.jp'
  urls 'http://pkg.hsp-users.jp/'
  action :create
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
  repository "https://github.com/hsp-users-jp/pkg.hsp-users.jp.git"
  reference "master"
  action :sync
  enable_submodules true
end

# inatall composer packages
execute "composer-install" do
  command <<-EOC
     pushd "#{install_dir}"
     php composer.phar self-update
     php -d disable_functions="" composer.phar install
     popd
  EOC
end

ruby_block "create pkg.hsp-users.jp production configuration from template" do
  block do
    cookbook            = self.cookbook_name
    api                 = YaPiwik::API.new(run_context)
    idsite              = api.site_id_from_site_url('http://pkg.hsp-users.jp/')
    opauth_twitter      = data_bag_item('opauth', 'twitter')

    %w{db.php opauth.php piwik.php}.each do |file|
      tmpl = Chef::Resource::Template.new "#{install_dir}/fuel/app/config/#{file}", run_context
      tmpl.cookbook cookbook.to_s
      tmpl.source "fuel-#{file}.erb"
      tmpl.owner "root"
      tmpl.group "root"
      tmpl.mode 0644
      tmpl.variables({
          :piwik_token => api.token,
          :piwik_idsite => idsite,
          :db_pkg_hsp_users_jp => db_users_pkg_hsp_users_jp,
          :opauth_twitter_key => opauth_twitter['key'],
          :opauth_twitter_secret => opauth_twitter['secret'],
          :salt => (0...63).map { o[rand(o.length)] }.join
        })
      tmpl.run_action :create
    end
  end
  action :run
end

execute "migration" do
  command <<-EOC
     pushd "#{install_dir}"
     env FUEL_ENV=production php oil r migrate --all
     popd
  EOC
end
