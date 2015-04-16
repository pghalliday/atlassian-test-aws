include_recipe 'crowd::service'
include_recipe 'crowd::backup'
include_recipe 'crowd::record_sets'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[crowd]', :immediately
  notifies :backup, 'backup_database[crowd]', :immediately
  notifies :backup, 'backup_database[crowdid]', :immediately
  notifies :backup, 'backup_home[crowd]', :immediately
  notifies :delete, 'aws_cli_route53_record_sets[crowd]', :immediately
end
