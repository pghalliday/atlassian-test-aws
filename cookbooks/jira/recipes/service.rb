service 'jira' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true, status: true
  action [ :enable ]
end

