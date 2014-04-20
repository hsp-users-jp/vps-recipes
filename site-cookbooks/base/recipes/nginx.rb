#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/nginx/sites-available/localhost" do
  source "nginx-localhost.conf.erb"
  # owner and group is root user, and permition is 644
  owner "root"
  group "root"
  mode 0644
end

# enable localhost
execute "enable localhost" do
  command <<-EOC
     ln -fs /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/000-localhost
  EOC

  # reload conf request to nginx
  notifies :reload, "service[nginx]"
end
