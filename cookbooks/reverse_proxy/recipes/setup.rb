include_recipe 'apt::default'

include_recipe 'iptables::default'
iptables_rule 'http' do
  action :enable
  variables(
    port: node['atlassian-test']['proxy_port']
  )
end
iptables_rule 'ssh' do
  action :enable
end

package 'nginx'

include_recipe 'reverse_proxy::service'
bash 'noop' do
  command '/bin/true'
  notifies :enable, 'service[nginx]', :immediately
  notifies :start, 'service[nginx]', :immediately
end
