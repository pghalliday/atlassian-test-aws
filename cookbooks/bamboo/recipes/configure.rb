layers = node['opsworks']['layers']
first_ip =  layers['bamboo']['instances'].first[1]['ip']
my_ip = node['opsworks']['instance']['ip']
if my_ip == first_ip
  include_recipe 'bamboo::record_sets'
  bash 'noop' do
    command '/bin/true'
    notifies :upsert, 'aws_cli_route53_record_sets[bamboo]', :immediately
  end
end
