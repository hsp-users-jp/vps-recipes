#
# Cookbook Name:: create_working_user
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

user_account 'john' do
    ssh_keygen true
    ssh_keys  ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXEvxZael5IUpch2GpX3U652wpx75IR3A7oRNs82mLuNGRwXx+WFQDaAX0rbIhxSluD/AUWrnXJlTKXkPrN31Wo9PU56T+h4I9f+m7u1Q/KZI2Bd7WY8XX5V1dWPWtL0EmKrvedj2Uh2SUPEbtFqR2YLBfIr1HL97BQ+J+cQh9BpiklJRD/D65eKQ+XZoeaXUwoUGuFfVkZJPBxx5ieAwe5PbGBJ00WhIgdvZQXpDKw3VqmBVfQpFFKnWCBVZf9pc2OYtrOahzf3fgN8uiugKrdrBrM/K5AR6x9r3l7PHwLE1SxXu92HJ+wyH0Z90rl6Ef6C8tKDQHPNh791VgCLKB samepp@mitsuki.local']
end
