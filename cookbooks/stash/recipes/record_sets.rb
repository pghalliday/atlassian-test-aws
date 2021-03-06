include_recipe 'aws_cli::default'
aws_cli_route53_record_sets 'stash' do
  hosted_zone_id node['atlassian-test']['route53']['hosted_zone_id']
  access_key_id node['atlassian-test']['route53']['access_key_id']
  secret_access_key node['atlassian-test']['route53']['secret_access_key']
  public_dns_name node['opsworks']['instance']['public_dns_name']
  hosts([
    node['atlassian-test']['stash']['ssh_host']
  ])
  action :nothing
end
