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

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def commands
  s3_access_key_id = new_resource.s3_access_key_id
  s3_secret_access_key = new_resource.s3_secret_access_key
  home = new_resource.home

  home_tarball_command = "tar cvf - #{home} | gzip -9c"
  aws_upload_home_command = [
    "AWS_ACCESS_KEY_ID=#{s3_access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key}",
    "aws s3 cp - #{s3_home_tarball_path}"
  ].join(' ')

  aws_download_home_command = [
    "AWS_ACCESS_KEY_ID=#{s3_access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key}",
    "aws s3 cp #{s3_home_tarball_path} -"
  ].join(' ')
  home_extract_command = 'tar zxf - -C /'

  aws_list_command = [
    "AWS_ACCESS_KEY_ID=#{s3_access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{s3_secret_access_key}",
    "aws s3 ls #{s3_path}"
  ].join(' ')

  cmds = {}
  cmds['backup'] = "#{home_tarball_command} | #{aws_upload_home_command}"
  cmds['restore'] = "#{aws_download_home_command} | #{home_extract_command}"
  cmds['list'] = aws_list_command
  cmds
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

action :enable do
  cron "backup to #{s3_home_tarball_path}" do
    hour '0'
    minute '0'
    user new_resource.user
    command commands['backup']
  end
end

action :backup do
  bash "backup to #{s3_home_tarball_path}" do
    user new_resource.user
    code commands['backup']
  end
end

action :restore do
  list_command = Mixlib::ShellOut.new(commands['list'])
  list_command.run_command
  list_command.error!
  backup_files = list_command.stdout
  bash "restore from #{s3_home_tarball_path}" do
    user new_resource.user
    code commands['restore']
    only_if { !(/ #{s3_home_tarball_file}$/ =~ backup_files).nil? }
  end
end
