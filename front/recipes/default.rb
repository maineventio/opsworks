#
# Cookbook Name:: front
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Author:: Jeremy Quinton (<jeremyquinton at gmail.com>)
# Cookbook Name:: Composer
# from https://github.com/jeremyquinton/composer/blob/master/recipes/default.rb
script "install_composer" do
  interpreter "bash"
  user "#{node['composer']['user']}"
  cwd "/tmp"
  code <<-EOH
  curl -s https://getcomposer.org/installer | php -- --install-dir="#{node['composer']['install_dir']}"
  EOH
end

apache_site "default" do
  enable true
end

deploy 'mainevent-front' do
  repo 'git@github.com:maineventio/mainevent.git'
  user 'ubuntu'
  deploy_to '/var/www/mainevent'
  action :deploy
end

template "/etc/httpd/conf.d/mainevent.conf" do
  source "apache-mainevent.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart,"service[apache2]", :delayed
end

