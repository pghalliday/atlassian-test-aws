include_recipe 'bamboo::service'
include_recipe 'bamboo::backup'
include_recipe 'bamboo::record_sets'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[bamboo]', :immediately
  notifies :backup, 'backup_database[bamboo]', :immediately
  notifies :backup, 'backup_home[bamboo]', :immediately
  notifies :delete, 'aws_cli_route53_record_sets[bamboo]', :immediately
end
