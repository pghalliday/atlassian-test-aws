include_recipe 'stash::service'
include_recipe 'stash::backup'

bash 'noop' do
  command '/bin/true'
  notifies :stop, 'service[stash]', :immediately
  notifies :backup, 'backup_database[stash]', :immediately
  notifies :backup, 'backup_home[stash]', :immediately
end
