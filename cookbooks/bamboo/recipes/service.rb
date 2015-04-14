service 'bamboo' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true, status: true
  action :nothing
end

