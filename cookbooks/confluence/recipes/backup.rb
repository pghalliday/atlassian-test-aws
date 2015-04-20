include_recipe 'backup::default'

confluence_user = 'confluence'
confluence_database = 'confluence'
confluence_database_user = 'confluence'
confluence_database_password = 'confluence'

backup_bucket_name = node['atlassian-test']['s3']['backup_bucket_name']
s3_access_key_id = node['atlassian-test']['s3']['access_key_id']
s3_secret_access_key = node['atlassian-test']['s3']['secret_access_key']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']

backup_database 'confluence' do
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  db confluence_database
  db_user confluence_database_user
  db_password confluence_database_password
  db_host db_host
  db_port db_port
  action :nothing
end

backup_home 'confluence' do
  user confluence_user
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  action :nothing
end
