layers = node['opsworks']['layers']
layer = layers['reverse_proxy']
if layer
  instance = layer['instances'].first
  ip = instance[1]['private_ip'] if instance
end
if ip
  crowd_database = 'crowd'
  crowd_database_user = 'crowd'
  crowd_database_password = 'crowd'
  postgresql_connection_info = {
    host: node['atlassian-test']['database']['address'],
    port: node['atlassian-test']['database']['port'],
    username: crowd_database_user,
    password: crowd_database_password
  }
  include_recipe 'database::postgresql'
  postgresql_database crowd_database do
    connection postgresql_connection_info
    sql <<-EOH
    INSERT INTO cwd_application_address (application_id, remote_address)
    SELECT 2, '#{ip}'
    WHERE NOT EXISTS
    (
      SELECT * FROM cwd_application_address
      WHERE
      remote_address = '#{ip}'
    )
    EOH
    action :query
  end
end

first_ip =  layers['crowd']['instances'].first[1]['ip']
my_ip = node['opsworks']['instance']['ip']
if my_ip == first_ip
  include_recipe 'crowd::record_sets'
  bash 'noop' do
    command '/bin/true'
    notifies :upsert, 'aws_cli_route53_record_sets[crowd]', :immediately
  end
end
