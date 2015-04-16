include_recipe 'stash::service'
include_recipe 'stash::backup'
include_recipe 'stash::record_sets'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[stash]', :immediately
  notifies :backup, 'backup_database[stash]', :immediately
  notifies :backup, 'backup_home[stash]', :immediately
  notifies :delete, 'aws_cli_route53_record_sets[stash]', :immediately
end
