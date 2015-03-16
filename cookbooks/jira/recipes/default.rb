bin_url = 'https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.3.15-x64.bin'
sha = 'a334865dd0b5df5b3bcc506b5c40ab7b65700e310edb6e7e6f86d30c3a8e3375'
bin = ::File.join(Chef::Config[:file_cache_path], 'jira.bin')
varfile = ::File.join(Chef::Config[:file_cache_path], 'jira.varfile')

remote_file bin do
  source bin_url
  checksum sha
  mode 0755
end

cookbook_file varfile do
  source 'response.varfile'
end

bash 'install JIRA' do
  code <<-EOH
    #{bin} -q -varfile #{varfile}
    EOH
  creates '/opt/atlassian/jira'
end
