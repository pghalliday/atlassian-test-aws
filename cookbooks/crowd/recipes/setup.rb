atlassian_home = '/var/atlassian/application-data'
crowd_user = 'crowd'
crowd_group = 'crowd'
crowd_checksum =
  'c857eb16f65ed99ab8b289fe671e3cea89140d42f85639304caa91a3ba9ade05'
crowd_basename = 'atlassian-crowd-2.8.0'
crowd_install_dir = '/opt/atlassian/crowd'
crowd_home = ::File.join(atlassian_home, 'crowd')
crowd_tarball = "#{crowd_basename}.tar.gz"
crowd_url =
  "https://www.atlassian.com/software/crowd/downloads/binary/#{crowd_tarball}"

crowd_database = 'crowd'
crowd_database_user = 'crowd'
crowd_database_password = 'crowd'

crowdid_database = 'crowdid'
crowdid_database_user = 'crowdid'
crowdid_database_password = 'crowdid'

crowd_port = node['atlassian-test']['crowd']['port']
crowd_redirect_port = node['atlassian-test']['crowd']['redirect_port']
crowd_proxy_port = node['atlassian-test']['proxy_port']
crowd_proxy_host = node['atlassian-test']['crowd']['proxy_host']
crowd_gmail_user = node['atlassian-test']['gmail']['username']
crowd_gmail_password = node['atlassian-test']['gmail']['password']
crowd_db_host = node['atlassian-test']['database']['address']
crowd_db_port = node['atlassian-test']['database']['port']

postgresql_connection_info = {
  host: crowd_db_host,
  port: crowd_db_port,
  username: node['atlassian-test']['database']['username'],
  password: node['atlassian-test']['database']['password']
}

include_recipe 'crowd::service'
include_recipe 'crowd::backup'

node.override['java']['jdk_version'] = '7'
include_recipe 'java::default'

directory atlassian_home do
  recursive true
end

group crowd_group do
  system true
end

user crowd_user do
  supports manage_home: true
  home crowd_home
  system true
  gid crowd_group
  notifies :restore, 'backup_home[crowd]', :immediately
end

directory crowd_install_dir do
  recursive true
end

remote_file ::File.join(crowd_install_dir, crowd_tarball) do
  source crowd_url
  checksum crowd_checksum
  notifies :run, 'bash[install crowd]', :immediately
end

bash 'install crowd' do
  code <<-EOH
  tar zxf #{crowd_tarball}
  ln -s #{crowd_basename} current
  chgrp #{crowd_group} current/*.sh
  chgrp #{crowd_group} current/apache-tomcat/bin/*.sh
  chmod g+x current/*.sh
  chmod g+x current/apache-tomcat/bin/*.sh
  chown -R #{crowd_user}:#{crowd_group} current/apache-tomcat/logs
  chown -R #{crowd_user}:#{crowd_group} current/apache-tomcat/work
  chown -R #{crowd_user}:#{crowd_group} current/apache-tomcat/temp
  touch -a current/atlassian-crowd-openid-server.log
  mkdir current/database
  chown -R #{crowd_user}:#{crowd_group} current/database
  chown -R #{crowd_user}:#{crowd_group} \
    current/atlassian-crowd-openid-server.log
  EOH
  cwd crowd_install_dir
  action :nothing
end

crowd_props =
  'current/crowd-openidserver-webapp/WEB-INF/classes/crowd.properties'
template ::File.join(crowd_install_dir, crowd_props) do
  source 'crowd.properties.erb'
  variables(
    port: crowd_port
  )
end

init_props = 'current/crowd-webapp/WEB-INF/classes/crowd-init.properties'
template ::File.join(crowd_install_dir, init_props) do
  source 'crowd-init.properties.erb'
  variables(
    home: crowd_home
  )
end

server_xml = 'current/apache-tomcat/conf/server.xml'
template ::File.join(crowd_install_dir, server_xml) do
  source 'crowd-server.xml.erb'
  variables(
    port: crowd_port,
    redirect_port: crowd_redirect_port,
    proxy_name: crowd_proxy_host,
    proxy_port: crowd_proxy_port
  )
end

openid_xml = 'current/apache-tomcat/conf/Catalina/localhost/openidserver.xml'
template ::File.join(crowd_install_dir, openid_xml) do
  source 'crowdid-postgres-openidserver.xml.erb'
  variables(
    username: crowdid_database_user,
    password: crowdid_database_password,
    host: crowd_db_host,
    port: crowd_db_port,
    database: crowdid_database
  )
end

jdbc_props = 'current/crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties'
template ::File.join(crowd_install_dir, jdbc_props) do
  source 'crowdid-postgres-jdbc.properties.erb'
end

crowd_xml = 'current/apache-tomcat/conf/Catalina/localhost/crowd.xml'
template ::File.join(crowd_install_dir, crowd_xml) do
  source 'crowd.xml.erb'
  variables(
    username: crowd_gmail_user,
    password: crowd_gmail_password
  )
end

include_recipe 'database::postgresql'

postgresql_database crowd_database do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user crowd_database_user do
  connection postgresql_connection_info
  password crowd_database_password
  action :create
end

postgresql_database_user crowd_database_user do
  connection postgresql_connection_info
  database_name crowd_database
  privileges [:all]
  action :grant
  notifies :restore, 'backup_database[crowd]', :immediately
end

postgresql_database crowdid_database do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user crowdid_database_user do
  connection postgresql_connection_info
  password crowdid_database_password
  action :create
end

postgresql_database_user crowdid_database_user do
  connection postgresql_connection_info
  database_name crowdid_database
  privileges [:all]
  action :grant
  notifies :restore, 'backup_database[crowdid]', :immediately
end

template '/etc/init/crowd.conf' do
  source 'crowd.conf.erb'
  variables(
    user: crowd_user,
    install_dir: crowd_install_dir
  )
end

include_recipe 'crowd::record_sets'
bash 'noop' do
  command '/bin/true'
  notifies :enable, 'backup_home[crowd]', :immediately
  notifies :enable, 'backup_database[crowd]', :immediately
  notifies :enable, 'backup_database[crowdid]', :immediately
  notifies :enable, 'service[crowd]', :immediately
  notifies :start, 'service[crowd]', :immediately
  notifies :upsert, 'aws_cli_route53_record_sets[crowd]', :immediately
end
