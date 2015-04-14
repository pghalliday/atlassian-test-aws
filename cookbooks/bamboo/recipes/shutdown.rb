include_recipe 'bamboo::service'
include_recipe 'bamboo::backup'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[bamboo]', :immediately
  notifies :backup, 'backup_database[bamboo]', :immediately
  notifies :backup, 'backup_home[bamboo]', :immediately
end
