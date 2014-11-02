#
# Cookbook Name:: create_working_user
# Recipe:: default
#
# Copyright 2014, sharkpp
#
# All rights reserved - Do Not Redistribute
#

user = data_bag_item('users', 'user')

user_account user['username'] do
    ssh_keygen true
    ssh_keys   [user['ssh_key']]
end
