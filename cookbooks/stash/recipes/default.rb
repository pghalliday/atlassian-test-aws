bin_url = 'https://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-3.7.1-x64.bin'
sha = 'b0fc10614d0f2254d00a41888f4b4f7d2107bdbff73fce524d16068075c45a78'
bin = ::File.join(Chef::Config[:file_cache_path], 'stash.bin')
varfile = ::File.join(Chef::Config[:file_cache_path], 'stash.varfile')

remote_file bin do
  source bin_url
  checksum sha
  mode 0755
end

package 'git'

cookbook_file varfile do
  source 'response.varfile'
end

bash 'install Stash' do
  code <<-EOH
    #{bin} -q -varfile #{varfile}
    EOH
  creates '/opt/atlassian/stash/3.7.1'
end
