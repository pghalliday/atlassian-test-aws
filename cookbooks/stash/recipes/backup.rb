include_recipe "backup::default"

atlassian_home = '/var/atlassian/application-data'
stash_user = 'stash'
stash_home = ::File.join(atlassian_home, 'stash')
stash_database = 'stash'
stash_database_user = 'stash'
stash_database_password = 'stash'

backup_bucket_name = node['atlassian-test']['s3']['backup_bucket_name']
s3_access_key_id = node['atlassian-test']['s3']['access_key_id']
s3_secret_access_key = node['atlassian-test']['s3']['secret_access_key']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']

backup_database 'stash' do
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  db stash_database
  db_user stash_database_user
  db_password stash_database_password
  db_host db_host
  db_port db_port
  action :nothing
end

backup_home 'stash' do
  user stash_user
  home stash_home
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  action :nothing
end
