include_recipe 'confluence::service'
include_recipe 'confluence::backup'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[confluence]', :immediately
  notifies :backup, 'backup_database[confluence]', :immediately
  notifies :backup, 'backup_home[confluence]', :immediately
end
