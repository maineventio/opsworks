
remote_file "#{Chef::Config[:file_cache_path]}/logstash.rpm" do
    source "#{node['logstash']['rpm_url']}"
    action :create
end

rpm_package "logstash-rpm" do
    source "#{Chef::Config[:file_cache_path]}/logstash.rpm"
    action :install
end

execute "install_es_plugin" do
    cwd "/opt/logstash"
    command "bin/plugin install logstash-output-amazon_es"
end

execute "install_geoip_plugin" do
    cwd "/opt/logstash"
    command "bin/plugin install logstash-filter-geoip"
end

service "logstash" do
  action :enable
  supports :status => true, :start => true, :stop => true, :restart => true
end
