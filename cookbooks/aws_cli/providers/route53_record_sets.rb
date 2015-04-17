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

def json
  ::File.join(json_dir, 'route53_record_sets.json')
end

def aws_command
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
  template json do
    source 'route53_record_sets.json.erb'
    cookbook 'aws_cli'
    variables(
      method: 'UPSERT',
      public_dns_name: new_resource.public_dns_name,
      hosts: new_resource.hosts
    )
  end
  bash "route53_record_sets upsert #{new_resource.name}" do
    code aws_command
  end
end

action :delete do
  directory json_dir do
    recursive true
  end
  template json do
    source 'route53_record_sets.json.erb'
    cookbook 'aws_cli'
    variables(
      method: 'DELETE',
      public_dns_name: new_resource.public_dns_name,
      hosts: new_resource.hosts
    )
  end
  bash "route53_record_sets delete #{new_resource.name}" do
    code aws_command
  end
end
