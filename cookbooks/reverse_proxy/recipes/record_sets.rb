include_recipe 'aws_cli::default'
aws_cli_route53_record_sets 'reverse_proxy' do
  hosted_zone_id node['atlassian-test']['route53']['hosted_zone_id']
  access_key_id node['atlassian-test']['route53']['access_key_id']
  secret_access_key node['atlassian-test']['route53']['secret_access_key']
  ip node['opsworks']['instance']['ip']
  hosts([
    node['atlassian-test']['proxy_ssh_host'],
    node['atlassian-test']['crowd']['proxy_host'],
    node['atlassian-test']['jira']['proxy_host'],
    node['atlassian-test']['confluence']['proxy_host'],
    node['atlassian-test']['stash']['proxy_host'],
    node['atlassian-test']['bamboo']['proxy_host']
  ])
  action :nothing
end
