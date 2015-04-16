def whyrun_supported?
  true
end

use_inline_resources

def s3_path
  "s3://#{new_resource.s3_bucket}"
end

def s3_db_dump_file
  "#{new_resource.name}.dump"
end

def s3_db_dump_path
  "#{s3_path}/#{s3_db_dump_file}"
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def commands
  s3_access_key_id = new_resource.s3_access_key_id
  s3_secret_access_key = new_resource.s3_secret_access_key
  db_host = new_resource.db_host
  db_port = new_resource.db_port
  db_user = new_resource.db_user
  db_password = new_resource.db_password
  db = new_resource.db

  db_dump_command = [
    "PGPASSWORD=#{db_password}",
    "pg_dump -h #{db_host} -p #{db_port} -U #{db_user} -Fc #{db}"
  ].join(' ')
  aws_upload_db_command = [
    "AWS_ACCESS_KEY_ID=#{s3_access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key}",
    "aws s3 cp - #{s3_db_dump_path}"
  ].join(' ')

  aws_download_db_command = [
    "AWS_ACCESS_KEY_ID=#{s3_access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key}",
    "aws s3 cp #{s3_db_dump_path} -"
  ].join(' ')
  db_restore_command = [
    "PGPASSWORD=#{db_password}",
    "pg_restore -h #{db_host} -p #{db_port} -U #{db_user} -d #{db}"
  ].join(' ')

  aws_list_command = [
    "AWS_ACCESS_KEY_ID=#{s3_access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key}",
    "aws s3 ls #{s3_path}"
  ].join(' ')

  cmds = {}
  cmds['backup'] = "#{db_dump_command} | #{aws_upload_db_command}"
  cmds['restore'] = "#{aws_download_db_command} | #{db_restore_command}"
  cmds['list'] = aws_list_command
  cmds
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

action :enable do
  cron "backup to #{s3_db_dump_path}" do
    hour '0'
    minute '0'
    command commands['backup']
  end
end

action :backup do
  bash "backup to #{s3_db_dump_path}" do
    code commands['backup']
  end
end

action :restore do
  list_command = Mixlib::ShellOut.new(commands['list'])
  list_command.run_command
  backup_files = list_command.stdout
  bash "restore from #{s3_db_dump_path}" do
    code commands['restore']
    only_if { !(/ #{s3_db_dump_file}$/ =~ backup_files).nil? }
  end
end
