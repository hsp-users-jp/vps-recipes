#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash 'add_hostname_to_hosts' do
  cwd "/etc/"
  code <<-EOH
    ifconfig | grep "inet " | grep -v "127.0.0.1" | while read line
    do
      IP=$(echo $line|cut -d ":" -f 2|cut -d " " -f 1)
      cat /etc/hosts | grep -v "$IP" > /etc/hosts~
      echo $IP vagrant-centos65 vagrant-centos65.vagrantup.com vagrant-centos65 vagrant-centos65.vagrantup.com >> /etc/hosts~
      mv /etc/hosts~ /etc/hosts
    done
  EOH
end
