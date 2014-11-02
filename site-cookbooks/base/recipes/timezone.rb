#
# Cookbook Name:: base::timezone
# Recipe:: timezone
#
# Copyright 2014, sharkpp
#
# The MIT License
#

execute "copy-asia-tokyo-timezone" do
  command <<-EOC
     cp -pf "/usr/share/zoneinfo/Asia/Tokyo" "/etc/localtime"
  EOC
end
