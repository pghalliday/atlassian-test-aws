include_recipe 'reverse-proxy::service'
include_recipe 'iptables::default'

ips = {}

# nginx reverse proxies
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
      ips[service] = instance[1]['private_ip']
    end
  end
  if ips[service]
    template "/etc/nginx/sites-available/#{service}" do
      source 'site.erb'
      variables(
        host: node['atlassian-test'][service]['proxy_host'],
        port: node['atlassian-test'][service]['port'],
        ip: ips[service]
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

# forward the stash ssh port
if ips['stash']
  bash 'enable ip forwarding' do
    code 'sysctl net.ipv4.ip_forward=1'
  end
  iptables_rule 'stash-ssh' do
    action :enable
    variables(
      ip: ips['stash'],
      port: node['atlassian-test']['stash']['ssh_port']
    )
  end
end
