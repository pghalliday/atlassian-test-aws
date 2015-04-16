include_recipe 'aws_cli::default'
aws_cli_route53_record_sets 'jira' do
  hosted_zone_id node['atlassian-test']['route53']['hosted_zone_id']
  access_key_id node['atlassian-test']['route53']['access_key_id']
  secret_access_key node['atlassian-test']['route53']['secret_access_key']
  ip node['opsworks']['instance']['ip']
  hosts([
    node['atlassian-test']['jira']['ssh_host']
  ])
  action :nothing
end
