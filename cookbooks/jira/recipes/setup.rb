atlassian_home = '/var/atlassian/application-data'
jira_user = 'jira'
jira_group = 'jira'
jira_checksum =
  'c979f112069594ab743c35193d915b42b8a5423e2a934b6adb0548d4556bbb99'
jira_basename = 'atlassian-jira-6.4'
jira_install_dir = '/opt/atlassian/jira'
jira_home = ::File.join(atlassian_home, 'jira')
jira_tarball = "#{jira_basename}.tar.gz"
jira_url =
  "https://www.atlassian.com/software/jira/downloads/binary/#{jira_tarball}"

jvm_support_recommended_args = '-Datlassian.plugins.enable.wait=300'

jira_database = 'jira'
jira_database_user = 'jira'
jira_database_password = 'jira'

jira_port = node['atlassian-test']['jira']['port']
jira_redirect_port = node['atlassian-test']['jira']['redirect_port']
jira_proxy_port = node['atlassian-test']['proxy_port']
jira_proxy_host = node['atlassian-test']['jira']['proxy_host']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']
db_user = node['atlassian-test']['database']['username']
db_password = node['atlassian-test']['database']['password']

crowd_proxy_port = node['atlassian-test']['proxy_port']
crowd_proxy_host = node['atlassian-test']['crowd']['proxy_host']
jira_crowd_application_name = 'jira'
jira_crowd_application_password = 'jira'
jira_crowd_base_url = "http://#{crowd_proxy_host}:#{crowd_proxy_port}/crowd"
jira_crowd_session_validation_interval = 2

postgresql_connection_info = {
  host: db_host,
  port: db_port,
  username: db_user,
  password: db_password
}

include_recipe 'jira::service'
include_recipe 'jira::backup'

node.override['java']['jdk_version'] = '7'
include_recipe 'java::default'

directory atlassian_home do
  recursive true
end

group jira_group do
  system true
end

user jira_user do
  supports manage_home: true
  home jira_home
  system true
  gid jira_group
  notifies :restore, 'backup_home[jira]', :immediately
end

directory jira_install_dir do
  recursive true
end

remote_file ::File.join(jira_install_dir, jira_tarball) do
  source jira_url
  checksum jira_checksum
  notifies :run, 'bash[install jira]', :immediately
end

bash 'install jira' do
  code <<-EOH
  tar zxf #{jira_tarball}
  ln -s #{jira_basename}-standalone current
  chown -R #{jira_user}:#{jira_group} current/logs
  chown -R #{jira_user}:#{jira_group} current/work
  chown -R #{jira_user}:#{jira_group} current/temp
  EOH
  cwd jira_install_dir
  action :nothing
  notifies :restart, 'service[jira]', :delayed
end

template ::File.join(jira_install_dir, 'current/bin/setenv.sh') do
  source 'setenv.sh.erb'
  variables(
    jvm_support_recommended_args: jvm_support_recommended_args
  )
  notifies :restart, 'service[jira]', :delayed
end

template ::File.join(jira_install_dir, 'current/conf/server.xml') do
  source 'server.xml.erb'
  variables(
    port: jira_port,
    redirect_port: jira_redirect_port,
    proxy_host: jira_proxy_host,
    proxy_port: jira_proxy_port
  )
  notifies :restart, 'service[jira]', :delayed
end

seraph_config = 'current/atlassian-jira/WEB-INF/classes/seraph-config.xml'
template ::File.join(jira_install_dir, seraph_config) do
  source 'seraph-config.xml.erb'
  notifies :restart, 'service[jira]', :delayed
end

crowd_props = 'current/atlassian-jira/WEB-INF/classes/crowd.properties'
template ::File.join(jira_install_dir, crowd_props) do
  source 'crowd.properties.erb'
  variables(
    crowd_application_name: jira_crowd_application_name,
    crowd_application_password: jira_crowd_application_password,
    crowd_base_url: jira_crowd_base_url,
    crowd_session_validation_interval: jira_crowd_session_validation_interval
  )
  notifies :restart, 'service[jira]', :delayed
end

include_recipe 'database::postgresql'

postgresql_database jira_database do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user jira_database_user do
  connection postgresql_connection_info
  password jira_database_password
  action :create
  notifies :run, 'bash[assign jira db owner]', :immediately
end

db_owner_command = [
  "PGPASSWORD=#{db_password}",
  "psql -h #{db_host} -p #{db_port} -U #{db_user} -q -c",
  "'ALTER DATABASE #{jira_database}",
  "OWNER TO #{jira_database_user};' #{jira_database}"
].join(' ')

bash 'assign jira db owner' do
  code db_owner_command
  action :nothing
  notifies :restore, 'backup_database[jira]', :immediately
end

template '/etc/init/jira.conf' do
  source 'jira.conf.erb'
  variables(
    user: jira_user,
    install_dir: jira_install_dir,
    home: jira_home
  )
  notifies :restart, 'service[jira]', :delayed
end

bash 'noop' do
  command '/bin/true'
  notifies :enable, 'backup_home[jira]', :immediately
  notifies :enable, 'backup_database[jira]', :immediately
  notifies :enable, 'service[jira]', :immediately
  notifies :start, 'service[jira]', :immediately
end
