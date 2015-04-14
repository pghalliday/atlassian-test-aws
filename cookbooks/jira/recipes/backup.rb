include_recipe "backup::default"

atlassian_home = '/var/atlassian/application-data'
jira_user = 'jira'
jira_home = ::File.join(atlassian_home, 'jira')
jira_database = 'jira'
jira_database_user = 'jira'
jira_database_password = 'jira'

backup_bucket_name = node['atlassian-test']['s3']['backup_bucket_name']
s3_access_key_id = node['atlassian-test']['s3']['access_key_id']
s3_secret_access_key = node['atlassian-test']['s3']['secret_access_key']
db_host = node['atlassian-test']['database']['address']
db_port = node['atlassian-test']['database']['port']

backup_database 'jira' do
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
  db jira_database
  db_user jira_database_user
  db_password jira_database_password
  db_host db_host
  db_port db_port
end

backup_home 'jira' do
  user jira_user
  home jira_home
  s3_bucket backup_bucket_name
  s3_access_key_id s3_access_key_id
  s3_secret_access_key s3_secret_access_key
end
