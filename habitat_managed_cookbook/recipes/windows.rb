#
# Cookbook:: habitat_managed_cookbook
# Recipe:: windows
#
# Copyright:: 2019, The Authors, All Rights Reserved.
hab_install

hab_sup 'default'

hab_service "#{node['habitat_managed_cookbook']['origin']}/windows_baseline" do
  channel 'stable'
  strategy 'at-once'
end

hab_config 'windows_baseline.default' do
  config({
    'sleep_time' => 30,
    'reporter' => {
      'url' => node['habitat_managed_cookbook']['server_url'],
      'token' => node['habitat_managed_cookbook']['token']
    },
  })
end

hab_service "#{node['habitat_managed_cookbook']['origin']}/chef-base" do 
  channel 'stable'
  strategy 'at-once'
end

hab_config 'chef-base.default' do
  config({
    'interval' => 30,
    'splay' => 30,
    'data_collector' => {
      'enable' => true,
      'server_url' => node['habitat_managed_cookbook']['server_url'],
      'token' => node['habitat_managed_cookbook']['token']
    },
  })
end