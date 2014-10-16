#
# Cookbook Name:: timezone
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "copy-asia-tokyo-timezone" do
  command <<-EOC
     cp -pf "/usr/share/zoneinfo/Asia/Tokyo" "/etc/localtime"
  EOC
end
