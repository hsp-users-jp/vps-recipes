#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/nginx/sites-available/phpmyadmin" do
  source "nginx-phpmyadmin.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644

  # reload conf request to nginx
  notifies :reload, "service[nginx]"
end

# enable phpmyadmin
execute "enable-phpmyadmin" do
  command <<-EOC
     ln -fs /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/010-phpmyadmin
  EOC
end
