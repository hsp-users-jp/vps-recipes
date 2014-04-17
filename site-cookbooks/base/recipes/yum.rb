#
# Cookbook Name:: base::yum
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# add the EPEL repo
yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
  fastestmirror_enabled true
  gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  action :create
end

# add the Remi repo
yum_repository 'remi' do
  description 'Les RPM de Remi - Repository'
  baseurl 'http://rpms.famillecollet.com/enterprise/6/remi/x86_64/'
  gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
  fastestmirror_enabled true
  action :create
end

#%w{rsync}.each do |pkg|
#    package pkg do
#        options "--enablerepo=remi"
#        action :install
#    end
#end

# %w{mysql-server php php-pear php-mbstring php-xml php-devel php-mysql php-gd}.each do |pkg|
#     package pkg do
#         options "--enablerepo=remi"
#         action :install
#     end
# end
