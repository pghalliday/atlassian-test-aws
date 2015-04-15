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

route53_change_batch = ::File.join(Chef::Config[:file_cache_path], 'route53-change-batch.json')
include_recipe 'aws-cli::default'
template route53_change_batch do
  source 'route53-change-batch.json.erb'
  variables(
    ip: node['opsworks']['instance']['ip'],
    crowd: node['atlassian-test']['crowd']['proxy_host'],
    jira: node['atlassian-test']['jira']['proxy_host'],
    confluence: node['atlassian-test']['confluence']['proxy_host'],
    stash: node['atlassian-test']['stash']['proxy_host'],
    bamboo: node['atlassian-test']['bamboo']['proxy_host'],
  )
  notifies :run, 'bash[update DNS entries]', :immediately
end
route53_access_key_id = node['atlassian-test']['route53']['access_key_id']
route53_secret_access_key = node['atlassian-test']['route53']['secret_access_key']
route53_hosted_zone_id = node['atlassian-test']['route53']['hosted_zone_id']
bash 'update DNS entries' do
  code <<-EOH
  AWS_ACCESS_KEY_ID=#{route53_access_key_id} AWS_SECRET_ACCESS_KEY=#{route53_secret_access_key} aws route53 change-resource-record-sets --hosted-zone-id #{route53_hosted_zone_id} --change-batch file://#{route53_change_batch}
  EOH
  action :nothing
end

include_recipe 'reverse-proxy::service'
package 'nginx'
bash 'noop' do
  command '/bin/true'
  notifies :enable, 'service[nginx]', :immediately
  notifies :start, 'service[nginx]', :immediately
end
