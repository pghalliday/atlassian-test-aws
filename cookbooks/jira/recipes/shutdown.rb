include_recipe 'jira::service'
include_recipe 'jira::backup'
include_recipe 'jira::record_sets'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[jira]', :immediately
  notifies :backup, 'backup_database[jira]', :immediately
  notifies :backup, 'backup_home[jira]', :immediately
  notifies :delete, 'aws_cli_route53_record_sets[jira]', :immediately
end
