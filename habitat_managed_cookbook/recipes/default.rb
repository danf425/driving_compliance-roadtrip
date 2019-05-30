#
# Cookbook:: habitat_managed_cookbook
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
hab_install do
  license 'accept'
end

hab_sup 'default'


if node['os'] == 'linux'
  include_recipe 'habitat_managed_cookbook::linux'
elsif node['os'] == 'windows'
  include_recipe 'habitat_managed_cookbook::windows'
end