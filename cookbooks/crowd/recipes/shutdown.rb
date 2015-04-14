include_recipe 'crowd::service'
include_recipe 'crowd::backup'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[crowd]', :immediately
  notifies :backup, 'backup_database[crowd]', :immediately
  notifies :backup, 'backup_database[crowdid]', :immediately
  notifies :backup, 'backup_home[crowd]', :immediately
end
