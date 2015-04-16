include_recipe 'reverse_proxy::record_sets'
bash 'noop' do
  command '/bin/true'
  notifies :delete, 'aws_cli_route53_record_sets[reverse_proxy]', :immediately
end
