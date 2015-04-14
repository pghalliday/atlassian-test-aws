include_recipe "backup::default"

atlassian_home = '/var/atlassian/application-data'
bamboo_user = 'bamboo'
bamboo_home = ::File.join(atlassian_home, 'bamboo')
bamboo_database = 'bamboo'
bamboo_database_user = 'bamboo'
bamboo_database_password = 'bamboo'

backup_bucket_name = node['atlassian-test']['s3']['backup_bucket_name']
s3_access_key_id = node['atlassian-test']['s3']['access_key_id']
s3_secret_access_key = node['atlassian-test']['s3']['secret_access_key']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']

backup_database 'bamboo' do
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  db bamboo_database
  db_user bamboo_database_user
  db_password bamboo_database_password
  db_host db_host
  db_port db_port
  action :nothing
end

backup_home 'bamboo' do
  user bamboo_user
  home bamboo_home
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  action :nothing
end
