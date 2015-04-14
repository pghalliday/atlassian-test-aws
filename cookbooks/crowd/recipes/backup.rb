include_recipe "backup::default"

atlassian_home = '/var/atlassian/application-data'
crowd_user = 'crowd'
crowd_home = ::File.join(atlassian_home, 'crowd')
crowd_database = 'crowd'
crowd_database_user = 'crowd'
crowd_database_password = 'crowd'
crowdid_database = 'crowdid'
crowdid_database_user = 'crowdid'
crowdid_database_password = 'crowdid'

backup_bucket_name = node['atlassian-test']['s3']['backup_bucket_name']
s3_access_key_id = node['atlassian-test']['s3']['access_key_id']
s3_secret_access_key = node['atlassian-test']['s3']['secret_access_key']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']

backup_database 'crowd' do
  s3_bucket backup_bucket_name 
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  db crowd_database
  db_user crowd_database_user
  db_password crowd_database_password
  db_host db_host
  db_port db_port
  action :nothing
end

backup_database 'crowdid' do
  s3_bucket backup_bucket_name 
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  db crowdid_database
  db_user crowdid_database_user
  db_password crowdid_database_password
  db_host db_host
  db_port db_port
  action :nothing
end

backup_home 'crowd' do
  user crowd_user
  home crowd_home
  s3_bucket backup_bucket_name 
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  action :nothing
end
