atlassian_home = '/var/atlassian/application-data'
stash_user = 'stash'
stash_group = 'stash'
stash_checksum = 'a217e71fed08113fadf8402f5bd9a0ce3257042bc2cbeb35af8276fff31498ac'
stash_basename = 'atlassian-stash-3.7.1'
stash_install_dir = '/opt/atlassian/stash'
stash_home = ::File.join(atlassian_home, 'stash')
stash_tarball = "#{stash_basename}.tar.gz"
stash_url = "https://www.atlassian.com/software/stash/downloads/binary/#{stash_tarball}"

stash_database = 'stash'
stash_database_user = 'stash'
stash_database_password = 'stash'

stash_port = node['atlassian-test']['stash']['port']
stash_redirect_port = node['atlassian-test']['stash']['redirect_port']
stash_proxy_port = node['atlassian-test']['proxy_port']
stash_proxy_host = node['atlassian-test']['stash']['proxy_host']
stash_db_host = node['atlassian-test']['database']['address']
stash_db_port = node['atlassian-test']['database']['port']

postgresql_connection_info = {
  host: stash_db_host,
  port: stash_db_port,
  username: node['atlassian-test']['database']['username'],
  password: node['atlassian-test']['database']['password']
}

include_recipe 'stash::service'
include_recipe 'stash::backup'

node.override['java']['jdk_version'] = '7'
include_recipe 'java::default'

package 'git'
package 'perl'

directory atlassian_home do
  recursive true
end

group stash_group do
  system true
end

user stash_user do
  supports manage_home: true
  home stash_home
  system true
  gid stash_group
  notifies :restore, 'backup_home[stash]', :immediately
end

directory stash_install_dir do
  recursive true
end

remote_file ::File.join(stash_install_dir, stash_tarball) do
  source stash_url
  checksum stash_checksum
  notifies :run, 'bash[install stash]', :immediately
end

bash 'install stash' do
  code <<-EOH
  tar zxf #{stash_tarball}
  ln -s #{stash_basename} current
  chown -R #{stash_user}:#{stash_group} current/logs
  chown -R #{stash_user}:#{stash_group} current/work
  chown -R #{stash_user}:#{stash_group} current/temp
  EOH
  cwd stash_install_dir
  action :nothing
  notifies :restart, 'service[stash]', :delayed
end

template ::File.join(stash_install_dir, 'current/conf/server.xml') do
  source 'server.xml.erb'
  variables(
    port: stash_port,
    redirect_port: stash_redirect_port,
    proxy_host: stash_proxy_host,
    proxy_port: stash_proxy_port
  )
  notifies :restart, 'service[stash]', :delayed
end

include_recipe 'database::postgresql'

postgresql_database stash_database do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user stash_database_user do
  connection postgresql_connection_info
  password stash_database_password
  action :create
end

postgresql_database_user stash_database_user do
  connection postgresql_connection_info
  database_name stash_database
  privileges [:all]
  action :grant
  notifies :restore, 'backup_database[stash]', :immediately
end

template '/etc/init/stash.conf' do
  source 'stash.conf.erb'
  variables(
    user: stash_user,
    install_dir: stash_install_dir,
    home: stash_home
  )
  notifies :restart, 'service[stash]', :delayed
end

bash 'noop' do
  command '/bin/true'
  notifies :enable, 'backup_home[stash]', :immediately
  notifies :enable, 'backup_database[stash]', :immediately
  notifies :enable, 'service[stash]', :immediately
  notifies :start, 'service[stash]', :immediately
end
