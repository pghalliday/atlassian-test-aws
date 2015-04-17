include_recipe 'reverse_proxy::service'
include_recipe 'iptables::default'

ips = {}
layers = node['opsworks']['layers']

# nginx reverse proxies
%w(
  crowd
  jira
  confluence
  stash
  bamboo
).each do |service|
  layer = layers[service]
  if layer
    instance = layer['instances'].first
    ips[service] = instance[1]['private_ip'] if instance
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

first_ip =  layers['reverse_proxy']['instances'].first[1]['ip']
my_ip = node['opsworks']['instance']['ip']
if my_ip == first_ip
  include_recipe 'reverse_proxy::record_sets'
  bash 'noop' do
    command '/bin/true'
    notifies :upsert, 'aws_cli_route53_record_sets[reverse_proxy]', :immediately
  end
end
