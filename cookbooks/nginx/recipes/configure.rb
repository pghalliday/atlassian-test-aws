%w(
  crowd
  jira
  confluence
  stash
  bamboo
).each do |service|
  layer = node['opsworks']['layers'][service]
  if layer
    instance = layer['instances'].first
    if instance
      ip = instance['private_ip']
    end
  end
  if ip
    template "/etc/nginx/sites-available/#{service}" do
      source 'site'
      variables(
        host: node['nginx'][service]['host'],
        port: node['nginx'][service]['port'],
        ip: ip
      )
      notifies :restart, 'service[nginx]', :delayed
    end
    link "/etc/nginx/sites-enabled/#{service}" do
      to "/etc/nginx/sites-available/#{service}"
      notifies :restart, 'service[nginx]', :delayed
    end
  else
    link "/etc/nginx/sites-enabled/#{service}" do
      to "/etc/nginx/sites-available/#{service}"
      action :delete
      notifies :restart, 'service[nginx]', :delayed
    end
  end
end
