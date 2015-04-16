require 'tempfile'

def whyrun_supported?
  true
end

use_inline_resources

def json_dir
  ::File.join(
    Chef::Config[:file_cache_path],
    'route53_record_sets',
    new_resource.name
  )
end

def aws_command(json)
  [
    "AWS_ACCESS_KEY_ID=#{new_resource.access_key_id}",
    "AWS_SECRET_ACCESS_KEY=#{new_resource.secret_access_key}",
    'aws route53 change-resource-record-sets',
    "--hosted-zone-id #{new_resource.hosted_zone_id}",
    "--change-batch file://#{json}"
  ].join(' ')
end

action :upsert do
  directory json_dir do
    recursive true
  end
  json = ::File.join(json_dir, 'upsert.json')
  template json do
    source 'route53_record_sets_upsert.json.erb'
    cookbook 'aws_cli'
    variables(
      ip: new_resource.ip,
      hosts: new_resource.hosts
    )
  end
  bash "route53_record_sets upsert #{new_resource.name}" do
    code aws_command(json)
  end
end

action :delete do
  directory json_dir do
    recursive true
  end
  json = ::File.join(json_dir, 'delete.json')
  template json do
    source 'route53_record_sets_delete.json.erb'
    cookbook 'aws_cli'
    variables(
      hosts: new_resource.hosts
    )
  end
  bash "route53_record_sets delete #{new_resource.name}" do
    code aws_command(json)
  end
end
