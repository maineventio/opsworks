#
# Cookbook Name:: front
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node.default['php']['directives'] = {
  'short_open_tag' => 'On',
  'memory_limit' => '1024M',
  'max_execution_time' => '120',
  'error_reporting' => 'E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING',
  'date.timezone' => '\'America/Vancouver\'',
  'expose_php' => 'Off'
}

include_recipe 'front::php'

deploy 'mainevent-front' do
  repo 'https://github.com/maineventio/main-event.git'
  deploy_to '/var/www/mainevent'
  action :deploy
  # irrelevant symlinks http://stackoverflow.com/questions/12568767/chef-deployment-with-irrelevant-default-symlinks
  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear
end

#include_recipe 'front::apache'
node.default['apache']['version'] = '2.4'
node.default['apache']['ext_status'] = true
include_recipe 'apache2'
#include_recipe 'apache2::mod_ssl'
include_recipe 'apache2::mod_php5'

#case node['platform']
#when 'amazon'
#  apache_module 'php5' do
#    filename 'libphp-5.6.so'
#    conf true
#    enable true
#  end
#when 'centos'
#  apache_module 'php5' do
#    filename 'libphp5.so'
#    conf true
#    enable true
#  end
#end


#apache_site "default" do
#  enable true
#end

template "/etc/httpd/conf.d/mainevent.conf" do
  source "apache-mainevent.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart,"service[apache2]", :delayed
end
