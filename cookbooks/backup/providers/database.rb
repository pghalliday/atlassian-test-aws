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

def commands
  s3_access_key_id = new_resource.s3_access_key_id
  s3_secret_access_key = new_resource.s3_secret_access_key
  db_host = new_resource.db_host
  db_port = new_resource.db_port
  db_user = new_resource.db_user
  db_password = new_resource.db_password
  db = new_resource.db

  db_dump_command = "PGPASSWORD=#{db_password} pg_dump -h #{db_host} -p #{db_port} -U #{db_user} -Fc #{db}"
  aws_upload_db_command = "AWS_ACCESS_KEY_ID=#{s3_access_key_id} AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key} aws s3 cp - #{s3_db_dump_path}"

  aws_download_db_command = "AWS_ACCESS_KEY_ID=#{s3_access_key_id} AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key} aws s3 cp #{s3_db_dump_path} -"
  db_restore_command = "PGPASSWORD=#{db_password} pg_restore -h #{db_host} -p #{db_port} -U #{db_user} -d #{db}"

  aws_list_command = "AWS_ACCESS_KEY_ID=#{s3_access_key_id} AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key} aws s3 ls #{s3_path}"

  {
    backup: "#{db_dump_command} | #{aws_upload_db_command}",
    restore: "#{aws_download_db_command} | #{db_restore_command}",
    list: aws_list_command
  }
end

action :enable do
  cron "backup to #{new_resource.s3_path}" do
    time :midnight
    command commands['backup']
  end
end

action :backup do
  bash "backup to #{new_resource.s3_path}" do
    command commands['backup']
  end
end

action :restore do
  list_command = Mixlib::ShellOut.new(commands['list'])
  list_command.run_command()
  backup_files = list_command.stdout
  bash "backup to #{new_resource.s3_path}" do
    command commands['restore']
    only_if { !(/ #{s3_db_dump_file}$/ =~ backup_files).nil? }
  end
end
