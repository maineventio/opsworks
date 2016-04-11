#
# Cookbook Name:: offerwall
# Recipe:: apache
#
# Copyright (c) 2016 SuperRewards, All Rights Reserved.

node.default['apache']['version'] = '2.4'
node.default['apache']['ext_status'] = true

node.default['apache']['prefork']['startservers'] = '50'
node.default['apache']['prefork']['minspareservers'] = '16'
node.default['apache']['prefork']['maxspareservers'] = '16'
node.default['apache']['prefork']['serverlimit'] = '400'

# Set ports for production where we have a number of sites on different
# ports due to SSL
# - This may be possible to undo now that we're on Apache 2.4 and can
# vhost SSL sites
case node.chef_environment
when 'Production'
  node.default['apache']['listen_ports'] = ['80', '443', '8443', '8444', '8445']
when 'Vagrant'
  node.default['apache']['version'] = '2.2'
end

include_recipe 'apache2'
include_recipe 'apache2::mod_ssl'

case node['platform']
when 'amazon'
  package 'mod24_geoip' do
    action :upgrade
  end
when 'centos'
  package 'mod_geoip' do
    action :upgrade
  end
end

case node.chef_environment
when 'Production', 'Staging'
  # The current RPM for mod_cloudflare is not compatible with Apache 2.4 despite
  # their docs suggesting it is. We need to compile this in order for it to
  # work.
  remote_file "#{Chef::Config['file_cache_path']}/mod_cloudflare.c" do
    source 'https://www.cloudflare.com/static/misc/mod_cloudflare/mod_cloudflare.c'
    action :create
    not_if { File.exist?('/usr/lib64/httpd/modules/mod_cloudflare.so') }
  end
  package ['libtool', 'httpd24-devel'] do
    action :upgrade
  end
  execute 'mod_cloudflare' do
    command "apxs -i -c #{Chef::Config['file_cache_path']}/mod_cloudflare.c"
    not_if { File.exist?('/usr/lib64/httpd/modules/mod_cloudflare.so') }
  end
  apache_module 'cloudflare' do
    enable true
    conf true
  end
end

apache_module 'filter' do
  enable true
end

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

apache_module 'geoip' do
  conf true
  enable true
end

# Vhosts dependent upon environment
case node.chef_environment
when 'Staging'

  # Vhost
  web_app 'staging' do
    template 'vhosts/staging.conf.erb'
  end
  # SSL Certificate
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.crt' do
    source 'sslcerts/STAR_superrewards_com.crt'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.ca-bundle' do
    source 'sslcerts/STAR_superrewards_com.ca-bundle'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.key' do
    source 'sslcerts/STAR_superrewards_com.key'
    notifies :reload, 'service[apache2]'
  end

when 'Production'

  # Vhosts
  web_app '00-global_settings' do
    template 'vhosts/global.conf.erb'
  end
  web_app '10-superrewards-offers' do
    template 'vhosts/10-superrewards-offers_com.conf.erb'
  end
  web_app '20-kitnmedia' do
    template 'vhosts/20-kitnmedia_com.conf.erb'
  end
  web_app '25-sradmin_superrewards' do
    template 'vhosts/25-sradmin_superrewards_com.conf.erb'
  end
  web_app '30-wall_superrewards' do
    template 'vhosts/30-wall_superrewards_com.conf.erb'
  end
  web_app '40-pub_superrewards' do
    template 'vhosts/40-pub_superrewards_com.conf.erb'
  end
  web_app '50-sradmin_playerize' do
    template 'vhosts/50-sradmin_playerize_com.conf.erb'
  end
  web_app '90-misc_redirects' do
    template 'vhosts/90_misc_redirects.conf.erb'
  end
  # SSL Certificates
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.crt' do
    source 'sslcerts/STAR_superrewards_com.crt'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.ca-bundle' do
    source 'sslcerts/STAR_superrewards_com.ca-bundle'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.key' do
    source 'sslcerts/STAR_superrewards_com.key'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_kitnmedia_com.crt' do
    source 'sslcerts/STAR_kitnmedia_com.crt'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_kitnmedia_com.ca-bundle' do
    source 'sslcerts/STAR_kitnmedia_com.ca-bundle'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_kitnmedia_com.key' do
    source 'sslcerts/STAR_kitnmedia_com.key'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards-offers_com.crt' do
    source 'sslcerts/STAR_superrewards-offers_com.crt'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards-offers_com.ca-bundle' do
    source 'sslcerts/STAR_superrewards-offers_com.ca-bundle'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards-offers_com.key' do
    source 'sslcerts/STAR_superrewards-offers_com.key'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/wildcard.playerize.com.crt' do
    source 'sslcerts/wildcard.playerize.com.crt'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/wildcard.playerize.com.ca-bundle' do
    source 'sslcerts/wildcard.playerize.com.ca-bundle'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/wildcard.playerize.com.key' do
    source 'sslcerts/wildcard.playerize.com.key'
    notifies :reload, 'service[apache2]'
  end

  logrotate_app 'httpd' do
      cookbook 'logrotate'
      path '/var/log/httpd/*log'
      frequency 'daily'
      rotate 3
      options ['missingok', 'compress', 'sharedscripts']
      postrotate '/etc/init.d/httpd reload > /dev/null 2>/dev/null || true'
  end

when 'Development'

  # Vhost
  # SSL Certificate

when 'Vagrant'

  # Vhost
  web_app 'localdev' do
    template 'vhosts/localdev.conf.erb'
  end
  # htpasswd
  cookbook_file '/etc/httpd/wall.passwd' do
    source 'apache/wall.passwd'
  end
  # SSL Certificate
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.crt' do
    source 'sslcerts/STAR_superrewards_com.crt'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.ca-bundle' do
    source 'sslcerts/STAR_superrewards_com.ca-bundle'
    notifies :reload, 'service[apache2]'
  end
  cookbook_file '/etc/httpd/ssl/STAR_superrewards_com.key' do
    source 'sslcerts/STAR_superrewards_com.key'
    notifies :reload, 'service[apache2]'
  end

end

# TODO:

# - main apache config
# - vhosts
# - ssl certs for dev, vagrant & prod
# - htpasswd files
