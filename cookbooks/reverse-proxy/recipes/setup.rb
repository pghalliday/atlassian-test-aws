include_recipe 'apt::default'
package 'nginx'
service 'nginx' do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end
