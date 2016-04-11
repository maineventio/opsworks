#
# Cookbook Name:: offerwall
# Recipe:: php
#
# Copyright (c) 2016 SuperRewards, All Rights Reserved.

# TODO:
# - Make this all work for CentOS (our vagrant image) as well as CentOS

case node['platform']
when 'amazon'
  node.default['php']['version'] = '5.6.17'
  node.default['php']['packages'] = %w(php56 php56-devel php56-cli php-pear)
when 'centos'
  include_recipe 'yum-webtatic'
  node.default['php']['version'] = '5.6.18'
  node.default['php']['packages'] = %w(php56w php56w-devel php56w-cli php56w-pear)
end

include_recipe 'php'

case node['platform']
when 'amazon'
  package ['php56-gd', 'php56-jsonc', 'php56-jsonc-devel', 'php56-mbstring', 'php56-mcrypt', 'php56-mysqlnd', 'php56-opcache', 'php56-pdo', 'php56-process', 'php56-soap', 'php56-xml'] do
    action :upgrade
  end
  package ['php56-pecl-apcu', 'php56-pecl-memcache' ] do
    action :upgrade
  end
when 'centos'
  package ['php56w-gd', 'php56w-mbstring', 'php56w-mcrypt', 'php56w-mysqlnd', 'php56w-opcache', 'php56w-pdo', 'php56w-process', 'php56w-soap', 'php56w-xml'] do
    action :upgrade
  end
  package ['php56w-pecl-apcu', 'php56w-pecl-memcache'] do
    action :upgrade
  end
end

# Necessary for geoip pecl install
package ['gcc', 're2c'] do
  action :upgrade
end

php_pear 'geoip' do
  action :install
end

include_recipe 'composer'
include_recipe 'nodejs'
