def whyrun_supported?
  true
end

use_inline_resources

def s3_path
  "s3://#{new_resource.s3_bucket}"
end

def s3_home_tarball_file
  "#{new_resource.name}.tar.gz"
end

def s3_home_tarball_path
  "#{s3_path}/#{s3_home_tarball_file}"
end

def commands
  s3_access_key_id = new_resource.s3_access_key_id
  s3_secret_access_key = new_resource.s3_secret_access_key
  home = new_resource.home

  home_tarball_command = "tar cvf - #{home} | gzip -9c"
  aws_upload_home_command = "AWS_ACCESS_KEY_ID=#{s3_access_key_id} AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key} aws s3 cp - #{s3_home_tarball_path}"

  aws_download_home_command = "AWS_ACCESS_KEY_ID=#{s3_access_key_id} AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key} aws s3 cp #{s3_home_tarball_path} -"
  home_extract_command = "tar zxf -C #{home} --strip-components=1 -"

  aws_list_command = "AWS_ACCESS_KEY_ID=#{s3_access_key_id} AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key} aws s3 ls #{s3_path}"

  {
    backup: "#{home_tarball_command} | #{aws_upload_home_command}",
    restore: "#{aws_download_home_command} | #{home_extract_command}",
    list: aws_list_command
  }
end

action :enable do
  cron "backup to #{new_resource.s3_path}" do
    time :midnight
    user new_resource.user
    command commands['backup']
  end
end

action :backup do
  bash "backup to #{new_resource.s3_path}" do
    user new_resource.user
    command commands['backup']
  end
end

action :restore do
  user = new_resource.user
  list_command = Mixlib::ShellOut.new(commands['list'], user: user)
  list_command.run_command()
  backup_files = list_command.stdout
  bash "backup to #{new_resource.s3_path}" do
    user user
    command commands['restore']
    only_if { !(/ #{s3_home_tarball_file}$/ =~ backup_files).nil? }
  end
end
