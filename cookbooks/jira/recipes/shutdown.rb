include_recipe 'jira::service'
include_recipe 'jira::backup'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[jira]', :immediately
  notifies :backup, 'backup_database[jira]', :immediately
  notifies :backup, 'backup_home[jira]', :immediately
end
