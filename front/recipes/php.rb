#
# Cookbook Name:: offerwall
# Recipe:: php
#

node.default['php']['version'] = '5.6.17'
node.default['php']['packages'] = %w(php56 php56-devel php56-cli php-pear)

%w{php56-gd php56-jsonc php56-jsonc-devel php56-mbstring php56-mcrypt php56-mysqlnd php56-opcache php56-pdo php56-process php56-soap php56-xml php56-pecl-memcache php56-pecl-memcached}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

include_recipe 'composer'
