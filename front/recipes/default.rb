#
# Cookbook Name:: front
# Recipe:: default
#
# Copyright 2014, Main Event
#
# All rights reserved
#

# Things we want in the PHP INI
node.default['php']['directives'] = {
  'short_open_tag' => 'On',
  'memory_limit' => '1024M',
  'max_execution_time' => '120',
  'error_reporting' => 'E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING',
  'date.timezone' => '\'America/Vancouver\'',
  'expose_php' => 'Off'
}

# Ensure all PHP packages installed
include_recipe 'front::php'

# Other packages we like
%w{mysql telnet wget}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

# Deploy latest MainEvent repo
deploy 'mainevent-front' do
  repo 'https://github.com/maineventio/mainevent.git'
  deploy_to '/var/www/mainevent'
  action :deploy
  # irrelevant symlinks http://stackoverflow.com/questions/12568767/chef-deployment-with-irrelevant-default-symlinks
  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear
end

# Run composer
execute "composer install" do
  cwd '/var/www/mainevent/current/event-api'
  command 'composer install'
end

# Laravel .env file
# Some good notes: http://stackoverflow.com/questions/30634338/how-can-i-pull-opsworks-variables-into-a-env-file-with-chef/30641803
template "/var/www/mainevent/current/event-api/.env" do
  source 'env.erb'
  mode '0660'
end

# Because Ross says so...
case node['platform']
when 'amazon'
  apache_module 'php5' do
    filename 'libphp-5.6.so'
    conf true
    enable true
  end
when 'centos'
  apache_module 'php5' do
    filename 'libphp5.so'
    conf true
    enable true
  end
end

# Deploy the Apache conf
web_app "mainevent" do
  template 'mainevent.conf.erb'
  server_name node[:mainevent][:front_dnsname]
end




