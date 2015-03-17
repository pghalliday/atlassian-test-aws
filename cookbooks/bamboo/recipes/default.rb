tarball_url = 'https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-5.8.0.tar.gz'
sha = '88e2463a775fe6078c6ccf5142117384beb0be4d73815ce2146e0f05cde771f5'
tarball = ::File.join(Chef::Config[:file_cache_path], 'bamboo.tar.gz')
install_dir = '/opt/atlassian/bamboo'
unpacked = ::File.join(install_dir, ::File.basename(tarball_url, '.tar.gz'))
current = ::File.join(install_dir, 'current')
bamboo_group = 'bamboo'
bamboo_user = 'bamboo'
bamboo_home = '/home/bamboo'

remote_file tarball do
  source tarball_url
  checksum sha
  mode 0755
end

node.override['java']['jdk_version'] = 7
include_recipe 'java::default'

group bamboo_group do
  system true
end

user bamboo_user do
  gid bamboo_group
  system true
  home bamboo_home
  supports manage_home: true
end

directory install_dir do
  owner bamboo_user
  group bamboo_group
  recursive true
end

bash 'unpack Bamboo' do
  code <<-EOH
    tar zxvf #{tarball}
    EOH
  cwd install_dir
  user bamboo_user
  creates unpacked
end

link current do
  to unpacked
  owner bamboo_user
  group bamboo_group
end

directory '/var/atlassian/application-data/bamboo' do
  owner bamboo_user
  group bamboo_group
  recursive true
end

cookbook_file ::File.join(current, 'atlassian-bamboo/WEB-INF/classes/bamboo-init.properties') do
  source 'bamboo-init.properties'
  owner bamboo_user
  group bamboo_group
  notifies :restart, 'service[bamboo]', :delayed
end

cookbook_file '/etc/init.d/bamboo' do
  source 'bamboo'
  mode 0755
end

service 'bamboo' do
  supports status: false, restart: true, reload: false
  action [ :enable, :start ]
end
