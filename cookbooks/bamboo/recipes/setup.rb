atlassian_home = '/var/atlassian/application-data'
bamboo_user = 'bamboo'
bamboo_group = 'bamboo'
# rubocop:disable Metrics/LineLength
bamboo_checksum = '88e2463a775fe6078c6ccf5142117384beb0be4d73815ce2146e0f05cde771f5'
# rubocop:enable Metrics/LineLength
bamboo_basename = 'atlassian-bamboo-5.8.0'
bamboo_install_dir = '/opt/atlassian/bamboo'
bamboo_home = ::File.join(atlassian_home, 'bamboo')
bamboo_tarball = "#{bamboo_basename}.tar.gz"
# rubocop:disable Metrics/LineLength
bamboo_url = "https://www.atlassian.com/software/bamboo/downloads/binary/#{bamboo_tarball}"
# rubocop:enable Metrics/LineLength

bamboo_database = 'bamboo'
bamboo_database_user = 'bamboo'
bamboo_database_password = 'bamboo'

bamboo_port = node['atlassian-test']['bamboo']['port']
bamboo_redirect_port = node['atlassian-test']['bamboo']['redirect_port']
bamboo_proxy_port = node['atlassian-test']['proxy_port']
bamboo_proxy_host = node['atlassian-test']['bamboo']['proxy_host']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']
db_user = node['atlassian-test']['database']['username']
db_password = node['atlassian-test']['database']['password']

postgresql_connection_info = {
  host: db_host,
  port: db_port,
  username: db_user,
  password: db_password
}

include_recipe 'bamboo::service'
include_recipe 'bamboo::backup'

node.override['java']['jdk_version'] = '7'
include_recipe 'java::default'

directory atlassian_home do
  recursive true
end

group bamboo_group do
  system true
end

user bamboo_user do
  supports manage_home: true
  home bamboo_home
  system true
  gid bamboo_group
  notifies :restore, 'backup_home[bamboo]', :immediately
end

directory bamboo_install_dir do
  recursive true
end

remote_file ::File.join(bamboo_install_dir, bamboo_tarball) do
  source bamboo_url
  checksum bamboo_checksum
  notifies :run, 'bash[install bamboo]', :immediately
end

bash 'install bamboo' do
  code <<-EOH
  tar zxf #{bamboo_tarball}
  ln -s #{bamboo_basename} current
  chown -R #{bamboo_user}:#{bamboo_group} current/logs
  chown -R #{bamboo_user}:#{bamboo_group} current/work
  chown -R #{bamboo_user}:#{bamboo_group} current/temp
  EOH
  cwd bamboo_install_dir
  action :nothing
  notifies :restart, 'service[bamboo]', :delayed
end

template ::File.join(bamboo_install_dir, 'current/conf/server.xml') do
  source 'server.xml.erb'
  variables(
    port: bamboo_port,
    redirect_port: bamboo_redirect_port,
    proxy_host: bamboo_proxy_host,
    proxy_port: bamboo_proxy_port
  )
  notifies :restart, 'service[bamboo]', :delayed
end

include_recipe 'database::postgresql'

postgresql_database bamboo_database do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user bamboo_database_user do
  connection postgresql_connection_info
  password bamboo_database_password
  action :create
  notifies :run, 'bash[assign bamboo db owner]', :immediately
end

db_owner_command = [
  "PGPASSWORD=#{db_password}",
  "psql -h #{db_host} -p #{db_port} -U #{db_user} -q -c",
  "'ALTER DATABASE #{bamboo_database}",
  "OWNER TO #{bamboo_database_user};' #{bamboo_database}"
].join(' ')

bash 'assign bamboo db owner' do
  code db_owner_command
  action :nothing
  notifies :restore, 'backup_database[bamboo]', :immediately
end

template '/etc/init/bamboo.conf' do
  source 'bamboo.conf.erb'
  variables(
    user: bamboo_user,
    install_dir: bamboo_install_dir,
    home: bamboo_home
  )
  notifies :restart, 'service[bamboo]', :delayed
end

bash 'noop' do
  command '/bin/true'
  notifies :enable, 'backup_database[bamboo]', :immediately
  notifies :enable, 'backup_home[bamboo]', :immediately
  notifies :enable, 'service[bamboo]', :immediately
  notifies :start, 'service[bamboo]', :immediately
end
