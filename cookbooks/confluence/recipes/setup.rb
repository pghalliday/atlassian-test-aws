atlassian_home = '/var/atlassian/application-data'
confluence_user = 'confluence'
confluence_group = 'confluence'
# rubocop:disable Metrics/LineLength
confluence_checksum = '17eae4db5f08e7829f465aa6a98d7bcfe30d335afc97c52f57472c91bbe88da8'
# rubocop:enable Metrics/LineLength
confluence_basename = 'atlassian-confluence-5.7.1'
confluence_install_dir = '/opt/atlassian/confluence'
confluence_home = ::File.join(atlassian_home, 'confluence')
confluence_tarball = "#{confluence_basename}.tar.gz"
# rubocop:disable Metrics/LineLength
confluence_url = "https://www.atlassian.com/software/confluence/downloads/binary/#{confluence_tarball}"
# rubocop:enable Metrics/LineLength

confluence_database = 'confluence'
confluence_database_user = 'confluence'
confluence_database_password = 'confluence'

confluence_port = node['atlassian-test']['confluence']['port']
confluence_redirect_port = node['atlassian-test']['confluence']['redirect_port']
confluence_proxy_port = node['atlassian-test']['proxy_port']
confluence_proxy_host = node['atlassian-test']['confluence']['proxy_host']
confluence_db_host = node['atlassian-test']['database']['address']
confluence_db_port = node['atlassian-test']['database']['port']

postgresql_connection_info = {
  host: confluence_db_host,
  port: confluence_db_port,
  username: node['atlassian-test']['database']['username'],
  password: node['atlassian-test']['database']['password']
}

include_recipe 'confluence::service'
include_recipe 'confluence::backup'

node.override['java']['jdk_version'] = '7'
node.override['java']['install_flavor'] = 'oracle'
node.override['java']['oracle']['accept_oracle_download_terms'] = true
include_recipe 'java::default'

directory atlassian_home do
  recursive true
end

group confluence_group do
  system true
end

user confluence_user do
  supports manage_home: true
  home confluence_home
  system true
  gid confluence_group
  notifies :restore, 'backup_home[confluence]', :immediately
end

directory confluence_install_dir do
  recursive true
end

remote_file ::File.join(confluence_install_dir, confluence_tarball) do
  source confluence_url
  checksum confluence_checksum
  notifies :run, 'bash[install confluence]', :immediately
end

bash 'install confluence' do
  code <<-EOH
  tar zxf #{confluence_tarball}
  ln -s #{confluence_basename} current
  chown -R #{confluence_user}:#{confluence_group} current/logs
  chown -R #{confluence_user}:#{confluence_group} current/work
  chown -R #{confluence_user}:#{confluence_group} current/temp
  EOH
  cwd confluence_install_dir
  action :nothing
  notifies :restart, 'service[confluence]', :delayed
end

init_props = 'current/confluence/WEB-INF/classes/confluence-init.properties'
template ::File.join(confluence_install_dir, init_props) do
  source 'confluence-init.properties.erb'
  variables(
    home: confluence_home
  )
  notifies :restart, 'service[confluence]', :delayed
end

template ::File.join(confluence_install_dir, 'current/conf/server.xml') do
  source 'server.xml.erb'
  variables(
    port: confluence_port,
    redirect_port: confluence_redirect_port,
    proxy_host: confluence_proxy_host,
    proxy_port: confluence_proxy_port
  )
  notifies :restart, 'service[confluence]', :delayed
end

include_recipe 'database::postgresql'

postgresql_database confluence_database do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user confluence_database_user do
  connection postgresql_connection_info
  password confluence_database_password
  action :create
end

postgresql_database_user confluence_database_user do
  connection postgresql_connection_info
  database_name confluence_database
  privileges [:all]
  action :grant
  notifies :restore, 'backup_database[confluence]', :immediately
end

template '/etc/init/confluence.conf' do
  source 'confluence.conf.erb'
  variables(
    user: confluence_user,
    install_dir: confluence_install_dir
  )
  notifies :restart, 'service[confluence]', :delayed
end

include_recipe 'confluence::record_sets'
bash 'noop' do
  command '/bin/true'
  notifies :enable, 'backup_database[confluence]', :immediately
  notifies :enable, 'backup_home[confluence]', :immediately
  notifies :enable, 'service[confluence]', :immediately
  notifies :start, 'service[confluence]', :immediately
  notifies :upsert, 'aws_cli_route53_record_sets[confluence]', :immediately
end
