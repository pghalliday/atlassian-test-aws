layer = node['opsworks']['layers']['nginx']
if layer
  instance = layer['instances'].first
  if instance
    ip = instance[1]['private_ip']
  end
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
