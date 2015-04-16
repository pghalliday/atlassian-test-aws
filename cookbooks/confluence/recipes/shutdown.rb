include_recipe 'confluence::service'
include_recipe 'confluence::backup'
include_recipe 'confluence::record_sets'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[confluence]', :immediately
  notifies :backup, 'backup_database[confluence]', :immediately
  notifies :backup, 'backup_home[confluence]', :immediately
  notifies :delete, 'aws_cli_route53_record_sets[confluence]', :immediately
end
